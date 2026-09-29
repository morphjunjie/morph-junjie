if GetResourceState('es_extended') ~= 'started' then return end

RegisterNetEvent('esx:playerLoaded', function()
    TriggerEvent('morph_prison:client:onLoad')
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    TriggerEvent('morph_prison:client:onUnload')
end)