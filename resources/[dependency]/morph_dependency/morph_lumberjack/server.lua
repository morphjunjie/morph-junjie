-- server.lua
local Config = require 'morph_lumberjack.config'

local eventRateLimit = {}
local activeSessions = {}     -- [src] = { type = 'chop'|'log'|'plank', index = n?, startedAt = ms, auto = bool }
local strikes = {}            -- [src] = count
local playerTreeState = {}    -- [src] = { [treeIndex] = lastChoppedAt (ms) }  -- per-player, doesn't affect other players

-- Toleransi buffer supaya lag/ping normal nggak ke-flag sebagai exploit.
local DIST_BUFFER = 1.5       -- meter ekstra di atas jarak yang diharuskan
local DURATION_BUFFER = 700   -- ms, boleh dianggap selesai sedikit lebih cepat dari durasi asli
local MAX_STRIKES = 3         -- baru di-ban setelah 3x pelanggaran, bukan sekali

local function isNearCoords(source, coords, maxDist)
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return false end
    local pos = GetEntityCoords(ped)
    return #(pos - coords) <= (maxDist or 5.0)
end

-- Nambah strike, baru ban kalau nyampe MAX_STRIKES. Ini yang bikin 1x
-- anomali (lag, desync posisi sesaat, dll) nggak langsung nge-ban
-- player biasa; cuma pola pelanggaran berulang yang ke-ban.
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

local function checkSpam(source, action)
    -- Sekarang cuma jaring pengaman kedua (defense in depth). Pertahanan
    -- utama ada di sistem sesi + cooldown per-tree di bawah.
    local now, key = os.time(), source .. '_' .. action
    if not eventRateLimit[key] then eventRateLimit[key] = { count = 1, firstTime = now } return false end
    local data = eventRateLimit[key]
    if now - data.firstTime > 60 then eventRateLimit[key] = { count = 1, firstTime = now } return false end
    data.count = data.count + 1
    if data.count >= 20 then addStrike(source, 'Lumberjack spam'); eventRateLimit[key] = nil; return true end
    return false
end

lib.callback.register('lumberjack:server:checkAxe', function(src)
    local items = exports.morph_inv:Search(src, 'slots', Config.Items.axe)
    if items and #items > 0 then
        for _, item in pairs(items) do
            local dur = tonumber(item.metadata.durability) or 100
            if dur > 0 then return { has = true, slot = item.slot, durability = math.floor(dur) } end
        end
    end
    return { has = false, slot = nil, durability = 0 }
end)

lib.callback.register('lumberjack:server:canCarry', function(src, item, amount)
    amount = tonumber(amount)
    if not amount or amount > 100 then
        addStrike(src, 'Lumberjack executor (canCarry amount)')
        return false
    end
    return exports.morph_inv:CanCarryItem(src, item, amount)
end)

lib.callback.register('lumberjack:server:checkItems', function(src, item, amount)
    return exports.morph_inv:GetItemCount(src, item) >= tonumber(amount)
end)

-- Ambil koordinat & jarak maksimum yang wajar buat tiap tipe aksi.
-- 'chop' pakai spawn point tree spesifik (per index), sisanya pakai
-- koordinat stasiun (log processing / packing).
local function getSpotForType(actionType, index)
    if actionType == 'chop' then
        local pos = Config.Tree.spawnPoints[index]
        if not pos then return nil end
        return vec3(pos.x, pos.y, pos.z), Config.targetDistance
    elseif actionType == 'log' then
        return Config.ProcessLog.coords, 5.0
    elseif actionType == 'plank' then
        return Config.ProcessPlank.coords, 5.0
    end
    return nil
end

local function expectedDuration(actionType, isAuto)
    if actionType == 'chop' then
        return Config.Tree.progressTime
    elseif actionType == 'log' then
        return isAuto and Config.AutoProcessLog.duration or Config.ProcessLog.progressTime
    elseif actionType == 'plank' then
        return isAuto and Config.AutoProcessPlank.duration or Config.ProcessPlank.progressTime
    end
    return nil
end

