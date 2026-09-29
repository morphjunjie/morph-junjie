-- client.lua
local Config = require 'morph_oilmining.config' -- ganti nama folder
local isInArea = false
local pumps = {}
local minedPumps = {}
local isMining = false

local MineOil
local SpawnPump

local busyCategories, categoryIndexes = {}, {}
local function getNextCategoryId() for i = 76, 77 do if not categoryIndexes[i] then categoryIndexes[i] = true; return i end end end
local function setBlipCategory(blip, name) local id = busyCategories[name] or getNextCategoryId() if not id then return end if not busyCategories[name] then busyCategories[name] = id; AddTextEntry("BLIP_CAT_" .. id, name) end SetBlipCategory(blip, id) end
exports('setBlipCategory', setBlipCategory)

local function CreateBlips()
    for _, data in ipairs(Config.Blips) do
        local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
        SetBlipSprite(blip, data.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, data.scale)
        SetBlipColour(blip, data.colour)
        SetBlipAsShortRange(blip, true)
        setBlipCategory(blip, "Morph Oil Mining")
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(data.name)
        EndTextCommandSetBlipName(blip)
    end
end

CreateThread(function() Wait(500) CreateBlips() end)

local function Notify(desc, type)
    lib.notify({ title = 'Oil Mining Job', description = desc, type = type or 'info', duration = 3000 })
end

local function startSession(actionType, isAuto, index)
    return lib.callback.await('oilmining:server:startAction', false, actionType, isAuto, index)
end

local function GetGroundPosition(coords)
    local found, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 100.0, 0)
    return found and groundZ > -1000 and vec3(coords.x, coords.y, groundZ + 0.02) or vec3(coords.x, coords.y, coords.z + 0.5)
end

local function LoadModel(model)
    lib.requestModel(model, 5000)
    return model
end

local function DeletePump(index)
    if pumps[index] and DoesEntityExist(pumps[index]) then
        exports.morph_tget:removeLocalEntity(pumps[index], 'oil_pump_' .. index)
        DeleteEntity(pumps[index])
        pumps[index] = nil
    end
end

local function RespawnPump(index)
    local pos = Config.OilPump.spawnPoints[index]
    SetTimeout(Config.OilPump.respawnTime, function()
        if isInArea and minedPumps[index] then
            minedPumps[index] = nil
            SpawnPump(index, pos)
        end
    end)
end

function SpawnPump(index, pos)
    if minedPumps[index] then return end
    if pumps[index] and DoesEntityExist(pumps[index]) then return end
    local model = LoadModel(Config.OilPump.pumpModel)
    local groundPos = GetGroundPosition(pos)
    local obj = CreateObject(model, groundPos.x, groundPos.y, groundPos.z, false, false, false)
    if not obj or obj == 0 then return end
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
    if pos.w then SetEntityHeading(obj, pos.w) end
    pumps[index] = obj
    exports.morph_tget:addLocalEntity(obj, {
        {
            name = 'oil_pump_' .. index,
            label = 'Oil Pump',
            icon = 'fa-solid fa-oil-well',
            distance = Config.targetDistance,
            onSelect = function() MineOil(index) end
        }
    })
end

local function SpawnAllPumps()
    for i, pos in ipairs(Config.OilPump.spawnPoints) do
        if not minedPumps[i] and not pumps[i] then
            SpawnPump(i, pos)
            Wait(1500)
        end
    end
end

local function ClearAllPumps()
    for i in pairs(pumps) do DeletePump(i) end
    pumps = {}
end

function MineOil(index)
    if isMining then return Notify('Already mining.', 'error') end
    if minedPumps[index] then return Notify('Oil pump already depleted.', 'error') end
    if not pumps[index] or not DoesEntityExist(pumps[index]) then return Notify('Oil pump not found.', 'error') end
    local dist = #(GetEntityCoords(cache.ped) - GetEntityCoords(pumps[index]))
    if dist > Config.targetDistance then return Notify('Too far from pump.', 'warn') end

    local wrench = lib.callback.await('oilmining:server:checkWrench', false)
    if not wrench or not wrench.has then return Notify('Need a wrench.', 'error') end
    if wrench.durability <= 20 and wrench.durability > 0 then Notify('Wrench durability: ' .. wrench.durability .. '%', 'warning') end
    if wrench.durability <= 0 then return Notify('Wrench is broken.', 'error') end
    if not lib.callback.await('oilmining:server:canCarry', false, Config.Items.crudeOil, Config.OilPump.maxOil) then return Notify('Inventory full.', 'error') end

    if not startSession('mine', false, index) then
        return Notify('Could not start mining here.', 'error')
    end

    isMining = true
    exports["morph_emote"]:EmoteCommandStart("mechanic", 0)
    local success = lib.progressBar({
        duration = Config.OilPump.progressTime,
        label = 'Extracting Oil...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true }
    })
    exports["morph_emote"]:EmoteCancel()
    isMining = false

    if not success then return Notify('Cancelled.', 'error') end
    TriggerServerEvent('hud:server:GainStress', Config.OilPump.stressGain)
    DeletePump(index)
    minedPumps[index] = true
    RespawnPump(index)
    TriggerServerEvent('oilmining:server:mineOil', index, wrench.slot, wrench.durability)
    Notify('Oil extracted successfully!', 'success')
