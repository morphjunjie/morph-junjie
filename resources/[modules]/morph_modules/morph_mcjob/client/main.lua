local config = require 'morph_mcjob.config.client'
local sharedConfig = require 'morph_mcjob.config.shared'

VehicleStatus = {}
local plateZones, dutyTargetBoxId, stashTargetBoxId = {}, 'dutyTarget', 'stashTarget'

local function getVehicleStatusList(plate) return VehicleStatus[plate] end
local function getVehicleStatus(plate, part) return VehicleStatus[plate] and VehicleStatus[plate][part] end
local function setVehicleStatus(plate, part, level) TriggerServerEvent("vehiclemod:server:updatePart", plate, part, level) end
exports('GetVehicleStatusList', getVehicleStatusList); exports('GetVehicleStatus', getVehicleStatus); exports('SetVehicleStatus', setVehicleStatus)

local function deleteTarget(id)
    if config.useTarget then exports.morph_tget:removeZone(id)
    elseif config.targets[id]?.zone then config.targets[id].zone:remove() end
    config.targets[id] = nil
end

local function registerDutyTarget()
    if config.targets[dutyTargetBoxId]?.created or QBX.PlayerData.job.type ~= 'mechanic' then return end
    local coords, label = sharedConfig.locations.duty, QBX.PlayerData.job.onduty and locale('labels.sign_off') or locale('labels.sign_in')
    if config.useTarget then
        dutyTargetBoxId = exports.morph_tget:addBoxZone({ coords = coords, size = vec3(2.5,1.5,1), rotation = 338.16, debug = config.debugPoly, options = {{ label = label, name = dutyTargetBoxId, icon = 'fa fa-clipboard', distance = 2.0, serverEvent = "QBCore:ToggleDuty", canInteract = function() return QBX.PlayerData.job.type == 'mechanic' end }} })
        config.targets[dutyTargetBoxId] = {created = true}
    else
        config.targets[dutyTargetBoxId] = {created = true, zone = lib.zones.box({ coords = coords, size = vec3(1.5,2,2), rotation = 338.16, debug = config.debugPoly, inside = function() if QBX.PlayerData.job.onduty and IsControlJustPressed(0,38) then TriggerServerEvent("QBCore:ToggleDuty"); Wait(500) end end, onEnter = function() if QBX.PlayerData.job.onduty then lib.showTextUI("[E] " .. label, {position = 'left-center'}) end end, onExit = function() lib.hideTextUI() end }) }
    end
end

local function registerStashTarget()
    if config.targets[stashTargetBoxId]?.created or QBX.PlayerData.job.type ~= 'mechanic' then return end
    local coords = sharedConfig.locations.stash
    if config.useTarget then
        stashTargetBoxId = exports.morph_tget:addBoxZone({ coords = coords, size = vec3(1.5,1.0,2), rotation = 248.41, debug = config.debugPoly, options = {{ label = locale('labels.o_stash'), name = stashTargetBoxId, icon = 'fa fa-archive', distance = 2.0, event = "qb-mechanicjob:client:target:OpenStash", canInteract = function() return QBX.PlayerData.job.onduty and QBX.PlayerData.job.type == 'mechanic' end }} })
        config.targets[stashTargetBoxId] = {created = true}
    else
        config.targets[stashTargetBoxId] = {created = true, zone = lib.zones.box({ coords = coords, size = vec3(1.5,1.5,2), rotation = 248.41, debug = config.debugPoly, inside = function() if QBX.PlayerData.job.onduty and QBX.PlayerData.job.type == 'mechanic' and IsControlJustPressed(0,38) then TriggerEvent("qb-mechanicjob:client:target:OpenStash"); Wait(500) end end, onEnter = function() if QBX.PlayerData.job.onduty and QBX.PlayerData.job.type == 'mechanic' then lib.showTextUI(locale('labels.o_stash'), {position = 'left-center'}) end end, onExit = function() lib.hideTextUI() end }) }
    end
end

local function registerGarageZone()
    local coords, veh = sharedConfig.locations.vehicle, cache.vehicle
    lib.zones.box({ coords = coords.xyz, size = vec3(15,5,6), rotation = 340.0, debug = config.debugPoly, inside = function()
        if QBX.PlayerData.job.onduty and QBX.PlayerData.job.type == 'mechanic' and IsControlJustPressed(0,38) then
            if veh then DeleteVehicle(veh); lib.hideTextUI() else lib.showContext('mechanicVehicles'); lib.hideTextUI() end; Wait(500)
        end
    end, onEnter = function()
        if QBX.PlayerData.job.onduty and QBX.PlayerData.job.type == 'mechanic' then lib.showTextUI(cache.vehicle and locale('labels.h_vehicle') or locale('labels.g_vehicle'), {position = 'left-center'}) end
    end, onExit = function() lib.hideTextUI() end })
