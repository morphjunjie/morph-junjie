local cruisedSpeed = 0
local cruiseThread = nil

local vehicleClasses = {
    [0]=true,[1]=true,[2]=true,[3]=true,[4]=true,[5]=true,[6]=true,
    [7]=true,[8]=true,[9]=true,[10]=true,[11]=true,[12]=true,
    [13]=false,[14]=false,[15]=false,[16]=false,
    [17]=true,[18]=true,[19]=true,[20]=true,
    [21]=false
}

local function StopCruiseControl(notify)
    if cruisedSpeed == 0 then return end
    cruisedSpeed = 0
    TriggerEvent('seatbelt:client:ToggleCruise')
    if notify then
        exports.morph_junjie:Notify(locale('error.cruise_control_disabled'), 'error')
    end
    if cruiseThread then
        cruiseThread = nil
    end
end

local function StartCruiseControl()
    cruisedSpeed = GetEntitySpeed(cache.vehicle)
    TriggerEvent('seatbelt:client:ToggleCruise')
    exports.morph_junjie:Notify(locale('success.cruise_control_enabled'), 'success')

    cruiseThread = CreateThread(function()
        while cruisedSpeed > 0 do
            Wait(150)
            if not cache.vehicle then
                StopCruiseControl(false)
                break
            end

            local speed = GetEntitySpeed(cache.vehicle)
            local turningOrBraking = IsControlPressed(2, 76) or IsControlPressed(2, 63) or IsControlPressed(2, 64)
            if not turningOrBraking and speed < (cruisedSpeed - 1.5) then
                StopCruiseControl(true)
                break
            end
            if not turningOrBraking and IsVehicleOnAllWheels(cache.vehicle) and speed < cruisedSpeed then
                SetVehicleForwardSpeed(cache.vehicle, cruisedSpeed)
            end
        end
    end)
end

local function TriggerCruiseControl()
    if cruisedSpeed == 0 and cache.seat == -1 and cache.vehicle then
        if GetEntitySpeed(cache.vehicle) > 0 and GetVehicleCurrentGear(cache.vehicle) > 0 then
            StartCruiseControl()
        end
    else
        StopCruiseControl(true)
    end
end

local keybindCruiseControl = lib.addKeybind({
    name = 'toggle_cruise_control',
    description = locale('actions.toggle_cruise_control'),
    defaultKey = 'Y',
    onPressed = function(self)
        if cache.seat == -1 and cache.vehicle then
            local vehicleClass = GetVehicleClass(cache.vehicle)
            if vehicleClasses[vehicleClass] then
                TriggerCruiseControl()
            else
                exports.morph_junjie:Notify(locale('error.cruise_control_unavailable'), 'error')
            end
        end
    end
})

return {
    keybindCruiseControl = keybindCruiseControl
}