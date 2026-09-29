if GetResourceState('morph_junjie') == 'started' then
    if not lib.checkDependency('morph_junjie', '1.18.0') then
        return lib.print.error('morph_junjie v1.18.0 is required for morph_prison') -- Requires 1.18.0 for HasGroup export || https://github.com/Qbox-project/morph_junjie/blob/c6f2b96a3644edce5958c76b447a98afa4801475/server/functions.lua#L447
    end
else return end

-- Load / Unload Events --
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerEvent('morph_prison:client:onLoad')
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    TriggerEvent('morph_prison:client:onUnload')
end)