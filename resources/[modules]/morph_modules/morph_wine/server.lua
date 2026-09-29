-- server.lua

local cfgFile = require 'morph_wine.config'
local config = setmetatable(cfgFile.server, { __index = cfgFile.shared })

local eventRateLimit = {}
local playerGrapeState = {} -- [src] = { [grapeIndex] = lastPickedAt (ms) } -- per-player, doesn't affect other players
local activeSessions = {}   -- [src] = { type = 'pick'|'juice'|'wine', index = n?, startedAt = ms }
local strikes = {}          -- [src] = count

-- Toleransi buffer supaya lag/ping normal nggak ke-flag sebagai exploit.
local DIST_BUFFER = 1.5
local DURATION_BUFFER = 700
local MAX_STRIKES = 3

local function checkEventSpamming(source, action)
    local currentTime = os.time()
    local key = source .. '_event_' .. action
    local limits = { getGrapes = 10, receiveWine = 10, receiveGrapeJuice = 10 }
    local limit = limits[action] or 10
    if not eventRateLimit[key] then eventRateLimit[key] = { count = 1, firstTime = currentTime } return false end
    local data = eventRateLimit[key]
    local timeDiff = currentTime - data.firstTime
    if timeDiff > 60 then eventRateLimit[key] = { count = 1, firstTime = currentTime } return false end
    data.count = data.count + 1
    if data.count >= limit then exports.morph_junjie:ExploitBan(source, 'Executor Vineyard Job'); eventRateLimit[key] = nil; return true end
    return false
end

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

local Inv = {
    HasItem = function(s, i, a) return exports.morph_inv:Search(s, 'count', i) >= (a or 1) end,
    CanCarry = function(s, i, a) return exports.morph_inv:CanCarryItem(s, i, a or 1) end,
    GetCount = function(s, i) return exports.morph_inv:Search(s, 'count', i) end,
    GetSlots = function(s, i) return exports.morph_inv:Search(s, 'slots', i) end,
    AddItem = function(s, i, a) exports.morph_inv:AddItem(s, i, a) end,
    RemoveItem = function(s, i, a, sl, m) exports.morph_inv:RemoveItem(s, i, a, sl, m) end,
    SetMeta = function(s, sl, m) exports.morph_inv:SetMetadata(s, sl, m) end
}

lib.callback.register('morph_wine:server:checkCanCarryGrapes', function()
    local src = source
    local amount = config.grapeAmount.max or 15
    if not Inv.CanCarry(src, 'grape', amount) then return false end
    if Inv.GetCount(src, 'grape') + amount > 500 then return false end
    return true
end)

lib.callback.register('morph_wine:server:checkCanCarryProcess', function()
    local src = source
    local juiceAmount = config.grapeJuiceAmount.max or 10
    local wineAmount = config.wineAmount.max or 10
    local maxAmount = math.max(juiceAmount, wineAmount)
    if not Inv.CanCarry(src, 'grapejuice', maxAmount) then return false end
    if not Inv.CanCarry(src, 'wine', maxAmount) then return false end
    if Inv.GetCount(src, 'grapejuice') + maxAmount > 500 then return false end
    if Inv.GetCount(src, 'wine') + maxAmount > 500 then return false end
    return true
end)

lib.callback.register('morph_wine:server:grapeJuicesNeeded', function()
    local src = source
    local itemCount = Inv.GetCount(src, 'grapejuice')
    if itemCount < config.grapeJuicesNeeded then return false end
    return true
end)

lib.callback.register('morph_wine:server:grapesNeeded', function()
    local src = source
    local itemCount = Inv.GetCount(src, 'grape')
    if itemCount < config.grapesNeeded then return false end
    return true
end)

-- Ambil koordinat & jarak maksimum yang wajar buat tiap tipe aksi.
-- 'pick' pakai titik anggur spesifik (per index), 'juice'/'wine' pakai
-- koordinat vineyard processing.
local function getSpotForType(actionType, index)
    if actionType == 'pick' then
        local coords = config.grapeLocations[index]
        if not coords then return nil end
        return coords, config.grapeRadius or 2.5
    elseif actionType == 'juice' or actionType == 'wine' then
        return config.vineyard.coords, config.vineyardRadius or 3.0
    end
    return nil
end

local function expectedDuration(actionType)
    if actionType == 'pick' then
        return config.pickDuration or 9000
    elseif actionType == 'juice' or actionType == 'wine' then
        return config.processDuration or 8000
    end
    return nil
end

