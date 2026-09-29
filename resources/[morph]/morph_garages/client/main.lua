local config = require 'config.client'
if not config.enableClient then return end
local VEHICLES = exports.morph_junjie:GetVehiclesByName()

---@enum ProgressColor
local ProgressColor = {
    GREEN = 'green.5',
    YELLOW = 'yellow.5',
    RED = 'red.5'
}

---@param percent number
---@return string
local function getProgressColor(percent)
    if percent >= 75 then
        return ProgressColor.GREEN
    elseif percent > 25 then
        return ProgressColor.YELLOW
    else
        return ProgressColor.RED
    end
end

---@param seconds number
---@return string
local function formatMMSS(seconds)
    seconds = math.max(0, math.floor(seconds))
    local m = math.floor(seconds / 60)
    local s = seconds % 60
    return ('%02d:%02d'):format(m, s)
end

local VehicleCategory = {
    all = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22},
    car = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 17, 18, 19, 20, 22},
    air = {15, 16},
    sea = {14},
}

---@param category VehicleType
---@param vehicle number
---@return boolean
local function isOfType(category, vehicle)
    local classSet = {}

    for _, class in pairs(VehicleCategory[category]) do
        classSet[class] = true
    end

    return classSet[GetVehicleClass(vehicle)] == true
end

---@param vehicle number
local function kickOutPeds(vehicle)
    for i = -1, 5, 1 do
        local seat = GetPedInVehicleSeat(vehicle, i)
        if seat then
            TaskLeaveVehicle(seat, vehicle, 0)
        end
    end
end

local spawnLock = false

---@param vehicleId number
---@param garageName string
---@param accessPoint integer
local function takeOutOfGarage(vehicleId, garageName, accessPoint)
    if spawnLock then
        exports.morph_junjie:Notify(locale('error.spawn_in_progress'), 'error')
        return
    end
    spawnLock = true

    local success, result = pcall(function()
        if cache.vehicle then
            exports.morph_junjie:Notify(locale('error.in_vehicle'), 'error')
            return
        end

        local netId = lib.callback.await('morph_garages:server:spawnVehicle', false, vehicleId, garageName, accessPoint)
        if not netId then return end

        local veh = lib.waitFor(function()
            if NetworkDoesEntityExistWithNetworkId(netId) then
                return NetToVeh(netId)
            end
        end)

        if veh == 0 then
            exports.morph_junjie:Notify(locale('error.spawn_failed'), 'error')
            return
        end

        if config.engineOn then
            SetVehicleEngineOn(veh, true, true, false)
        end
    end)
    spawnLock = false
    assert(success, result)
end

---@param vehicle PlayerVehicle
---@param garageName string
---@param garageInfo GarageConfig
---@param accessPoint integer
local function displayVehicleInfo(vehicle, garageName, garageInfo, accessPoint)
    local engine = qbx.math.round(vehicle.props.engineHealth / 10)
    local body = qbx.math.round(vehicle.props.bodyHealth / 10)
    local engineColor = getProgressColor(engine)
    local bodyColor = getProgressColor(body)
    local fuelColor = getProgressColor(vehicle.props.fuelLevel)
    local vehicleLabel = ('%s %s'):format(VEHICLES[vehicle.modelName].brand, VEHICLES[vehicle.modelName].name)
    local impoundRemaining = vehicle.impoundRemaining or 0

    local options = {
        {
            title = locale('menu.information'),
            icon = 'circle-info',
            description = locale('menu.description', vehicleLabel, vehicle.props.plate, lib.math.groupdigits(vehicle.depotPrice)),
            readOnly = true,
        },
    }

    if garageInfo.type == GarageType.DEPOT and impoundRemaining > 0 then
        options[#options + 1] = {
            title = locale('menu.time_remaining'),
            icon = 'clock',
            description = locale('menu.time_remaining_desc', formatMMSS(impoundRemaining)),
            readOnly = true,
        }
    end

    options[#options + 1] = {
        title = locale('menu.body'),
        icon = 'car-side',
        readOnly = true,
        progress = body,
        colorScheme = bodyColor,
    }
    options[#options + 1] = {
        title = locale('menu.engine'),
        icon = 'oil-can',
        readOnly = true,
        progress = engine,
        colorScheme = engineColor,
    }
    options[#options + 1] = {
        title = locale('menu.fuel'),
        icon = 'gas-pump',
        readOnly = true,
        progress = vehicle.props.fuelLevel,
        colorScheme = fuelColor,
    }

    if vehicle.state == VehicleState.OUT then
        if garageInfo.type == GarageType.DEPOT then
            if impoundRemaining > 0 then
                options[#options + 1] = {
                    title = locale('menu.impound_locked'),
                    icon = 'lock',
                    description = formatMMSS(impoundRemaining),
                    readOnly = true,
                }
            else
                options[#options + 1] = {
                    title = 'Take out',
                    icon = 'fa-truck-ramp-box',
                    description = ('$%s'):format(lib.math.groupdigits(vehicle.depotPrice)),
                    arrow = true,
                    onSelect = function()
                        takeOutOfGarage(vehicle.id, garageName, accessPoint)
                    end,
                }
            end
        else
            options[#options + 1] = {
                title = 'Your vehicle is already out...',
                icon = VehicleType.CAR,
                readOnly = true,
            }
        end
    elseif vehicle.state == VehicleState.GARAGED then
        options[#options + 1] = {
            title = locale('menu.take_out'),
            icon = 'car-rear',
            arrow = true,
            onSelect = function()
                takeOutOfGarage(vehicle.id, garageName, accessPoint)
            end,
        }
    elseif vehicle.state == VehicleState.IMPOUNDED then
        if impoundRemaining > 0 then
            options[#options + 1] = {
                title = locale('menu.impound_locked'),
                icon = 'lock',
                description = formatMMSS(impoundRemaining),
                readOnly = true,
            }
        else
            options[#options + 1] = {
                title = locale('menu.veh_impounded'),
                icon = 'building-shield',
                description = ('$%s'):format(lib.math.groupdigits(vehicle.depotPrice)),
                arrow = true,
                onSelect = function()
                    takeOutOfGarage(vehicle.id, garageName, accessPoint)
                end,
            }
        end
    end

    lib.registerContext({
        id = 'vehicleList',
        title = garageInfo.label,
        menu = 'garageMenu',
        options = options,
    })

    lib.showContext('vehicleList')
