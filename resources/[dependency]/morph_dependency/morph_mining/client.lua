-- client.lua
local Config = require 'morph_mining.config'
local isInArea = false -- whether the player is currently inside the mining zone
local rocks = {} -- spawned rock entities, keyed by spawn point index
local minedRocks = {} -- spawn point indexes currently on cooldown (already mined)
local isMining = false -- prevents starting a new mine action while one is in progress
local MineRock
local SpawnRock

-- ox blip category setup so mining blips group under their own submenu on the map legend
local busyCategories, categoryIndexes = {}, {}
local function getNextCategoryId() for i = 127, 128 do if not categoryIndexes[i] then categoryIndexes[i] = true; return i end end end
local function setBlipCategory(blip, name) local id = busyCategories[name] or getNextCategoryId() if not id then return end if not busyCategories[name] then busyCategories[name] = id; AddTextEntry("BLIP_CAT_" .. id, name) end SetBlipCategory(blip, id) end
exports('setBlipCategory', setBlipCategory)

-- creates the map blips listed in Config.Blips
local function CreateBlips()
    for _, data in ipairs(Config.Blips) do
        local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
        SetBlipSprite(blip, data.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, data.scale)
        SetBlipColour(blip, data.colour)
        SetBlipAsShortRange(blip, true)
        setBlipCategory(blip, "Morph Mining")
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(data.name)
        EndTextCommandSetBlipName(blip)
    end
end

-- small delay so blips are created after other resources finish loading
CreateThread(function() Wait(500) CreateBlips() end)

-- shorthand wrapper around lib.notify
local function Notify(desc, type)
    lib.notify({ title = 'Mining Job', description = desc, type = type or 'info', duration = 3000 })
end

-- asks the server to open a session for this action, server validates position/cooldowns
local function startSession(actionType, isAuto, index)
    return lib.callback.await('mining:server:startAction', false, actionType, isAuto, index)
end

-- finds the ground height under a coord so props/peds don't float or clip
local function GetGroundPosition(coords)
    local found, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 100.0, 0)
    return found and groundZ > -1000 and vec3(coords.x, coords.y, groundZ + 0.02) or vec3(coords.x, coords.y, coords.z + 0.5)
end

-- requests a model into memory before spawning it
local function LoadModel(model)
    lib.requestModel(model, 5000)
    return model
end

-- removes a spawned rock and its target option
local function DeleteRock(index)
    if rocks[index] and DoesEntityExist(rocks[index]) then
        exports.morph_tget:removeLocalEntity(rocks[index], 'mine_rock_' .. index)
        DeleteEntity(rocks[index])
        rocks[index] = nil
    end
end

-- spawns a rock at a given spawn point and attaches its morph_tget interaction
function SpawnRock(index, pos)
    if minedRocks[index] then return end -- still on cooldown, don't respawn yet
    if rocks[index] and DoesEntityExist(rocks[index]) then return end -- already spawned
    local model = LoadModel(Config.Mining.rockModel)
    local groundPos = GetGroundPosition(pos)
    local obj = CreateObject(model, groundPos.x, groundPos.y, groundPos.z, false, false, false)
    if not obj or obj == 0 then return end
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
    if pos.w then SetEntityHeading(obj, pos.w) end
    rocks[index] = obj
    exports.morph_tget:addLocalEntity(obj, {
        {
            name = 'mine_rock_' .. index,
            label = 'Mining Stone',
            icon = 'fa-solid fa-hammer',
            distance = Config.targetDistance,
            onSelect = function() MineRock(index) end
        }
    })
end

-- schedules a rock to reappear after its respawn timer, only if the player is still nearby
local function RespawnRock(index)
    local pos = Config.Mining.spawnPoints[index]
    SetTimeout(Config.Mining.respawnTime, function()
        if isInArea and minedRocks[index] then
            minedRocks[index] = nil
            SpawnRock(index, pos)
        end
    end)
end

