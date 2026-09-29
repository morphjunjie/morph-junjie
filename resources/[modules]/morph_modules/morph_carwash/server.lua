lib.callback.register('randol_carwash:server:canAfford', function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false end

    local cost = WashConfig.Cost
    local cash = Player.PlayerData.money.cash
    local bank = Player.PlayerData.money.bank

    if cash >= cost then
        Player.Functions.RemoveMoney('cash', cost, 'car-wash')
        QBCore.Functions.Notify(src, ('You paid $%s in cash to get a car wash.'):format(cost), 'success')
        return true
    elseif bank >= cost then
        Player.Functions.RemoveMoney('bank', cost, 'car-wash')
        QBCore.Functions.Notify(src, ('You paid $%s from your bank to get a car wash.'):format(cost), 'success')
        return true
    end

    QBCore.Functions.Notify(src, ('You need $%s in cash or bank to get a car wash.'):format(cost), 'error')
    return false
end)