end

---@param garageName string
---@param garageInfo GarageConfig
---@param accessPoint integer
local function openGarageMenu(garageName, garageInfo, accessPoint)
    ---@type PlayerVehicle[]?
    local vehicleEntities = lib.callback.await('morph_garages:server:getGarageVehicles', false, garageName)

    if not vehicleEntities or #vehicleEntities == 0 then
        if garageInfo.type == GarageType.DEPOT then
            exports.morph_junjie:Notify(locale('error.not_impound'), 'error')
        else
            exports.morph_junjie:Notify(locale('error.no_vehicles'), 'error')
        end
        return
    end

    table.sort(vehicleEntities, function(a, b)
        return a.modelName < b.modelName
    end)

    local options = {}
    for i = 1, #vehicleEntities do
        local vehicleEntity = vehicleEntities[i]
        local vehicleLabel = ('%s %s'):format(VEHICLES[vehicleEntity.modelName].brand, VEHICLES[vehicleEntity.modelName].name)

        options[#options + 1] = {
            title = vehicleLabel,
            description = vehicleEntity.props.plate,
            arrow = true,
            onSelect = function()
                displayVehicleInfo(vehicleEntity, garageName, garageInfo, accessPoint)
            end,
        }
    end

    lib.registerContext({
        id = 'garageMenu',
        title = garageInfo.label,
        options = options,
    })

    lib.showContext('garageMenu')
end

---@param vehicle number
---@param garageName string
local function parkVehicle(vehicle, garageName)
    if GetVehicleNumberOfPassengers(vehicle) ~= 1 then
        local isParkable = lib.callback.await('morph_garages:server:isParkable', false, garageName, NetworkGetNetworkIdFromEntity(vehicle))

        if not isParkable then
            exports.morph_junjie:Notify(locale('error.not_owned'), 'error', 5000)
            return
        end

        kickOutPeds(vehicle)
        SetVehicleDoorsLocked(vehicle, 2)
        Wait(1500)
        lib.callback.await('morph_garages:server:parkVehicle', false, NetworkGetNetworkIdFromEntity(vehicle), lib.getVehicleProperties(vehicle), garageName)
        exports.morph_junjie:Notify(locale('success.vehicle_parked'), 'primary', 4500)
    else
        exports.morph_junjie:Notify(locale('error.vehicle_occupied'), 'error', 3500)
    end
end

---@param garage GarageConfig
---@return boolean
local function checkCanAccess(garage)
    if garage.groups and not exports.morph_junjie:HasPrimaryGroup(garage.groups, QBX.PlayerData) then
        exports.morph_junjie:Notify(locale('error.no_access'), 'error')
        return false
    end
    if cache.vehicle and not isOfType(garage.vehicleType, cache.vehicle) then
        exports.morph_junjie:Notify(locale('error.not_correct_type'), 'error')
        return false
    end
    return true
end

---@param garage GarageConfig
---@param coords vector3
---@return integer
local function getNearestAccessPoint(garage, coords)
    local nearestIndex, nearestDist = 1, nil
    local accessPoints = garage.accessPoints or {}

    for i = 1, #accessPoints do
        local apCoords = accessPoints[i].coords
        local dist = #(coords - vec3(apCoords.x, apCoords.y, apCoords.z))
        if not nearestDist or dist < nearestDist then
            nearestDist = dist
            nearestIndex = i
        end
    end

    return nearestIndex
end

