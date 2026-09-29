-- server.lua

local Config = require 'morph_cocaine.config'

local eventRateLimit = {}
local activeSessions = {}    -- [src] = { farmId = id, index = n, startedAt = ms }
local strikes = {}           -- [src] = count
local playerSpotState = {}   -- [src] = { [farmId] = { [index] = lastHarvestedAt (ms) } } -- per-player

-- Toleransi buffer supaya lag/ping normal nggak ke-flag sebagai exploit.
local DIST_BUFFER = 1.5
local DURATION_BUFFER = 700
local MAX_STRIKES = 3

local function isNearCoords(source, coords, maxDist)
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return false end
    local pos = GetEntityCoords(ped)
    return #(pos - coords) <= (maxDist or 5.0)
end

-- Nambah strike, baru ban kalau nyampe MAX_STRIKES. 1x anomali (lag,
-- desync posisi sesaat, dll) nggak langsung nge-ban player biasa; cuma
-- pola pelanggaran berulang yang ke-ban.
local function addStrike(source, reason)
    strikes[source] = (strikes[source] or 0) + 1
    if strikes[source] >= MAX_STRIKES then
        exports.morph_junjie:ExploitBan(source, reason)
        strikes[source] = nil
    end
end

local function resetStrikes(source)
    strikes[source] = nil
end

local function checkEventSpamming(src, action)
    -- Sekarang cuma jaring pengaman kedua. Pertahanan utama ada di sistem
    -- sesi + cooldown per-titik di bawah.
    local now, key = os.time(), src .. '_event_' .. action
    if not eventRateLimit[key] then eventRateLimit[key] = { count = 1, firstTime = now }; return false end
    local data = eventRateLimit[key]
    if now - data.firstTime > 60 then eventRateLimit[key] = { count = 1, firstTime = now }; return false end
    data.count = data.count + 1
    if data.count >= 15 then addStrike(src, 'Cocaine Farm spam'); eventRateLimit[key] = nil; return true end
    return false
end

lib.callback.register('cocaine:server:checkShovel', function(src)
    local items = exports.morph_inv:Search(src, 'slots', 'shovel')
    if items and #items > 0 then
        for _, item in pairs(items) do
            local dur = item.metadata.durability or 100
            if dur > 0 then return { slot = item.slot, durability = dur } end
        end
    end
    return false
end)

lib.callback.register('cocaine:server:canCarry', function(src, item, amount)
    local validItems = {}
    for _, farm in pairs(Config.Farm) do validItems[farm.item] = true end
    if not validItems[item] then
        addStrike(src, 'Cocaine Farm executor (invalid item)')
        return false
    end
    if amount > 100 then
        addStrike(src, 'Cocaine Farm executor (suspicious amount)')
        return false
    end
    return exports.morph_inv:CanCarryItem(src, item, amount)
end)

-- Client wajib minta sesi ini SEBELUM progress bar mulai. Server cek
-- posisi saat itu dan cooldown titik ini punya player ini sendiri
-- sebelum ngasih izin.
lib.callback.register('cocaine:server:startAction', function(source, farmId, index)
    local data = Config.Farm[farmId]
    if not data then return false end
    local coords = data.spawnPoints[index]
    if not coords then return false end

    if not isNearCoords(source, vec3(coords.x, coords.y, coords.z), (Config.targetDistance or 2.5) + DIST_BUFFER) then
        addStrike(source, 'Exploiting Cocaine Farm (start out of range)')
        return false
    end

    local state = playerSpotState[source] and playerSpotState[source][farmId]
    local lastHarvested = state and state[index]
    if lastHarvested and (GetGameTimer() - lastHarvested) < Config.Settings.RespawnTime then
        addStrike(source, 'Exploiting Cocaine Farm (spot still on cooldown)')
        return false
    end

    activeSessions[source] = { farmId = farmId, index = index, startedAt = GetGameTimer() }
    return true
end)

-- Validasi sesi: harus ada, farmId & index harus cocok, durasi yang
-- beneran lewat harus mendekati durasi asli (dikurangi buffer), dan
-- posisi masih di lokasi. Sesi dikonsumsi begitu dipakai (single-use).
local function validateSession(source, farmId, index)
    local session = activeSessions[source]
    if not session or session.farmId ~= farmId or session.index ~= index then
        addStrike(source, 'Exploiting Cocaine Farm (no valid session)')
        return false
    end

    local data = Config.Farm[farmId]
    local elapsed = GetGameTimer() - session.startedAt
    if elapsed < (data.duration - DURATION_BUFFER) then
        activeSessions[source] = nil
        addStrike(source, 'Exploiting Cocaine Farm (reward claimed too fast)')
        return false
    end

    local coords = data.spawnPoints[index]
    if not coords or not isNearCoords(source, vec3(coords.x, coords.y, coords.z), (Config.targetDistance or 2.5) + DIST_BUFFER) then
        activeSessions[source] = nil
        addStrike(source, 'Exploiting Cocaine Farm (out of range on claim)')
        return false
    end

    activeSessions[source] = nil -- consume, single-use
    return true
end

RegisterNetEvent('cocaine:server:giveHarvest', function(farmId, index, slot, currentDurability)
    local src = source
    if checkEventSpamming(src, 'giveHarvest') then return end

    local data = Config.Farm[farmId]
    if not data then return end
    if not validateSession(src, farmId, index) then return end

    -- Validasi slot & durability shovel BENERAN cocok sama item asli di
    -- inventory sebelum server nulis metadata ke slot itu.
    local shovelItems = exports.morph_inv:Search(src, 'slots', 'shovel')
    local found = false
    if shovelItems and #shovelItems > 0 then
        for _, item in pairs(shovelItems) do
            if item.slot == slot then
                local dur = item.metadata.durability or 100
                if dur == currentDurability and dur > 0 then found = true; break end
            end
        end
    end
    if not found then
        addStrike(src, 'Cocaine Farm executor (shovel mismatch)')
        return
    end

    -- Amount di-roll di server sendiri, bukan percaya angka dari client
    -- (client sebelumnya bisa selalu klaim jumlah maksimal).
    local amount = math.random(data.amount.min, data.amount.max)

    if exports.morph_inv:GetItemCount(src, data.item) + amount > 500 then return end
    if not exports.morph_inv:CanCarryItem(src, data.item, amount) then return end

    local newDur = currentDurability - Config.Settings.ShovelDurabilityLoss
    if newDur <= 0 then
        exports.morph_inv:RemoveItem(src, 'shovel', 1, nil, slot)
    else
        exports.morph_inv:SetMetadata(src, slot, { durability = newDur })
    end

    exports.morph_inv:AddItem(src, data.item, amount)

    -- Tandai titik ini "baru dipanen" khusus buat player ini. Titik yang
    -- sama tetap bebas dipanen player lain kapan aja, karena state-nya
    -- independen per source.
    playerSpotState[src] = playerSpotState[src] or {}
    playerSpotState[src][farmId] = playerSpotState[src][farmId] or {}
    playerSpotState[src][farmId][index] = GetGameTimer()

    resetStrikes(src)
end)

AddEventHandler('playerDropped', function()
    local src = source
    activeSessions[src] = nil
    strikes[src] = nil
    playerSpotState[src] = nil
    for key in pairs(eventRateLimit) do
        if key:match('^' .. src .. '_event_') then
            eventRateLimit[key] = nil
        end
    end
end)

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() == res then
        eventRateLimit = {}
        activeSessions = {}
        strikes = {}
        playerSpotState = {}
    end
end)

print("^2[Cocaine Farm] Server loaded^7")