function ClothingExports(cacheped, skinData)
    if GetResourceState('bl_appearance') == 'started' then
        exports.bl_appearance:SetPlayerPedAppearance(skinData)
    elseif GetResourceState('rcore_clothing') == 'started' then
        exports.rcore_clothing:setPedSkin(cacheped, skinData)
    elseif GetResourceState('crm-appearance') == 'started' then
        exports['crm-appearance']:crm_set_ped_appearance(cacheped, skinData)
    elseif GetResourceState('morph_cloth') == 'started' then
        exports['morph_cloth']:setPedAppearance(cacheped, skinData)
    elseif GetResourceState('fivem-appearance') == 'started' then
        exports['fivem-appearance']:setPedAppearance(cacheped, skinData)
    elseif GetResourceState('qb-clothing') == 'started' then
        TriggerEvent('qb-clothing:client:loadPlayerClothing', skinData, cacheped)
    else
        Debug('You can add your own clothing exports here.')
    end
end
