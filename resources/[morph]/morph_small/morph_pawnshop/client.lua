-- client.lua
local config = require 'morph_pawnshop.config'
local invImagePath = "nui://morph_inv/web/images/"

local function Notify(desc, type)
    TriggerEvent('morph_ui:notify', { title = 'Morph Pawnshop', description = desc, type = type or 'info', duration = 3000 })
end

local function ShowAlert(header, content, confirmLbl)
    return lib.alertDialog({ header = header, content = content, centered = true, cancel = true, labels = { confirm = confirmLbl or 'OK', cancel = 'Cancel' } })
end

-- adds the interaction to open the pawnshop, either as a zone or an morph_tget-style box
local function addPawnShop(id, shopConfig)
    if not config.useTarget then
        lib.zones.box({
            name = 'PawnShop' .. id,
            coords = shopConfig.coords,
            size = shopConfig.size,
            rotation = shopConfig.heading,
            debug = shopConfig.debugPoly,
            onEnter = function()
                lib.registerContext({
                    id = 'open_pawnShopMain',
                    title = 'Morph Pawnshop',
                    options = { { title = 'Open Pawnshop', description = 'Access pawnshop services', icon = 'fas fa-store', event = 'qb-pawnshop:client:openMenu' } }
                })
                lib.showContext('open_pawnShopMain')
            end,
            onExit = function() lib.hideContext(false) end
        })
        return
    end

    exports.morph_tget:addBoxZone({
        coords = shopConfig.coords,
        size = shopConfig.size,
        rotation = shopConfig.heading,
        debug = shopConfig.debugPoly,
        options = { { name = 'PawnShop' .. id, event = 'qb-pawnshop:client:openMenu', icon = 'fas fa-hand-holding-dollar', label = 'Open Pawnshop', distance = shopConfig.distance } }
    })
end

-- blip category setup so pawnshop blips group under their own submenu on the map legend
local busyCategories, categoryIndexes = {}, {}
local function getNextCategoryId()
    for i = 50, 51 do
        if not categoryIndexes[i] then
            categoryIndexes[i] = true
            return i
        end
    end
end

local function setBlipCategory(blip, categoryName)
    local categoryId = busyCategories[categoryName]
    if not categoryId then
        categoryId = getNextCategoryId()
        if not categoryId then print("No available category IDs left."); return end
        busyCategories[categoryName] = categoryId
        AddTextEntry("BLIP_CAT_" .. categoryId, categoryName)
    end
    SetBlipCategory(blip, categoryId)
end
exports('setBlipCategory', setBlipCategory)
Blip = { setBlipCategory = setBlipCategory }

-- spawns a blip and interaction for every pawnshop location in the config
CreateThread(function()
    for i = 1, #config.pawnLocation do
        local shopConfig = config.pawnLocation[i]
        local blip = AddBlipForCoord(shopConfig.coords.x, shopConfig.coords.y, shopConfig.coords.z)
        SetBlipSprite(blip, 431)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.6)
        SetBlipAsShortRange(blip, true)
        SetBlipColour(blip, 5)
        setBlipCategory(blip, "Morph Property")
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName('Pawnshop')
        EndTextCommandSetBlipName(blip)
        addPawnShop(i, shopConfig)
    end
end)

RegisterNetEvent('qb-pawnshop:client:openMenu', function()
    lib.registerContext({
        id = 'pawn_main',
        title = 'Morph Pawnshop',
        options = {
            { title = 'Sell Items', description = 'Turn your valuable items into instant cash', icon = 'fa-solid fa-coins', event = 'qb-pawnshop:client:openPawn' },
            { title = 'Buy Items', description = 'Browse and purchase pre-owned items', icon = 'fa-solid fa-cart-shopping', event = 'qb-pawnshop:client:openBuyMenu' }
        }
    })
    lib.showContext('pawn_main')
end)

RegisterNetEvent('qb-pawnshop:client:playTradeSound', function()
    PlaySoundFrontend(-1, "PURCHASE", "HUD_LIQUOR_STORE_SOUNDSET", true)
end)

RegisterNetEvent('qb-pawnshop:client:pawnitems', function(item)
    local input = lib.inputDialog("Sell Item - " .. item.label, {
        { type = 'number', label = 'Quantity to Sell', description = 'Available: ' .. item.amount .. ' pcs', placeholder = "Max: " .. item.amount, min = 1, max = item.amount }
    })
    if not input or not input[1] then return end

    local amount = input[1]
    local totalPrice = amount * item.price
    local content = string.format("You are about to sell %d pcs of %s for $%d.\n\nProceed with this sale?", amount, item.label, totalPrice)

    if ShowAlert("Confirm Sale", content, "Sell Now") == "confirm" then
        TriggerServerEvent('qb-pawnshop:server:sellPawnItems', item.name, amount)
        lib.hideContext(true)
    end
end)

