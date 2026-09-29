-- Ban Player
RegisterNetEvent('morph_god:server:BanPlayer', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local player = tonumber(selectedData["Player"] and selectedData["Player"].value)
    local reason = (selectedData["Reason"] and selectedData["Reason"].value) or ""
    local time = tonumber(selectedData["Duration"] and selectedData["Duration"].value)

    if not player then
        QBCore.Functions.Notify(source, locale("not_online"), 'error', 7500)
        return
    end

    if not time then
        QBCore.Functions.Notify(source, locale("empty_input"), 'error', 7500)
        return
    end

    if time >= 2147483647 then
        exports.morph_junjie:ExploitBan(player, reason)
    else
        exports.morph_junjie:TempBan(player, reason, time)
    end

    if source and GetPlayerName(source) then
        QBCore.Functions.Notify(source, locale("playerbanned", player, time, reason), 'success', 7500)
    end
end)

-- Warn Player
RegisterNetEvent('morph_god:server:WarnPlayer', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    local targetId = selectedData["Player"].value
    local target = QBCore.Functions.GetPlayer(targetId)
    local reason = selectedData["Reason"].value
    local sender = QBCore.Functions.GetPlayer(source)
    local warnId = 'WARN-' .. math.random(1111, 9999)
    if target ~= nil then
        QBCore.Functions.Notify(target.PlayerData.source,
            locale("warned") .. ", for: " .. locale("reason") .. ": " .. reason, 'inform', 10000)
        QBCore.Functions.Notify(source,
            locale("warngiven") .. GetPlayerName(target.PlayerData.source) .. ", for: " .. reason)
        MySQL.insert('INSERT INTO player_warns (senderIdentifier, targetIdentifier, reason, warnId) VALUES (?, ?, ?, ?)',
            {
                sender.PlayerData.license,
                target.PlayerData.license,
                reason,
                warnId
            })
    else
        TriggerClientEvent('QBCore:Notify', source, locale("not_online"), 'error')
    end
end)

RegisterNetEvent('morph_god:server:KickPlayer', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    local src = source
    local target = QBCore.Functions.GetPlayer(selectedData["Player"].value)
    local reason = selectedData["Reason"].value

    if not target then
        QBCore.Functions.Notify(src, locale("not_online"), 'error', 7500)
        return
    end

    DropPlayer(target.PlayerData.source, locale("kicked") .. '\n' .. locale("reason") .. reason)
end)

-- Revive Player
RegisterNetEvent('morph_god:server:Revive', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    local player = selectedData["Player"].value
    if GetResourceState('morph_medic') == 'started' then
        exports.morph_medic:Revive(player)
    else
        TriggerClientEvent('hospital:client:Revive', player)
    end
end)

-- Revive All
RegisterNetEvent('morph_god:server:ReviveAll', function(data)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    if GetResourceState('morph_medic') == 'started' then
        exports.morph_medic:Revive(-1)
    else
        TriggerClientEvent('hospital:client:Revive', -1)
    end
end)

-- Revive Radius
RegisterNetEvent('morph_god:server:ReviveRadius', function(data)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local ped = GetPlayerPed(src)
    local pos = GetEntityCoords(ped)
    local players = QBCore.Functions.GetPlayers()

    for k, v in pairs(players) do
        local target = GetPlayerPed(v)
        local targetPos = GetEntityCoords(target)
        local dist = #(pos - targetPos)

        if dist < 15.0 then
            if GetResourceState('morph_medic') == 'started' then
                exports.morph_medic:Revive(v)
            else
                TriggerClientEvent('hospital:client:Revive', v)
            end
        end
    end
end)

-- Set RoutingBucket
RegisterNetEvent('morph_god:server:SetBucket', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local player = selectedData["Player"].value
    local bucket = selectedData["Bucket"].value
    local currentBucket = GetPlayerRoutingBucket(player)

    if bucket == currentBucket then
        return QBCore.Functions.Notify(src, locale("target_same_bucket", player), 'error', 7500)
    end

    SetPlayerRoutingBucket(player, bucket)
    QBCore.Functions.Notify(src, locale("bucket_set_for_target", player, bucket), 'success', 7500)
end)

