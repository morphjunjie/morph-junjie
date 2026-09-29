-- client.lua

local Config = require 'morph_meth.config'
local isInArea = {}
local props, minedSpots = {}, {}
local isHarvesting = false

local function Notify(desc, type) lib.notify({ title = 'Meth Farm', description = desc, type = type or 'info', duration = 3000 }) end
local function formatItem(item) return item:gsub("_", " "):gsub("^%l", string.upper) end
local function Progress(d, l) return lib.progressBar({ duration = d, label = l, canCancel = true, disable = { move = true, car = true, combat = true } }) end

local function Emote(emoteName)
    if emoteName and emoteName ~= "" then
        exports["morph_emote"]:EmoteCommandStart(emoteName, 0)
    end
end

local function EmoteCancel()
    exports["morph_emote"]:EmoteCancel()
end

-- Minta izin/sesi ke server sebelum progress bar mulai. Server bakal
-- validasi ulang posisi & cooldown titik ini punya player ini, dan
-- nyimpen jam mulainya buat dicocokin lagi pas reward diklaim.
local function startSession(farmId, index)
    return lib.callback.await('meth:server:startAction', false, farmId, index)
end

local function LoadModel(model)
    lib.requestModel(model, 5000)
    return model
end

local function DeleteProp(farmId, index)
    local prop = props[farmId] and props[farmId][index]
    if prop and DoesEntityExist(prop) then
        exports.morph_tget:removeLocalEntity(prop, 'collect_' .. farmId .. '_' .. index)
        DeleteEntity(prop)
        props[farmId][index] = nil
    end
end

local function HarvestFarm(farmId, index)
    if isHarvesting then return Notify('Already collecting.', 'error') end
    local data = Config.Farm[farmId]
    local prop = props[farmId] and props[farmId][index]
    if not prop or not DoesEntityExist(prop) then return Notify('Nothing to collect here.', 'error') end

    local dist = #(GetEntityCoords(cache.ped) - GetEntityCoords(prop))
    if dist > Config.targetDistance then return Notify('Too far away.', 'warn') end

    if not lib.callback.await('meth:server:canCarry', false, data.item, data.amount.max) then
        return Notify('Inventory is full', 'error')
    end
    if not lib.skillCheck(data.skill, data.keys) then return Notify('You messed up', 'warn') end

    if not startSession(farmId, index) then
        return Notify('Could not collect here.', 'error')
    end

    isHarvesting = true
    Emote(data.emote)
    TriggerServerEvent(Config.Settings.StressEvent, data.stress)
    local success = Progress(data.duration, string.format('Collecting %s...', formatItem(data.item)))
    EmoteCancel()
    isHarvesting = false

    if not success then return Notify('Collection cancelled', 'error') end

    TriggerServerEvent('meth:server:collectReward', farmId, index)
    Notify(string.format('Collected %s', formatItem(data.item)), 'success')

    DeleteProp(farmId, index)
    minedSpots[farmId] = minedSpots[farmId] or {}
    minedSpots[farmId][index] = true

    SetTimeout(data.respawnTime, function()
        if isInArea[farmId] and minedSpots[farmId][index] then
            minedSpots[farmId][index] = nil
            SpawnProp(farmId, index)
        end
    end)
end

function SpawnProp(farmId, index)
    local data = Config.Farm[farmId]
    local pos = data.spawnPoints[index]
    if not pos then return end
    if minedSpots[farmId] and minedSpots[farmId][index] then return end
    if props[farmId] and props[farmId][index] and DoesEntityExist(props[farmId][index]) then return end

    local model = LoadModel(data.prop)
    local obj = CreateObject(model, pos.x, pos.y, pos.z, false, false, false)
    if not obj or obj == 0 then return end
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
    if pos.w then SetEntityHeading(obj, pos.w) end

    props[farmId] = props[farmId] or {}
    props[farmId][index] = obj

    exports.morph_tget:addLocalEntity(obj, {
        {
            name = 'collect_' .. farmId .. '_' .. index,
            label = data.label,
            icon = 'fas fa-flask',
            distance = Config.targetDistance,
            onSelect = function() HarvestFarm(farmId, index) end
        }
    })
end

local function SpawnAllProps(farmId)
    local data = Config.Farm[farmId]
    for i in ipairs(data.spawnPoints) do
        if not (minedSpots[farmId] and minedSpots[farmId][i]) and not (props[farmId] and props[farmId][i]) then
            SpawnProp(farmId, i)
            Wait(900)
        end
    end
end

local function DespawnAllProps(farmId)
    if not props[farmId] then return end
    for i in pairs(props[farmId]) do
        DeleteProp(farmId, i)
    end
end

CreateThread(function()
    Wait(500)
    for id, data in pairs(Config.Farm) do
        lib.zones.sphere({
            coords = data.coords,
            radius = data.inDistance,
            onEnter = function()
                if isInArea[id] then return end
                isInArea[id] = true
                SpawnAllProps(id)
            end,
            onExit = function()
                if not isInArea[id] then return end
                isInArea[id] = false
                DespawnAllProps(id)
            end
        })
    end
end)

AddEventHandler('onResourceStop', function(name)
    if GetCurrentResourceName() ~= name then return end
    for id in pairs(Config.Farm) do DespawnAllProps(id) end
end)