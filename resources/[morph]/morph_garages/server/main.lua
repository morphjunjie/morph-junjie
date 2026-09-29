local logger = require '@morph_junjie.modules.logger'

assert(lib.checkDependency('morph_junjie', '1.19.0', true))
assert(lib.checkDependency('morph_vehicles', '1.3.1', true))
lib.versionCheck('Qbox-project/morph_garages')

---@class ErrorResult
---@field code string
---@field message string

---@class PlayerVehicle
---@field id number
---@field citizenid? string
---@field modelName string
---@field garage string
---@field state VehicleState
---@field depotPrice integer
---@field props table morph_ui properties table
---@field impound_release_at integer

Config = require 'config.server'
VEHICLES = exports.morph_junjie:GetVehiclesByName()
Storage = require 'server.storage'
---@type table<string, GarageConfig>
Garages = Config.garages

local ImpoundReleaseAt = {}

---@param vehicleId integer
function SetImpoundTimer(vehicleId)
    local waitSeconds = (Config.impoundWaitTime) * 60
    local releaseAt = os.time() + waitSeconds
    ImpoundReleaseAt[vehicleId] = releaseAt
    Storage.setImpoundRelease(vehicleId, releaseAt)
end

---@param vehicleId integer
function ClearImpoundTimer(vehicleId)
    ImpoundReleaseAt[vehicleId] = nil
    Storage.clearImpoundTimer(vehicleId)
end

---@param vehicleId integer
---@return integer secondsRemaining
function GetImpoundRemaining(vehicleId)
    local releaseAt = ImpoundReleaseAt[vehicleId]
    if not releaseAt then
        releaseAt = Storage.getImpoundRelease(vehicleId)
        if releaseAt then
            ImpoundReleaseAt[vehicleId] = releaseAt
        end
    end
    if not releaseAt then return 0 end
    local remaining = releaseAt - os.time()
    return remaining > 0 and remaining or 0
end

---@param seconds integer
---@return string
function FormatDuration(seconds)
    seconds = math.max(0, math.floor(seconds))
    local m = math.floor(seconds / 60)
    local s = seconds % 60
    return ('%02d:%02d'):format(m, s)
end

