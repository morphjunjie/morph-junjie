local logger = require '@morph_junjie.modules.logger'

---@param vehicleId integer
---@param modelName string
local function setVehicleStateToOut(vehicleId, vehicle, modelName)
    local depotPrice = Config.calculateImpoundFee(vehicleId, modelName) or 0
    exports.morph_vehicles:SaveVehicle(vehicle, {
        state = VehicleState.OUT,
        depotPrice = depotPrice
    })
    SetImpoundTimer(vehicleId)
end

---@param player table
---@param depotPrice integer
local function payDepotPrice(player, depotPrice)
    local cashBalance = player.PlayerData.money.cash
    local bankBalance = player.PlayerData.money.bank

    if cashBalance >= depotPrice then
        player.Functions.RemoveMoney('cash', depotPrice, 'paid-depot')
        return true
    elseif bankBalance >= depotPrice then
        player.Functions.RemoveMoney('bank', depotPrice, 'paid-depot')
        return true
    end
    return false
end

---@param point vector3|vector4
---@param points vector3[]
---@return boolean
local function isPointInPoly(point, points)
    local inside = false
    local n = #points
    local j = n

    for i = 1, n do
        local pi, pj = points[i], points[j]
        if ((pi.y > point.y) ~= (pj.y > point.y)) and
            (point.x < (pj.x - pi.x) * (point.y - pi.y) / (pj.y - pi.y) + pi.x) then
            inside = not inside
        end
        j = i
    end

    return inside
end

---@param source number
---@param garage GarageConfig
---@param accessPoint AccessPoint
---@return boolean
local function isPlayerNearGarage(source, garage, accessPoint)
    local playerCoords = GetEntityCoords(GetPlayerPed(source))

    local gz = garage.garageZone
    if gz then
        local minZ = gz.minZ or -math.huge
        local maxZ = gz.maxZ or math.huge

        if playerCoords.z < minZ - 1.0 or playerCoords.z > maxZ + 1.0 then
            return false
        end

        if gz.points then
            return isPointInPoly(playerCoords, gz.points)
        elseif gz.coords then
            local maxDim = math.max(gz.length or 10.0, gz.width or 10.0)
            local dist = #(playerCoords - vec3(gz.coords.x, gz.coords.y, gz.coords.z))
            return dist <= maxDim
        end
    end

    local dist = #(playerCoords - accessPoint.coords.xyz)
    return dist <= 3.0
end

---@param coords vector3
---@param radius number
---@return boolean
local function isSpawnPositionClear(coords, radius)
    radius = radius or 2.0
    
    local players = GetPlayers()
    for _, src in ipairs(players) do
        local ped = GetPlayerPed(src)
        if ped and DoesEntityExist(ped) then
            local pedCoords = GetEntityCoords(ped)
            if #(coords - pedCoords) < radius then
                return false
            end
        end
    end
    
    local vehicles = GetAllVehicles()
    for _, veh in ipairs(vehicles) do
        if veh and DoesEntityExist(veh) then
            local vehCoords = GetEntityCoords(veh)
            if #(coords - vehCoords) < radius then
                return false
            end
        end
    end
    
    return true
end

