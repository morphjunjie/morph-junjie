local Config = require 'morph_warehouse.config'
local QBX = exports.morph_junjie

---@param citizenid string
---@return string
local function GetStashId(citizenid)
    return ('warehouse_%s'):format(citizenid)
end

---@param citizenid string
---@param locationLabel string?
local function EnsureStashRegistered(citizenid, locationLabel)
    exports.morph_inv:RegisterStash(
        GetStashId(citizenid),
        locationLabel and ('Warehouse Storage - %s'):format(locationLabel) or 'Warehouse Storage',
        Config.StorageSlots,
        Config.StorageWeight,
        citizenid
    )
end

---@param citizenid string
---@return table?
local function GetWarehouseRecord(citizenid)
    return MySQL.single.await('SELECT * FROM player_warehouses WHERE citizenid = ?', { citizenid })
end

---@param title string
---@param description string
---@param color number
local function SendLog(title, description, color)
    if Config.DiscordWebhook == '' then return end

    PerformHttpRequest(Config.DiscordWebhook, function() end, 'POST', json.encode({
        username = Config.DiscordUsername,
        embeds = { {
            title = title,
            description = description,
            color = color,
            footer = { text = os.date(Config.DateFormat) },
        } },
    }), { ['Content-Type'] = 'application/json' })
end

AddEventHandler('onResourceStart', function(resource)
    if resource ~= cache.resource then return end

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `player_warehouses` (
            `citizenid` VARCHAR(50) NOT NULL,
            `expires_at` INT NOT NULL DEFAULT 0,
            `rented_at` INT NOT NULL DEFAULT 0,
            PRIMARY KEY (`citizenid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end)

-- Returns the current state of the player's storage: none / expired / active
lib.callback.register('morph_warehouse:checkStorage', function(source, locationLabel)
    local player = QBX:GetPlayer(source)
    if not player then return { state = 'error' } end

    local citizenid = player.PlayerData.citizenid
    local record = GetWarehouseRecord(citizenid)

    if not record then
        return { state = 'none' }
    end

    if record.expires_at < os.time() then
        return {
            state = 'expired',
            expiresLabel = os.date(Config.DateFormat, record.expires_at),
        }
    end

    EnsureStashRegistered(citizenid, locationLabel)

    return {
        state = 'active',
        stashId = GetStashId(citizenid),
        expiresLabel = os.date(Config.DateFormat, record.expires_at),
    }
end)

-- Rents a new storage, or extends/renews an existing one
lib.callback.register('morph_warehouse:rentStorage', function(source, days, method, locationLabel)
    local player = QBX:GetPlayer(source)
    if not player then return false, 'error' end

    days = tonumber(days)
    if not days or days < 1 or days > Config.MaxDays then
        return false, 'invalid_days'
    end

    if method ~= 'cash' and method ~= 'bank' then
        return false, 'invalid_method'
    end

    local cost = days * Config.DailyPrice
    local balance = player.Functions.GetMoney(method)

    if not balance or balance < cost then
        return false, 'no_money'
    end

    local citizenid = player.PlayerData.citizenid
    local record = GetWarehouseRecord(citizenid)
    local now = os.time()
    local isRenewal = record ~= nil

    -- If the storage is still active, extend from its current expiry.
    -- If it has expired (or is new), start counting from now.
    local baseTime = (record and record.expires_at > now) and record.expires_at or now
    local newExpiry = baseTime + (days * 86400)

    if not player.Functions.RemoveMoney(method, cost, 'warehouse-rental') then
        return false, 'no_money'
    end

    if record then
        MySQL.update.await('UPDATE player_warehouses SET expires_at = ? WHERE citizenid = ?', { newExpiry, citizenid })
    else
        MySQL.insert.await('INSERT INTO player_warehouses (citizenid, expires_at, rented_at) VALUES (?, ?, ?)', { citizenid, newExpiry, now })
    end

    EnsureStashRegistered(citizenid, locationLabel)

    local charName = ('%s %s'):format(player.PlayerData.charinfo.firstname, player.PlayerData.charinfo.lastname)

    SendLog(
        isRenewal and 'Warehouse Storage Renewed' or 'Warehouse Storage Rented',
        string.format(
            'Player: %s\nCitizen ID: %s\nDuration: %d day(s)\nCost: %s%d\nPayment Method: %s\nNew Expiry: %s',
            charName, citizenid, days, Config.Currency, cost, method:upper(), os.date(Config.DateFormat, newExpiry)
        ),
        isRenewal and 3901635 or 3066993
    )

    return true, {
        days = days,
        isRenewal = isRenewal,
        expiresLabel = os.date(Config.DateFormat, newExpiry),
    }
end)

AddEventHandler('playerDropped', function()
    -- Nothing to clean up: storage state lives entirely in the database.
end)

--[[
    Hook 1: Blacklist enforcement.
    Only invoked for blacklisted items being moved into or out of a warehouse stash.
    Always rejects the transfer.
]]
local blacklistHookId = exports.morph_inv:registerHook('swapItems', function(payload)
    return false
end, {
    print = false,
    inventoryFilter = { '^warehouse_' },
    itemFilter = Config.Blacklist,
})

AddEventHandler(blacklistHookId, function(success, payload)
    local source = payload.source
    local player = source and QBX:GetPlayer(source)
    if not player then return end

    local item = (payload.fromSlot and payload.fromSlot.name) or (payload.toSlot and payload.toSlot.name) or 'unknown'
    local charName = ('%s %s'):format(player.PlayerData.charinfo.firstname, player.PlayerData.charinfo.lastname)

    SendLog(
        'Warehouse Blacklisted Item Blocked',
        string.format('Player: %s\nCitizen ID: %s\nItem: %s\nResult: Transfer denied', charName, player.PlayerData.citizenid, item),
        15158332
    )
end)

--[[
    Hook 2: Deposit / withdrawal logging.
    Invoked for every item moved into or out of a warehouse stash (blacklisted items
    never reach this point successfully, since the hook above already rejects them).
]]
local logHookId = exports.morph_inv:registerHook('swapItems', function(payload)
    return true
end, {
    inventoryFilter = { '^warehouse_' },
})

AddEventHandler(logHookId, function(success, payload)
    if not success then return end

    local source = payload.source
    local player = source and QBX:GetPlayer(source)
    if not player then return end

    local toWarehouse = type(payload.toInventory) == 'string' and payload.toInventory:find('^warehouse_') ~= nil
    local item = (payload.fromSlot and payload.fromSlot.name) or (payload.toSlot and payload.toSlot.name) or 'unknown'
    local count = payload.count or 1
    local charName = ('%s %s'):format(player.PlayerData.charinfo.firstname, player.PlayerData.charinfo.lastname)

    SendLog(
        toWarehouse and 'Warehouse Item Deposited' or 'Warehouse Item Withdrawn',
        string.format('Player: %s\nCitizen ID: %s\nItem: %s\nAmount: %d', charName, player.PlayerData.citizenid, item, count),
        toWarehouse and 3066993 or 15105570
    )
end)

print(('^2[morph_warehouse] Loaded. %d storage locations available.^7'):format(#Config.Locations))