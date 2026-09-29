-- Vehicles
RegisterServerEvent('!morphjunjie:enteringVehicle', function(veh, seat, modelName, netId)
    local src = source
    local data = {
        vehicle = veh,
        seat = seat,
        name = modelName,
        netId = netId,
        event = 'Entering'
    }
    TriggerClientEvent('QBCore:Client:VehicleInfo', src, data)
end)

RegisterServerEvent('!morphjunjie:enteredVehicle', function(veh, seat, modelName, netId)
    local src = source
    local data = {
        vehicle = veh,
        seat = seat,
        name = modelName,
        netId = netId,
        event = 'Entered'
    }
    TriggerClientEvent('QBCore:Client:VehicleInfo', src, data)
end)

RegisterServerEvent('!morphjunjie:enteringAborted', function()
    local src = source
    TriggerClientEvent('QBCore:Client:AbortVehicleEntering', src)
end)

RegisterServerEvent('!morphjunjie:leftVehicle', function(veh, seat, modelName, netId)
    local src = source
    local data = {
        vehicle = veh,
        seat = seat,
        name = modelName,
        netId = netId,
        event = 'Left'
    }
    TriggerClientEvent('QBCore:Client:VehicleInfo', src, data)
end)