---@param source number
---@param vehicleId integer
---@param garageName string
---@param accessPointIndex integer
---@return number? netId
lib.callback.register('morph_garages:server:spawnVehicle', function (source, vehicleId, garageName, accessPointIndex)
    local garage = TryGetGarage(source, garageName)
    if not garage then return end

    local accessPoint = garage.accessPoints[accessPointIndex]
    if not accessPoint then
        logger.log({
            source = source,
            message = string.format(
                'Attempted to spawn a vehicle from a non-existent access point index: %d for garage: %s',
                accessPointIndex,
                garageName
            ),
            webhook = Config.logging.webhook.error,
            event = 'error',
            color = 'red'
        })
        return
    end

    if not isPlayerNearGarage(source, garage, accessPoint) then
        logger.log({
            source = source,
            message = string.format(
                'Player attempted to spawn a vehicle but was not within the garage zone. Access Point Index: %d, Garage: %s',
                accessPointIndex,
                garageName
            ),
            webhook = Config.logging.webhook.anticheat,
            event = 'suspicious',
            color = 'white'
        })
        return
    end

    local garageType = GetGarageType(garageName)
    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)
    local spawnCoords = vector4(playerCoords.x, playerCoords.y, playerCoords.z, playerHeading)
    
    if not isSpawnPositionClear(spawnCoords.xyz, 1.5) then
        for offset = 1.0, 3.0, 0.5 do
            local rad = math.rad(playerHeading + 90)
            local checkX = playerCoords.x + math.cos(rad) * offset
            local checkY = playerCoords.y + math.sin(rad) * offset
            local checkPos = vec3(checkX, checkY, playerCoords.z)
            
            if isSpawnPositionClear(checkPos, 1.5) then
                spawnCoords = vector4(checkX, checkY, playerCoords.z, playerHeading)
                break
            end
        end
    end

    if not isSpawnPositionClear(spawnCoords.xyz, 1.5) then
        exports.morph_junjie:Notify(source, locale('error.no_space'), 'error')
        return
    end

    if Config.distanceCheck then
        local nearbyVehicle = lib.getClosestVehicle(spawnCoords.xyz, Config.distanceCheck, false)
        if nearbyVehicle then
            exports.morph_junjie:Notify(source, locale('error.no_space'), 'error')
            return
        end
    end

    local filter = GetPlayerVehicleFilter(source, garageName)
    local playerVehicle = exports.morph_vehicles:GetPlayerVehicle(vehicleId, filter)
    if not playerVehicle then
        exports.morph_junjie:Notify(source, locale('error.not_owned'), 'error')
        return
    end
    if garageType == GarageType.DEPOT and FindPlateOnServer(playerVehicle.props.plate) then
        return exports.morph_junjie:Notify(source, locale('error.not_impound'), 'error')
    end

    if garageType == GarageType.DEPOT then
        local remaining = GetImpoundRemaining(vehicleId)
        if remaining > 0 then
            exports.morph_junjie:Notify(source, locale('error.impound_locked', FormatDuration(remaining)), 'error')
            return
        end
    end

    if garageType == GarageType.DEPOT and playerVehicle.depotPrice then
        local player = exports.morph_junjie:GetPlayer(source)
        OverrideFreeDepotPriceForOutVehicle(playerVehicle)
        local canPay = payDepotPrice(player, playerVehicle.depotPrice)

        if not canPay then
            exports.morph_junjie:Notify(source, locale('error.not_enough'), 'error')
            return
        end
    end

    playerVehicle.props.lockState = 1

    local warpPed = Config.warpInVehicle and GetPlayerPed(source)
    local netId, veh = qbx.spawnVehicle({ spawnSource = spawnCoords, model = playerVehicle.props.model, props = playerVehicle.props, warp = warpPed})

    if Config.doorsLocked then
        if GetResourceState('morph_vkeys') == 'started' then
            TriggerEvent('qb-vehiclekeys:server:setVehLockState', netId, 2)
        else
            SetVehicleDoorsLocked(veh, 2)
        end
    end

    TriggerClientEvent('vehiclekeys:client:SetOwner', source, playerVehicle.props.plate)

    Entity(veh).state:set('vehicleid', vehicleId, false)
    setVehicleStateToOut(vehicleId, veh, playerVehicle.modelName)
    TriggerEvent('morph_garages:server:vehicleSpawned', veh)
    return netId
end)

function OverrideFreeDepotPriceForOutVehicle(vehicle)
    if VehicleState.OUT ~= vehicle.state then return end
    if vehicle.depotPrice and vehicle.depotPrice > 0 then return end

    vehicle.depotPrice = Config.calculateImpoundFee(vehicle.id, vehicle.modelName)
end