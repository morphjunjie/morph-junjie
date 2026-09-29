-- client.lua

local Config = require 'morph_weed.config'
local props, minedSpots = {}, {}
local isInArea = false
local isHarvesting = false

local function Notify(desc, type) lib.notify({ title = 'Weed Farm', description = desc, type = type or 'info', duration = 3000 }) end
local function Progress(d, l) return lib.progressBar({ duration = d, label = l, canCancel = true, disable = { move = true, car = true, combat = true } }) end
local function Emote(n) exports["morph_emote"]:EmoteCommandStart(n, 0) end
local function EmoteCancel() exports["morph_emote"]:EmoteCancel() end

local function startSession(index)
    return lib.callback.await('weedfarm:server:startAction', false, index)
end

local function LoadModel(model)
    lib.requestModel(model, 5000)
    return model
end

local function DeleteProp(index)
    local prop = props[index]
    if prop and DoesEntityExist(prop) then
        exports.morph_tget:removeLocalEntity(prop, 'harvest_weed_' .. index)
        DeleteEntity(prop)
        props[index] = nil
    end
end

function SpawnProp(index)
    local pos = Config.Farm.spawnPoints[index]
    if not pos then return end
    if minedSpots[index] then return end
    if props[index] and DoesEntityExist(props[index]) then return end

    local model = LoadModel(Config.Farm.propModel)
    local obj = CreateObject(model, pos.x, pos.y, pos.z, false, false, false)
    if not obj or obj == 0 then return end
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
    if pos.w then SetEntityHeading(obj, pos.w) end

    props[index] = obj

    exports.morph_tget:addLocalEntity(obj, {
        {
            name = 'harvest_weed_' .. index,
            icon = 'fa-solid fa-cannabis',
            label = 'Harvest Weed',
            distance = Config.targetDistance,
            onSelect = function() HarvestWeed(index) end
        }
    })
end

local function SpawnAllProps()
    for i in ipairs(Config.Farm.spawnPoints) do
        if not minedSpots[i] and not props[i] then
            SpawnProp(i)
            Wait(800)
        end
    end
end

local function DespawnAllProps()
    for i in pairs(props) do
        DeleteProp(i)
    end
end

lib.zones.sphere({
    coords = Config.Farm.coords,
    radius = Config.Farm.inDistance,
    onEnter = function()
        if isInArea then return end
        isInArea = true
        SpawnAllProps()
    end,
    onExit = function()
        if not isInArea then return end
        isInArea = false
        DespawnAllProps()
    end
})

function HarvestWeed(index)
    if isHarvesting then return Notify('Already harvesting.', 'error') end
    local prop = props[index]
    if not prop or not DoesEntityExist(prop) then return Notify('Nothing to harvest here.', 'error') end

    local dist = #(GetEntityCoords(cache.ped) - GetEntityCoords(prop))
    if dist > Config.targetDistance then return Notify('Too far away.', 'warn') end

    if not lib.callback.await('weedfarm:server:canCarry', false, Config.Farm.rewardItem, Config.Farm.rewardMax) then
        return Notify('Your inventory is full', 'error')
    end

    local hasItemData = lib.callback.await('weedfarm:server:checkHarvestItem', false)
    if not hasItemData then return Notify('You need a weed scissors', 'warn') end

    local currentDur = hasItemData.durability or 100
    if currentDur <= 20 and currentDur > 0 then
        Notify(string.format('Scissors durability: %d%%', currentDur), 'warning')
    end
    if currentDur <= 0 then return Notify('Scissors broken', 'error') end

    if not lib.skillCheck(Config.Farm.skill, Config.Farm.keys) then
        return Notify('You messed up', 'error')
    end

    if not startSession(index) then
        return Notify('Could not start harvesting here.', 'error')
    end

    isHarvesting = true
    Emote("garden")
    TriggerServerEvent('hud:server:GainStress', Config.Farm.stressGain)
    local success = Progress(Config.Farm.progressTime, 'Harvesting weed...')
    EmoteCancel()
    isHarvesting = false

    if not success then return Notify('Harvest cancelled', 'error') end

    TriggerServerEvent('weedfarm:server:harvestReward', index, hasItemData.slot, hasItemData.durability)
    Notify('Weed harvested successfully', 'success')

    DeleteProp(index)
    minedSpots[index] = true

    SetTimeout(Config.Farm.respawnTime, function()
        if isInArea and minedSpots[index] then
            minedSpots[index] = nil
            SpawnProp(index)
        end
    end)
end

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() == res then DespawnAllProps() end
end)