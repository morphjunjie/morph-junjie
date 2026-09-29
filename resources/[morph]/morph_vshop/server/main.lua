lib.versionCheck('Qbox-project/morph_vshop')
assert(lib.checkDependency('morph_junjie', '1.17.2'), 'morph_junjie v1.17.2 or higher is required')
assert(lib.checkDependency('morph_vehicles', '1.4.1'), 'morph_vehicles v1.4.1 or higher is required')

local config = require 'config.server'
local sharedConfig = require 'config.shared'
local financeStorage = require 'server.storage'
COREVEHICLES = exports.morph_junjie:GetVehiclesByName()
local saleTimeout = {}
local testDrives = {}

---@param data {toVehicle: string}
RegisterNetEvent('morph_vshop:server:swapVehicle', function(data)
    if not CheckVehicleList(data.toVehicle) then return end
    TriggerClientEvent('morph_vshop:client:swapVehicle', -1, data)
end)

---@param vehicle string
RegisterNetEvent('morph_vshop:server:testDrive', function(vehicle)
    if not sharedConfig.enableTestDrive then return end
    local src = source

    if Player(src).state.isInTestDrive then
        return exports.morph_junjie:Notify(src, locale('error.testdrive_alreadyin'), 'error')
    end

    local shopId = GetShopZone(src)
    local shop = sharedConfig.shops[shopId]
    if not shop then return end

    if not CheckVehicleList(vehicle, shopId) then
        return exports.morph_junjie:Notify(src, locale('error.notallowed'), 'error')
    end

    local coords = GetClearSpawnArea(shop.vehicleSpawns)
    if not coords then
        return exports.morph_junjie:Notify(src, locale('error.no_clear_spawn'), 'error')
    end

    local testDrive = shop.testDrive
    local plate = 'TEST'..lib.string.random('1111')

    local netId = SpawnVehicle(src, {
        modelName = vehicle,
        coords = coords,
        plate = plate
    })

    testDrives[src] = {
        netId = netId,
        endBehavior = testDrive.endBehavior,
        returnLocation = shop.returnLocation
    }

    Player(src).state:set('isInTestDrive', testDrive.limit, true)
    SetTimeout(testDrive.limit * 60000, function()
        Player(src).state:set('isInTestDrive', nil, true)
    end)
end)

---@param vehicle string
---@param playerId string|number
RegisterNetEvent('morph_vshop:server:customTestDrive', function(vehicle, playerId)
    local src = source
    local target = tonumber(playerId) --[[@as number]]

    if not exports.morph_junjie:GetPlayer(target) then
        exports.morph_junjie:Notify(src, locale('error.Invalid_ID'), 'error')
        return
    end

    if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(target))) < 3 then
        TriggerClientEvent('morph_vshop:client:testDrive', target, { vehicle = vehicle })
    else
        exports.morph_junjie:Notify(src, locale('error.playertoofar'), 'error')
    end
end)

AddStateBagChangeHandler('isInTestDrive', nil, function(bagName, _, value)
    if value then return end

    local plySrc = GetPlayerFromStateBagName(bagName)
    if not plySrc then return end
    local testDrive = testDrives[plySrc]
    if not testDrive then return end
    local netId = testDrive.netId
    local endBehavior = testDrive.endBehavior
    if not netId or endBehavior == 'none' then return end

    local vehicle = NetworkGetEntityFromNetworkId(netId)

    if endBehavior == 'return' then
        local coords = testDrive.returnLocation
        local plyPed = GetPlayerPed(plySrc)
        if #(GetEntityCoords(plyPed) - coords) > 10 then -- don't teleport if they are standing near the spot
            SetEntityCoords(plyPed, coords.x, coords.y, coords.z, false, false, false, false)
        end
        if DoesEntityExist(vehicle) then
            DeleteEntity(vehicle)
        end
    elseif endBehavior == 'destroy' then
        if DoesEntityExist(vehicle) then
            DeleteEntity(vehicle)
        end
    end
    testDrives[plySrc] = nil
end)

