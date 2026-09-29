exports.morph_junjie:CreateUseableItem('diving_gear', function(source)
    TriggerClientEvent('morph_dvgear:client:useGear', source)
end)

exports.morph_junjie:CreateUseableItem('diving_fill', function(source)
    local success = lib.callback.await('morph_dvgear:client:fillTank', source)
    if success then
        exports.morph_inv:RemoveItem(source, 'diving_fill', 1)
    end
end)