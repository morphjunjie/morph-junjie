-- client.lua
local driftMode = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)
            if IsControlPressed(0, 21) then -- 21 = Left Shift
                if not driftMode then
                    driftMode = true
                    -- ubah handling biar gampang drift
                    SetVehicleReduceGrip(veh, true)
                    SetVehicleEnginePowerMultiplier(veh, 45.0) -- boost dikit
                end
            else
                if driftMode then
                    driftMode = false
                    -- balikin handling normal
                    SetVehicleReduceGrip(veh, false)
                    SetVehicleEnginePowerMultiplier(veh, 0.0)
                end
            end
        end
    end
end)