AddEventHandler('onResourceStop', function (resourceName)
    if cache.resource ~= resourceName then return end

    for player, _ in pairs(testDrives) do
        Player(player).state:set('isInTestDrive', nil, true)
    end
end)

---@param vehicle string
RegisterNetEvent('morph_vshop:server:buyShowroomVehicle', function(vehicle)
    local src = source

    local shopId = GetShopZone(src)
    local shop = sharedConfig.shops[shopId]
    if not shop then return end

    if not CheckVehicleList(vehicle, shopId) then
        return exports.morph_junjie:Notify(src, locale('error.notallowed'), 'error')
    end

    local coords = GetClearSpawnArea(shop.vehicleSpawns)
    if not coords then
        return exports.morph_junjie:Notify(src, locale('error.no_clear_spawn'), 'error')
    end

    local player = exports.morph_junjie:GetPlayer(src)
    local vehiclePrice = COREVEHICLES[vehicle].price
    if not RemoveMoney(src, vehiclePrice, 'vehicle-bought-in-showroom') then
        return exports.morph_junjie:Notify(src, locale('error.notenoughmoney'), 'error')
    end

    local vehicleId = exports.morph_vehicles:CreatePlayerVehicle({
        model = vehicle,
        citizenid = player.PlayerData.citizenid,
    })

    exports.morph_junjie:Notify(src, locale('success.purchased'), 'success')

    SpawnVehicle(src, {
        coords = coords,
        vehicleId = vehicleId
    })
end)

---@param src number
---@param target table
---@param price number
---@param downPayment number
---@return boolean success
function SellShowroomVehicleTransact(src, target, price, downPayment)
    local player = exports.morph_junjie:GetPlayer(src)

    if not RemoveMoney(target.PlayerData.source, downPayment, 'vehicle-bought-in-showroom') then
        exports.morph_junjie:Notify(src, locale('error.notenoughmoney'), 'error')
        return false
    end

    local commission = lib.math.round(price * config.commissionRate)
    config.addPlayerFunds(player, 'bank', commission, 'vehicle-commission')
    exports.morph_junjie:Notify(src, locale('success.earned_commission', lib.math.groupdigits(commission)), 'success')

    config.addSocietyFunds(player.PlayerData.job.name, price)
    exports.morph_junjie:Notify(target.PlayerData.source, locale('success.purchased'), 'success')

    return true
end

---@param vehicle string
---@param playerId string|number
RegisterNetEvent('morph_vshop:server:sellShowroomVehicle', function(vehicle, playerId)
    local src = source
    local target = exports.morph_junjie:GetPlayer(tonumber(playerId))

    if not target then
        return exports.morph_junjie:Notify(src, locale('error.Invalid_ID'), 'error')
    end

    if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(target.PlayerData.source))) >= 3 then
        return exports.morph_junjie:Notify(src, locale('error.playertoofar'), 'error')
    end

    local shopId = GetShopZone(target.PlayerData.source)
    local shop = sharedConfig.shops[shopId]
    if not shop then return end

    if not CheckVehicleList(vehicle, shopId) then
        return exports.morph_junjie:Notify(src, locale('error.notallowed'), 'error')
    end

    local coords = GetClearSpawnArea(shop.vehicleSpawns)
    if not coords then
        return exports.morph_junjie:Notify(src, locale('error.no_clear_spawn'), 'error')
    end

    local vehiclePrice = COREVEHICLES[vehicle].price
    local cid = target.PlayerData.citizenid

    if not SellShowroomVehicleTransact(src, target, vehiclePrice, vehiclePrice) then return end

    local vehicleId = exports.morph_vehicles:CreatePlayerVehicle({
        model = vehicle,
        citizenid = cid,
    })

    SpawnVehicle(playerId, {
        coords = coords,
        vehicleId = vehicleId
    })
end)

