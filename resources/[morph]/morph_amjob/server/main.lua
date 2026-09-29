local sharedConfig = require 'config.shared'

---@alias source number

lib.callback.register('morph_amjob:server:getPlayerStatus', function(_, targetSrc)
	return exports.morph_medical:GetPlayerStatus(targetSrc)
end)

local function alertAmbulance(src, text)
	local ped = GetPlayerPed(src)
	local coords = GetEntityCoords(ped)
	local players = exports.morph_junjie:GetQBPlayers()
	for _, v in pairs(players) do
		if v.PlayerData.job.type == 'ems' and v.PlayerData.job.onduty then
			TriggerClientEvent('hospital:client:ambulanceAlert', v.PlayerData.source, coords, text)
		end
	end
end

local function registerArmory()
	for _, armory in pairs(sharedConfig.locations.armory) do
		exports.morph_inv:RegisterShop(armory.shopType, armory)
	end
end

local function registerStashes()
    for _, stash in pairs(sharedConfig.locations.stash) do
        exports.morph_inv:RegisterStash(stash.name, stash.label, stash.slots, stash.weight, stash.owner, stash.groups, stash.location)
    end
end

RegisterNetEvent('hospital:server:ambulanceAlert', function(text)
	if GetInvokingResource() then return end
	local src = source
	alertAmbulance(src, text or locale('info.civ_down'))
end)

RegisterNetEvent('hospital:server:emergencyAlert', function()
	if GetInvokingResource() then return end
	local src = source
	local player = exports.morph_junjie:GetPlayer(src)
	alertAmbulance(src, locale('info.ems_down', player.PlayerData.charinfo.lastname))
end)

RegisterNetEvent('morph_medical:server:onPlayerLaststand', function()
	if GetInvokingResource() then return end
	local src = source
	alertAmbulance(src, locale('info.civ_down'))
end)

---@param playerId number
RegisterNetEvent('hospital:server:TreatWounds', function(playerId)
	if GetInvokingResource() then return end
	local src = source
	local player = exports.morph_junjie:GetPlayer(src)
	local patient = exports.morph_junjie:GetPlayer(playerId)
	if player.PlayerData.job.type ~= 'ems' or not patient then return end

	if exports.morph_inv:RemoveItem(src, 'bandage', 1) then
        TriggerClientEvent('hospital:client:HealInjuries', patient.PlayerData.source, 'full')
    else
        exports.morph_junjie:Notify(src, locale('error.no_bandage'), 'error')
    end
end)

---@param playerId number
RegisterNetEvent('hospital:server:RevivePlayer', function(playerId)
	if GetInvokingResource() then return end
	local player = exports.morph_junjie:GetPlayer(source)
	local patient = exports.morph_junjie:GetPlayer(playerId)
	if not patient then return end

    if player.PlayerData.job.type ~= 'ems' then
        lib.logger(source, 'RevivePlayer', ('"%s" triggered event for "%s" bus was missing the required job'):format(player.PlayerData.citizenid, patient.PlayerData.citizenid or ''))
        return
    end

	if exports.morph_inv:RemoveItem(player.PlayerData.source, 'firstaid', 1) then
        TriggerClientEvent('morph_medical:client:playerRevived', patient.PlayerData.source)
    else
        exports.morph_junjie:Notify(player.PlayerData.source, locale('error.no_firstaid'), 'error')
    end
end)

---@param targetId number
RegisterNetEvent('hospital:server:UseFirstAid', function(targetId)
	if GetInvokingResource() then return end
	local src = source
	local target = exports.morph_junjie:GetPlayer(targetId)
	if not target then return end

	local canHelp = lib.callback.await('hospital:client:canHelp', targetId)
	if not canHelp then
		exports.morph_junjie:Notify(src, locale('error.cant_help'), 'error')
		return
	end

	TriggerClientEvent('hospital:client:HelpPerson', src, targetId)
end)

lib.callback.register('morph_amjob:server:getNumDoctors', function()
	return exports.morph_junjie:GetDutyCountType('ems')
end)

lib.addCommand('911e', {
    help = locale('info.ems_report'),
    params = {
        {name = 'message', help = locale('info.message_sent'), type = 'longString', optional = true},
    }
}, function(source, args)
	local message = args.message or locale('info.civ_call')
	local ped = GetPlayerPed(source)
	local coords = GetEntityCoords(ped)
	local players = exports.morph_junjie:GetQBPlayers()
	for _, v in pairs(players) do
		if v.PlayerData.job.type == 'ems' and v.PlayerData.job.onduty then
			TriggerClientEvent('hospital:client:ambulanceAlert', v.PlayerData.source, coords, message)
		end
	end
end)

---@param src number
---@param event string
local function triggerEventOnEmsPlayer(src, event)
	local player = exports.morph_junjie:GetPlayer(src)
	if player.PlayerData.job.type ~= 'ems' then
		exports.morph_junjie:Notify(src, locale('error.not_ems'), 'error')
		return
	end

	TriggerClientEvent(event, src)
end

lib.addCommand('status', {
    help = locale('info.check_health'),
}, function(source)
	triggerEventOnEmsPlayer(source, 'hospital:client:CheckStatus')
end)

lib.addCommand('heal', {
    help = locale('info.heal_player'),
}, function(source)
	triggerEventOnEmsPlayer(source, 'hospital:client:TreatWounds')
end)

lib.addCommand('revivep', {
    help = locale('info.revive_player'),
}, function(source)
	triggerEventOnEmsPlayer(source, 'hospital:client:RevivePlayer')
end)

-- Items
---@param src number
---@param item table
---@param event string
local function triggerItemEventOnPlayer(src, item, event)
	local player = exports.morph_junjie:GetPlayer(src)
	if not player then return end

	if exports.morph_inv:Search(src, 'count', item.name) == 0 then return end

	local removeItem = lib.callback.await(event, src)
	if not removeItem then return end

	exports.morph_inv:RemoveItem(src, item.name, 1)
end

exports.morph_junjie:CreateUseableItem('ifaks_stress', function(source, item)
	triggerItemEventOnPlayer(source, item, 'hospital:client:UseIfaks')
end)

exports.morph_junjie:CreateUseableItem('bandage', function(source, item)
	triggerItemEventOnPlayer(source, item, 'hospital:client:UseBandage')
end)

exports.morph_junjie:CreateUseableItem('painkillers', function(source, item)
	triggerItemEventOnPlayer(source, item, 'hospital:client:UsePainkillers')
end)

exports.morph_junjie:CreateUseableItem('firstaid', function(source, item)
	triggerItemEventOnPlayer(source, item, 'hospital:client:UseFirstAid')
end)

RegisterNetEvent('morph_medical:server:playerDied', function()
	if GetInvokingResource() then return end
	local src = source
	alertAmbulance(src, locale('info.civ_died'))
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    registerArmory()
    registerStashes()
end)