---@param garageName string
---@param garage GarageConfig
local function createZone(garageName, garage)
    local gz = garage.garageZone
    if not gz then return end

    CreateThread(function()
        local zId = garageName .. '_zone'

        local zone
        if gz.points then
            zone = morph_zone:Create(gz.points, {
                name = zId,
                minZ = gz.minZ or 0.0,
                maxZ = gz.maxZ or 100.0,
                debugPoly = config.debugPoly,
            })
        else
            zone = BoxZone:Create(vec3(gz.coords.x, gz.coords.y, gz.coords.z), gz.length, gz.width, {
                name = zId,
                heading = gz.heading or 0.0,
                minZ = gz.minZ,
                maxZ = gz.maxZ,
                debugPoly = config.debugPoly,
            })
        end

        if not zone then return end
        Zones = Zones or {}
        Zones[zId] = zone

        zone:onPlayerInOut(function(isInside)
            if not isInside then
                lib.hideTextUI()
                return
            end

            local last, cooldown = nil, 0

            local function refresh(isInVeh)
                if isInVeh == last or GetGameTimer() < cooldown then return end
                last = isInVeh

                local label
                local icon
                
                if isInVeh then
                    label = locale('info.park_e')
                    icon = 'fa-solid fa-parking'  -- Ganti ke fa-solid
                elseif garage.type == GarageType.DEPOT then
                    label = locale('info.impound_e')
                    icon = 'fa-solid fa-triangle-exclamation'  -- Ganti icon
                else
                    label = locale('info.car_e')
                    icon = 'fa-solid fa-car'
                end

                lib.showTextUI(label, {
                    icon = icon,
                    position = 'left-center',
                })
            end

            while zone:isPointInside(GetEntityCoords(cache.ped)) do
                local currentVeh = GetVehiclePedIsIn(cache.ped, false)
                local isInVeh = currentVeh ~= 0 and garage.type ~= GarageType.DEPOT
                refresh(isInVeh)

                if IsControlJustReleased(0, 38) then
                    if checkCanAccess(garage) then
                        if isInVeh then
                            parkVehicle(currentVeh, garageName)
                            Wait(100)
                            refresh(false)
                        else
                            local apIndex = getNearestAccessPoint(garage, GetEntityCoords(cache.ped))
                            openGarageMenu(garageName, garage, apIndex)
                            cooldown = GetGameTimer() + 4000
                            lib.hideTextUI()
                            last = nil
                        end
                    else
                        lib.hideTextUI()
                    end
                end
                Wait(0)
            end

            lib.hideTextUI()
            last = nil
        end)
    end)
end

local busyCategories = {}
local categoryIndexes = {}

local function getNextCategoryId()
    for i = 52, 53 do
        if not categoryIndexes[i] then
            categoryIndexes[i] = true
            return i
        end
    end
end

---@param blip number
---@param categoryName string
local function setBlipCategory(blip, categoryName)
    local categoryId = busyCategories[categoryName]
    if not categoryId then
        categoryId = getNextCategoryId()
        if not categoryId then print("No available category IDs left."); return end
        busyCategories[categoryName] = categoryId
        AddTextEntry("BLIP_CAT_" .. categoryId, categoryName)
    end
    SetBlipCategory(blip, categoryId)
end

exports('setBlipCategory', setBlipCategory)

---@param garageInfo GarageConfig
---@param accessPoint AccessPoint
local function createBlips(garageInfo, accessPoint)
    local blip = AddBlipForCoord(accessPoint.coords.x, accessPoint.coords.y, accessPoint.coords.z)
    local isDepot = garageInfo.type == GarageType.DEPOT
    local sprite = accessPoint.blip.sprite or (isDepot and 527 or 357)
    local color = accessPoint.blip.color or (isDepot and 1 or 5)
    SetBlipSprite(blip, sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, isDepot and 0.7 or 0.60)
    SetBlipAsShortRange(blip, true)
    setBlipCategory(blip, isDepot and "Morph Impound" or "Morph Garage")
    SetBlipColour(blip, color)
    local blipName = accessPoint.blip.name or garageInfo.label
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(blipName)
    EndTextCommandSetBlipName(blip)
end

local function createGarage(name, garage)
    local accessPoints = garage.accessPoints or {}
    if #accessPoints == 0 then
        print("Warning: garage " .. name .. " no accessPoints")
        return
    end

    createZone(name, garage)

    for i = 1, #accessPoints do
        local accessPoint = accessPoints[i]
        accessPoint.index = i

        if accessPoint.blip then
            createBlips(garage, accessPoint)
        end
    end
end

local function createGarages()
    local garages = lib.callback.await('morph_garages:server:getGarages')
    for name, garage in pairs(garages) do
        createGarage(name, garage)
    end
end

RegisterNetEvent('morph_garages:client:garageRegistered', function(name, garage)
    createGarage(name, garage)
end)

CreateThread(function()
    createGarages()
end)