-- Transfer vehicle to player in passenger seat
lib.addCommand('transfervehicle', {
    help = locale('general.command_transfervehicle'),
    params = {
        {
            name = 'id',
            type = 'playerId',
            help = locale('general.command_transfervehicle_help')
        },
        {
            name = 'amount',
            type = 'number',
            help = locale('general.command_transfervehicle_amount'),
            optional = true
        }
    }
}, function(source, args)
    local buyerId = args.id
    local sellAmount = args.amount or 0

    if source == buyerId then
        return exports.morph_junjie:Notify(source, locale('error.selftransfer'), 'error')
    end
    if saleTimeout[source] then
        return exports.morph_junjie:Notify(source, locale('error.sale_timeout'), 'error')
    end
    if buyerId == 0 then
        return exports.morph_junjie:Notify(source, locale('error.Invalid_ID'), 'error')
    end

    local ped = GetPlayerPed(source)
    local targetPed = GetPlayerPed(buyerId)
    if targetPed == 0 then
        return exports.morph_junjie:Notify(source, locale('error.buyerinfo'), 'error')
    end

    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then
        return exports.morph_junjie:Notify(source, locale('error.notinveh'), 'error')
    end

    local vehicleId = Entity(vehicle).state.vehicleid or exports.morph_vehicles:GetVehicleIdByPlate(GetVehicleNumberPlateText(vehicle))
    if not vehicleId then
        return exports.morph_junjie:Notify(source, locale('error.notowned'), 'error')
    end

    local player = exports.morph_junjie:GetPlayer(source)
    local target = exports.morph_junjie:GetPlayer(buyerId)
    local row = exports.morph_vehicles:GetPlayerVehicle(vehicleId)
    local isFinanced = sharedConfig.finance.enable and financeStorage.fetchIsFinanced(vehicleId)

    if not row then return end

    if config.finance.preventSelling and isFinanced then
        return exports.morph_junjie:Notify(source, locale('error.financed'), 'error')
    end

    if row.citizenid ~= player.PlayerData.citizenid then
        return exports.morph_junjie:Notify(source, locale('error.notown'), 'error')
    end

    if #(GetEntityCoords(ped) - GetEntityCoords(targetPed)) > 5.0 then
        return exports.morph_junjie:Notify(source, locale('error.playertoofar'), 'error')
    end

    local targetcid = target.PlayerData.citizenid
    if not target then
        return exports.morph_junjie:Notify(source, locale('error.buyerinfo'), 'error')
    end

    saleTimeout[source] = true

    SetTimeout(config.saleTimeout, function()
        saleTimeout[source] = false
    end)

    if isFinanced then
        local financeData = financeStorage.fetchFinancedVehicleEntityById(vehicleId)
        local confirmFinance = lib.callback.await('morph_vshop:client:confirmFinance', buyerId, financeData)
        if not confirmFinance then
            return exports.morph_junjie:Notify(source, locale('error.buyerdeclined'), 'error')
        end
    end

    lib.callback('morph_vshop:client:confirmTrade', buyerId, function(approved)
        if not approved then
            exports.morph_junjie:Notify(source, locale('error.buyerdeclined'), 'error')
            return
        end

        if sellAmount > 0 then
            local currencyType = FindChargeableCurrencyType(sellAmount, target.PlayerData.money.cash, target.PlayerData.money.bank)

            if not currencyType then
                return exports.morph_junjie:Notify(source, locale('error.buyertoopoor'), 'error')
            end

            config.addPlayerFunds(player, currencyType, sellAmount, 'vehicle-sold-to-player')
            config.removePlayerFunds(target, currencyType, sellAmount, 'vehicle-bought-from-player')
        end

        exports.morph_vehicles:SetPlayerVehicleOwner(row.id, targetcid)
        config.giveKeys(buyerId, row.plate, vehicle)

        local sellerMessage = sellAmount > 0 and locale('success.soldfor') .. lib.math.groupdigits(sellAmount) or locale('success.gifted')
        local buyerMessage = sellAmount > 0 and locale('success.boughtfor') .. lib.math.groupdigits(sellAmount) or locale('success.received_gift')

        exports.morph_junjie:Notify(source, sellerMessage, 'success')
        exports.morph_junjie:Notify(buyerId, buyerMessage, 'success')
        if isFinanced then
            SetHasFinanced(buyerId, true)
        end
    end, GetEntityModel(vehicle), sellAmount)
end)
