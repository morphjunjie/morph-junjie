-- EjectFromVehicle and its triggers are taken from 'qb-smallresources/seatbelt.lua' and modified for this script. Thanks to its creators.
--[[ https://github.com/qbcore-framework/qb-smallresources/blob/main/client/seatbelt.lua ]]

local seatbelt = {}

local Utils = require 'modules.utils.client'

local isSeatbeltOn = false
local sleep = 0
local newvehicleBodyHealth, currentvehicleBodyHealth, frameBodyChange, lastFrameVehiclespeed, lastFrameVehiclespeed2, thisFrameVehicleSpeed, tick =
    0, 0, 0, 0, 0, 0, 0
local veloc = 0
local isCheckingSeatbelt = false

-- This function checks if the given vehicle's class is allowed.
---@param vehicle number
---@return boolean state
local function IsVehicleClassAllowed(vehicle)
    local class = GetVehicleClass(vehicle)
    local disallowedClasses = {
        [8] = true,  -- Motorcycles
        [13] = true, -- Cycles
        [14] = true  -- Boats
    }

    return not disallowedClasses[class]
end

--- Ejects the player from the vehicle if the seatbelt is not on and the vehicle is moving.
-- The player is ejected, put into a ragdoll state, and their velocity is multiplied, causing potential injury based on speed.
local function EjectFromVehicle()
    if isSeatbeltOn then return end
    local ped = cache.ped
    local veh = GetVehiclePedIsIn(ped, false)
    if IsVehicleStopped(veh) then return end
    local coords = GetOffsetFromEntityInWorldCoords(veh, 1.0, 0.0, 1.0)
    SetEntityCoords(ped, coords.x, coords.y, coords.z)
    Wait(1)
    SetPedToRagdoll(ped, 5511, 5511, 0, 0, 0, 0)
    SetEntityVelocity(ped, veloc.x * 4, veloc.y * 4, veloc.z * 4)
end

--- Toggles the state of the seatbelt (on or off)
---@param state boolean | nil
function seatbelt.ToggleSeatBelt(state)
    local vehicle = cache.vehicle
    if not vehicle or IsPauseMenuActive() then return end
    if not IsVehicleClassAllowed(vehicle) then return end

    if state ~= nil then
        isSeatbeltOn = state
    else
        isSeatbeltOn = not isSeatbeltOn
    end

    local message = locale(isSeatbeltOn and 'seatbelt_on' or 'seatbelt_off')
    lib.notify({
        description = message,
        type = 'success',
        duration = 1000
    })

    if isSeatbeltOn then
        exports['morph_sound']:PlayUrl('seatbelt_sound', 'nui://morph_sound/html/sounds/seatbelt_on.ogg', 0.3, false)
    else
        exports['morph_sound']:PlayUrl('seatbelt_sound', 'nui://morph_sound/html/sounds/seatbelt_off.ogg', 0.3, false)
    end
end

---Get current seat belt state
---@return boolean
function seatbelt.GetCurrentState()
    return isSeatbeltOn
end

---Reset seatbelt state when vehicle is removed/despawned
local function ResetSeatbeltState()
    if isSeatbeltOn then
        isSeatbeltOn = false
        -- Optional: Notify player that seatbelt was automatically removed
        lib.notify({
            description = locale('Seatbelt Auto Off'),
            type = 'info',
            duration = 2000
        })
    end
end

function seatbelt.EnteredVehicle()
    if not Config.ToggleSeatBelt.active then return end
    if not IsVehicleClassAllowed(cache.vehicle) then return end
    
    -- Reset state when entering new vehicle
    ResetSeatbeltState()
    
    CreateThread(function()
        local function resetVehicle()
            lastFrameVehiclespeed2 = 0
            lastFrameVehiclespeed = 0
            newvehicleBodyHealth = 0
            currentvehicleBodyHealth = 0
            frameBodyChange = 0
            isSeatbeltOn = false
            isCheckingSeatbelt = false
            Wait(1000)
        end
        
        while true do
            Wait(5)
            local currentVehicle = cache.vehicle
            
            -- Check if vehicle still exists and is valid
            if currentVehicle and DoesEntityExist(currentVehicle) then
                local multip = Config.DefaultHudSettings.vehicle_info.kmH and 3.6 or 2.236936
                thisFrameVehicleSpeed = GetEntitySpeed(currentVehicle) * multip
                currentvehicleBodyHealth = GetVehicleBodyHealth(currentVehicle)
                
                if currentvehicleBodyHealth == 1000 and frameBodyChange ~= 0 then
                    frameBodyChange = 0
                end
                
                if not isSeatbeltOn then
                    -- Eject on impact when seatbelt is off
                    if frameBodyChange > 18.0 and thisFrameVehicleSpeed < (lastFrameVehiclespeed * .75) then
                        if lastFrameVehiclespeed > Config.ToggleSeatBelt.ejectSpeed then
                            -- Higher speeds = more likely to eject
                            local ejectChance = math.min(99, (lastFrameVehiclespeed / 100) * 100)
                            if math.random(1, 100) <= ejectChance then
                                EjectFromVehicle()
                            end
                        end
                    end
                    
                    -- Also eject on sustained high speed without seatbelt (slight chance)
                    if lastFrameVehiclespeed > (Config.ToggleSeatBelt.ejectSpeed * 1.5) and frameBodyChange > 5.0 then
                        if math.random(1, 100) <= 15 then  -- 15% chance per frame at extreme speeds with light impact
                            EjectFromVehicle()
                        end
                    end
                end
                
                if lastFrameVehiclespeed < Config.ToggleSeatBelt.ejectSpeed then
                    Wait(100)
                    tick = 0
                end
                
                frameBodyChange = newvehicleBodyHealth - currentvehicleBodyHealth
                
                if tick > 0 then
                    tick = tick - 1
                    if tick == 1 then
                        lastFrameVehiclespeed = GetEntitySpeed(currentVehicle) * multip
                    end
                else
                    lastFrameVehiclespeed2 = GetEntitySpeed(currentVehicle) * multip
                    if lastFrameVehiclespeed2 > lastFrameVehiclespeed then
                        lastFrameVehiclespeed = GetEntitySpeed(currentVehicle) * multip
                    end
                    if lastFrameVehiclespeed2 < lastFrameVehiclespeed then
                        tick = 25
                    end
                end
                
                if tick < 0 then
                    tick = 0
                end
                
                newvehicleBodyHealth = GetVehicleBodyHealth(currentVehicle)
                veloc = GetEntityVelocity(currentVehicle)
            else
                -- Vehicle is no longer valid (despawned or removed)
                resetVehicle()
                break
            end
        end
    end)
    
    --When the belt is active, it is prevented from taking it out of the vehicle.
    CreateThread(function()
        while true do
            if not cache.vehicle or not DoesEntityExist(cache.vehicle) then
                -- Vehicle is gone, reset seatbelt state
                ResetSeatbeltState()
                break
            end
            
            if isSeatbeltOn then
                DisableControlAction(0, 75, true)
            end
            
            Wait(5)
        end
    end)
    
    if Config.ToggleSeatBelt.warning and not isCheckingSeatbelt then
        isCheckingSeatbelt = true
        CreateThread(function()
            while true do
                if not cache.vehicle or not DoesEntityExist(cache.vehicle) then
                    isCheckingSeatbelt = false
                    break
                end

                Wait(5000)

                if not isSeatbeltOn and cache.vehicle and DoesEntityExist(cache.vehicle) and IsVehicleClassAllowed(cache.vehicle) then
                    lib.notify({
                        description = locale('seatbelt_warning'),
                        type = 'warning',
                        duration = 5000
                    })
                end

                Wait(25000)
            end
        end)
    end
end

RegisterNetEvent('seatbelt:client:ToggleSeatbelt', function() -- Triggered in smallresources
    seatbelt.ToggleSeatBelt()
end)

---Exports the SetSeatBeltState function, allowing it to be called from other scripts or resources.
---@param state boolean | nil
exports('SetSeatBeltState', seatbelt.ToggleSeatBelt)

-- Optional: Add event handler for when player exits vehicle
-- This provides an additional layer of safety
RegisterNetEvent('!morphjunjie:enteredVehicle', function()
    -- Reset state when entering vehicle
    seatbelt.EnteredVehicle()
end)

RegisterNetEvent('!morphjunjie:leftVehicle', function()
    -- Reset seatbelt when leaving vehicle
    ResetSeatbeltState()
end)

return seatbelt