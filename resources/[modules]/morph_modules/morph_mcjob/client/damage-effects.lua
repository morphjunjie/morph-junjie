local effectTimer = 0

local damageLevels = {
    { min = 81, max = 100, engineDamage = {0,0}, handbrakeWait = 0, steeringWait = 0, fuelLoss = 0, clutchDelay = 0 },
    { min = 61, max = 80, engineDamage = {10,15}, handbrakeWait = 1000, steeringWait = 5, fuelLoss = 2, clutchDelay = 50 },
    { min = 41, max = 60, engineDamage = {15,20}, handbrakeWait = 3000, steeringWait = 10, fuelLoss = 4, clutchDelay = 100 },
    { min = 21, max = 40, engineDamage = {20,30}, handbrakeWait = 5000, steeringWait = 15, fuelLoss = 6, clutchDelay = 150 },
    { min = 6, max = 20, engineDamage = {30,40}, handbrakeWait = 7000, steeringWait = 20, fuelLoss = 8, clutchDelay = 200 },
    { min = 0, max = 5, engineDamage = {40,50}, handbrakeWait = 9000, steeringWait = 25, fuelLoss = 10, clutchDelay = 250 }
}

local function getDamageLevel(value) for _, level in ipairs(damageLevels) do if value <= level.max and value >= level.min then return level end end return damageLevels[1] end

local function applyRadiatorEffects(vehicle, plate)
    local level = getDamageLevel(VehicleStatus[plate].radiator)
    SetVehicleEngineHealth(vehicle, GetVehicleEngineHealth(vehicle) - math.random(level.engineDamage[1], level.engineDamage[2]))
end

local function applyAxleEffects(vehicle, plate)
    local level = getDamageLevel(VehicleStatus[plate].axle)
    for i = 0, 360 do SetVehicleSteeringScale(vehicle, i); Wait(level.steeringWait) end
end

local function applyBrakeEffects(vehicle, plate)
    local level = getDamageLevel(VehicleStatus[plate].brakes)
    if level.handbrakeWait > 0 then SetVehicleHandbrake(vehicle, true); Wait(level.handbrakeWait); SetVehicleHandbrake(vehicle, false) end
end

local function applyClutchEffects(vehicle, plate)
    local level = getDamageLevel(VehicleStatus[plate].clutch)
    if level.clutchDelay > 0 then
        SetVehicleHandbrake(vehicle, true); SetVehicleEngineOn(vehicle, false, false, true); SetVehicleUndriveable(vehicle, true)
        Wait(level.clutchDelay)
        SetVehicleEngineOn(vehicle, true, false, true); SetVehicleUndriveable(vehicle, false)
        for i = 1, 360 do SetVehicleSteeringScale(vehicle, i); Wait(level.steeringWait) end
        Wait(level.handbrakeWait / 2)
        SetVehicleHandbrake(vehicle, false)
    end
end

local function leakFuel(vehicle, plate)
    local level = getDamageLevel(VehicleStatus[plate].fuel)
    if level.fuelLoss > 0 then SetVehicleFuelLevel(vehicle, GetVehicleFuelLevel(vehicle) - level.fuelLoss) end
end

local function applyEffects(vehicle)
    local plate = qbx.getVehiclePlate(vehicle)
    local class = GetVehicleClass(vehicle)
    if class == 13 or class == 21 or class == 16 or class == 15 or class == 14 or not VehicleStatus[plate] then return end
    local chance = math.random(1, 100)
    if VehicleStatus[plate].radiator <= 80 and chance <= 20 then applyRadiatorEffects(vehicle, plate)
    elseif VehicleStatus[plate].axle <= 80 and chance <= 40 then applyAxleEffects(vehicle, plate)
    elseif VehicleStatus[plate].brakes <= 80 and chance <= 60 then applyBrakeEffects(vehicle, plate)
    elseif VehicleStatus[plate].clutch <= 80 and chance <= 80 then applyClutchEffects(vehicle, plate)
    elseif VehicleStatus[plate].fuel <= 80 and chance <= 100 then leakFuel(vehicle, plate) end
end

local function updatePartHealth()
    local veh = cache.vehicle
    if not veh then effectTimer = 0; return 2000 end
    if IsThisModelABicycle(GetEntityModel(veh)) or cache.seat ~= -1 then effectTimer = 0; return 1000 end
    local engineHealth, bodyHealth, plate = GetVehicleEngineHealth(veh), GetVehicleBodyHealth(veh), qbx.getVehiclePlate(veh)
    if not VehicleStatus[plate] then TriggerServerEvent("vehiclemod:server:setupVehicleStatus", plate, engineHealth, bodyHealth)
    else
        TriggerServerEvent("vehiclemod:server:updatePart", plate, "engine", engineHealth)
        TriggerServerEvent("vehiclemod:server:updatePart", plate, "body", bodyHealth)
        effectTimer = effectTimer + 1
        if effectTimer >= math.random(10, 15) then applyEffects(veh); effectTimer = 0 end
    end
end

CreateThread(function()
    while true do Wait(1000); local wait = updatePartHealth(); Wait(wait) end
end)