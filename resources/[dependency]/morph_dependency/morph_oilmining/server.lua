-- server.lua
local Config = require 'morph_oilmining.config'

local eventRateLimit = {}
local activeSessions = {}
local strikes = {}
local playerPumpState = {}

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

local function checkSpam(source, action)
    local now, key = os.time(), source .. '_' .. action
    if not eventRateLimit[key] then eventRateLimit[key] = { count = 1, firstTime = now } return false end
    local data = eventRateLimit[key]
    if now - data.firstTime > 60 then eventRateLimit[key] = { count = 1, firstTime = now } return false end
    data.count = data.count + 1
    if data.count >= 20 then addStrike(source, 'Oil Mining spam'); eventRateLimit[key] = nil; return true end
    return false
end

lib.callback.register('oilmining:server:checkWrench', function(src)
    local items = exports.morph_inv:Search(src, 'slots', Config.Items.wrench)
    if items and #items > 0 then
        for _, item in pairs(items) do
            local dur = tonumber(item.metadata.durability) or 100
            if dur > 0 then return { has = true, slot = item.slot, durability = math.floor(dur) } end
        end
    end
    return { has = false, slot = nil, durability = 0 }
end)

lib.callback.register('oilmining:server:canCarry', function(src, item, amount)
    amount = tonumber(amount)
    if not amount or amount > 100 then
        addStrike(src, 'Oil Mining executor (canCarry amount)')
        return false
    end
    return exports.morph_inv:CanCarryItem(src, item, amount)
end)

lib.callback.register('oilmining:server:checkItems', function(src, item, amount)
    return exports.morph_inv:GetItemCount(src, item) >= tonumber(amount)
end)

local function getSpotForType(actionType, index)
    if actionType == 'mine' then
        local pos = Config.OilPump.spawnPoints[index]
        if not pos then return nil end
        return vec3(pos.x, pos.y, pos.z), Config.targetDistance
    elseif actionType == 'oil' then
        return Config.ProcessOil.coords, 5.0
    elseif actionType == 'barrel' then
        return Config.ProcessBarrel.coords, 5.0
    end
    return nil
end

local function expectedDuration(actionType, isAuto)
    if actionType == 'mine' then
        return Config.OilPump.progressTime
    elseif actionType == 'oil' then
        return isAuto and Config.AutoProcessOil.duration or Config.ProcessOil.progressTime
    elseif actionType == 'barrel' then
        return isAuto and Config.AutoProcessBarrel.duration or Config.ProcessBarrel.progressTime
    end
    return nil
end