end

local closestPlate = nil

local function destroyVehiclePlateZone(id) if plateZones[id] then plateZones[id]:remove(); plateZones[id] = nil end end

local function registerVehiclePlateZone(id, plate)
    local coords, boxData = plate.coords, plate.boxData
    closestPlate = id
    plateZones[id] = lib.zones.box({ coords = coords.xyz, size = vec3(boxData.width, boxData.length, 4), rotation = boxData.heading, debug = boxData.debugPoly, inside = function()
        if not QBX.PlayerData.job.onduty then return end
        local veh = cache.vehicle
        if plate.AttachedVehicle then
            if IsControlJustPressed(0,38) then lib.hideTextUI(); lib.showContext('lift') end
        elseif IsControlJustPressed(0,38) and veh then
            DoScreenFadeOut(150); Wait(150)
            plate.AttachedVehicle = veh
            SetEntityCoords(veh, coords.x, coords.y, coords.z, false, false, false, false); SetEntityHeading(veh, coords.w); FreezeEntityPosition(veh, true)
            Wait(500); DoScreenFadeIn(150)
            TriggerServerEvent('qb-vehicletuning:server:SetAttachedVehicle', id, veh)
            destroyVehiclePlateZone(id); registerVehiclePlateZone(id, plate)
        end
    end, onEnter = function()
        if not QBX.PlayerData.job.onduty then return end
        lib.showTextUI(plate.AttachedVehicle and locale('labels.o_menu') or (cache.vehicle and locale('labels.work_v')), {position = 'left-center'})
    end, onExit = function() lib.hideTextUI() end })
end

local function setVehiclePlateZones()
    if #sharedConfig.plates == 0 then print('No vehicle plates configured'); return end
    for i = 1, #sharedConfig.plates do registerVehiclePlateZone(i, sharedConfig.plates[i]) end
end

local function sendStatusMessage(status)
    if not status then return end
    local template = '<div class="chat-message normal"><div class="chat-message-body"><strong>{0}:</strong><br><br> <strong>Engine:</strong> {1}<br><strong>Body:</strong> {2}<br><strong>Radiator:</strong> {3}<br><strong>Axle:</strong> {4}<br><strong>Brakes:</strong> {5}<br><strong>Clutch:</strong> {6}<br><strong>Fuel:</strong> {7}</div></div>'
    local max = sharedConfig.maxStatusValues
    local items = exports.morph_inv:Items()
    TriggerEvent('chat:addMessage', { template = template, args = { locale('labels.veh_status'),
        qbx.math.round(status.engine) .. "/" .. max.engine .. " ("..items.advancedrepairkit.label..")",
        qbx.math.round(status.body) .. "/" .. max.body .. " ("..items[sharedConfig.repairCost.body].label..")",
        qbx.math.round(status.radiator) .. "/" .. max.radiator .. ".0 ("..items[sharedConfig.repairCost.radiator].label..")",
        qbx.math.round(status.axle) .. "/" .. max.axle .. ".0 ("..items[sharedConfig.repairCost.axle].label..")",
        qbx.math.round(status.brakes) .. "/" .. max.brakes .. ".0 ("..items[sharedConfig.repairCost.brakes].label..")",
        qbx.math.round(status.clutch) .. "/" .. max.clutch .. ".0 ("..items[sharedConfig.repairCost.clutch].label..")",
        qbx.math.round(status.fuel) .. "/" .. max.fuel .. ".0 ("..items[sharedConfig.repairCost.fuel].label..")"
    } })
end

local function detachVehicle()
    DoScreenFadeOut(150); Wait(150)
    local plate = sharedConfig.plates[closestPlate]
    FreezeEntityPosition(plate.AttachedVehicle, false)
    SetEntityCoords(plate.AttachedVehicle, plate.coords.x, plate.coords.y, plate.coords.z, false, false, false, false); SetEntityHeading(plate.AttachedVehicle, plate.coords.w)
    TaskWarpPedIntoVehicle(cache.ped, plate.AttachedVehicle, -1)
    Wait(500); DoScreenFadeIn(250)
    plate.AttachedVehicle = nil
    TriggerServerEvent('qb-vehicletuning:server:SetAttachedVehicle', closestPlate, false)
    destroyVehiclePlateZone(closestPlate); registerVehiclePlateZone(closestPlate, plate)
end