RegisterNetEvent('qb-pawnshop:client:openBuyMenu', function()
    local stocks = lib.callback.await('qb-pawnshop:server:getShopStock', false)
    local marketPrices = lib.callback.await('qb-pawnshop:server:getMarketPrices', false)
    if #stocks == 0 then Notify("No items in stock at the moment.", "info"); return end

    local buyMenu = {}
    local shouldSearch = lib.alertDialog({ header = 'Purchase Catalog', content = 'Do you want to search for a specific item?', centered = true, cancel = true, labels = { confirm = 'Search', cancel = 'Show All' } })
    local searchQuery = nil
    if shouldSearch == "confirm" then
        local searchInput = lib.inputDialog('Search Items', { { type = 'input', label = 'Item Name', placeholder = 'Type item name...' } })
        if searchInput and searchInput[1] and searchInput[1] ~= "" then searchQuery = string.lower(searchInput[1]) end
    end

    for _, data in pairs(stocks) do
        local itemInfo = exports.morph_inv:Items()[data.item]
        local itemLabel = itemInfo and itemInfo.label or data.item

        if searchQuery then
            local lowerLabel = string.lower(itemLabel)
            if not string.find(lowerLabel, searchQuery, 1, true) then goto continue end
        end

        local sellPrice = marketPrices[data.item] or 0
        local buyPrice = math.floor(sellPrice * config.ProfitMargin)
        local itemImage = invImagePath .. data.item .. ".png"

        buyMenu[#buyMenu + 1] = {
            title = itemLabel,
            description = string.format("Price $%d | Stock: %d pcs", buyPrice, data.stock),
            image = itemImage,
            metadata = { { label = 'Unit Price', value = '$' .. buyPrice }, { label = 'Stock Available', value = data.stock .. ' pcs' } },
            onSelect = function()
                local input = lib.inputDialog('Purchase - ' .. itemLabel, {
                    { type = 'number', label = 'Quantity to Buy', description = 'Available stock: ' .. data.stock .. ' pcs\nPrice per unit: $' .. buyPrice, placeholder = "Max: " .. data.stock, min = 1, max = data.stock }
                })
                if not input or not input[1] then return end

                local amount = input[1]
                local totalCost = amount * buyPrice
                local content = string.format("You are about to buy %d pcs of %s for $%d.\n\nProceed with this purchase?", amount, itemLabel, totalCost)

                if ShowAlert("Confirm Purchase", content, "Buy Now") == "confirm" then
                    TriggerServerEvent('qb-pawnshop:server:buyItem', { item = data.item, amount = amount })
                    lib.hideContext(true)
                end
            end
        }
        ::continue::
    end

    if #buyMenu == 0 then
        Notify(searchQuery and ("No items found matching '" .. searchQuery .. "'") or "No items found.", "info")
        return
    end

    lib.registerContext({ id = 'pawn_buy', menu = 'pawn_main', title = searchQuery and ('Purchase Catalog (' .. searchQuery .. ')') or 'Purchase Catalog', options = buyMenu })
    lib.showContext('pawn_buy')
end)

RegisterNetEvent('qb-pawnshop:client:openPawn', function()
    local marketPrices = lib.callback.await('qb-pawnshop:server:getMarketPrices', false)
    local inventory = exports.morph_inv:GetPlayerItems()
    local pawnMenu = {}

    for _, invItem in pairs(inventory) do
        local price = marketPrices[invItem.name]
        if price then
            local amountOwned = invItem.count or invItem.amount -- supports both inventory data formats
            local itemImage = invImagePath .. invItem.name .. ".png"
            pawnMenu[#pawnMenu + 1] = {
                title = invItem.label,
                description = string.format("$%d | Owned: %d pcs", price, amountOwned),
                image = itemImage,
                metadata = { { label = 'Sell Price', value = '$' .. price }, { label = 'In Inventory', value = amountOwned .. ' pcs' } },
                event = 'qb-pawnshop:client:pawnitems',
                args = { name = invItem.name, label = invItem.label, amount = amountOwned, price = price }
            }
        end
    end

    if #pawnMenu == 0 then Notify("No pawnable items in inventory.", "info"); return end
    lib.registerContext({ id = 'open_pawnMenu', menu = 'pawn_main', title = 'Sell Items', options = pawnMenu })
    lib.showContext('open_pawnMenu')
end)