-- server.lua
local Config = require 'morph_tailor.config'

local eventRateLimit = {}
local activeSessions = {}      -- [src] = { type = 'take'|'cotton'|'clothes', index = n?, startedAt = ms, auto = bool }
local strikes = {}             -- [src] = count
local playerCottonState = {}   -- [src] = { [spotIndex] = lastTakenAt (ms) }  -- per-player, doesn't affect other players

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

local function checkEventSpamming(source, action)
    -- Sekarang cuma jaring pengaman kedua (defense in depth). Pertahanan
    -- utama ada di sistem sesi + cooldown per-cotton di bawah.
    local currentTime = os.time()
    local key = source .. '_event_' .. action
    local limits = { takeCotton = 20, processCottonReward = 20, processClothesReward = 20 }
    local limit = limits[action] or 20
    if not eventRateLimit[key] then
        eventRateLimit[key] = { count = 1, firstTime = currentTime }
        return false
    end
    local data = eventRateLimit[key]
    local timeDiff = currentTime - data.firstTime
    if timeDiff > 60 then
        eventRateLimit[key] = { count = 1, firstTime = currentTime }
        return false
    end
    data.count = data.count + 1
    if data.count >= limit then
        addStrike(source, 'Executor Tailor Job (rate limit)')
        eventRateLimit[key] = nil
        return true
    end
    return false
end

lib.callback.register('tailor:server:checkScissors', function(src)
    local items = exports.morph_inv:Search(src, 'slots', Config.CottonField.requiredItem)
    if items and #items > 0 then
        for _, item in pairs(items) do
            local dur = item.metadata.durability or 100
            if dur > 0 then return { has = true, slot = item.slot, durability = math.floor(dur) } end
        end
    end
    return { has = false, slot = nil, durability = 0 }
end)

lib.callback.register('tailor:server:canCarry', function(src, item, amount)
    if amount > 100 then
        addStrike(src, 'Executor Tailor Job (canCarry amount)')
        return false
    end
    return exports.morph_inv:CanCarryItem(src, item, amount)
end)

lib.callback.register('tailor:server:checkProcessCotton', function(src)
    return exports.morph_inv:Search(src, 'count', Config.ProcessCotton.inputItem) >= Config.ProcessCotton.inputAmount
end)

lib.callback.register('tailor:server:checkProcessClothes', function(src)
    return exports.morph_inv:Search(src, 'count', Config.ProcessClothes.inputItem) >= Config.ProcessClothes.inputAmount
end)

-- Ambil koordinat & jarak maksimum yang wajar buat tiap tipe aksi.
-- 'take' pakai spawn point cotton spesifik (per index), sisanya pakai
-- koordinat stasiun (cotton processing / clothes making).
local function getSpotForType(actionType, index)
    if actionType == 'take' then
        local pos = Config.CottonField.spawnPoints[index]
        if not pos then return nil end
        return vec3(pos.x, pos.y, pos.z), Config.targetDistance
    elseif actionType == 'cotton' then
        return Config.ProcessCotton.coords, 5.0
    elseif actionType == 'clothes' then
        return Config.ProcessClothes.coords, 5.0
    end
    return nil
end

local function expectedDuration(actionType, isAuto)
    if actionType == 'take' then
        return Config.CottonField.duration
    elseif actionType == 'cotton' then
        return isAuto and Config.AutoProcessCotton.duration or Config.ProcessCotton.duration
    elseif actionType == 'clothes' then
        return isAuto and Config.AutoProcessClothes.duration or Config.ProcessClothes.duration
    end
    return nil
end

-- Client wajib minta sesi ini SEBELUM progress bar mulai. Server cek
-- posisi saat itu (dan, khusus 'take', cooldown cotton milik player
-- ini sendiri) sebelum ngasih izin.
lib.callback.register('tailor:server:startAction', function(source, actionType, isAuto, index)
    local coords, maxDist = getSpotForType(actionType, index)
    if not coords then return false end

    if not isNearCoords(source, coords, maxDist + DIST_BUFFER) then
        addStrike(source, 'Exploiting Tailor Job (start out of range)')
        return false
    end

    if actionType == 'take' then
        local state = playerCottonState[source]
        local lastTaken = state and state[index]
        if lastTaken and (GetGameTimer() - lastTaken) < Config.CottonField.respawnTime then
            addStrike(source, 'Exploiting Tailor Job (cotton still on cooldown)')
            return false
        end
    end

    activeSessions[source] = {
        type = actionType,
        index = index,
        startedAt = GetGameTimer(),
        auto = isAuto and true or false,
    }
    return true
end)

-- Validasi sesi: harus ada, tipe & index harus cocok, durasi yang
-- beneran lewat harus mendekati durasi asli (dikurangi buffer), dan
-- posisi masih di lokasi. Sesi dikonsumsi begitu dipakai (single-use).
local function validateSession(source, actionType, index)
    local session = activeSessions[source]
    if not session or session.type ~= actionType or session.index ~= index then
        addStrike(source, 'Exploiting Tailor Job (no valid session)')
        return false
    end

    local elapsed = GetGameTimer() - session.startedAt
    local minDuration = expectedDuration(actionType, session.auto) - DURATION_BUFFER
    if elapsed < minDuration then
        activeSessions[source] = nil
        addStrike(source, 'Exploiting Tailor Job (reward claimed too fast)')
        return false
    end

    local coords, maxDist = getSpotForType(actionType, index)
    if not coords or not isNearCoords(source, coords, maxDist + DIST_BUFFER) then
        activeSessions[source] = nil
        addStrike(source, 'Exploiting Tailor Job (out of range on claim)')
        return false
    end

    activeSessions[source] = nil -- consume, single-use
    return true