local function checkStatus() sendStatusMessage(VehicleStatus[qbx.getVehiclePlate(sharedConfig.plates[closestPlate].AttachedVehicle)]) end

local function repairPart(part)
    if not lib.callback.await('morph_mcjob:server:checkForItems', false, part) then
        local item = sharedConfig.repairCostAmount[part]
        return exports.morph_junjie:Notify(locale('notifications.not_enough', exports.morph_inv:Items()[item.item].label, item.costs), 'error')
    end
    exports.morph_emote:playEmoteByCommand('mechanic')
    if lib.progressBar({ duration = math.random(5000,10000), label = locale('labels.progress_bar', string.lower(config.partLabels[part])), canCancel = true, disable = { move = true, car = true, combat = true, mouse = false } }) then
        exports.morph_emote:cancelEmote()
        local veh = sharedConfig.plates[closestPlate].AttachedVehicle
        local plate = qbx.getVehiclePlate(veh)
        if part == "engine" then SetVehicleEngineHealth(veh, sharedConfig.maxStatusValues[part]); TriggerServerEvent("vehiclemod:server:updatePart", plate, "engine", sharedConfig.maxStatusValues[part])
        elseif part == "body" then
            local enhealth, realFuel = GetVehicleEngineHealth(veh), GetVehicleFuelLevel(veh)
            SetVehicleBodyHealth(veh, sharedConfig.maxStatusValues[part]); TriggerServerEvent("vehiclemod:server:updatePart", plate, "body", sharedConfig.maxStatusValues[part])
            SetVehicleFixed(veh); SetVehicleEngineHealth(veh, enhealth)
            if GetVehicleFuelLevel(veh) ~= realFuel then SetVehicleFuelLevel(veh, realFuel) end
        else TriggerServerEvent("vehiclemod:server:updatePart", plate, part, sharedConfig.maxStatusValues[part]) end
        exports.morph_junjie:Notify(locale('notifications.partrep', config.partLabels[part]))
        Wait(250); OpenVehicleStatusMenu()
    else exports.morph_emote:cancelEmote(); exports.morph_junjie:Notify(locale('notifications.rep_canceled'), "error") end
end

local function openPartMenu(data)
    lib.registerContext({ id = 'part', title = locale('parts_menu.menu_header'), options = { { title = data.name, description = locale('parts_menu.repair_op', exports.morph_inv:Items()[sharedConfig.repairCostAmount[data.parts].item].label, sharedConfig.repairCostAmount[data.parts].costs), onSelect = function() repairPart(data.parts) end } }, menu = 'vehicleStatus' })
    lib.showContext('part')
end

