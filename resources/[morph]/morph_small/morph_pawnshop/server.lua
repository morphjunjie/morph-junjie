-- server.lua
local config = require 'morph_pawnshop.config'

local eventRateLimit = {} -- per-player, per-action spam tracking
local marketPrices = {}   -- runtime cache: item -> current price
local basePrices = {}     -- item -> base price (from config)
local RATE_LIMIT = 15     -- max calls per action per player per minute before a ban

for i = 1, #config.pawnItems do
    local entry = config.pawnItems[i]
    basePrices[entry.item] = entry.price
end

-- bans a player who spams a sell/buy event faster than a real client ever would
local function checkEventSpamming(source, action)
    local currentTime = os.time()
    local key = source .. '_event_' .. action
    if not eventRateLimit[key] then
        eventRateLimit[key] = { count = 1, firstTime = currentTime }
        return false
    end
    local data = eventRateLimit[key]
    if currentTime - data.firstTime > 60 then
        eventRateLimit[key] = { count = 1, firstTime = currentTime }
        return false
    end
    data.count = data.count + 1
    if data.count >= RATE_LIMIT then
        exports.morph_junjie:ExploitBan(source, 'Executor Pawnshop')
        eventRateLimit[key] = nil
        return true
    end
    return false
end

-- rejects non-numeric, zero, negative, or fractional amounts sent straight to the server event
local function isValidAmount(amount)
    return type(amount) == 'number' and amount > 0 and amount == math.floor(amount)
end

local function getItemLabel(itemName)
    local itemInfo = exports.morph_inv:Items()[itemName]
    return itemInfo and itemInfo.label or itemName
end

local function getStock(itemName)
    return MySQL.scalar.await('SELECT stock FROM pawnshop_stocks WHERE item = ?', { itemName }) or 0
end

local function getCurrentPrice(itemName)
    return marketPrices[itemName] or basePrices[itemName] or 0
end

-- adds thousands separators to a number, e.g. 12345 -> "12,345"
local function formatNumber(n)
    local formatted = tostring(math.floor(n))
    local sign = ''
    if formatted:sub(1, 1) == '-' then
        sign = '-'
        formatted = formatted:sub(2)
    end
    local k
    repeat
        formatted, k = formatted:gsub('^(%d+)(%d%d%d)', '%1,%2')
    until k == 0
    return sign .. formatted
end