-- Get RoutingBucket
RegisterNetEvent('morph_god:server:GetBucket', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local player = selectedData["Player"].value
    local currentBucket = GetPlayerRoutingBucket(player)

    QBCore.Functions.Notify(src, locale("bucket_get", player, currentBucket), 'success', 7500)
end)

-- Give Money
RegisterNetEvent('morph_god:server:GiveMoney', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local target, amount, moneyType = selectedData["Player"].value, selectedData["Amount"].value,
        selectedData["Type"].value
    local Player = QBCore.Functions.GetPlayer(tonumber(target))

    if Player == nil then
        return QBCore.Functions.Notify(src, locale("not_online"), 'error', 7500)
    end

    Player.Functions.AddMoney(tostring(moneyType), tonumber(amount))
    QBCore.Functions.Notify(src,
        locale((moneyType == "crypto" and "give_money_crypto" or "give_money"), tonumber(amount),
            Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname), "success")
end)

-- Give Money to all
RegisterNetEvent('morph_god:server:GiveMoneyAll', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local amount, moneyType = selectedData["Amount"].value, selectedData["Type"].value
    local players = QBCore.Functions.GetPlayers()

    for _, v in pairs(players) do
        local Player = QBCore.Functions.GetPlayer(tonumber(v))
        Player.Functions.AddMoney(tostring(moneyType), tonumber(amount))
        QBCore.Functions.Notify(src,
            locale((moneyType == "crypto" and "give_money_all_crypto" or "give_money_all"), tonumber(amount)), "success")
    end
end)

-- Take Money
RegisterNetEvent('morph_god:server:TakeMoney', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local target, amount, moneyType = selectedData["Player"].value, selectedData["Amount"].value,
        selectedData["Type"].value
    local Player = QBCore.Functions.GetPlayer(tonumber(target))

    if Player == nil then
        return QBCore.Functions.Notify(src, locale("not_online"), 'error', 7500)
    end

    if Player.PlayerData.money[moneyType] >= tonumber(amount) then
        Player.Functions.RemoveMoney(moneyType, tonumber(amount), "state-fees")
    else
        QBCore.Functions.Notify(src, locale("not_enough_money"), "primary")
    end

    QBCore.Functions.Notify(src,
        locale((moneyType == "crypto" and "take_money_crypto" or "take_money"), tonumber(amount) .. "$",
            Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname), "success")
end)

-- Blackout
local Blackout = false
RegisterNetEvent('morph_god:server:ToggleBlackout', function(data)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    Blackout = not Blackout

    local src = source

    if Blackout then
        TriggerClientEvent('QBCore:Notify', src, locale("blackout", "enabled"), 'primary')
        while Blackout do
            Wait(0)
            exports["qb-weathersync"]:setBlackout(true)
        end
        exports["qb-weathersync"]:setBlackout(false)
        TriggerClientEvent('QBCore:Notify', src, locale("blackout", "disabled"), 'primary')
    end
end)

-- Toggle Cuffs
RegisterNetEvent('morph_god:server:CuffPlayer', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local target = selectedData["Player"].value

    TriggerClientEvent('morph_god:client:ToggleCuffs', target)
    QBCore.Functions.Notify(source, locale("toggled_cuffs"), 'success')
end)

-- Give Clothing Menu
RegisterNetEvent('morph_god:server:ClothingMenu', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local target = tonumber(selectedData["Player"].value)

    if target == nil then
        return QBCore.Functions.Notify(src, locale("not_online"), 'error', 7500)
    end

    if target == src then
        TriggerClientEvent("morph_god:client:CloseUI", src)
    end

    TriggerClientEvent('qb-clothing:client:openMenu', target)
end)

-- Set Ped
RegisterNetEvent("morph_god:server:setPed", function(data, selectedData)
    local src = source
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then
        QBCore.Functions.Notify(src, locale("no_perms"), "error", 5000)
        return
    end

    local ped = selectedData["Ped Models"].label
    local tsrc = selectedData["Player"].value
    local Player = QBCore.Functions.GetPlayer(tsrc)

    if not Player then
        QBCore.Functions.Notify(locale("not_online"), "error", 5000)
        return
    end

    TriggerClientEvent("morph_god:client:setPed", Player.PlayerData.source, ped)
end)
