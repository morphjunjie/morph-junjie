RegisterCommand('acban', function(source, args)
    if source == 0 then
        if not args[1] then print("Usage: acban [playerId] [reason]"); return end
        local targetId = tonumber(args[1])
        if not targetId then print("Invalid player ID"); return end
        local reason = table.concat(args, " ", 2)
        if reason == "" then reason = "Banned by console" end
        exports.morph_junjie:ExploitBan(targetId, reason)
        print(string.format("^1[AC] Console banned %s - Reason: %s", GetPlayerName(targetId), reason))
        return
    end

    local hasPermission = IsPlayerAceAllowed(source, 'admin')
    if not hasPermission then
        lib.notify(source, { title = 'Morph Shield', description = 'No permission', type = 'error' })
        return
    end

    if not args[1] then
        lib.notify(source, { title = 'Morph Shield', description = 'Usage: /acban [playerId] [reason]', type = 'error' })
        return
    end

    local targetId = tonumber(args[1])
    if not targetId then
        lib.notify(source, { title = 'Morph Shield', description = 'Invalid player ID', type = 'error' })
        return
    end

    local targetName = GetPlayerName(targetId)
    if not targetName or targetName == "" then
        lib.notify(source, { title = 'Morph Shield', description = 'Player not found', type = 'error' })
        return
    end

    local reason = table.concat(args, " ", 2)
    if reason == "" then reason = "Banned by admin" end

    exports.morph_junjie:ExploitBan(targetId, reason)
    print(string.format("^1[AC] %s banned %s - Reason: %s", GetPlayerName(source), targetName, reason))
    lib.notify(source, { title = 'Morph Shield', description = string.format('%s banned', targetName), type = 'success' })
end, false)