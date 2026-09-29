local QBCore = exports['qb-core']:GetCoreObject()
local ActiveRentals = {}
local DISCORD_WEBHOOK = Config.DiscordWebhook or ""

local function SendLog(player, action, details)
    if DISCORD_WEBHOOK == "" then return end
    local embed = { { color = 5763719, title = "Bicycle Rental - " .. action, description = details, fields = { { name = "Player", value = player, inline = false } }, footer = { text = "Morph Empire • " .. os.date("%Y-%m-%d %H:%M:%S") } } }
    PerformHttpRequest(DISCORD_WEBHOOK, function() end, 'POST', json.encode({ username = "M.A.D. District", embeds = embed }), { ['Content-Type'] = 'application/json' })
end

local function IsNearRentalLocation(coords)
    if not Config.RentalLocations then return false end
    for _, loc in ipairs(Config.RentalLocations) do
        if #(vector3(coords.x, coords.y, coords.z) - loc) < Config.RentalRadius then return true end
    end
    return false
end

RegisterNetEvent('morph_bikerental:server:rentBike', function(minutes, locationIndex, method)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)

    if not IsNearRentalLocation(coords) then
        TriggerClientEvent('morph_bikerental:client:rentalError', src, 'You are too far from the rental terminal.')
        return
    end

    if ActiveRentals[src] then
        TriggerClientEvent('morph_bikerental:client:rentalError', src, 'You already have an active rental.')
        return
    end

    minutes = tonumber(minutes)
    local totalPrice = minutes * Config.PricePerMinute
    local playerMoney = Player.Functions.GetMoney(method)

    if playerMoney < totalPrice then
        TriggerClientEvent('morph_bikerental:client:rentalError', src, 'Insufficient balance.')
        return
    end

    Player.Functions.RemoveMoney(method, totalPrice, 'bike-rental')
    ActiveRentals[src] = { deposit = math.floor(totalPrice * Config.DepositPercent), method = method, totalPrice = totalPrice, minutes = minutes }

    local name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
    SendLog(name, "Rental Started", string.format("Minutes: %d\nTotal: %s%d\nMethod: %s", minutes, Config.Currency, totalPrice, method:upper()))
    TriggerClientEvent('morph_bikerental:client:startRental', src, minutes, locationIndex, method, totalPrice)
end)

RegisterNetEvent('morph_bikerental:server:returnBike', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local data = ActiveRentals[src]
    if not Player or not data then return end
    Player.Functions.AddMoney(data.method, data.deposit, 'bike-refund')
    local name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
    SendLog(name, "Rental Returned", string.format("Deposit: %s%d\nMethod: %s\nDuration: %d mins", Config.Currency, data.deposit, data.method:upper(), data.minutes))
    TriggerClientEvent('morph_bikerental:client:returnSuccess', src, data.deposit)
    ActiveRentals[src] = nil
end)

RegisterNetEvent('morph_bikerental:server:endRental', function()
    local src = source
    local data = ActiveRentals[src]
    if data then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            local name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
            SendLog(name, "Rental Expired", string.format("Duration: %d mins\nTotal Paid: %s%d", data.minutes, Config.Currency, data.totalPrice))
        end
    end
    ActiveRentals[src] = nil
end)

AddEventHandler('playerDropped', function() ActiveRentals[source] = nil end)