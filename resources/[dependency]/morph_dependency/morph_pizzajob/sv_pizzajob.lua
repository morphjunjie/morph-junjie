local Server = lib.require('morph_pizzajob.sv_config')
local players = {}

local function createPizzaVehicle(source)
    local veh = CreateVehicle(Server.Vehicle, Server.VehicleSpawn.x, Server.VehicleSpawn.y, Server.VehicleSpawn.z, Server.VehicleSpawn.w, true, true)
    local ped = GetPlayerPed(source)
    while not DoesEntityExist(veh) do Wait(0) end
    while GetVehiclePedIsIn(ped, false) ~= veh do
        TaskWarpPedIntoVehicle(ped, veh, -1)
        Wait(0)
    end
    return NetworkGetNetworkIdFromEntity(veh)
end

-- Bayar deposit + earned yang udah kekumpul ke player, dipakai bareng
-- oleh clockOut, playerDropped, dan ServerOnLogout biar behaviornya sama
-- persis di semua jalur keluar dari job.
local function payoutAndClear(src, reason)
    local data = players[src]
    if not data or data.pending then
        players[src] = nil
        return
    end

    local ent = data.entity
    if DoesEntityExist(ent) then
        DeleteEntity(ent)
    end

    local player = exports.morph_junjie:GetPlayer(src)
    if player then
        if data.paymentMethod == 'cash' then
            player.Functions.AddMoney('cash', data.deposit, 'Pizza Job Deposit Refund' .. (reason and (' (' .. reason .. ')') or ''))
        else
            player.Functions.AddMoney('bank', data.deposit, 'Pizza Job Deposit Refund' .. (reason and (' (' .. reason .. ')') or ''))
        end
    end

    local earned = data.earned or 0
    if earned > 0 then
        local Player = GetPlayer(src)
        if Player then
            AddMoney(Player, Server.Account, earned)
        end
    end

    players[src] = nil
    return earned, data.deposit
end

