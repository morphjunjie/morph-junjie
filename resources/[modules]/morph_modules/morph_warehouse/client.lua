-- client.lua
local Config = require 'morph_warehouse.config'

local busyCategories = {}
local categoryIndexes = {}

local function getNextCategoryId()
    for i = 66, 67 do
        if not categoryIndexes[i] then
            categoryIndexes[i] = true
            return i
        end
    end
end

---@param blip number
---@param categoryName string
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

Blip = {}
Blip.setBlipCategory = setBlipCategory

local function CreateWarehouseBlips()
    for _, location in ipairs(Config.Locations) do
        local blip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
        SetBlipSprite(blip, 473)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 5)
        SetBlipAsShortRange(blip, true)
        setBlipCategory(blip, "Morph Warehouse")
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(location.label)
        EndTextCommandSetBlipName(blip)
    end
end

---@param locationLabel string
local function RentOrRenewStorage(locationLabel)
    local input = lib.inputDialog('Rent Warehouse Storage', {
        {
            type = 'number',
            label = 'Duration (Days)',
            description = string.format('Price: %s%d per day', Config.Currency, Config.DailyPrice),
            icon = 'calendar',
            min = 1,
            max = Config.MaxDays,
            default = 1,
            required = true,
        },
        {
            type = 'select',
            label = 'Payment Method',
            description = 'Select your payment method',
            icon = 'wallet',
            required = true,
            default = 'cash',
            options = {
                { value = 'cash', label = 'Cash Payment' },
                { value = 'bank', label = 'Bank Transfer' },
            },
        },
    })

    if not input then return end

    local days, method = input[1], input[2]
    local success, result = lib.callback.await('morph_warehouse:rentStorage', false, days, method, locationLabel)

    if not success then
        local reason = 'Something went wrong. Please try again.'

        if result == 'invalid_days' then
            reason = string.format('Please choose a duration between 1 and %d days.', Config.MaxDays)
        elseif result == 'no_money' then
            reason = 'Insufficient balance.'
        elseif result == 'invalid_method' then
            reason = 'Invalid payment method.'
        end

        lib.notify({ title = 'Warehouse Storage', description = reason, type = 'error' })
        return
    end

    lib.notify({
        title = 'Warehouse Storage',
        description = string.format(
            '%s for %d day(s). Expires: %s',
            result.isRenewal and 'Storage renewed' or 'Storage rented',
            result.days,
            result.expiresLabel
        ),
        type = 'success',
    })
end

---@param locationLabel string
local function OpenStorage(locationLabel)
    local state = lib.callback.await('morph_warehouse:checkStorage', false, locationLabel)

    if state.state == 'active' then
        exports.morph_inv:openInventory('stash', state.stashId)
        return
    end

    if state.state == 'expired' then
        lib.notify({
            title = 'Warehouse Storage',
            description = string.format('Your storage expired on %s. Renew it to regain access.', state.expiresLabel),
            type = 'error',
        })
        RentOrRenewStorage(locationLabel)
        return
    end

    -- state.state == 'none'
    RentOrRenewStorage(locationLabel)
end

CreateThread(function()
    CreateWarehouseBlips()

    for i, location in ipairs(Config.Locations) do
        exports.morph_tget:addBoxZone({
            coords = location.coords,
            size = Config.TargetSize,
            rotation = 0,
            debug = false,
            options = {
                {
                    name = 'warehouse_open_' .. i,
                    icon = 'fa-solid fa-warehouse',
                    label = 'Open Storage',
                    distance = Config.TargetDistance,
                    onSelect = function()
                        OpenStorage(location.label)
                    end,
                },
            },
        })
    end
end)

print('^2[Warehouse] Client loaded^7')