-- posts a market update to discord. role mention has to live in top-level "content",
-- discord does not ping roles from inside an embed no matter how it's formatted.
local function sendDiscordLog(changes)
    local webhook = config.market.discord.webhook
    if not webhook or webhook == '' then return end
    if #changes == 0 then return end

    local gainers, losers = {}, {}
    for i = 1, #changes do
        if changes[i].percent > 0 then
            gainers[#gainers + 1] = changes[i]
        elseif changes[i].percent < 0 then
            losers[#losers + 1] = changes[i]
        end
    end

    local fields = {}
    for i = 1, #changes do
        local c = changes[i]
        local arrow = c.percent >= 0 and '📈' or '📉'
        fields[#fields + 1] = {
            name = string.format('%s %s', arrow, c.label),
            value = string.format(
                '$%s ➜ $%s\n**%s%.1f%%**',
                formatNumber(c.oldPrice), formatNumber(c.newPrice),
                c.percent >= 0 and '+' or '', c.percent
            ),
            inline = true
        }
    end

    -- sell recommendations: items whose price went UP this cycle, sorted by
    -- the largest percentage gain first. Good time for players to sell those.
    table.sort(gainers, function(a, b) return a.percent > b.percent end)
    if #gainers > 0 then
        local recommendCount = math.min(config.market.recommendCount or 3, #gainers)
        local lines = {}
        for i = 1, recommendCount do
            local g = gainers[i]
            lines[#lines + 1] = string.format('• **%s** — $%s (+%.1f%%)', g.label, formatNumber(g.newPrice), g.percent)
        end
        fields[#fields + 1] = {
            name = '💡 Sell Recommendations',
            value = table.concat(lines, '\n'),
            inline = false
        }
    end

    -- embed color reflects the overall market trend this cycle: green if
    -- mostly gaining, red if mostly dropping, neutral blue if it's a wash
    local color = 3447003
    if #gainers > #losers then
        color = 3066993 -- green
    elseif #losers > #gainers then
        color = 15158332 -- red
    end

    PerformHttpRequest(webhook, function() end, 'POST', json.encode({
        username = config.market.discord.name,
        avatar_url = config.market.discord.avatar,
        embeds = {
            {
                title = '🏪 Pawnshop Market Update',
                description = string.format('**%d** items changed this cycle — **%d** up, **%d** down', #changes, #gainers, #losers),
                color = color,
                fields = fields,
                footer = { text = 'M.A.D. District' },
                timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'), -- Discord renders this natively (localized, relative on hover)
            }
        }
    }), { ['Content-Type'] = 'application/json' })
end

-- randomly nudges a handful of item prices within their configured deviation range
local function updateMarket()
    local items = {}
    for item in pairs(basePrices) do items[#items + 1] = item end
    if #items == 0 then return end

    local minCount = math.min(config.market.minItemsPerUpdate, #items)
    local maxCount = math.min(config.market.maxItemsPerUpdate, #items)
    if minCount > maxCount then minCount, maxCount = maxCount, minCount end -- guards against a misconfigured min/max
    local changeCount = math.random(minCount, maxCount)

    -- shuffle so the same items don't always change first
    for i = #items, 2, -1 do
        local j = math.random(i)
        items[i], items[j] = items[j], items[i]
    end

    local minPercent = math.min(config.market.minPercentChange, config.market.maxPercentChange)
    local maxPercent = math.max(config.market.minPercentChange, config.market.maxPercentChange)

    local changes = {}

    for i = 1, changeCount do
        local item = items[i]
        local basePrice = basePrices[item]
        local oldPrice = marketPrices[item] or basePrice

        local percent = math.random(minPercent * 10, maxPercent * 10) / 10
        if math.random(1, 2) == 1 then percent = -percent end

        local newPrice = math.floor(oldPrice * (1 + percent / 100) + 0.5)

        local minPrice = math.max(1, math.floor(basePrice * (1 - config.market.maxDeviation / 100)))
        local maxPrice = math.floor(basePrice * (1 + config.market.maxDeviation / 100))
        newPrice = math.max(minPrice, math.min(newPrice, maxPrice))

        if newPrice ~= oldPrice then
            marketPrices[item] = newPrice
            MySQL.update('UPDATE pawnshop_market SET price = ? WHERE item = ?', { newPrice, item })

            changes[#changes + 1] = {
                item = item,
                label = getItemLabel(item),
                oldPrice = oldPrice,
                newPrice = newPrice,
                percent = math.floor(((newPrice - oldPrice) / oldPrice) * 1000 + 0.5) / 10
            }
        end
    end

    if #changes > 0 then
        sendDiscordLog(changes)
    end
end

CreateThread(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `pawnshop_market` (
            `item` VARCHAR(50) NOT NULL PRIMARY KEY,
            `price` INT NOT NULL
        )
    ]])

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `pawnshop_stocks` (
            `item` VARCHAR(50) NOT NULL PRIMARY KEY,
            `stock` INT NOT NULL DEFAULT 0
        )
    ]])

    for item, basePrice in pairs(basePrices) do
        local existing = MySQL.scalar.await('SELECT price FROM pawnshop_market WHERE item = ?', { item })
        if existing then
            marketPrices[item] = existing
        else
            marketPrices[item] = basePrice
            MySQL.insert('INSERT INTO pawnshop_market (item, price) VALUES (?, ?)', { item, basePrice })
        end
    end

    while true do
        Wait(config.market.updateInterval * 60 * 1000)
        -- pcall so a single bad update (e.g. a config typo) can't silently kill this loop forever
        local ok, err = pcall(updateMarket)
        if not ok then
            print(('^1[Pawnshop] Market update failed: %s^7'):format(tostring(err)))
        end
    end
end)

lib.callback.register('qb-pawnshop:server:getMarketPrices', function(source)
    return marketPrices
end)

lib.callback.register('qb-pawnshop:server:getShopStock', function(source)
    return MySQL.query.await('SELECT * FROM pawnshop_stocks WHERE stock > 0')
end)

RegisterNetEvent('qb-pawnshop:server:sellPawnItems', function(itemName, itemAmount)
    local src = source
    if checkEventSpamming(src, 'sellPawnItems') then return end
    if not basePrices[itemName] then return end

    itemAmount = tonumber(itemAmount)
    if not isValidAmount(itemAmount) then
        exports.morph_junjie:ExploitBan(src, 'Executor Pawnshop (invalid sell amount)')
        return
    end

    local Player = exports.morph_junjie:GetPlayer(src)
    if not Player then return end

    local sellPrice = getCurrentPrice(itemName)
    local totalPrice, itemLabel = itemAmount * sellPrice, getItemLabel(itemName)

    if Player.Functions.RemoveItem(itemName, itemAmount) then
        Player.Functions.AddMoney(config.bankMoney and 'bank' or 'cash', totalPrice, 'pawnshop-sell')
        TriggerClientEvent('qb-pawnshop:client:playTradeSound', src)
        exports.morph_junjie:Notify(src, "Sold " .. itemAmount .. "x " .. itemLabel, 'success')
        TriggerClientEvent('inventory:client:ItemBox', src, exports.morph_inv:Items()[itemName], 'remove')
        MySQL.query('INSERT INTO pawnshop_stocks (item, stock) VALUES (?, ?) ON DUPLICATE KEY UPDATE stock = stock + ?', { itemName, itemAmount, itemAmount })
    end
end)

RegisterNetEvent('qb-pawnshop:server:buyItem', function(data)
    local src = source
    if checkEventSpamming(src, 'buyItem') then return end
    if type(data) ~= 'table' then return end

    local itemName = data.item
    local amount = tonumber(data.amount)
    if not itemName or not basePrices[itemName] then return end
    if not isValidAmount(amount) then
        exports.morph_junjie:ExploitBan(src, 'Executor Pawnshop (invalid buy amount)')
        return
    end

    local Player = exports.morph_junjie:GetPlayer(src)
    if not Player then return end

    local sellPrice = getCurrentPrice(itemName)
    local pricePerItem = math.floor(sellPrice * config.ProfitMargin)
    local totalCost, itemLabel = pricePerItem * amount, getItemLabel(itemName)

    if Player.PlayerData.money.cash < totalCost then
        exports.morph_junjie:Notify(src, "Insufficient funds", "error")
        return
    end

    if not exports.morph_inv:CanCarryItem(src, itemName, amount) then
        exports.morph_junjie:Notify(src, "Inventory full", "error")
        return
    end

    -- atomic check-and-decrement so two near-simultaneous purchases can't both pass
    -- a separate stock check and oversell/duplicate the same stock
    local rowsAffected = MySQL.update.await('UPDATE pawnshop_stocks SET stock = stock - ? WHERE item = ? AND stock >= ?', { amount, itemName, amount })
    if rowsAffected == 0 then
        exports.morph_junjie:Notify(src, "Out of stock", "error")
        return
    end

    if Player.Functions.AddItem(itemName, amount) then
        Player.Functions.RemoveMoney('cash', totalCost, 'pawnshop-buy')
        TriggerClientEvent('qb-pawnshop:client:playTradeSound', src)
        exports.morph_junjie:Notify(src, "Purchased " .. amount .. "x " .. itemLabel, "success")
        TriggerClientEvent('inventory:client:ItemBox', src, exports.morph_inv:Items()[itemName], 'add')
    else
        -- item couldn't be given after all, put the stock back
        MySQL.update('UPDATE pawnshop_stocks SET stock = stock + ? WHERE item = ?', { amount, itemName })
        exports.morph_junjie:Notify(src, "Failed to add item", "error")
    end
end)