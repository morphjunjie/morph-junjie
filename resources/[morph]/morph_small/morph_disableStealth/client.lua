CreateThread(function()
    while true do
        local ped = PlayerPedId()

        -- Force disable stealth mode (GTA will never enter stealth movement)
        if GetPedStealthMovement(ped) then
            SetPedStealthMovement(ped, false, 0)
        end

        -- Disable the input that activates stealth
        DisableControlAction(0, 36, true) -- CTRL (stealth keybind)

        Wait(0)
    end
end)
