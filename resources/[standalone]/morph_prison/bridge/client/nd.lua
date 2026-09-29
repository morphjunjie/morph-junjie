if not lib.checkDependency('ND_Core', '2.0.0') then return end

RegisterNetEvent('ND:characterLoaded', function()
    TriggerEvent('morph_prison:client:onLoad')
end)

RegisterNetEvent('ND:characterUnloaded', function()
    TriggerEvent('morph_prison:client:onUnload')
end)