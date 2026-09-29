lib.versionCheck('Qbox-project/morph_small')

exports.morph_junjie:CreateUseableItem('binoculars', function(source)
    TriggerClientEvent('morph_small:client:toggle', source)
end)
