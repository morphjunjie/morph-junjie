local config = require 'morph_mcjob.config.client'
local vehicleMeters, previousVehiclePos, checkDone = -1, nil, false
DrivingDistance = {}

local function round(num) return math.floor(num + 0.5) end

local function getDamageMultiplier(meters)
    local check = round(meters / 1000)
    for i = 1, #config.minimalMetersForDamage do
        local v = config.minimalMetersForDamage[i]
        if check >= v.min and check <= v.max then return v.multiplier end
    end
    local last = config.minimalMetersForDamage[#config.minimalMetersForDamage]
    if check >= last.min then return last.multiplier end
end

local function damageParts(mult, plate)
    local cur = VehicleStatus[plate]
    for i = 1, #config.damageableParts do
        local part = config.damageableParts[i]
        local rand = math.random(mult.min, mult.max) / 100
        local new = cur[part] - rand
        if new < 0 then new = 0 end
        TriggerServerEvent('qb-vehicletuning:server:SetPartLevel', plate, part, new)
    end
end

local function trackDistanceFromPreviousPosition(pos, plate)
    local dist = #(pos - previousVehiclePos)
    local mult = getDamageMultiplier(vehicleMeters)
    vehicleMeters = vehicleMeters + (dist / 100) * 325
    DrivingDistance[plate] = vehicleMeters
    if mult and math.random(3) == 3 then damageParts(mult, plate) end
    local amount = round(DrivingDistance[plate] / 1000)
    TriggerEvent('hud:client:UpdateDrivingMeters', true, amount)
    TriggerServerEvent('qb-vehicletuning:server:UpdateDrivingDistance', DrivingDistance[plate], plate)
end

local function trackDistance()
    local ped, veh = cache.ped, cache.vehicle
    if not veh then vehicleMeters = -1; checkDone = false; previousVehiclePos = nil; Wait(500); return end
    local isDriver, pos, plate = cache.seat == -1, GetEntityCoords(ped), qbx.getVehiclePlate(veh)
    if not plate then Wait(2000); return end
    if isDriver then
        if not checkDone and vehicleMeters == -1 then
            checkDone = true
            lib.callback('qb-vehicletuning:server:IsVehicleOwned', false, function(owned)
                if not DrivingDistance[plate] then DrivingDistance[plate] = owned and 0 or math.random(111111, 999999) end
                vehicleMeters = DrivingDistance[plate]
            end, plate)
        end
        if previousVehiclePos then trackDistanceFromPreviousPosition(pos, plate); trackDistanceFromPreviousPosition(pos, plate) end
    elseif vehicleMeters == -1 and DrivingDistance[plate] then
        vehicleMeters = DrivingDistance[plate]
    end
    if vehicleMeters ~= -1 and not isDriver and DrivingDistance[plate] then
        TriggerEvent('hud:client:UpdateDrivingMeters', true, round(DrivingDistance[plate] / 1000))
    end
    previousVehiclePos = pos
    Wait(2000)
end

RegisterNetEvent('qb-vehicletuning:client:UpdateDrivingDistance', function(amt, plate) DrivingDistance[plate] = amt end)

CreateThread(function() Wait(500); while true do trackDistance() end end)