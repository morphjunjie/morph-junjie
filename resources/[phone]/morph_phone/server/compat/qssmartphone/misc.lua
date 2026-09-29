---@type table Shared shim helpers (server.compat.qssmartphone.shared): export registration + warn-once.
local shim = require 'server.compat.qssmartphone.shared'
---@type table SIM feature flags (server.sim.state): whether SIM trays exist at all this session.
local simState = require 'server.sim.state'
---@type table SIM session (server.sim.session): the phone a player is actually acting on.
local session = require 'server.sim.session'
---@type table SIM inventory glue (server.sim.inv): the phone items a player carries.
local siminv = require 'server.sim.inv'

local registerExport, stubExport, stubPro, warnOnce =
    shim.registerExport, shim.stubExport, shim.stubPro, shim.warnOnce

---The acting player's server id inside an morph_inv item-use export, which hands the inventory
---rather than the source.
---@param inventory any
---@return number|nil
local function sourceOf(inventory)
    if type(inventory) == 'table' then return tonumber(inventory.id or inventory.source) end
    return tonumber(inventory)
end

---The inventory slot of the PHONE a player is acting on: their SIM session's active phone, else the
---first phone item they carry. morph_phone's tray is addressed by the phone's slot, never the SIM's.
---@param src number player server id
---@return number|nil slot
local function phoneSlotOf(src)
    local resolved = session.resolve(src)
    if resolved and resolved.slot then return resolved.slot end

    local phones = siminv.findPhones(src)
    return phones[1] and phones[1].slot or nil
end

---useSimCard(event, item, inventory, slot): the morph_inv item-use export for the SIM item, which
---opens the SIM tray of the PHONE the player carries. Only meaningful while unique phones are on.
---@param event string|nil morph_inv hook name; nil when a caller invokes the export directly
---@param item any the sim_card item being used
---@param inventory any the using player's inventory, or their server id
---@param slot any the SIM ITEM's own slot, which is never the phone's and is not forwarded
registerExport('useSimCard', function(event, item, inventory, slot)
    if event ~= 'usingItem' and event ~= nil then return end

    local src = sourceOf(inventory)
    if not src then return end

    if not simState.active then
        warnOnce('useSimCard', ('useSimCard was called (by %s) while morph_phone is not running unique phones, so there is no SIM tray to open; every character already has one permanent number'):format(GetInvokingResource() or 'unknown'))
        return
    end
    if simState.mode ~= 'tray' then
        warnOnce('useSimCard.mode', ('useSimCard was called (by %s) while morph_phone attaches SIMs to the phone item itself rather than to a tray, so there is no tray to open; install a number with exports["morph_phone"]:giveSimCard(source, opts) instead'):format(GetInvokingResource() or 'unknown'))
        return
    end

    local phoneSlot = phoneSlotOf(src)
    if not phoneSlot then return end

    TriggerClientEvent('morph_phone:client:compat:qs:openSimTray', src, phoneSlot)
end)

-- Wireless earbuds and the powerbank have no morph_phone counterpart. Bluetooth audio is modelled as
-- devices another resource registers (registerBluetoothDevice), not as an inventory item, and the
-- battery is a cosmetic drain counter with no stored charge to top up.
stubExport('useWirelessEarbuds', nil,
    'has no morph_phone equivalent: Bluetooth audio is modelled as devices a resource registers with exports["morph_phone"]:registerBluetoothDevice, not as a worn item')
stubExport('usePowerbank', nil,
    'has no morph_phone equivalent: the morph_phone battery is a cosmetic status-bar drain, not a stored charge, so there is nothing to recharge')

-- The crypto DLC's undocumented balance writer. morph_phone's Crypto is a market simulation with no
-- external grant path, so a caller's award has nowhere to land.
stubExport('AddCrypto', false,
    'has no morph_phone equivalent: morph_phone Crypto is a price simulation with no external grant path')

-- PRO's undocumented unique-phone item hook. morph_phone reads phone ownership from the inventory on
-- demand rather than caching it, so a removed phone needs no notification to stay correct.
stubPro('handleDeleteItem', nil,
    'is not needed on morph_phone: phone ownership is read from the inventory on demand, so removing a phone item takes effect without a hook')

-- The Dynamic Island and housing-charger exports are per-player and live on the CLIENT in morph_phone,
-- but Quasar's own developer-api page lists them under Server Exports, so callers reach for them on
-- this side too. Registering the names here means such a call warns and returns rather than raising
-- "No such export" inside a housing script.
stubExport('showDynamicIsland', false,
    'is a client surface in morph_phone: call it from the client, where the island is rendered as a notification banner')
stubExport('updateDynamicIsland', false,
    'is a client surface in morph_phone: call it from the client, where the island is rendered as a notification banner')
stubExport('hideDynamicIsland', false,
    'is a client surface in morph_phone: call it from the client, where the island is rendered as a notification banner')
stubExport('getDynamicIsland', nil,
    'is a client surface in morph_phone: call it from the client, which holds the island registry')
stubExport('getAllDynamicIslands', {},
    'is a client surface in morph_phone: call it from the client, which holds the island registry')
stubExport('hasDynamicIsland', false,
    'is a client surface in morph_phone: call it from the client, which holds the island registry')

stubExport('BatteryRegisterHousingCharger', false,
    'has no morph_phone equivalent: the battery is a cosmetic drain counter with no charging, so a charging point has nothing to charge')
stubExport('BatteryUnregisterHousingCharger', false,
    'has no morph_phone equivalent: the battery is a cosmetic drain counter with no charging, so there is no charger to unregister')
