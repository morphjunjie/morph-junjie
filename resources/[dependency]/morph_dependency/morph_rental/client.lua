-- client.lua
local config = require 'morph_rental.config'
local rentalActive, rentalEndTime, rentedVehicle = false, 0, nil
local busyCategories, categoryIndexes = {}, {}
local rentalTargetId = nil

local function Notify(desc, type, duration) lib.notify({ title = 'Bicycle Rental', description = desc, type = type or 'info', duration = duration or 3000 }) end
local function getNextCategoryId() for i = 62, 63 do if not categoryIndexes[i] then categoryIndexes[i] = true; return i end end end
local function setBlipCategory(blip, name)
    local id = busyCategories[name] or getNextCategoryId()
    if not id then return end
    if not busyCategories[name] then busyCategories[name] = id; AddTextEntry("BLIP_CAT_" .. id, name) end
    SetBlipCategory(blip, id)
end
exports('setBlipCategory', setBlipCategory); Blip = { setBlipCategory = setBlipCategory }

local function CreateRentalBlips()
    for _, target in ipairs(Config.Target) do
        local blip = AddBlipForCoord(target.Coords.x, target.Coords.y, target.Coords.z)
        SetBlipSprite(blip, 226); SetBlipDisplay(blip, 4); SetBlipScale(blip, 0.6); SetBlipColour(blip, 3); SetBlipAsShortRange(blip, true)
        setBlipCategory(blip, "Morph Rental")
        BeginTextCommandSetBlipName("STRING"); AddTextComponentString(target.Label or "Bicycle Rental"); EndTextCommandSetBlipName(blip)
    end
end

local function addRentalTarget(vehicle)
    if rentalTargetId then exports.morph_tget:removeLocalEntity(rentalTargetId, 'return_bike'); rentalTargetId = nil end
    rentalTargetId = exports.morph_tget:addLocalEntity(vehicle, { {
        name = 'return_bike',
        label = 'Return Bicycle',
        icon = 'fa-solid fa-rotate-left',
        distance = 2.5,
        onSelect = function()
            if not rentalActive then Notify('No active rental found.', 'error') return end
            if not DoesEntityExist(rentedVehicle) then Notify('Vehicle not found.', 'error'); rentalActive = false; TriggerServerEvent('morph_bikerental:server:returnBike'); return end
            local ped, pedCoords, vehCoords = PlayerPedId(), GetEntityCoords(PlayerPedId()), GetEntityCoords(rentedVehicle)
            if #(pedCoords - vehCoords) > 5.0 then Notify('You are too far from the bicycle!', 'error') return end
            if GetVehiclePedIsIn(ped, false) == rentedVehicle then TaskLeaveVehicle(ped, rentedVehicle, 0); Wait(1000) end
            DeleteVehicle(rentedVehicle); rentalActive = false; lib.hideTextUI()
            if rentalTargetId then exports.morph_tget:removeLocalEntity(rentalTargetId, 'return_bike'); rentalTargetId = nil end
            TriggerServerEvent('morph_bikerental:server:returnBike')
        end
    } })
end

