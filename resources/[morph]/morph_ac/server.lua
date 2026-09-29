lib.versionCheck('Peak-Scripts/morph_ac')

lib.callback.register('morph_ac:server:isPlayerAdmin', function()
    return IsPlayerAceAllowed(source, 'command')
end)
