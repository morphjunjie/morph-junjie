local lastReported = nil

CreateThread(function()
    while true do
        Wait(Config.CheckInterval)

        local ped = PlayerPedId()
        local weaponHash = GetSelectedPedWeapon(ped)

        if Config.BannedWeapons[weaponHash] then
            if lastReported ~= weaponHash then
                lastReported = weaponHash
                TriggerServerEvent('weaponautoban:server:reportWeapon', weaponHash)
            end
        else
            lastReported = nil
        end
    end
end)
