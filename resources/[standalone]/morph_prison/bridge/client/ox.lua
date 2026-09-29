if GetResourceState('ox_core') ~= 'started' then return end

AddEventHandler('ox:playerLoaded', function()
    TriggerEvent('morph_prison:client:onLoad')
end)

AddEventHandler('ox:playerLogout', function()
    TriggerEvent('morph_prison:client:onUnload')
end)