end

RegisterNetEvent('tailor:server:takeCotton', function(index, slot, currentDurability)
    local src = source
    if checkEventSpamming(src, 'takeCotton') then return end
    if not validateSession(src, 'take', index) then return end

    -- FIX: sebelumnya di sini kita bandingin `dur == currentDurability`,
    -- di mana `dur` adalah nilai ASLI (bisa desimal) dari metadata, dan
    -- `currentDurability` adalah nilai yang udah dibulatin (math.floor)
    -- waktu dikirim ke client lewat checkScissors. Kalau durability lagi
    -- di angka desimal (mis. 87.4), client cuma tau 87, kirim balik 87,
    -- lalu 87.4 == 87 gagal -> false ban ("scissors mismatch") padahal
    -- player sama sekali ga curang.
    --
    -- currentDurability dari client cuma dipakai buat display/log, BUKAN
    -- lagi jadi basis validasi keamanan -- yang penting scissors di slot
    -- itu masih ada & durability aslinya (dari server) masih > 0. Jarak,
    -- session, dan cooldown per-player udah cukup nutup exploit-nya.
    local scissorItems = exports.morph_inv:Search(src, 'slots', Config.CottonField.requiredItem)
    local found, scissorDur = false, 0
    if scissorItems and #scissorItems > 0 then
        for _, item in pairs(scissorItems) do
            if item.slot == slot then
                local dur = item.metadata.durability or 100
                if dur > 0 then
                    found, scissorDur = true, dur
                end
                break
            end
        end
    end
    if not found then
        addStrike(src, 'Executor Tailor Job (scissors mismatch)')
        return
    end

    local amount = math.random(Config.CottonField.outputMin, Config.CottonField.outputMax)
    if not exports.morph_inv:CanCarryItem(src, Config.CottonField.outputItem, amount) then return end
    if exports.morph_inv:GetItemCount(src, Config.CottonField.outputItem) + amount > 500 then return end

    -- scissorDur = durability ASLI dari server (bukan currentDurability
    -- yang dikirim client), jadi perhitungan durability baru tetap akurat.
    local newDur = scissorDur - Config.CottonField.durabilityLoss
    if newDur <= 0 then exports.morph_inv:RemoveItem(src, Config.CottonField.requiredItem, 1, nil, slot)
    else exports.morph_inv:SetMetadata(src, slot, { durability = newDur }) end
    exports.morph_inv:AddItem(src, Config.CottonField.outputItem, amount)

    -- Tandai cotton spot ini "baru diambil" khusus buat player ini. Spot
    -- yang sama tetap bebas diambil player lain kapan aja, karena
    -- state-nya independen per source.
    playerCottonState[src] = playerCottonState[src] or {}
    playerCottonState[src][index] = GetGameTimer()

    resetStrikes(src)
end)

RegisterNetEvent('tailor:server:processCottonReward', function()
    local src = source
    if checkEventSpamming(src, 'processCottonReward') then return end
    if not validateSession(src, 'cotton', nil) then return end

    if exports.morph_inv:GetItemCount(src, Config.ProcessCotton.inputItem) < Config.ProcessCotton.inputAmount then
        addStrike(src, 'Executor Tailor Job (missing input)')
        return
    end
    if not exports.morph_inv:CanCarryItem(src, Config.ProcessCotton.outputItem, Config.ProcessCotton.outputAmount) then return end
    if exports.morph_inv:GetItemCount(src, Config.ProcessCotton.outputItem) + Config.ProcessCotton.outputAmount > 500 then return end
    exports.morph_inv:RemoveItem(src, Config.ProcessCotton.inputItem, Config.ProcessCotton.inputAmount)
    exports.morph_inv:AddItem(src, Config.ProcessCotton.outputItem, Config.ProcessCotton.outputAmount)

    resetStrikes(src)
end)

RegisterNetEvent('tailor:server:processClothesReward', function()
    local src = source
    if checkEventSpamming(src, 'processClothesReward') then return end
    if not validateSession(src, 'clothes', nil) then return end

    if exports.morph_inv:GetItemCount(src, Config.ProcessClothes.inputItem) < Config.ProcessClothes.inputAmount then
        addStrike(src, 'Executor Tailor Job (missing input)')
        return
    end
    if not exports.morph_inv:CanCarryItem(src, Config.ProcessClothes.outputItem, Config.ProcessClothes.outputAmount) then return end
    if exports.morph_inv:GetItemCount(src, Config.ProcessClothes.outputItem) + Config.ProcessClothes.outputAmount > 500 then return end
    exports.morph_inv:RemoveItem(src, Config.ProcessClothes.inputItem, Config.ProcessClothes.inputAmount)
    exports.morph_inv:AddItem(src, Config.ProcessClothes.outputItem, Config.ProcessClothes.outputAmount)

    resetStrikes(src)
end)

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() == res then
        eventRateLimit = {}
        activeSessions = {}
        strikes = {}
        playerCottonState = {}
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    activeSessions[src] = nil
    strikes[src] = nil
    playerCottonState[src] = nil
    for key in pairs(eventRateLimit) do
        if key:match('^' .. src .. '_event_') then
            eventRateLimit[key] = nil
        end
    end
end)

print("^2[TAILOR JOB] Server loaded!^7")