-- main mining flow: validates the player, plays the animation/progress bar, then reports to server
function MineRock(index)
    if isMining then return Notify('Already mining.', 'error') end
    if minedRocks[index] then return Notify('Rock already mined.', 'error') end
    if not rocks[index] or not DoesEntityExist(rocks[index]) then return Notify('Rock not found.', 'error') end
    local dist = #(GetEntityCoords(cache.ped) - GetEntityCoords(rocks[index]))
    if dist > Config.targetDistance then return Notify('Too far from rock.', 'warn') end

    -- check for a pickaxe and its durability before starting anything
    local pickaxe = lib.callback.await('mining:server:checkPickaxe', false)
    if not pickaxe or not pickaxe.has then return Notify('Need a pickaxe.', 'error') end
    if pickaxe.durability <= 20 and pickaxe.durability > 0 then Notify('Pickaxe durability: ' .. pickaxe.durability .. '%', 'warning') end
    if pickaxe.durability <= 0 then return Notify('Pickaxe is broken.', 'error') end

    -- pre-check that the player has room for the stone reward before wasting their time
    if not lib.callback.await('mining:server:canCarry', false, 'stone', Config.Mining.maxStone) then return Notify('Inventory full.', 'error') end

    if not startSession('mine', false, index) then
        return Notify('Could not start mining here.', 'error')
    end

    isMining = true
    exports["morph_emote"]:EmoteCommandStart("axe4", 0)
    local success = lib.progressBar({
        duration = Config.Mining.progressTime,
        label = 'Mining Stone...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true }
    })
    exports["morph_emote"]:EmoteCancel()
    isMining = false

    if not success then return Notify('Cancelled.', 'error') end

    TriggerServerEvent('hud:server:GainStress', 0.8)
    DeleteRock(index)
    minedRocks[index] = true
    RespawnRock(index)
    -- server re-validates the session, position, and pickaxe before actually giving stone
    TriggerServerEvent('mining:server:mineRock', index, pickaxe.slot, pickaxe.durability)
    Notify('Stone mined successfully!', 'success')
end

-- spawns every rock that isn't currently on cooldown, staggered slightly to avoid a spawn spike
local function SpawnAllRocks()
    for i, pos in ipairs(Config.Mining.spawnPoints) do
        if not minedRocks[i] and not rocks[i] then
            SpawnRock(i, pos)
            Wait(1000)
        end
    end
end

-- despawns every currently spawned rock, used when leaving the mining zone
local function ClearAllRocks()
    for i in pairs(rocks) do DeleteRock(i) end
    rocks = {}
end

-- spawns/despawns rocks based on whether the player is inside the mining zone,
-- avoids having every rock active on the server at all times
lib.zones.sphere({
    coords = Config.Mining.coords,
    radius = Config.Mining.inDistance,
    onEnter = function()
        if isInArea then return end
        isInArea = true
        SpawnAllRocks()
    end,
    onExit = function()
        if not isInArea then return end
        isInArea = false
        ClearAllRocks()
    end
})

-- server sends this after a wash/smelt/gems attempt resolves, only shown on failure
-- (e.g. inventory filled up mid-action) so success stays silent and doesn't spam notifications
RegisterNetEvent('mining:client:smeltResult', function(success, reasonIfFailed)
    if not success then
        Notify(reasonIfFailed or 'Could not receive any items.', 'warn')
    end
end)