function OpenVehicleStatusMenu()
    local plate = qbx.getVehiclePlate(sharedConfig.plates[closestPlate].AttachedVehicle)
    if not VehicleStatus[plate] then return end
    local options, max = {}, sharedConfig.maxStatusValues
    for partName, label in pairs(config.partLabels) do
        local val = VehicleStatus[plate][partName]
        local perc = math.ceil(val) > 100 and math.ceil(val) / 10 or math.ceil(val)
        options[#options+1] = { title = label, description = locale('parts_menu.status', perc), onSelect = function() openPartMenu({ name = label, parts = partName }) end, arrow = true }
    end
    lib.registerContext({ id = 'vehicleStatus', title = locale('labels.status'), options = options })
    lib.showContext('vehicleStatus')
end

local function resetClosestVehiclePlate() destroyVehiclePlateZone(closestPlate); registerVehiclePlateZone(closestPlate, sharedConfig.plates[closestPlate]) end

local function spawnListVehicle(model)
    local netId = lib.callback.await('morph_mcjob:server:spawnVehicle', false, model, sharedConfig.locations.vehicle, true)
    local timeout = 100
    while not NetworkDoesEntityExistWithNetworkId(netId) and timeout > 0 do Wait(10); timeout = timeout - 1 end
    local veh = NetworkGetEntityFromNetworkId(netId)
    SetVehicleNumberPlateText(veh, "MECH"..tostring(math.random(1000,9999))); SetVehicleFuelLevel(veh, 100.0)
    TaskWarpPedIntoVehicle(cache.ped, veh, -1); TriggerEvent("vehiclekeys:client:SetOwner", qbx.getVehiclePlate(veh)); SetVehicleEngineOn(veh, true, true, false)
end

-- Events
AddEventHandler('onResourceStart', function(res) if res ~= GetCurrentResourceName() then return end
    registerGarageZone(); registerDutyTarget(); registerStashTarget(); setVehiclePlateZones()
    if QBX.PlayerData.job.onduty and QBX.PlayerData.type == 'mechanic' then TriggerServerEvent("QBCore:ToggleDuty") end
    lib.callback('qb-vehicletuning:server:GetAttachedVehicle', false, function(plates) for k, v in pairs(plates) do sharedConfig.plates[k].AttachedVehicle = v.AttachedVehicle end end)
    lib.callback('qb-vehicletuning:server:GetDrivingDistances', false, function(retval) DrivingDistance = retval end)
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    registerGarageZone(); registerDutyTarget(); registerStashTarget(); setVehiclePlateZones()
    if QBX.PlayerData.job.onduty and QBX.PlayerData.type == 'mechanic' then TriggerServerEvent("QBCore:ToggleDuty") end
    lib.callback('qb-vehicletuning:server:GetAttachedVehicle', false, function(plates) for k, v in pairs(plates) do sharedConfig.plates[k].AttachedVehicle = v.AttachedVehicle end end)
    lib.callback('qb-vehicletuning:server:GetDrivingDistances', false, function(retval) DrivingDistance = retval end)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function()
    deleteTarget(dutyTargetBoxId); deleteTarget(stashTargetBoxId)
    if QBX.PlayerData.type ~= 'mechanic' then return end
    registerDutyTarget()
    if QBX.PlayerData.job.onduty then registerStashTarget() end
end)

RegisterNetEvent('QBCore:Client:SetDuty', function()
    deleteTarget(dutyTargetBoxId); deleteTarget(stashTargetBoxId)
    if QBX.PlayerData.type == 'mechanic' then registerDutyTarget(); if QBX.PlayerData.job.onduty then registerStashTarget() end end
end)

RegisterNetEvent('qb-vehicletuning:client:SetAttachedVehicle', function(veh, key) sharedConfig.plates[key].AttachedVehicle = veh end)
RegisterNetEvent('vehiclemod:client:setVehicleStatus', function(plate, status) VehicleStatus[plate] = status end)

RegisterNetEvent('vehiclemod:client:fixEverything', function()
    local veh = cache.vehicle
    if not veh then exports.morph_junjie:Notify(locale('notifications.not_vehicle'), "error"); return end
    if IsThisModelABicycle(GetEntityModel(veh)) or cache.seat ~= -1 then exports.morph_junjie:Notify(locale('notifications.wrong_seat'), "error"); return end
    TriggerServerEvent("vehiclemod:server:fixEverything", qbx.getVehiclePlate(veh))
end)

RegisterNetEvent('vehiclemod:client:setPartLevel', function(part, level)
    local veh = cache.vehicle
    if not veh then exports.morph_junjie:Notify(locale('notifications.not_vehicle'), "error"); return end
    if IsThisModelABicycle(GetEntityModel(veh)) or cache.seat ~= -1 then exports.morph_junjie:Notify(locale('notifications.wrong_seat'), "error"); return end
    local plate = qbx.getVehiclePlate(veh)
    if part == "engine" then SetVehicleEngineHealth(veh, level); TriggerServerEvent("vehiclemod:server:updatePart", plate, "engine", GetVehicleEngineHealth(veh))
    elseif part == "body" then SetVehicleBodyHealth(veh, level); TriggerServerEvent("vehiclemod:server:updatePart", plate, "body", GetVehicleBodyHealth(veh))
    else TriggerServerEvent("vehiclemod:server:updatePart", plate, part, level) end
end)

AddEventHandler('qb-mechanicjob:client:target:OpenStash', function() exports.morph_inv:openInventory('stash', {id = 'mechanicstash'}) end)

-- Static menus
local function registerLiftMenu()
    lib.registerContext({ id = 'lift', title = locale('lift_menu.header_menu'), onExit = resetClosestVehiclePlate, options = {
        { title = locale('lift_menu.header_vehdc'), description = locale('lift_menu.desc_vehdc'), onSelect = detachVehicle },
        { title = locale('lift_menu.header_stats'), description = locale('lift_menu.desc_stats'), onSelect = checkStatus },
        { title = locale('lift_menu.header_parts'), description = locale('lift_menu.desc_parts'), arrow = true, onSelect = OpenVehicleStatusMenu }
    } })
end

local function registerVehicleListMenu()
    local options = {}
    for k, v in pairs(config.vehicles) do options[#options+1] = { title = v, description = locale('labels.vehicle_title', v), onSelect = function() spawnListVehicle(k) end } end
    lib.registerContext({ id = 'mechanicVehicles', title = locale('labels.vehicle_list'), options = options })
end

registerLiftMenu(); registerVehicleListMenu()