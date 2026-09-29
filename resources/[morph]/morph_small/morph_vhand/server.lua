if not lib then print('^1morph_ui must be started before this resource.^0') return end
lib.locale()

lib.versionCheck("QuantumMalice/morph_vhand")

if GetResourceState('morph_inv') == 'started' then
    exports('cleaningkit', function(event, item, inventory)
        if event == 'usingItem' then
            local success = lib.callback.await('morph_vhand:basicwash', inventory.id)
            if success then return else return false end
        end
    end)

    exports('tirekit', function(event, item, inventory)
        if event == 'usingItem' then
            local success = lib.callback.await('morph_vhand:basicfix', inventory.id, 'tirekit')
            if success then return else return false end
        end
    end)

    exports('repairkit', function(event, item, inventory)
        if event == 'usingItem' then
            local success = lib.callback.await('morph_vhand:basicfix', inventory.id, 'bigkit')
            if success then return else return false end
        end
    end)

    exports('advancedrepairkit', function(event, item, inventory)
        if event == 'usingItem' then
            local success = lib.callback.await('morph_vhand:basicfix', inventory.id, 'smallkit')
            if success then return else return false end
        end
    end)
end

lib.callback.register('morph_vhand:sync', function()
    return true
end)

lib.addCommand('fix', {
    help = locale('commands.fix.help'),
    restricted = 'group.admin'
}, function(source)
    lib.callback('morph_vhand:adminfix', source, function() end)
end)

lib.addCommand('wash', {
    help = locale('commands.wash.help'),
    restricted = 'group.admin'
}, function(source)
    lib.callback('morph_vhand:adminwash', source, function() end)
end)

lib.addCommand('setfuel', {
    help = locale('commands.setfuel.help'),
    params = {
        {
            name = locale('commands.setfuel.params.name'),
            type = locale('commands.setfuel.params.type'),
            help = locale('commands.setfuel.params.help'),
        },
    },
    restricted = 'group.admin'
}, function(source, args)
    local level = args.level

    if level then
        lib.callback('morph_vhand:adminfuel', source, function() end, level)
    end
end)