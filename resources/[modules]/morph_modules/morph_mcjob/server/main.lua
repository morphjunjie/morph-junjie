local config = require 'morph_mcjob.config.server'
local sharedConfig = require 'morph_mcjob.config.shared'
local vehicleStatus, vehicleDrivingDistance = {}, {}

local stash = { id = 'mechanicstash', label = locale('labels.stash'), slots = 500, weight = 4000000, owner = false, groups = {mechanic = 0}, coords = sharedConfig.locations.stash }
exports.morph_inv:RegisterStash(stash.id, stash.label, stash.slots, stash.weight, stash.owner, stash.groups, stash.coords)

local function isVehicleOwned(plate) return MySQL.scalar.await('SELECT 1 from player_vehicles WHERE plate = ?', {plate}) end
local function getVehicleStatus(plate) local r = MySQL.query.await('SELECT status FROM player_vehicles WHERE plate = ?', {plate}); return r[1] and r[1].status and json.decode(r[1].status) end
local function isAuthorized(cid) for i = 1, #config.authorizedIds do if config.authorizedIds[i] == cid then return true end end; return false end

lib.callback.register('qb-vehicletuning:server:GetDrivingDistances', function() return vehicleDrivingDistance end)
lib.callback.register('qb-vehicletuning:server:IsVehicleOwned', function(_, plate) return MySQL.scalar.await('SELECT 1 from player_vehicles WHERE plate = ?', {plate}) end)
lib.callback.register('qb-vehicletuning:server:GetAttachedVehicle', function() return sharedConfig.plates end)
lib.callback.register('morph_mcjob:server:spawnVehicle', function(src, name, coords) return qbx.spawnVehicle({ model = joaat(name), spawnSource = coords, warp = GetPlayerPed(src) }) end)

lib.callback.register('morph_mcjob:server:checkForItems', function(src, part)
    local item, cost = sharedConfig.repairCostAmount[part].item, sharedConfig.repairCostAmount[part].costs
    local has = exports.morph_inv:Search(src, 'count', item) >= cost
    if has then exports.morph_inv:RemoveItem(src, item, cost) end
    return has
end)

RegisterNetEvent('qb-vehicletuning:server:SaveVehicleProps', function(props) if isVehicleOwned(props.plate) then MySQL.update.await('UPDATE player_vehicles SET mods = ? WHERE plate = ?', {json.encode(props), props.plate}) end end)

RegisterNetEvent('vehiclemod:server:setupVehicleStatus', function(plate, engine, body)
    local status = vehicleStatus[plate] or getVehicleStatus(plate) or { engine = engine or 1000, body = body or 1000, radiator = sharedConfig.maxStatusValues.radiator, axle = sharedConfig.maxStatusValues.axle, brakes = sharedConfig.maxStatusValues.brakes, clutch = sharedConfig.maxStatusValues.clutch, fuel = sharedConfig.maxStatusValues.fuel }
    vehicleStatus[plate] = status
    TriggerClientEvent("vehiclemod:client:setVehicleStatus", -1, plate, status)
end)

RegisterNetEvent('qb-vehicletuning:server:UpdateDrivingDistance', function(amt, plate)
    vehicleDrivingDistance[plate] = amt
    TriggerClientEvent('qb-vehicletuning:client:UpdateDrivingDistance', -1, amt, plate)
    if MySQL.query.await('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})[1] then MySQL.update.await('UPDATE player_vehicles SET drivingdistance = ? WHERE plate = ?', {amt, plate}) end
end)

RegisterNetEvent('qb-vehicletuning:server:LoadStatus', function(veh, plate) vehicleStatus[plate] = veh; TriggerClientEvent("vehiclemod:client:setVehicleStatus", -1, plate, veh) end)

RegisterNetEvent('vehiclemod:server:updatePart', function(plate, part, level)
    if not vehicleStatus[plate] then return end
    local max = (part == "engine" or part == "body") and 1000 or 100
    vehicleStatus[plate][part] = level < 0 and 0 or level > max and max or level
    TriggerClientEvent("vehiclemod:client:setVehicleStatus", -1, plate, vehicleStatus[plate])
end)

RegisterNetEvent('qb-vehicletuning:server:SetPartLevel', function(plate, part, level) if vehicleStatus[plate] then vehicleStatus[plate][part] = level; TriggerClientEvent("vehiclemod:client:setVehicleStatus", -1, plate, vehicleStatus[plate]) end end)

RegisterNetEvent('vehiclemod:server:fixEverything', function(plate)
    if not vehicleStatus[plate] then return end
    for k, v in pairs(sharedConfig.maxStatusValues) do vehicleStatus[plate][k] = v end
    TriggerClientEvent("vehiclemod:client:setVehicleStatus", -1, plate, vehicleStatus[plate])
end)

RegisterNetEvent('vehiclemod:server:saveStatus', function(plate) if vehicleStatus[plate] then MySQL.update.await('UPDATE player_vehicles SET status = ? WHERE plate = ?', { json.encode(vehicleStatus[plate]), plate }) end end)

RegisterNetEvent('qb-vehicletuning:server:SetAttachedVehicle', function(k, veh) if sharedConfig.plates[k] then sharedConfig.plates[k].AttachedVehicle = veh; TriggerClientEvent('qb-vehicletuning:client:SetAttachedVehicle', -1, veh, k) end end)

lib.addCommand('setvehiclestatus', { help = 'Set Vehicle Status', params = { { name = 'part', type = 'string', help = 'Part Name' }, { name = 'amount', type = 'number', help = 'Percentage' } }, restricted = 'group.god' }, function(src, args) TriggerClientEvent("vehiclemod:client:setPartLevel", src, args.part:lower(), args.amount) end)

lib.addCommand('setmechanic', { help = 'Give Mechanic Job', params = { { name = 'target', type = 'playerId', help = 'Player ID' } } }, function(src, args)
    local p = exports.morph_junjie:GetPlayer(src)
    if not isAuthorized(p.PlayerData.citizenid) then return TriggerClientEvent('QBCore:Notify', src, "You Cannot Do This!", "error") end
    if not args.target then return TriggerClientEvent('QBCore:Notify', src, "You Must Provide A Player ID!", "error") end
    local target = exports.morph_junjie:GetPlayer(args.target)
    if not target then return end
    target.Functions.SetJob("mechanic")
    TriggerClientEvent('QBCore:Notify', target.PlayerData.source, "You Were Hired As An Autocare Employee!")
    TriggerClientEvent('QBCore:Notify', src, "You Hired (" .. target.PlayerData.charinfo.firstname .. ") As Autocare Employee!")
end)

lib.addCommand('firemechanic', { help = 'Fire A Mechanic', params = { { name = 'target', type = 'playerId', help = 'Player ID' } } }, function(src, args)
    local p = exports.morph_junjie:GetPlayer(src)
    if not isAuthorized(p.PlayerData.citizenid) then return TriggerClientEvent('QBCore:Notify', src, "You Cannot Do This!", "error") end
    if not args.target then return TriggerClientEvent('QBCore:Notify', src, "You Must Provide A Player ID!", "error") end
    local target = exports.morph_junjie:GetPlayer(args.target)
    if not target or target.PlayerData.job.name ~= "mechanic" then return TriggerClientEvent('QBCore:Notify', src, "Not A Mechanic!", "error") end
    target.Functions.SetJob("unemployed")
    TriggerClientEvent('QBCore:Notify', target.PlayerData.source, "You Were Fired From Autocare!")
    TriggerClientEvent('QBCore:Notify', src, "You Fired (" .. target.PlayerData.charinfo.firstname .. ") From Autocare!")
end)