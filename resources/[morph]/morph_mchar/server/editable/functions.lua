Framework:Core()

local qbox = GetResourceState('morph_junjie') == 'started' and true or false

local function defaultQBMetaData(player, item)
    local data = {}
    if item == "id_card" then
        data = {
            firstname = player.charinfo.firstname,
            lastname = player.charinfo.lastname,
            birthdate = player.charinfo.birthdate,
            gender = player.charinfo.gender,
            nationality = player.charinfo.nationality,
        }
    elseif item == "driver_license" then
        data = {
            firstname = player.charinfo.firstname,
            lastname = player.charinfo.lastname,
            birthdate = player.charinfo.birthdate,
            type = "Class C Driver License",
        }
    end
    return data
end

local function customIDCard(src, item)
    if GetResourceState 'morph_id' == 'started' then
        exports['morph_id']:CreateMetaLicense(src, item)
    elseif GetResourceState 'bl_idcard' == 'started' then
        exports.bl_idcard:createLicense(src, item)
    elseif GetResourceState 'morph_id' == 'started' then
        exports['morph_id']:CreateMetaLicense(src, item)
    else
        warn('You need to start one of the idcard resources to use custom ID Card')
    end
end


local function addItemToInventory(src, item, amount, metadata, pFunction)
    if qbox then
        exports.morph_inv:AddItem(src, item, amount, metadata)
        return
    end

    pFunction.AddItem(item, amount, false, metadata)
    -- exports['qb-inventory']:AddItem(src, item, amount, false, metadata)
end

function GiveStarterItems(src)
    local Player = Framework:GetPlayer(src)
    if not Player then return end

    local starterItems = Config.StarterItems

    for i = 1, #starterItems do
        local data = starterItems[i]
        local metadata = {}

        if data.item == 'id_card' or data.item == 'driver_license' then
            if data.customExport then
                customIDCard(src, data.item)
            else
                metadata = defaultQBMetaData(Player.PlayerData, data.item)
            end
        end

        if not data.customExport then
            addItemToInventory(src, data.item, data.amount, metadata, not qbox and Player.Functions or nil)
        end
    end
end

function loadHouseData(src)
    if GetResourceState('ps-housing') == 'started' then return end

    local HouseGarages = {}
    local Houses = {}
    local status, result = pcall(function()
        return MySQL.query.await('SELECT * FROM houselocations', {})
    end)

    if not status then return end

    if result[1] ~= nil then
        for _, v in pairs(result) do
            local owned = false
            if tonumber(v.owned) == 1 then
                owned = true
            end
            local garage = v.garage ~= nil and json.decode(v.garage) or {}
            Houses[v.name] = {
                coords = json.decode(v.coords),
                owned = owned,
                price = v.price,
                locked = true,
                adress = v.label,
                tier = v.tier,
                garage = garage,
                decorations = {},
            }
            HouseGarages[v.name] = {
                label = v.label,
                takeVehicle = garage,
            }
        end
    end

    TriggerClientEvent("qb-garages:client:houseGarageConfig", src, HouseGarages)
    TriggerClientEvent("qb-houses:client:setHouseConfig", src, Houses)
end

-- Stop resources that are not needed
local stopThis = { 'basic-gamemode', 'fivem-map-skater', 'fivem-map-hipster' }

for _, stopResources in pairs(stopThis) do
    if GetResourceState(stopResources) == "started" or GetResourceState(stopResources) == "starting" then
        StopResource(stopResources)
        print((
                "^1[IMPORTANT!] %s is running on your server, stopped ^7")
            :format(stopResources))
    end
end
