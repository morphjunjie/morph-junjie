local washingVehicle = false

local function washCar()
    local success = lib.callback.await("randol_carwash:server:canAfford", false)
    if not success then return end
    washingVehicle = true
    QBCore.Functions.Progressbar("wash_car", "Washing vehicle..", WashConfig.WashTime, false, false, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        SetVehicleDirtLevel(cache.vehicle, 0.0)
        WashDecalsFromVehicle(cache.vehicle, 1.0)
        washingVehicle = false
        QBCore.Functions.Notify('Your car is now clean.', 'success')
    end)
end

local function onEnter(self)
    if IsPedInAnyVehicle(cache.ped, false) then
        lib.showTextUI('E - Wash Car $50', { icon = 'fa-solid fa-car', position = 'left-center', })
    end
end
 
local function onExit(self)
    lib.hideTextUI()
end

local function inside(self)
    if IsControlJustReleased(0, 38) and not washingVehicle and cache.seat == -1 then
        washCar()
    end
end

local busyCategories = {}
local categoryIndexes = {}

local function getNextCategoryId()
    for i = 56, 57 do
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

for i = 1, #WashConfig.CarWashLocs do
    local zone = lib.zones.poly({
        points = WashConfig.CarWashLocs[i].points,
        thickness = 9.0,
        debug = false,
        onEnter = onEnter,
        inside = inside,
        onExit = onExit,
    })
    local washBlip = AddBlipForCoord(WashConfig.CarWashLocs[i].Blip.x, WashConfig.CarWashLocs[i].Blip.y, WashConfig.CarWashLocs[i].Blip.z)
    SetBlipSprite(washBlip, 100)
    SetBlipDisplay(washBlip, 4)
    SetBlipScale(washBlip, 0.75)
    SetBlipAsShortRange(washBlip, true)
    SetBlipColour(washBlip, 37)
    setBlipCategory(washBlip, "Morph Car Wash")
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(WashConfig.CarWashLocs[i].Label)
    EndTextCommandSetBlipName(washBlip)
end