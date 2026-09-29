-- server.lua
local Config = require 'morph_pork.config'

local eventRateLimit = {}
local activeSessions = {}   -- [src] = { type = 'catch'|'meat'|'pack', startedAt = ms, auto = bool }
local strikes = {}          -- [src] = count

-- Durasi progress bar 'catch' itu hardcoded 4000ms di client (bukan
-- di config), jadi disamain di sini biar validasi durasi cocok.
local CATCH_DURATION = 4000

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

local function isSpamming(src, action, limit)
    local now = os.time()
    local key = src .. '_' .. action

    if not eventRateLimit[key] then
        eventRateLimit[key] = { count = 1, firstTime = now }
        return false
    end

    local data = eventRateLimit[key]
    if now - data.firstTime > 60 then
        eventRateLimit[key] = { count = 1, firstTime = now }
        return false
    end

    data.count = data.count + 1
    if data.count >= (limit or 30) then
        addStrike(src, 'Executor Pork Farm (rate limit)')
        eventRateLimit[key] = nil
        return true
    end

    return false
end

lib.callback.register('pig:server:checkSack', function(src)
    local items = exports.morph_inv:Search(src, 'slots', Config.Job.requiredItem)
    if items and #items > 0 then
        for _, item in pairs(items) do
            local dur = item.metadata.durability or 100
            if dur > 0 then
                return { slot = item.slot, durability = dur }
            end
        end
    end
    return false
end)

lib.callback.register('pig:server:canCarry', function(src, item, amount)
    if amount > 100 then
        addStrike(src, 'Executor Pork Farm (canCarry amount)')
        return false
    end
    return exports.morph_inv:CanCarryItem(src, item, amount)
end)

lib.callback.register('pig:server:checkItems', function(src, item, amount)
    if not item or not amount then return true end
    return exports.morph_inv:Search(src, 'count', item) >= amount
end)

-- Ambil koordinat & jarak maksimum yang wajar buat tiap tipe aksi.
-- 'catch' pakai area kerja keseluruhan (AutoStopDistance), karena pig
-- bisa kabur/berpindah cukup jauh dari titik spawn awal.
local function getSpotForType(actionType)
    if actionType == 'catch' then
        return Config.Job.SpawnCenter, Config.Job.AutoStopDistance
    elseif actionType == 'meat' then
        return Config.ProcessMeat.coords, Config.ProcessMeat.targetDistance
    elseif actionType == 'pack' then
        return Config.ProcessPack.coords, Config.ProcessPack.targetDistance
    end
    return nil
end

local function expectedDuration(actionType, isAuto)
    if actionType == 'catch' then
        return CATCH_DURATION
    elseif actionType == 'meat' then
        return isAuto and Config.AutoProcessMeat.duration or Config.ProcessMeat.duration
    elseif actionType == 'pack' then
        return isAuto and Config.AutoProcessPack.duration or Config.ProcessPack.duration
    end
    return nil
end

-- Client wajib minta sesi ini SEBELUM progress bar mulai.
lib.callback.register('pig:server:startAction', function(source, actionType, isAuto)
    local coords, maxDist = getSpotForType(actionType)
    if not coords then return false end

    if not isNearCoords(source, coords, maxDist + DIST_BUFFER) then
        addStrike(source, 'Exploiting Pork Farm (start out of range)')
        return false
    end

    activeSessions[source] = {
        type = actionType,
        startedAt = GetGameTimer(),
        auto = isAuto and true or false,
    }
    return true
end)

local function validateSession(source, actionType)
    local session = activeSessions[source]
    if not session or session.type ~= actionType then
        addStrike(source, 'Exploiting Pork Farm (no valid session)')
        return false
    end

    local elapsed = GetGameTimer() - session.startedAt
    local minDuration = expectedDuration(actionType, session.auto) - DURATION_BUFFER
    if elapsed < minDuration then
        activeSessions[source] = nil
        addStrike(source, 'Exploiting Pork Farm (reward claimed too fast)')
        return false
    end

    local coords, maxDist = getSpotForType(actionType)
    if not coords or not isNearCoords(source, coords, maxDist + DIST_BUFFER) then
        activeSessions[source] = nil
        addStrike(source, 'Exploiting Pork Farm (out of range on claim)')
        return false
    end

    activeSessions[source] = nil -- consume, single-use
    return true
