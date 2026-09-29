-- MORPH FALL FIX - Optimized

local QBCore = exports['qb-core']:GetCoreObject()
local cooldownTime = 100
local lastUsed = 0

local function isPlayerFalling(ped)
    local coords = GetEntityCoords(ped)
    local _, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, 0)
    local diff = coords.z - groundZ
    if diff < -5.0 or IsPedFalling(ped) then
        return true, diff
    end
    return false, diff
end

local function findNearestSurface(coords, ped)
    local foundGround, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 1000.0, 0)
    if foundGround then
        return vector3(coords.x, coords.y, groundZ + 1.5)
    end
    
    local handle = StartShapeTestRay(coords.x, coords.y, coords.z + 1000.0, coords.x, coords.y, coords.z - 1000.0, 1, ped, 0)
    Wait(100)
    local _, hit, endCoords, _, _ = GetShapeTestResult(handle)
    
    if hit then
        return vector3(coords.x, coords.y, endCoords.z + 1.5)
    end
    return nil
end

local function teleportEntity(ped, vehicle, coords, isInVehicle)
    if isInVehicle and vehicle and vehicle ~= 0 then
        SetEntityCoords(vehicle, coords.x, coords.y, coords.z, false, false, false, false)
        SetEntityHeading(vehicle, GetEntityHeading(vehicle))
        SetVehicleOnGroundProperly(vehicle)
    else
        SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
        SetEntityHeading(ped, GetEntityHeading(ped))
    end
end

RegisterCommand("fn", function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    local isInVehicle = (vehicle and vehicle ~= 0)
    local coords = GetEntityCoords(isInVehicle and vehicle or ped)
    local currentTime = GetGameTimer()
    
    if currentTime - lastUsed < cooldownTime then
        local remaining = math.ceil((cooldownTime - (currentTime - lastUsed)) / 1000)
        QBCore.Functions.Notify(string.format('Cooldown: %ds', remaining), 'error')
        return
    end
    
    local isFalling = isPlayerFalling(ped)
    if not isFalling then
        QBCore.Functions.Notify('Not falling', 'error')
        return
    end
    
    lastUsed = currentTime
    QBCore.Functions.Notify('Finding surface...', 'info')
    
    local surface = findNearestSurface(coords, ped)
    
    if surface then
        teleportEntity(ped, vehicle, surface, isInVehicle)
        QBCore.Functions.Notify('Pulled to surface!', 'success')
    else
        local spawns = {
            vector3(-1034.0, -2736.0, 13.0),
            vector3(425.0, -980.0, 30.0),
            vector3(196.0, -930.0, 30.0),
        }
        
        local nearestSpawn = nil
        local minDist = math.huge
        
        for _, spawn in ipairs(spawns) do
            local dist = #(coords - spawn)
            if dist < minDist then
                minDist = dist
                nearestSpawn = spawn
            end
        end
        
        if nearestSpawn then
            local spawnZ = nearestSpawn.z + (isInVehicle and 2.0 or 1.0)
            teleportEntity(ped, vehicle, vector3(nearestSpawn.x, nearestSpawn.y, spawnZ), isInVehicle)
            QBCore.Functions.Notify('Sent to spawn', 'warning')
        else
            teleportEntity(ped, vehicle, vector3(coords.x, coords.y, coords.z + 50.0), isInVehicle)
            QBCore.Functions.Notify('Force teleported up', 'warning')
        end
    end
end, false)

-- AUTO DETECT FALLING WITH INSTANT NOTIFICATION
CreateThread(function()
    local lastNotify = 0
    local notifyCooldown = 100
    
    while true do
        Wait(100)
        
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        local isInVehicle = (vehicle and vehicle ~= 0)
        local coords = GetEntityCoords(isInVehicle and vehicle or ped)
        
        local isFalling = false
        if isInVehicle then
            local _, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, 0)
            isFalling = (coords.z - groundZ) < -5.0
        else
            isFalling = IsPedFalling(ped)
        end
        
        if isFalling then
            local _, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, 0)
            local diff = coords.z - groundZ
            
            if diff < -10.0 and GetGameTimer() - lastNotify > notifyCooldown then
                lastNotify = GetGameTimer()
            end
        end
    end
end)

print("^2[Morph Fall Fix] ^3Loaded!^7")