end

lib.zones.sphere({
    coords = Config.OilPump.coords,
    radius = Config.OilPump.inDistance,
    onEnter = function()
        if isInArea then return end
        isInArea = true
        SpawnAllPumps()
    end,
    onExit = function()
        if not isInArea then return end
        isInArea = false
        ClearAllPumps()
    end
})

local function ProcessAction(cfg, auto, type)
    local plyCoords = GetEntityCoords(cache.ped)
    if #(plyCoords - cfg.coords) > 5.0 then return Notify('Too far from area.', 'warn') end
    if not lib.callback.await('oilmining:server:checkItems', false, cfg.inputItem, cfg.inputAmount) then
        return Notify(string.format('Need %d %s.', cfg.inputAmount, cfg.inputItem:gsub('_', ' ')), 'error')
    end
    if not lib.callback.await('oilmining:server:canCarry', false, cfg.outputItem, cfg.outputAmount) then
        return Notify('Inventory full.', 'error')
    end

    local total, isCancelled = 0, false
    local duration = auto and (type == 'oil' and Config.AutoProcessOil.duration or Config.AutoProcessBarrel.duration) or cfg.progressTime
    local stress = auto and (type == 'oil' and Config.AutoProcessOil.stressGain or Config.AutoProcessBarrel.stressGain) or cfg.stressGain
    local label = auto and (type == 'oil' and Config.AutoProcessOil.label or Config.AutoProcessBarrel.label) or cfg.label
    local event = type == 'oil' and 'oilmining:server:processOil' or 'oilmining:server:processBarrel'

    if auto then Notify('Auto started.', 'success') end

    repeat
        local current = exports.morph_inv:GetItemCount(cfg.outputItem)
        if current >= 500 then Notify('Inventory full.', 'error'); break end
        if #(GetEntityCoords(cache.ped) - cfg.coords) > 5.0 then Notify('Moved too far.', 'warn'); break end
        if not lib.callback.await('oilmining:server:checkItems', false, cfg.inputItem, cfg.inputAmount) then
            Notify('Out of materials.', 'error'); break
        end

        -- FIX: re-check kapasitas beneran (berat/slot) tiap putaran, bukan
        -- cuma sekali sebelum loop. Sebelumnya kalau inventory penuh gara-
        -- gara berat/slot (bukan stack outputItem nyampe 500), auto job
        -- ga pernah berhenti sendiri.
        if not lib.callback.await('oilmining:server:canCarry', false, cfg.outputItem, cfg.outputAmount) then
            Notify('Inventory full.', 'error'); break
        end

        if not startSession(type, auto, nil) then
            Notify('Could not start action.', 'error'); break
        end

        exports["morph_emote"]:EmoteCommandStart("mechanic", 0)
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
        TriggerServerEvent(event)
        total = total + 1
        if not auto then Notify('Completed successfully.', 'success'); break end
        Wait(1500)
    until false

    if auto and total > 0 and not isCancelled then
        Notify(string.format('Auto completed. Total: %d', total), 'success')
    elseif isCancelled and auto then
        Notify('Auto cancelled.', 'error')
    end
end

exports.morph_tget:addBoxZone({
    coords = Config.ProcessOil.coords,
    size = vec3(6, 6, 6),
    options = {
        { label = 'Processing Crude Oil', icon = 'fa-solid fa-hand', onSelect = function() ProcessAction(Config.ProcessOil, false, 'oil') end },
        { label = 'Auto Processing Oil', icon = 'fa-solid fa-robot', onSelect = function() ProcessAction(Config.ProcessOil, true, 'oil') end }
    }
})

exports.morph_tget:addBoxZone({
    coords = Config.ProcessBarrel.coords,
    size = vec3(4, 4, 4),
    options = {
        { label = 'Packing Oil Barrels', icon = 'fa-solid fa-hand', onSelect = function() ProcessAction(Config.ProcessBarrel, false, 'barrel') end },
        { label = 'Auto Packing Barrels', icon = 'fa-solid fa-robot', onSelect = function() ProcessAction(Config.ProcessBarrel, true, 'barrel') end }
    }
})

AddEventHandler('onResourceStop', function()
    ClearAllPumps()
end)