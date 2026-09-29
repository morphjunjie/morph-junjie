-- DRUG ITEMS
exports.morph_junjie:CreateUseableItem('cocaine_bag', function(source)
    TriggerClientEvent('consumables:client:Cocainebaggy', source)
end)

exports.morph_junjie:CreateUseableItem('crack_bag', function(source)
    TriggerClientEvent('consumables:client:Crackbaggy', source)
end)

exports.morph_junjie:CreateUseableItem('meth_bag', function(source)
    TriggerClientEvent('consumables:client:meth', source)
end)

exports.morph_junjie:CreateUseableItem('weed_bag', function(source)
    TriggerClientEvent('consumables:client:weed', source)
end)

-- LOCKPICKS
exports.morph_junjie:CreateUseableItem('lockpick', function(source)
    TriggerClientEvent('lockpicks:UseLockpick', source, false)
    TriggerEvent('lockpicks:UseLockpick', source, false)
end)

exports.morph_junjie:CreateUseableItem('advancedlockpick', function(source)
    TriggerClientEvent('lockpicks:UseLockpick', source, true)
    TriggerEvent('lockpicks:UseLockpick', source, true)
end)

-- CALLBACK: REMOVE ITEM
lib.callback.register('consumables:server:usedItem', function(source, item)
    local player = exports.morph_junjie:GetPlayer(source)
    if not player then return end
    return exports.morph_inv:RemoveItem(source, item, 1)
end)