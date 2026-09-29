local lastCamMode = nil
local lastContext = nil
local isForcedPOV = false

CreateThread(function()
    while true do
        Wait(0)

        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local isArmed = IsPedArmed(ped, 4)
            local isAiming = isArmed and (IsControlPressed(0, 25) or IsControlPressed(0, 24))

            if isAiming and not isForcedPOV then
                local context = GetCamActiveViewModeContext()
                local currentMode = GetCamViewModeForContext(context)

                if currentMode ~= 4 then
                    lastCamMode = currentMode
                    lastContext = context
                    SetCamViewModeForContext(context, 4)
                    SetFollowVehicleCamViewMode(4)
                    isForcedPOV = true
                end
            end

            if not isAiming and isForcedPOV then
                if lastCamMode and lastContext then
                    SetCamViewModeForContext(lastContext, lastCamMode)
                    SetFollowVehicleCamViewMode(lastCamMode)
                end
                lastCamMode = nil
                lastContext = nil
                isForcedPOV = false
            end

        else
            if isForcedPOV then
                if lastCamMode and lastContext then
                    SetCamViewModeForContext(lastContext, lastCamMode)
                    SetFollowVehicleCamViewMode(lastCamMode)
                end
                lastCamMode = nil
                lastContext = nil
                isForcedPOV = false
            end
        end
    end
end)