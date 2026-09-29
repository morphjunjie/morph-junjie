-- server.lua
local Config = require 'morph_mining.config'

local eventRateLimit = {} -- tracks event call frequency per player, used for spam detection
local activeSessions = {} -- tracks each player's currently open action session
local strikes = {} -- exploit strike counter per player
local playerRockState = {} -- last time each player mined each rock index, for cooldown checks

local DIST_BUFFER = 1.5 -- extra leeway (units) added to distance checks to account for movement/latency
local DURATION_BUFFER = 700 -- ms of leeway subtracted from expected duration to account for network delay
local MAX_STRIKES = 3 -- strikes before a player gets banned

-- checks if a player is within maxDist of a coord, false if their ped doesn't exist
local function isNearCoords(source, coords, maxDist)
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return false end
    local pos = GetEntityCoords(ped)
    return #(pos - coords) <= (maxDist or 5.0)
end

-- adds an exploit strike, bans the player once MAX_STRIKES is reached
local function addStrike(source, reason)
    strikes[source] = (strikes[source] or 0) + 1
    if strikes[source] >= MAX_STRIKES then
        if GetResourceState('morph_junjie') == 'started' then
            local ok, err = pcall(function()
                exports.morph_junjie:ExploitBan(source, reason)
            end)
            if not ok then
                print(('^1[Morph Mining] Failed to ban source %s: %s^7'):format(source, tostring(err)))
            end
        else
            -- morph_junjie missing/not started, log instead of erroring so the resource keeps running
            print(('^1[Morph Mining] morph_junjie not started, could not ban source %s for: %s^7'):format(source, reason))
        end
        strikes[source] = nil
    end
end

-- clears strikes after a successful, legitimate action
local function resetStrikes(source)
    strikes[source] = nil
end

-- basic per-action rate limit, strikes a player spamming the same event too fast
local function checkSpam(source, action)
    local now, key = os.time(), source .. '_' .. action
    if not eventRateLimit[key] then
        eventRateLimit[key] = { count = 1, firstTime = now }
        return false
    end
    local data = eventRateLimit[key]
    if now - data.firstTime > 60 then
        eventRateLimit[key] = { count = 1, firstTime = now } -- window expired, reset counter
        return false
    end
    data.count = data.count + 1
    if data.count >= 20 then
        addStrike(source, 'Mining spam')
        eventRateLimit[key] = nil
        return true
    end
    return false
end

-- returns whether the player has a pickaxe, its slot, and its durability (rounded down)
lib.callback.register('mining:server:checkPickaxe', function(src)
    local items = exports.morph_inv:Search(src, 'slots', Config.Mining.requiredItem)
    if items and #items > 0 then
        for _, item in pairs(items) do
            local dur = item.metadata.durability or 100
            if dur > 0 then
                return { has = true, slot = item.slot, durability = math.floor(dur) }
            end
        end
    end
    return { has = false, slot = nil, durability = 0 }
end)

-- generic carry-capacity check, also caps the amount to block obviously spoofed requests
lib.callback.register('mining:server:canCarry', function(src, item, amount)
    if amount > 100 then
        addStrike(src, 'Mining executor (canCarry amount)')
        return false
    end
    return exports.morph_inv:CanCarryItem(src, item, amount)
end)

-- pre-check used before starting wash/smelt/gems, so the player isn't stuck
-- waiting through a whole progress bar just to receive nothing.
-- washing has one fixed output item, checked directly.
-- smelt/gems have randomized output, so instead we check whether AT LEAST ONE
-- possible item (at its minimum roll amount) still fits — if literally none
-- of them fit, the player's inventory is clearly full for this category.
lib.callback.register('mining:server:canReceiveOutput', function(src, actionType)
    if actionType == 'wash' then
        local cfg = Config.Washing
        return exports.morph_inv:CanCarryItem(src, cfg.outputItem, cfg.outputAmount)
            and (exports.morph_inv:GetItemCount(src, cfg.outputItem) + cfg.outputAmount <= cfg.maxStack)
    end

    local cfg, chances
    if actionType == 'smelt' then
        cfg, chances = Config.Smelting, Config.Smelting.oreChances
    elseif actionType == 'gems' then
        cfg, chances = Config.GemSmelting, Config.GemSmelting.gemChances
    else
        return true
    end

    for _, entry in ipairs(chances) do
        local fits = exports.morph_inv:CanCarryItem(src, entry.item, entry.min)
            and (exports.morph_inv:GetItemCount(src, entry.item) + entry.min <= cfg.maxStack)
        if fits then return true end
    end

    return false
end)

-- checks if the player currently holds at least `amount` of `item`
lib.callback.register('mining:server:checkItems', function(src, item, amount)
    if not item or not amount then return true end
    return exports.morph_inv:Search(src, 'count', item) >= amount
end)