CreateThread(function()
    Wait(2000)
    local impoundedVehicles = Storage.getAllImpoundedVehicles()
    for _, vehicle in ipairs(impoundedVehicles) do
        if vehicle.impound_release_at and vehicle.impound_release_at > os.time() then
            ImpoundReleaseAt[vehicle.id] = vehicle.impound_release_at
        end
    end
    print(('^2[GARAGES] Restored %d impound timers from database^7'):format(#impoundedVehicles))
end)

lib.callback.register('morph_garages:server:getGarages', function()
    return Garages
end)

local function getGarages()
    return Garages
end
exports('GetGarages', getGarages)

---@param name string
---@param config GarageConfig
local function registerGarage(name, config)
    Garages[name] = config
    TriggerClientEvent('morph_garages:client:garageRegistered', -1, name, config)
    TriggerEvent('morph_garages:server:garageRegistered', name, config)
end

exports('RegisterGarage', registerGarage)

---@param vehicleId integer
---@param garageName string
---@return boolean success, ErrorResult?
local function setVehicleGarage(vehicleId, garageName)
    local garage = Garages[garageName]
    if not garage then
        return false, {
            code = 'not_found',
            message = string.format('garage name %s not found. Did you forget to register it?', garageName)
        }
    end

    local state = garage.type == GarageType.DEPOT and VehicleState.IMPOUNDED or VehicleState.GARAGED
    local numRowsAffected = Storage.setVehicleGarage(vehicleId, garageName, state)
    if numRowsAffected == 0 then
        return false, {
            code = 'no_rows_changed',
            message = string.format('no rows were changed for vehicleId=%s', vehicleId)
        }
    end

    if state == VehicleState.IMPOUNDED then
        SetImpoundTimer(vehicleId)
    end

    return true
end

exports('SetVehicleGarage', setVehicleGarage)

---@param vehicleId integer
---@param depotPrice integer
---@return boolean success, ErrorResult?
local function setVehicleDepotPrice(vehicleId, depotPrice)
    local numRowsAffected = Storage.setVehicleDepotPrice(vehicleId, depotPrice)
    if numRowsAffected == 0 then
        return false, {
            code = 'no_rows_changed',
            message = string.format('no rows were changed for vehicleId=%s', vehicleId)
        }
    end
    return true
end

exports('SetVehicleDepotPrice', setVehicleDepotPrice)

function FindPlateOnServer(plate)
    local vehicles = GetAllVehicles()
    for i = 1, #vehicles do
        if plate == GetVehicleNumberPlateText(vehicles[i]) then
            return true
        end
    end
end

---@param garage string
---@return GarageType?
function GetGarageType(garage)
    return Garages[garage]?.type
end

---@class PlayerVehiclesFilters
---@field citizenid? string
---@field states? VehicleState|VehicleState[]
---@field garage? string

---@param source number
---@param garageName string
---@return PlayerVehiclesFilters
function GetPlayerVehicleFilter(source, garageName)
    local player = exports.morph_junjie:GetPlayer(source)
    local garage = Garages[garageName]
    local filter = {}
    filter.citizenid = not garage.shared and player.PlayerData.citizenid or nil

    if garage.states then
        filter.states = garage.states
    elseif garage.type == GarageType.DEPOT then
        filter.states = { VehicleState.OUT, VehicleState.IMPOUNDED }
    else
        filter.states = VehicleState.GARAGED
    end

    filter.garage = not garage.skipGarageCheck and garageName or nil
    return filter
end

---@param source number
---@param garageName string
---@return GarageConfig?
function TryGetGarage(source, garageName)
    local garage = Garages[garageName]
    if garage then return garage end

    logger.log({
        source = source,
        event = 'error',
        message = string.format(
            'Attempted to spawn a vehicle from a non-existent garage: %s',
            garageName
        ),
        webhook = Config.logging.webhook.error,
        color = 'red'
    })
end

local function getCanAccessGarage(player, garage)
    if garage.groups and not exports.morph_junjie:HasPrimaryGroup(player.PlayerData.source, garage.groups) then
        return false
    end
    if garage.canAccess ~= nil and not garage.canAccess(player.PlayerData.source) then
        return false
    end
    return true
end

---@param playerVehicle PlayerVehicle
---@return VehicleType
local function getVehicleType(playerVehicle)
    if VEHICLES[playerVehicle.modelName].category == 'helicopters' or VEHICLES[playerVehicle.modelName].category == 'planes' then
        return VehicleType.AIR
    elseif VEHICLES[playerVehicle.modelName].category == 'boats' then
        return VehicleType.SEA
    else
        return VehicleType.CAR
    end
end

---@param source number
---@param garageName string
---@return PlayerVehicle[]?
lib.callback.register('morph_garages:server:getGarageVehicles', function(source, garageName)
    local player = exports.morph_junjie:GetPlayer(source)
    local garage = TryGetGarage(source, garageName)
    if not garage then return end
    if not getCanAccessGarage(player, garage) then return end
    local filter = GetPlayerVehicleFilter(source, garageName)
    local playerVehicles = exports.morph_vehicles:GetPlayerVehicles(filter)
    local toSend = {}
    if not playerVehicles[1] then return end

    local vehicleType = garage.vehicleType
    for _, vehicle in pairs(playerVehicles) do
        if not FindPlateOnServer(vehicle.props.plate) then
            if vehicleType == getVehicleType(vehicle) then
                OverrideFreeDepotPriceForOutVehicle(vehicle)
                vehicle.impoundRemaining = GetImpoundRemaining(vehicle.id)
                toSend[#toSend + 1] = vehicle
            end
        end
    end
    return toSend
end)

---@param source number
---@param vehicleId string
---@param garageName string
---@return boolean
local function isParkable(source, vehicleId, garageName)
    local garageType = GetGarageType(garageName)
    if garageType == GarageType.DEPOT then return false end
    if not vehicleId then return false end
    local player = exports.morph_junjie:GetPlayer(source)
    local garage = Garages[garageName]
    if not getCanAccessGarage(player, garage) then
        return false
    end
    ---@type PlayerVehicle
    local playerVehicle = exports.morph_vehicles:GetPlayerVehicle(vehicleId)
    if getVehicleType(playerVehicle) ~= garage.vehicleType then
        return false
    end
    if not garage.shared then
        if playerVehicle.citizenid ~= player.PlayerData.citizenid then
            return false
        end
    end
    return true
end

lib.callback.register('morph_garages:server:isParkable', function(source, garage, netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    local vehicleId = Entity(vehicle).state.vehicleid or exports.morph_vehicles:GetVehicleIdByPlate(GetVehicleNumberPlateText(vehicle))
    return isParkable(source, vehicleId, garage)
end)

---@param source number
---@param netId number
---@param props table
---@param garage string
lib.callback.register('morph_garages:server:parkVehicle', function(source, netId, props, garage)
    assert(Garages[garage] ~= nil, string.format('Garage %s not found. Did you register this garage?', garage))
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    local vehicleId = Entity(vehicle).state.vehicleid or exports.morph_vehicles:GetVehicleIdByPlate(GetVehicleNumberPlateText(vehicle))
    local owned = isParkable(source, vehicleId, garage)
    if not owned then
        exports.morph_junjie:Notify(source, locale('error.not_owned'), 'error')
        return
    end

    exports.morph_vehicles:SaveVehicle(vehicle, {
        garage = garage,
        state = VehicleState.GARAGED,
        props = props
    })

    ClearImpoundTimer(vehicleId)
    exports.morph_junjie:DeleteVehicle(vehicle)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= cache.resource then return end
    Wait(100)
    if Config.autoRespawn then
        Storage.moveOutVehiclesIntoGarages()
    end
end)