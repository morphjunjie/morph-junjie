lib.addCommand('removearmour', { help = 'Remove your own armour', restricted = false }, function(source) TriggerClientEvent('morph_armour:client:removeArmour', source) end)

lib.addCommand('setarmour', { help = 'Set player armour to specific amount', restricted = true, params = { { name = 'id', help = 'Player ID', type = 'number' }, { name = 'amount', help = 'Amount of armour (0-100)', type = 'number' } } }, function(source, args)
    if not IsPlayerAceAllowed(source, 'command') then TriggerClientEvent('morph_ui:notify', source, { title = 'Armour Management', description = 'You don\'t have permission to use this command!', type = 'error', duration = 3000 }) return end
    local targetId = tonumber(args.id)
    local amount = tonumber(args.amount)
    if not targetId or amount == nil then TriggerClientEvent('morph_ui:notify', source, { title = 'Armour Management', description = 'Usage: /setarmour [id] [amount]', type = 'error', duration = 3000 }) return end
    if amount < 0 or amount > 100 then TriggerClientEvent('morph_ui:notify', source, { title = 'Armour Management', description = 'Amount must be between 0 and 100', type = 'error', duration = 3000 }) return end
    local targetPed = GetPlayerPed(targetId)
    if not targetPed or not DoesEntityExist(targetPed) then TriggerClientEvent('morph_ui:notify', source, { title = 'Armour Management', description = 'Player not found!', type = 'error', duration = 3000 }) return end
    SetPedArmour(targetPed, amount)
    local targetName = GetPlayerName(targetId)
    TriggerClientEvent('morph_ui:notify', source, { title = 'Armour Management', description = string.format('Set %s armour to %d', targetName, amount), type = 'success', duration = 3000 })
end)

lib.addCommand('addarmour', { help = 'Add armour to a player', restricted = true, params = { { name = 'id', help = 'Player ID', type = 'number' }, { name = 'amount', help = 'Amount of armour to add (1-100)', type = 'number' } } }, function(source, args)
    if not IsPlayerAceAllowed(source, 'command') then TriggerClientEvent('morph_ui:notify', source, { title = 'Armour Management', description = 'You don\'t have permission to use this command!', type = 'error', duration = 3000 }) return end
    local targetId = tonumber(args.id)
    local amount = tonumber(args.amount)
    if not targetId or not amount then TriggerClientEvent('morph_ui:notify', source, { title = 'Armour Management', description = 'Usage: /addarmour [id] [amount]', type = 'error', duration = 3000 }) return end
    if amount < 1 or amount > 100 then TriggerClientEvent('morph_ui:notify', source, { title = 'Armour Management', description = 'Amount must be between 1 and 100', type = 'error', duration = 3000 }) return end
    local targetPed = GetPlayerPed(targetId)
    if not targetPed or not DoesEntityExist(targetPed) then TriggerClientEvent('morph_ui:notify', source, { title = 'Armour Management', description = 'Player not found!', type = 'error', duration = 3000 }) return end
    local currentArmour = GetPedArmour(targetPed)
    local newArmour = math.min(currentArmour + amount, 100)
    local added = newArmour - currentArmour
    SetPedArmour(targetPed, newArmour)
    local targetName = GetPlayerName(targetId)
    TriggerClientEvent('morph_ui:notify', source, { title = 'Armour Management', description = string.format('Added %d armour to %s (Total: %d)', added, targetName, newArmour), type = 'success', duration = 3000 })
end)