CreateThread(function()
    CreateRentalBlips()
    for i, target in ipairs(Config.Target) do exports.morph_tget:addBoxZone({
        name = 'bike_rental_' .. i,
        coords = target.Coords,
        size = target.Size,
        rotation = target.Heading,
        options = { {
            name = 'bike_menu_' .. i,
            icon = 'fa-solid fa-bicycle',
            label = target.Label,
            distance = 2.0,
            onSelect = function()
                local rentLabel = rentalActive and 'Rental Active' or 'Rent New Bicycle'
                local rentDesc = rentalActive and 'You have an active rental' or string.format('Rate: %s%d/min | Limit: %d-%d mins', Config.Currency, Config.PricePerMinute, Config.MinMinutes, Config.MaxMinutes)
                lib.registerContext({
                    id = 'bike_rental_menu',
                    title = 'Bicycle Rental',
                    options = { {
                        title = rentLabel,
                        description = rentDesc,
                        icon = 'bicycle',
                        image = Config.UI.Image,
                        disabled = rentalActive,
                        metadata = { { label = 'Price', value = string.format('%s%d per min', Config.Currency, Config.PricePerMinute) }, { label = 'Limit', value = string.format('%d - %d mins', Config.MinMinutes, Config.MaxMinutes) } },
                        onSelect = function()
                            local input = lib.inputDialog('Bicycle Rental', {
                                { type = 'number', label = 'Duration (Minutes)', description = 'How long do you want to ride?', icon = 'clock', min = Config.MinMinutes, max = Config.MaxMinutes, required = true, default = Config.MinMinutes },
                                { type = 'select', label = 'Payment Method', description = 'Select your payment method', icon = 'wallet', required = true, default = 'cash', options = { { value = 'cash', label = 'Cash Payment' }, { value = 'bank', label = 'Bank Transfer' } } }
                            })
                            if input then TriggerServerEvent('morph_bikerental:server:rentBike', input[1], i, input[2]) end
                        end
                    }, {
                        title = 'Return Bicycle',
                        description = rentalActive and 'Return your bike and get deposit back' or 'No active rental found',
                        icon = 'rotate-left',
                        disabled = not rentalActive,
                        onSelect = function()
                            if not rentalActive then return end
                            if DoesEntityExist(rentedVehicle) then
                                local ped = PlayerPedId()
                                if GetVehiclePedIsIn(ped, false) == rentedVehicle then TaskLeaveVehicle(ped, rentedVehicle, 0); Wait(1000) end
                                DeleteVehicle(rentedVehicle)
                            end
                            rentalActive = false; lib.hideTextUI()
                            if rentalTargetId then exports.morph_tget:removeLocalEntity(rentalTargetId, 'return_bike'); rentalTargetId = nil end
                            TriggerServerEvent('morph_bikerental:server:returnBike')
                        end
                    } }
                })
                lib.showContext('bike_rental_menu')
            end
        } }
    }) end
end)

RegisterNetEvent('morph_bikerental:client:rentalError', function(message)
    Notify(message, 'error')
end)

RegisterNetEvent('morph_bikerental:client:startRental', function(minutes, locationIndex, method, amount)
    rentalActive = true; rentalEndTime = GetGameTimer() + (minutes * 60000)
    local model = joaat(Config.BikeModel); lib.requestModel(model)
    local spawnLoc = Config.SpawnLocations[locationIndex] or Config.SpawnLocations[1]
    rentedVehicle = CreateVehicle(model, spawnLoc.x, spawnLoc.y, spawnLoc.z, spawnLoc.w, true, false)
    SetVehicleOnGroundProperly(rentedVehicle); TaskWarpPedIntoVehicle(PlayerPedId(), rentedVehicle, -1); Wait(500); addRentalTarget(rentedVehicle)
    Notify(string.format('Paid %s%d via %s for %d minutes', Config.Currency, amount, method:lower(), minutes), 'success')
    CreateThread(function()
        while rentalActive do
            local timeLeft = rentalEndTime - GetGameTimer()
            if timeLeft <= 0 then rentalActive = false; lib.hideTextUI()
                if DoesEntityExist(rentedVehicle) then DeleteVehicle(rentedVehicle) end
                if rentalTargetId then exports.morph_tget:removeLocalEntity(rentalTargetId, 'return_bike'); rentalTargetId = nil end
                TriggerServerEvent('morph_bikerental:server:endRental'); Notify('Rental time has expired', 'warning'); break
            end
            lib.showTextUI(string.format('Bicycle | %02d:%02d remaining', math.floor(timeLeft / 60000), math.floor((timeLeft % 60000) / 1000)), { position = 'left-center', icon = 'bicycle' })
            Wait(1000)
        end
    end)
end)

RegisterNetEvent('morph_bikerental:client:returnSuccess', function(deposit)
    Notify(string.format('Deposit of %s%d returned', Config.Currency, deposit), 'success')
end)

AddEventHandler('onResourceStop', function(res) if GetCurrentResourceName() == res then lib.hideTextUI(); if rentalTargetId then exports.morph_tget:removeLocalEntity(rentalTargetId, 'return_bike'); rentalTargetId = nil end end end)