lib.callback.register('oilmining:server:startAction', function(source, actionType, isAuto, index)
    local coords, maxDist = getSpotForType(actionType, index)
    if not coords then return false end

    if not isNearCoords(source, coords, maxDist + DIST_BUFFER) then
        addStrike(source, 'Exploiting Oil Mining (start out of range)')
        return false
    end

    if actionType == 'mine' then
        local state = playerPumpState[source]
        local lastMined = state and state[index]
        if lastMined and (GetGameTimer() - lastMined) < Config.OilPump.respawnTime then
            addStrike(source, 'Exploiting Oil Mining (pump still on cooldown)')
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

local function validateSession(source, actionType, index)
    local session = activeSessions[source]
    if not session or session.type ~= actionType or session.index ~= index then
        addStrike(source, 'Exploiting Oil Mining (no valid session)')
        return false
    end

    local elapsed = GetGameTimer() - session.startedAt
    local minDuration = expectedDuration(actionType, session.auto) - DURATION_BUFFER
    if elapsed < minDuration then
        activeSessions[source] = nil
        addStrike(source, 'Exploiting Oil Mining (reward claimed too fast)')
        return false
    end

    local coords, maxDist = getSpotForType(actionType, index)
    if not coords or not isNearCoords(source, coords, maxDist + DIST_BUFFER) then
        activeSessions[source] = nil
        addStrike(source, 'Exploiting Oil Mining (out of range on claim)')
        return false
    end

    activeSessions[source] = nil
    return true
end

RegisterNetEvent('oilmining:server:mineOil', function(index, slot, durability)
    local src = source
    if checkSpam(src, 'mineOil') then return end
    if not validateSession(src, 'mine', index) then return end

    -- FIX: sebelumnya kita bandingin `dur == durability`, di mana `dur`
    -- adalah nilai ASLI (bisa desimal) dari metadata dan `durability`
    -- adalah nilai yang udah dibulatin (math.floor) waktu dikirim ke
    -- client lewat checkWrench. Kalau durability lagi di angka desimal
    -- (mis. 63.7), client cuma tau 63, kirim balik 63, terus
    -- 63.7 == 63 gagal -> false ban ("wrench mismatch") padahal player
    -- ga curang sama sekali.
    --
    -- `durability` dari client sekarang cuma dipakai buat info/log, BUKAN
    -- basis validasi keamanan lagi -- yang penting wrench di slot itu
    -- masih ada & durability ASLI dari server masih > 0. Jarak, session,
    -- dan cooldown per-player udah cukup nutup exploit-nya.
    local items = exports.morph_inv:Search(src, 'slots', Config.Items.wrench)
    local found, actualDur = false, 0
    if items and #items > 0 then
        for _, item in pairs(items) do
            if item.slot == slot then
                local dur = tonumber(item.metadata.durability) or 100
                if dur > 0 then
                    found, actualDur = true, dur
                end
                break
            end
        end
    end

    if not found then
        addStrike(src, 'Oil Mining executor (wrench mismatch)')
        return
    end

    if not exports.morph_inv:CanCarryItem(src, Config.Items.crudeOil, Config.OilPump.maxOil) then return end

    -- Pakai actualDur (dari server), bukan durability yang dikirim client,
    -- buat hitung durability baru -- tetap akurat & aman.
    local newDur = actualDur - Config.OilPump.durabilityLoss
    if newDur <= 0 then
        exports.morph_inv:RemoveItem(src, Config.Items.wrench, 1, nil, slot)
    else
        exports.morph_inv:SetMetadata(src, slot, { durability = newDur })
    end

    local amount = math.random(Config.OilPump.minOil, Config.OilPump.maxOil)
    exports.morph_inv:AddItem(src, Config.Items.crudeOil, amount)

    playerPumpState[src] = playerPumpState[src] or {}
    playerPumpState[src][index] = GetGameTimer()

    resetStrikes(src)
end)

RegisterNetEvent('oilmining:server:processOil', function()
    local src = source
    if checkSpam(src, 'processOil') then return end
    if not validateSession(src, 'oil', nil) then return end

    if exports.morph_inv:GetItemCount(src, Config.Items.crudeOil) < Config.ProcessOil.inputAmount then
        addStrike(src, 'Oil Mining executor (missing input)')
        return
    end

    if not exports.morph_inv:CanCarryItem(src, Config.Items.processedOil, Config.ProcessOil.outputAmount) then
        return
    end

    exports.morph_inv:RemoveItem(src, Config.Items.crudeOil, Config.ProcessOil.inputAmount)
    exports.morph_inv:AddItem(src, Config.Items.processedOil, Config.ProcessOil.outputAmount)

    resetStrikes(src)
end)

RegisterNetEvent('oilmining:server:processBarrel', function()
    local src = source
    if checkSpam(src, 'processBarrel') then return end
    if not validateSession(src, 'barrel', nil) then return end

    if exports.morph_inv:GetItemCount(src, Config.Items.processedOil) < Config.ProcessBarrel.inputAmount then
        addStrike(src, 'Oil Mining executor (missing input)')
        return
    end

    if not exports.morph_inv:CanCarryItem(src, Config.Items.oilBarrel, Config.ProcessBarrel.outputAmount) then
        return
    end

    exports.morph_inv:RemoveItem(src, Config.Items.processedOil, Config.ProcessBarrel.inputAmount)
    exports.morph_inv:AddItem(src, Config.Items.oilBarrel, Config.ProcessBarrel.outputAmount)

    resetStrikes(src)
end)

AddEventHandler('onResourceStop', function()
    eventRateLimit = {}
    activeSessions = {}
    strikes = {}
    playerPumpState = {}
end)

AddEventHandler('playerDropped', function()
    local src = source
    activeSessions[src] = nil
    strikes[src] = nil
    playerPumpState[src] = nil
    for key in pairs(eventRateLimit) do
        if key:match('^' .. src .. '_') then
            eventRateLimit[key] = nil
        end
    end
end)

print('^2[Oil Mining Job] Server loaded^7')