-- shared flow for washing, ore smelting, and gem smelting (manual or auto-looped)
local function ProcessAction(cfg, auto, type)
    local plyCoords = GetEntityCoords(cache.ped)
    if #(plyCoords - cfg.coords) > 5.0 then return Notify('Too far from area.', 'warn') end
    if not lib.callback.await('mining:server:checkItems', false, cfg.inputItem, cfg.inputAmount) then
        return Notify(string.format('Need %d %s.', cfg.inputAmount, cfg.inputItem:gsub('_', ' ')), 'error')
    end

    local total, isCancelled = 0, false
    -- pick the right duration/stress/label depending on manual vs auto and action type
    local duration = auto and (type == 'wash' and Config.AutoWash.duration or Config.AutoSmelt.duration) or cfg.progressTime
    local stress = auto and (type == 'wash' and Config.AutoWash.stressGain or Config.AutoSmelt.stressGain) or cfg.stressGain
    local label = auto and (type == 'wash' and Config.AutoWash.label or Config.AutoSmelt.label) or cfg.label
    local event = type == 'wash' and 'mining:server:washStone' or (type == 'smelt' and 'mining:server:smeltOre') or 'mining:server:smeltGems'

    if auto then Notify('Auto started.', 'success') end

    repeat
        if #(GetEntityCoords(cache.ped) - cfg.coords) > 5.0 then Notify('Moved too far.', 'warn'); break end
        if not lib.callback.await('mining:server:checkItems', false, cfg.inputItem, cfg.inputAmount) then
            Notify('Out of materials.', 'error'); break
        end
        -- pre-check inventory space for the output before starting the progress bar,
        -- so the player doesn't wait through the whole animation just to get nothing
        if not lib.callback.await('mining:server:canReceiveOutput', false, type) then
            Notify('Inventory full, cannot receive any output.', 'error'); break
        end

        if not startSession(type, auto, nil) then
            Notify('Could not start action.', 'error'); break
        end

        exports["morph_emote"]:EmoteCommandStart("parkingmeter", 0)
        local success = lib.progressBar({
            duration = duration,
            label = auto and string.format('%s (X to Stop)', label) or label,
            useWhileDead = false,
            canCancel = true,
            disable = { move = true, car = true, combat = true }
        })
        exports["morph_emote"]:EmoteCancel()
        if not success then isCancelled = true; break end

        TriggerServerEvent('hud:server:GainStress', stress)
        TriggerServerEvent(event) -- server rolls the actual reward and applies it
        total = total + 1
        if not auto then Notify('Completed successfully.', 'success'); break end
        Wait(1000) -- short gap between auto cycles
    until false

    -- covers both manual and auto cancels, previously manual cancels showed nothing
    if isCancelled then
        Notify(auto and 'Auto cancelled.' or 'Cancelled.', 'error')
    elseif auto and total > 0 then
        Notify(string.format('Auto completed. Total: %d', total), 'success')
    end
end

-- washing station target options
exports.morph_tget:addBoxZone({
    coords = Config.Washing.coords,
    size = vec3(5, 5, 5),
    options = {
        { label = 'Washing Stone', icon = 'fa-solid fa-hand', onSelect = function() ProcessAction(Config.Washing, false, 'wash') end },
        { label = 'Auto Washing Stone', icon = 'fa-solid fa-robot', onSelect = function() ProcessAction(Config.Washing, true, 'wash') end }
    }
})

-- ore smelter target options
exports.morph_tget:addBoxZone({
    coords = Config.Smelting.coords,
    size = vec3(5, 5, 5),
    options = {
        { label = 'Smelting Ore', icon = 'fa-solid fa-fire', onSelect = function() ProcessAction(Config.Smelting, false, 'smelt') end },
        { label = 'Auto Smelting Ore', icon = 'fa-solid fa-robot', onSelect = function() ProcessAction(Config.Smelting, true, 'smelt') end }
    }
})

-- gem smelter target option, only added if enabled in config (manual only, no auto)
if Config.GemSmelting.enabled then
    exports.morph_tget:addBoxZone({
        coords = Config.GemSmelting.coords,
        size = vec3(5, 5, 5),
        options = {
            { label = 'Smelting Gems', icon = 'fa-solid fa-gem', onSelect = function() ProcessAction(Config.GemSmelting, false, 'gems') end }
        }
    })
end

-- clean up rocks if the resource is stopped/restarted while a player is inside the zone
AddEventHandler('onResourceStop', function()
    ClearAllRocks()
end)

print('^2[Morph Mining] Client loaded^7')