local config = require 'config'

if not config then return end

if config.versionCheck then lib.versionCheck('overextended/morph_fuel') end

local morph_inv = exports.morph_inv

---@param vehicle number
---@param fuel number
---@param reduceOnly? boolean Don't allow fuel to be increased, unless fuel state has not been initialised.
local function setFuelState(vehicle, fuel, reduceOnly)
	if vehicle == 0 or GetEntityType(vehicle) ~= 2 then
		return
	end

	local state = Entity(vehicle).state
	fuel = math.clamp(fuel, 0, reduceOnly and state.fuel or 100)

	state:set('fuel', fuel, true)
end

---@param playerId number
---@param price number
---@return boolean?
local function defaultPaymentMethod(playerId, price)
	local success = morph_inv:RemoveItem(playerId, 'money', price)

	if success then return true end

	local money = morph_inv:GetItemCount(playerId, 'money')

	TriggerClientEvent('morph_ui:notify', playerId, {
		type = 'error',
		description = locale('not_enough_money', price - money)
	})
end

local payMoney = defaultPaymentMethod

exports('setPaymentMethod', function(fn)
	payMoney = fn or defaultPaymentMethod
end)

RegisterNetEvent('morph_fuel:pay', function(price, fuel, netid)
	assert(type(price) == 'number', ('Price expected a number, received %s'):format(type(price)))
	local source = source
	if not payMoney(source, price) then return end

	fuel = math.floor(fuel)
	setFuelState(NetworkGetEntityFromNetworkId(netid), fuel)

	TriggerClientEvent('morph_ui:notify', source, {
		type = 'success',
		description = locale('fuel_success', fuel, price)
	})
end)

RegisterNetEvent('morph_fuel:fuelCan', function(hasCan, price)
	local source = source
	if hasCan then
		local item = morph_inv:GetCurrentWeapon(source)

		if not item or item.name ~= 'WEAPON_PETROLCAN' or not payMoney(source, price) then return end

		item.metadata.durability = 100
		item.metadata.ammo = 100

		morph_inv:SetMetadata(source, item.slot, item.metadata)

		TriggerClientEvent('morph_ui:notify', source, {
			type = 'success',
			description = locale('petrolcan_refill', price)
		})
	else
		if not morph_inv:CanCarryItem(source, 'WEAPON_PETROLCAN', 1) then
			return TriggerClientEvent('morph_ui:notify', source, {
				type = 'error',
				description = locale('petrolcan_cannot_carry')
			})
		end

		if not payMoney(source, price) then return end

		morph_inv:AddItem(source, 'WEAPON_PETROLCAN', 1)

		TriggerClientEvent('morph_ui:notify', source, {
			type = 'success',
			description = locale('petrolcan_buy', price)
		})
	end
end)

RegisterNetEvent('morph_fuel:updateFuelCan', function(durability, netid, fuel)
	local source = source
	local item = morph_inv:GetCurrentWeapon(source)

	if item and durability > 0 then
		durability = math.floor(item.metadata.durability - durability)
		item.metadata.durability = durability
		item.metadata.ammo = durability

		morph_inv:SetMetadata(source, item.slot, item.metadata)
		setFuelState(NetworkGetEntityFromNetworkId(netid), fuel)
	end

	-- player is sus?
end)

RegisterNetEvent('morph_fuel:setFuel', function(fuel)
	local playerPed = GetPlayerPed(source)
	local handle = GetVehiclePedIsIn(playerPed, false)

	setFuelState(handle, fuel, true)
end)