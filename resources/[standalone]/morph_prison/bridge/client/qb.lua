if GetResourceState('qb-core') ~= 'started' or GetResourceState('morph_junjie') == 'started' then return end

-- Load / Unload Events --
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerEvent('morph_prison:client:onLoad')
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    TriggerEvent('morph_prison:client:onUnload')
end)