-- Client wajib minta sesi ini SEBELUM progress bar mulai. Server cek
-- posisi saat itu (dan, khusus chop, cooldown tree milik player ini
-- sendiri) sebelum ngasih izin. Tanpa sesi valid, event reward bakal
-- ditolak.
lib.callback.register('lumberjack:server:startAction', function(source, actionType, isAuto, index)
    local coords, maxDist = getSpotForType(actionType, index)
    if not coords then return false end

    if not isNearCoords(source, coords, maxDist + DIST_BUFFER) then
        addStrike(source, 'Exploiting Lumberjack (start out of range)')
        return false
    end

    if actionType == 'chop' then
        local state = playerTreeState[source]
        local lastChopped = state and state[index]
        if lastChopped and (GetGameTimer() - lastChopped) < Config.Tree.respawnTime then
            addStrike(source, 'Exploiting Lumberjack (tree still on cooldown)')
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
        addStrike(source, 'Exploiting Lumberjack (no valid session)')
        return false
    end

    local elapsed = GetGameTimer() - session.startedAt
    local minDuration = expectedDuration(actionType, session.auto) - DURATION_BUFFER
    if elapsed < minDuration then
        activeSessions[source] = nil
        addStrike(source, 'Exploiting Lumberjack (reward claimed too fast)')
        return false
    end

    local coords, maxDist = getSpotForType(actionType, index)
    if not coords or not isNearCoords(source, coords, maxDist + DIST_BUFFER) then
        activeSessions[source] = nil
        addStrike(source, 'Exploiting Lumberjack (out of range on claim)')
        return false
    end

    activeSessions[source] = nil -- consume, single-use
    return true
end

RegisterNetEvent('lumberjack:server:chopTree', function(index, slot, durability)
    local src = source
    if checkSpam(src, 'chopTree') then return end
    if not validateSession(src, 'chop', index) then return end

    -- Validasi slot & durability yang dikirim client itu BENERAN cocok
    -- sama axe yang lagi dipegang player, sebelum server nulis apa pun
    -- ke metadata slot itu. Sebelumnya slot/durability langsung
    -- dipercaya mentah-mentah dari client -- itu bisa dipakai buat
    -- nulis metadata ke slot MANA PUN (bukan cuma axe).
    local items = exports.morph_inv:Search(src, 'slots', Config.Items.axe)
    local found = false
    durability = tonumber(durability)
    for _, item in pairs(items) do
        if item.slot == slot then
            local dur = tonumber(item.metadata.durability) or 100
            if durability and dur == durability and dur > 0 then
                found = true
                break
            end
        end
    end

    if not found then
        addStrike(src, 'Lumberjack executor (axe mismatch)')
        return
    end

    if not exports.morph_inv:CanCarryItem(src, Config.Items.woodLog, Config.Tree.maxWood) then return end

    local newDur = durability - Config.Tree.durabilityLoss
    if newDur <= 0 then
        exports.morph_inv:RemoveItem(src, Config.Items.axe, 1, nil, slot)
    else
        exports.morph_inv:SetMetadata(src, slot, { durability = newDur })
    end

    local amount = math.random(Config.Tree.minWood, Config.Tree.maxWood)
    exports.morph_inv:AddItem(src, Config.Items.woodLog, amount)

    -- Chance dapet buah (orange/apple) sekalian pas nebang, sesuai
    -- fruitChance/fruitMin/fruitMax/fruits di config. Kalau salah satu
    -- field-nya nggak diisi di config, bagian ini otomatis di-skip.
    local fruits = Config.Tree.fruits
    if Config.Tree.fruitChance and fruits and #fruits > 0 and math.random(1, 100) <= Config.Tree.fruitChance then
        local fruitItem = fruits[math.random(#fruits)]
        local fruitAmount = math.random(Config.Tree.fruitMin or 1, Config.Tree.fruitMax or 1)
        if exports.morph_inv:CanCarryItem(src, fruitItem, fruitAmount) then
            if exports.morph_inv:GetItemCount(src, fruitItem) + fruitAmount <= 500 then
                exports.morph_inv:AddItem(src, fruitItem, fruitAmount)
            end
        end
    end

    -- Tandai tree ini "baru ditebang" khusus buat player ini. Tree yang
    -- sama tetap bebas ditebang player lain kapan aja, karena state-nya
    -- independen per source.
    playerTreeState[src] = playerTreeState[src] or {}
    playerTreeState[src][index] = GetGameTimer()

    resetStrikes(src)
end)

RegisterNetEvent('lumberjack:server:processLog', function()
    local src = source
    if checkSpam(src, 'processLog') then return end
    if not validateSession(src, 'log', nil) then return end

    if exports.morph_inv:GetItemCount(src, Config.Items.woodLog) < Config.ProcessLog.inputAmount then
        addStrike(src, 'Lumberjack executor (missing input)')
        return
    end

    if not exports.morph_inv:CanCarryItem(src, Config.Items.woodPlank, Config.ProcessLog.outputAmount) then
        return
    end

    exports.morph_inv:RemoveItem(src, Config.Items.woodLog, Config.ProcessLog.inputAmount)
    exports.morph_inv:AddItem(src, Config.Items.woodPlank, Config.ProcessLog.outputAmount)

    resetStrikes(src)
end)

RegisterNetEvent('lumberjack:server:processPlank', function()
    local src = source
    if checkSpam(src, 'processPlank') then return end
    if not validateSession(src, 'plank', nil) then return end

    if exports.morph_inv:GetItemCount(src, Config.Items.woodPlank) < Config.ProcessPlank.inputAmount then
        addStrike(src, 'Lumberjack executor (missing input)')
        return
    end

    if not exports.morph_inv:CanCarryItem(src, Config.Items.woodCrate, Config.ProcessPlank.outputAmount) then
        return
    end

    exports.morph_inv:RemoveItem(src, Config.Items.woodPlank, Config.ProcessPlank.inputAmount)
    exports.morph_inv:AddItem(src, Config.Items.woodCrate, Config.ProcessPlank.outputAmount)

    resetStrikes(src)
end)

AddEventHandler('onResourceStop', function()
    eventRateLimit = {}
    activeSessions = {}
    strikes = {}
    playerTreeState = {}
end)

AddEventHandler('playerDropped', function()
    local src = source
    activeSessions[src] = nil
    strikes[src] = nil
    playerTreeState[src] = nil
    for key in pairs(eventRateLimit) do
        if key:match('^' .. src .. '_') then
            eventRateLimit[key] = nil
        end
    end
end)

print('^2[Lumberjack Job] Server loaded^7')