-- resolves the coords/range to validate against for a given action type
local function getSpotForType(actionType, index)
    if actionType == 'mine' then
        local pos = Config.Mining.spawnPoints[index]
        if not pos then return nil end
        return vec3(pos.x, pos.y, pos.z), Config.targetDistance
    elseif actionType == 'wash' then
        return Config.Washing.coords, 5.0
    elseif actionType == 'smelt' then
        return Config.Smelting.coords, 5.0
    elseif actionType == 'gems' then
        return Config.GemSmelting.coords, 5.0
    end
    return nil
end

-- resolves how long an action's progress bar should have taken, for the min-duration check
local function expectedDuration(actionType, isAuto)
    if actionType == 'mine' then
        return Config.Mining.progressTime
    elseif actionType == 'wash' then
        return isAuto and Config.AutoWash.duration or Config.Washing.progressTime
    elseif actionType == 'smelt' then
        return isAuto and Config.AutoSmelt.duration or Config.Smelting.progressTime
    elseif actionType == 'gems' then
        return Config.GemSmelting.progressTime
    end
    return nil
end

-- opens a session for an action after validating position and (for mining) rock cooldown.
-- the reward events below refuse to run unless a matching session was opened first.
lib.callback.register('mining:server:startAction', function(source, actionType, isAuto, index)
    local coords, maxDist = getSpotForType(actionType, index)
    if not coords then return false end

    if not isNearCoords(source, coords, maxDist + DIST_BUFFER) then
        addStrike(source, 'Exploiting Mining (start out of range)')
        return false
    end

    if actionType == 'mine' then
        local state = playerRockState[source]
        local lastMined = state and state[index]
        if lastMined and (GetGameTimer() - lastMined) < Config.Mining.respawnTime then
            addStrike(source, 'Exploiting Mining (rock still on cooldown)')
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

-- confirms a matching session exists, enough time has actually passed, and the player
-- is still in range, before letting a reward event proceed. consumes the session either way.
local function validateSession(source, actionType, index)
    local session = activeSessions[source]
    if not session or session.type ~= actionType or session.index ~= index then
        addStrike(source, 'Exploiting Mining (no valid session)')
        return false
    end

    local elapsed = GetGameTimer() - session.startedAt
    local minDuration = expectedDuration(actionType, session.auto) - DURATION_BUFFER
    if elapsed < minDuration then
        activeSessions[source] = nil
        addStrike(source, 'Exploiting Mining (reward claimed too fast)')
        return false
    end

    local coords, maxDist = getSpotForType(actionType, index)
    if not coords or not isNearCoords(source, coords, maxDist + DIST_BUFFER) then
        activeSessions[source] = nil
        addStrike(source, 'Exploiting Mining (out of range on claim)')
        return false
    end

    activeSessions[source] = nil
    return true
end

local DEFAULT_CHANCE = 50 -- fallback chance % used only if an entry is missing 'chance' in config
local warnedMissingChance = {} -- avoids spamming the console with the same warning repeatedly

-- rolls the random reward set for a smelt/gem action.
-- each item independently rolls its own chance field, so a single smelt
-- naturally gives a random subset of item types instead of always all of them.
-- one item is always guaranteed to hit so a smelt never returns completely empty.
-- if an individual item fails the carry/maxStack check (e.g. that stack is full),
-- only that item is skipped — it does not cancel other items that already
-- rolled successfully, and it does not add a strike, since the player never
-- chose which items get rolled in the first place.
local function rollAndCheck(src, chances, cfg)
    local rolled = {}
    local guaranteedIndex = math.random(1, #chances)

    for i, entry in ipairs(chances) do
        if entry.chance == nil and not warnedMissingChance[entry.item] then
            warnedMissingChance[entry.item] = true
            print(('^3[Morph Mining] WARNING: "%s" has no chance field in config.lua, defaulting to %d%%. Add chance = <1-100> to fix.^7')
                :format(entry.item, DEFAULT_CHANCE))
        end

        local hit = (i == guaranteedIndex) or (math.random(1, 100) <= (entry.chance or DEFAULT_CHANCE))
        if hit then
            local amount = math.random(entry.min, entry.max)
            local canCarry = exports.morph_inv:CanCarryItem(src, entry.item, amount)
            local underMax = exports.morph_inv:GetItemCount(src, entry.item) + amount <= cfg.maxStack
            if canCarry and underMax then
                rolled[#rolled + 1] = { item = entry.item, amount = amount }
            end
        end
    end

    return rolled
end

-- gives stone after re-validating the session, position, and that the client's
-- reported pickaxe/durability actually matches what the server has on record
RegisterNetEvent('mining:server:mineRock', function(index, slot, durability)
    local src = source
    if checkSpam(src, 'mineRock') then return end
    if not validateSession(src, 'mine', index) then return end

    local items = exports.morph_inv:Search(src, 'slots', Config.Mining.requiredItem)
    local found, actualDur = false, nil
    for _, item in pairs(items) do
        if item.slot == slot then
            actualDur = item.metadata.durability or 100
            -- compare against the floored value since that's what the client was given
            if math.floor(actualDur) == durability and actualDur > 0 then
                found = true
            end
            break
        end
    end

    if not found then
        addStrike(src, 'Mining executor (pickaxe mismatch)')
        return
    end

    local amount = math.random(Config.Mining.minStone, Config.Mining.maxStone)
    if not exports.morph_inv:CanCarryItem(src, 'stone', amount) then return end
    if exports.morph_inv:GetItemCount(src, 'stone') + amount > 500 then return end

    -- durability math uses the real float value, not the rounded one shown to the client
    local newDur = actualDur - Config.Mining.durabilityLoss
    if newDur <= 0 then
        exports.morph_inv:RemoveItem(src, Config.Mining.requiredItem, 1, nil, slot)
    else
        exports.morph_inv:SetMetadata(src, slot, { durability = newDur })
    end

    exports.morph_inv:AddItem(src, 'stone', amount)

    playerRockState[src] = playerRockState[src] or {}
    playerRockState[src][index] = GetGameTimer()

    resetStrikes(src)
end)

-- converts stone into washed_stone after re-validating the session and inventory space
RegisterNetEvent('mining:server:washStone', function()
    local src = source
    if checkSpam(src, 'washStone') then return end
    if not validateSession(src, 'wash', nil) then return end

    local cfg = Config.Washing
    if exports.morph_inv:GetItemCount(src, cfg.inputItem) < cfg.inputAmount then
        addStrike(src, 'Mining executor (missing input)')
        return
    end
    if not exports.morph_inv:CanCarryItem(src, cfg.outputItem, cfg.outputAmount)
        or exports.morph_inv:GetItemCount(src, cfg.outputItem) + cfg.outputAmount > cfg.maxStack then
        TriggerClientEvent('mining:client:smeltResult', src, false, 'Inventory too full to receive washed stone.')
        return
    end

    exports.morph_inv:RemoveItem(src, cfg.inputItem, cfg.inputAmount)
    exports.morph_inv:AddItem(src, cfg.outputItem, cfg.outputAmount)

    TriggerClientEvent('mining:client:smeltResult', src, true)
    resetStrikes(src)
end)

-- converts washed_stone into a random set of ores after re-validating the session
RegisterNetEvent('mining:server:smeltOre', function()
    local src = source
    if checkSpam(src, 'smeltOre') then return end
    if not validateSession(src, 'smelt', nil) then return end

    local cfg = Config.Smelting
    if exports.morph_inv:GetItemCount(src, cfg.inputItem) < cfg.inputAmount then
        addStrike(src, 'Mining executor (missing input)')
        return
    end

    local rolled = rollAndCheck(src, cfg.oreChances, cfg)

    exports.morph_inv:RemoveItem(src, cfg.inputItem, cfg.inputAmount)

    if #rolled == 0 then
        TriggerClientEvent('mining:client:smeltResult', src, false, 'Inventory too full to receive any ore.')
        resetStrikes(src)
        return
    end

    for _, r in ipairs(rolled) do
        exports.morph_inv:AddItem(src, r.item, r.amount)
    end

    TriggerClientEvent('mining:client:smeltResult', src, true)
    resetStrikes(src)
end)

-- converts washed_stone into a random set of gems after re-validating the session
RegisterNetEvent('mining:server:smeltGems', function()
    local src = source
    if checkSpam(src, 'smeltGems') then return end

    local cfg = Config.GemSmelting
    if not cfg.enabled then return end

    if not validateSession(src, 'gems', nil) then return end

    if exports.morph_inv:GetItemCount(src, cfg.inputItem) < cfg.inputAmount then
        addStrike(src, 'Mining executor (missing input)')
        return
    end

    local rolled = rollAndCheck(src, cfg.gemChances, cfg)

    exports.morph_inv:RemoveItem(src, cfg.inputItem, cfg.inputAmount)

    if #rolled == 0 then
        TriggerClientEvent('mining:client:smeltResult', src, false, 'Inventory too full to receive any gems.')
        resetStrikes(src)
        return
    end

    for _, r in ipairs(rolled) do
        exports.morph_inv:AddItem(src, r.item, r.amount)
    end

    TriggerClientEvent('mining:client:smeltResult', src, true)
    resetStrikes(src)
end)

-- resets all in-memory state on resource restart, but only for THIS resource
-- (previously this fired on every resource stop server-wide, wiping everyone's
-- session/strikes any time an unrelated resource restarted)
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    eventRateLimit = {}
    activeSessions = {}
    strikes = {}
    playerRockState = {}
end)

-- cleans up a player's state when they disconnect, avoids memory buildup over time
AddEventHandler('playerDropped', function()
    local src = source
    activeSessions[src] = nil
    strikes[src] = nil
    playerRockState[src] = nil
    for key in pairs(eventRateLimit) do
        if key:match('^' .. src .. '_') then
            eventRateLimit[key] = nil
        end
    end
end)

print('^2[Morph Mining] Server loaded^7')