lib.callback.register('morph_pizzajob:server:spawnVehicle', function(source)
    if players[source] then return false end

    -- Lock slot ini SEBELUM ada yield/Wait apa pun, supaya call kedua yang
    -- masuk saat createPizzaVehicle() masih nunggu tidak lolos pengecekan di atas.
    players[source] = { pending = true }

    local src = source
    local player = exports.morph_junjie:GetPlayer(src)
    local depositAmount = Server.Deposit
    local cash = player.PlayerData.money.cash
    local bank = player.PlayerData.money.bank
    local paymentMethod = 'cash'
    if cash >= depositAmount then
        player.Functions.RemoveMoney('cash', depositAmount, 'Pizza Job Deposit')
        paymentMethod = 'cash'
    elseif bank >= depositAmount then
        player.Functions.RemoveMoney('bank', depositAmount, 'Pizza Job Deposit')
        paymentMethod = 'bank'
    else
        players[src] = nil -- gagal, lepas lock
        DoNotification(src, string.format('You need $%d deposit (cash or bank)', depositAmount), 'error')
        return false
    end

    local netid = createPizzaVehicle(src)

    -- Kalau di antara Wait() tadi player sudah disconnect atau slotnya
    -- diutak-atik dari tempat lain, batalkan dan refund biar tidak nyangkut.
    if not players[src] or not players[src].pending then
        if paymentMethod == 'cash' then
            player.Functions.AddMoney('cash', depositAmount, 'Pizza Job Deposit Refund (aborted)')
        else
            player.Functions.AddMoney('bank', depositAmount, 'Pizza Job Deposit Refund (aborted)')
        end
        local ent = NetworkGetEntityFromNetworkId(netid)
        if DoesEntityExist(ent) then DeleteEntity(ent) end
        return false
    end

    local generatedLocs = {}
    local addedLocs = {}
    local deliveryCount = math.random(Server.Deliveries.min, Server.Deliveries.max)
    while #generatedLocs < deliveryCount do
        local index = math.random(#Server.Locations)
        if not addedLocs[index] then
            local randomLoc = Server.Locations[index]
            generatedLocs[#generatedLocs + 1] = randomLoc
            addedLocs[index] = true
        end
    end
    local currentLocIndex = math.random(#generatedLocs)
    local currentLoc = generatedLocs[currentLocIndex]
    table.remove(generatedLocs, currentLocIndex)
    local payout = math.random(Server.Payout.min, Server.Payout.max)

    -- Overwrite lock dengan data final.
    players[src] = {
        entity = NetworkGetEntityFromNetworkId(netid),
        locations = generatedLocs,
        payment = payout,
        current = currentLoc,
        deposit = depositAmount,
        paymentMethod = paymentMethod,
        earned = 0, -- akumulasi hasil delivery, dibayar pas clock out / disconnect
        deliveriesCompleted = 0,
        minDeliveries = Server.MinDeliveries or 0,
    }
    DoNotification(src, string.format('Deposit of $%d paid via %s. Good luck!', depositAmount, paymentMethod), 'success')
    return netid, players[src]
end)

lib.callback.register('morph_pizzajob:server:clockOut', function(source)
    local src = source
    local data = players[src]
    if not data or data.pending then
        return false
    end

    local minDeliveries = Server.MinDeliveries or 0
    if (data.deliveriesCompleted or 0) < minDeliveries then
        local remaining = minDeliveries - (data.deliveriesCompleted or 0)
        DoNotification(src, string.format('You need to complete %d more delivery/deliveries before ending your shift.', remaining), 'error')
        return false
    end

    local earned = payoutAndClear(src)

    if earned and earned > 0 then
        DoNotification(src, string.format('Shift complete! You earned $%d from deliveries.', earned), 'success')
    end
    DoNotification(src, string.format('Deposit of $%d refunded.', data.deposit), 'success')

    return true
end)

lib.callback.register('morph_pizzajob:server:Payment', function(source)
    local src = source
    local Player = GetPlayer(src)
    local pos = GetEntityCoords(GetPlayerPed(src))
    if not players[src] or players[src].pending
        or not DoesEntityExist(players[src].entity)
        or #(pos - vec3(players[src].current.x, players[src].current.y, players[src].current.z)) > 5.0 then
        handleExploit(src, 'Exploiting Pizza Job.')
        return false
    end

    -- dikumpulin dulu, baru cair pas clock out (atau auto-payout kalau disconnect)
    players[src].earned = (players[src].earned or 0) + players[src].payment
    players[src].deliveriesCompleted = (players[src].deliveriesCompleted or 0) + 1

    -- players[src].locations here is the list BEFORE assigning a new current,
    -- so #locations == 0 genuinely means there is no next delivery to give.
    if #players[src].locations == 0 then
        DoNotification(src, ('Delivery collected! Total earned this shift: $%s'):format(players[src].earned), 'success')
        return true
    end

    DoNotification(src, ('Delivery collected! Total so far: $%s. Deliveries left: %s'):format(players[src].earned, #players[src].locations), 'success')
    local index = math.random(#players[src].locations)
    local newLoc = players[src].locations[index]
    local payout = math.random(Server.Payout.min, Server.Payout.max)
    table.remove(players[src].locations, index)
    players[src].current = newLoc
    players[src].payment = payout
    return true, players[src]
end)

lib.callback.register('morph_pizzajob:server:checkDeposit', function(source)
    local player = exports.morph_junjie:GetPlayer(source)
    local depositAmount = Server.Deposit
    local cash = player.PlayerData.money.cash
    local bank = player.PlayerData.money.bank
    return cash >= depositAmount or bank >= depositAmount
end)

lib.addCommand('forcepizza', {
    help = 'Force complete all pizza deliveries',
    restricted = true,
    params = {}
}, function(source)
    local src = source
    if not IsPlayerAceAllowed(src, 'command') then
        DoNotification(src, 'You don\'t have permission to use this command!', 'error')
        return
    end
    if not players[src] or players[src].pending then
        DoNotification(src, 'You are not currently on a pizza job!', 'error')
        return
    end

    local playerData = players[src]
    local deliveriesCompleted = #playerData.locations + 1 -- +1 for the delivery currently in progress

    -- forcepizza itu admin override, langsung cair semuanya termasuk earned
    -- yang udah kekumpul, tanpa lewat syarat MinDeliveries di clockOut.
    local totalPayment = (playerData.earned or 0) + playerData.payment
    for i = 1, #playerData.locations do
        totalPayment = totalPayment + math.random(Server.Payout.min, Server.Payout.max)
    end

    playerData.locations = {}
    playerData.current = nil
    playerData.earned = 0

    local Player = GetPlayer(src)
    AddMoney(Player, Server.Account, totalPayment)
    DoNotification(src, string.format('Force completed all %d deliveries! Total earned: $%s', deliveriesCompleted, totalPayment), 'success')
    TriggerClientEvent('morph_pizzajob:client:forceComplete', src)
end)

AddEventHandler("playerDropped", function()
    local src = source
    if players[src] then
        -- Refund deposit + auto-payout earned kalau job-nya sudah beneran jalan
        -- (bukan pending). Dicatat ke log server supaya admin bisa pantau kalau
        -- ada yang sering-sering disconnect saat kerja (indikasi abuse).
        local wasPending = players[src].pending
        local earned, deposit = payoutAndClear(src, 'disconnect')
        if not wasPending and deposit then
            print(string.format('[morph_pizzajob] Player %s disconnected mid-shift, deposit $%d refunded, earned $%d paid out.', src, deposit, earned or 0))
        end
    end
end)

function ServerOnLogout(source)
    if players[source] then
        payoutAndClear(source, 'logout')
    end
end