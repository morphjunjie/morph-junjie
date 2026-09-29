-- Freeze Player
local frozen = false
RegisterNetEvent('morph_god:server:FreezePlayer', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    local src = source

    local target = selectedData["Player"].value

    local ped = GetPlayerPed(target)
    local Player = QBCore.Functions.GetPlayer(target)

    if not frozen then
        frozen = true
        FreezeEntityPosition(ped, true)
        QBCore.Functions.Notify(src,
            locale("Frozen",
                Player.PlayerData.charinfo.firstname ..
                " " .. Player.PlayerData.charinfo.lastname .. " | " .. Player.PlayerData.citizenid), 'Success', 7500)
    else
        frozen = false
        FreezeEntityPosition(ped, false)
        QBCore.Functions.Notify(src,
            locale("deFrozen",
                Player.PlayerData.charinfo.firstname ..
                " " .. Player.PlayerData.charinfo.lastname .. " | " .. Player.PlayerData.citizenid), 'Success', 7500)
    end
    if Player == nil then return QBCore.Functions.Notify(src, locale("not_online"), 'error', 7500) end
end)

-- Drunk Player
RegisterNetEvent('morph_god:server:DrunkPlayer', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local target = selectedData["Player"].value
    local targetPed = GetPlayerPed(target)
    local Player = QBCore.Functions.GetPlayer(target)

    if not Player then
        return QBCore.Functions.Notify(src, locale("not_online"), 'error', 7500)
    end

    TriggerClientEvent('morph_god:client:InitiateDrunkEffect', target)
    QBCore.Functions.Notify(src,
        locale("playerdrunk",
            Player.PlayerData.charinfo.firstname ..
            " " .. Player.PlayerData.charinfo.lastname .. " | " .. Player.PlayerData.citizenid), 'Success', 7500)
end)

-- Explode Player
RegisterNetEvent('morph_god:server:ExplodePlayer', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    
    local src = source
    local target = selectedData["Player"].value
    local targetPed = GetPlayerPed(target)
    local Player = QBCore.Functions.GetPlayer(target)

    if not Player then
        return QBCore.Functions.Notify(src, locale("not_online"), 'error', 7500)
    end

    TriggerClientEvent('morph_god:client:ExplodePlayer', target, "nodamage")
    QBCore.Functions.Notify(src,
        locale("player_exploded",
            Player.PlayerData.charinfo.firstname ..
            " " .. Player.PlayerData.charinfo.lastname .. " | " .. Player.PlayerData.citizenid), 'Success', 7500)
end)