end

-- Diganti jadi callback (bukan event) supaya roll CatchChance dilakuin
-- SERVER yang nentuin, bukan client. Sebelumnya client yang roll
-- sendiri dan cuma nge-trigger event kalau "beruntung" -- exploiter
-- yang manggil event langsung otomatis 100% berhasil, ngelewatin
-- peluang gagalnya sama sekali.
lib.callback.register('pig:server:catchReward', function(source, slot, currentDurability)
    local src = source
    if isSpamming(src, 'catchReward', 20) then return false end
    if not validateSession(src, 'catch') then return false end

    local sackItems = exports.morph_inv:Search(src, 'slots', Config.Job.requiredItem)
    local found = false
    local sackDur = 0

    if sackItems and #sackItems > 0 then
        for _, item in pairs(sackItems) do
            if item.slot == slot then
                local dur = item.metadata.durability or 100
                if dur == currentDurability and dur > 0 then
                    found = true
                    sackDur = dur
                    break
                end
            end
        end
    end

    if not found then
        addStrike(src, 'Executor Pork Farm (sack mismatch)')
        return false
    end

    -- Roll chance-nya di sini, bukan di client.
    local rolledSuccess = math.random(1, 100) <= Config.Job.CatchChance
    if not rolledSuccess then
        resetStrikes(src) -- ini attempt valid, cuma emang lagi apes
        return false
    end

    local amount = math.random(Config.Job.RewardMin, Config.Job.RewardMax)
    if not exports.morph_inv:CanCarryItem(src, Config.Job.RewardItem, amount) then return false end
    if exports.morph_inv:GetItemCount(src, Config.Job.RewardItem) + amount > 500 then return false end

    local newDur = sackDur - Config.Job.durabilityLoss
    if newDur <= 0 then
        exports.morph_inv:RemoveItem(src, Config.Job.requiredItem, 1, nil, slot)
    else
        exports.morph_inv:SetMetadata(src, slot, { durability = newDur })
    end

    exports.morph_inv:AddItem(src, Config.Job.RewardItem, amount)
    resetStrikes(src)
    return true
end)

RegisterNetEvent('pig:server:processMeatReward', function()
    local src = source
    if isSpamming(src, 'processMeatReward') then return end
    if not validateSession(src, 'meat') then return end

    local cfg = Config.ProcessMeat
    if exports.morph_inv:GetItemCount(src, cfg.inputItem) < cfg.inputAmount then
        addStrike(src, 'Executor Pork Farm (missing input)')
        return
    end
    if not exports.morph_inv:CanCarryItem(src, cfg.outputItem, cfg.outputAmount) then return end
    if exports.morph_inv:GetItemCount(src, cfg.outputItem) + cfg.outputAmount > cfg.maxStack then return end

    exports.morph_inv:RemoveItem(src, cfg.inputItem, cfg.inputAmount)
    exports.morph_inv:AddItem(src, cfg.outputItem, cfg.outputAmount)

    resetStrikes(src)
end)

RegisterNetEvent('pig:server:processPackReward', function()
    local src = source
    if isSpamming(src, 'processPackReward') then return end
    if not validateSession(src, 'pack') then return end

    local cfg = Config.ProcessPack
    if exports.morph_inv:GetItemCount(src, cfg.inputItem) < cfg.inputAmount then
        addStrike(src, 'Executor Pork Farm (missing input)')
        return
    end
    if not exports.morph_inv:CanCarryItem(src, cfg.outputItem, cfg.outputAmount) then return end
    if exports.morph_inv:GetItemCount(src, cfg.outputItem) + cfg.outputAmount > cfg.maxStack then return end

    exports.morph_inv:RemoveItem(src, cfg.inputItem, cfg.inputAmount)
    exports.morph_inv:AddItem(src, cfg.outputItem, cfg.outputAmount)

    resetStrikes(src)
end)

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() == res then
        eventRateLimit = {}
        activeSessions = {}
        strikes = {}
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    activeSessions[src] = nil
    strikes[src] = nil
    for key in pairs(eventRateLimit) do
        if key:match('^' .. src .. '_') then
            eventRateLimit[key] = nil
        end
    end
end)

print("^2[PORK FARM] Server loaded.^7")