-- Client wajib minta sesi ini SEBELUM progress bar mulai. Server cek
-- posisi saat itu (dan, khusus 'pick', cooldown titik anggur milik
-- player ini sendiri) sebelum ngasih izin.
lib.callback.register('morph_wine:server:startAction', function(source, actionType, index)
    local coords, maxDist = getSpotForType(actionType, index)
    if not coords then return false end

    if not isNearCoords(source, coords, maxDist + DIST_BUFFER) then
        addStrike(source, 'Exploiting Vineyard Job (start out of range)')
        return false
    end

    if actionType == 'pick' then
        local state = playerGrapeState[source]
        local lastPicked = state and state[index]
        if lastPicked and (GetGameTimer() - lastPicked) < (config.regrowTime or 20000) then
            addStrike(source, 'Exploiting Vineyard Job (grape still on cooldown)')
            return false
        end
    end

    activeSessions[source] = { type = actionType, index = index, startedAt = GetGameTimer() }
    return true
end)

-- Validasi sesi: harus ada, tipe & index harus cocok, durasi yang
-- beneran lewat harus mendekati durasi asli (dikurangi buffer), dan
-- posisi masih di lokasi. Sesi dikonsumsi begitu dipakai (single-use).
local function validateSession(source, actionType, index)
    local session = activeSessions[source]
    if not session or session.type ~= actionType or session.index ~= index then
        addStrike(source, 'Exploiting Vineyard Job (no valid session)')
        return false
    end

    local elapsed = GetGameTimer() - session.startedAt
    local minDuration = expectedDuration(actionType) - DURATION_BUFFER
    if elapsed < minDuration then
        activeSessions[source] = nil
        addStrike(source, 'Exploiting Vineyard Job (reward claimed too fast)')
        return false
    end

    local coords, maxDist = getSpotForType(actionType, index)
    if not coords or not isNearCoords(source, coords, maxDist + DIST_BUFFER) then
        activeSessions[source] = nil
        addStrike(source, 'Exploiting Vineyard Job (out of range on claim)')
        return false
    end

    activeSessions[source] = nil -- consume, single-use
    return true
end

RegisterNetEvent('morph_wine:server:getGrapes', function(index)
    local src = source
    if checkEventSpamming(src, 'getGrapes') then return end
    if not validateSession(src, 'pick', index) then return end

    local amount = math.random(config.grapeAmount.min, config.grapeAmount.max)
    if not Inv.CanCarry(src, 'grape', amount) then return end
    if Inv.GetCount(src, 'grape') + amount > 500 then return end
    Inv.AddItem(src, 'grape', amount)

    -- Tandai titik ini "baru dipetik" khusus buat player ini. Titik yang
    -- sama tetap bebas dipetik player lain kapan aja, karena state-nya
    -- independen per source.
    playerGrapeState[src] = playerGrapeState[src] or {}
    playerGrapeState[src][index] = GetGameTimer()

    resetStrikes(src)
end)

RegisterNetEvent('morph_wine:server:receiveWine', function()
    local src = source
    if checkEventSpamming(src, 'receiveWine') then return end
    if not validateSession(src, 'wine', nil) then return end

    local itemCount = Inv.GetCount(src, 'grapejuice')
    if itemCount < config.grapeJuicesNeeded then return end

    local amount = math.random(config.wineAmount.min, config.wineAmount.max)
    if not Inv.CanCarry(src, 'wine', amount) then return end
    if Inv.GetCount(src, 'wine') + amount > 500 then return end

    Inv.RemoveItem(src, 'grapejuice', config.grapeJuicesNeeded)
    Inv.AddItem(src, 'wine', amount)

    resetStrikes(src)
end)

RegisterNetEvent('morph_wine:server:receiveGrapeJuice', function()
    local src = source
    if checkEventSpamming(src, 'receiveGrapeJuice') then return end
    if not validateSession(src, 'juice', nil) then return end

    local itemCount = Inv.GetCount(src, 'grape')
    if itemCount < config.grapesNeeded then return end

    local amount = math.random(config.grapeJuiceAmount.min, config.grapeJuiceAmount.max)
    if not Inv.CanCarry(src, 'grapejuice', amount) then return end
    if Inv.GetCount(src, 'grapejuice') + amount > 500 then return end

    Inv.RemoveItem(src, 'grape', config.grapesNeeded)
    Inv.AddItem(src, 'grapejuice', amount)

    resetStrikes(src)
end)

AddEventHandler('playerDropped', function()
    local src = source
    playerGrapeState[src] = nil
    activeSessions[src] = nil
    strikes[src] = nil
    for key in pairs(eventRateLimit) do
        if key:match('^' .. src .. '_event_') then
            eventRateLimit[key] = nil
        end
    end
end)

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() == res then
        eventRateLimit = {}
        playerGrapeState = {}
        activeSessions = {}
        strikes = {}
    end
end)

print("^2[VINEYARD] Server loaded!^7")