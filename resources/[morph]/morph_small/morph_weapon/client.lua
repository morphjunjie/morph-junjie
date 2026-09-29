local wasInVehicle = false
local lastWeapon   = nil
local blacklist = {
    [`WEAPON_KNIFE`]     = true,
    [`WEAPON_STUNGUN`]   = true,
    [`WEAPON_NIGHTSTICK`]= true,
}

CreateThread(function()
    while true do
        Wait(250)
        local ped = PlayerPedId()
        if not DoesEntityExist(ped) then goto skip end

        local inVehicle = IsPedInAnyVehicle(ped, false)
        if inVehicle then
            local weapon = GetSelectedPedWeapon(ped)
            if weapon and weapon ~= `WEAPON_UNARMED` then
                lastWeapon = weapon
            end
        end
        if wasInVehicle and not inVehicle then
            if lastWeapon and lastWeapon ~= `WEAPON_UNARMED` then
                if not blacklist[lastWeapon] then
                    TriggerEvent('morph_inv:disarm', true)
                end

                SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
                TriggerServerEvent('morph_weapon:autoHolster:log', lastWeapon)
            end

            lastWeapon = nil
        end

        wasInVehicle = inVehicle
        ::skip::
    end
end)