local zoneId
local allowAccess = false
local sharedConfig = require 'config.shared'
local openCustoms = require('client.menus.main')

local function checkAccess()
    while not cache.vehicle do
        Wait(50)
    end
    local zone = sharedConfig.zones[zoneId]
    local vehicleClass = GetVehicleClass(cache.vehicle)
    local hasJob = true

    if (zone.deniedClasses and zone.deniedClasses[vehicleClass]) or (zone.allowedClasses and not zone.allowedClasses[vehicleClass]) or (zone.modelBlacklist and zone.modelBlacklist[GetEntityModel(cache.vehicle)]) then
        allowAccess = false
        return
    end

    if zone.job and QBX?.PlayerData then
        hasJob = false
        local playerJob = QBX.PlayerData.job.name
        for i = 1, #zone.job do
            if playerJob == zone.job[i] then
                hasJob = true
                break
            end
        end
    end

    allowAccess = hasJob
end

---@param vertices vector3[]
---@return vector3
local function calculatePolyzoneCenter(vertices)
    local xSum = 0
    local ySum = 0
    local zSum = 0

    for i = 1, #vertices do
        xSum = xSum + vertices[i].x
        ySum = ySum + vertices[i].y
        zSum = zSum + vertices[i].z
    end

    local center = vec3(xSum / #vertices, ySum / #vertices, zSum / #vertices)

    return center
end

local busyCategories = {}
local categoryIndexes = {}

local function getNextCategoryId()
    for i = 64, 65 do
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

CreateThread(function()
    for _, v in ipairs(sharedConfig.zones) do
        lib.zones.poly({
            points = v.points,
            onEnter = function(s)
                zoneId = s.id
                if not cache.vehicle then return end
                checkAccess()

                if not allowAccess then
                    return
                end

                lib.showTextUI(locale('textUI.tune'), {
                    icon = 'fa-solid fa-car',
                    position = 'left-center',
                })
            end,
            onExit = function()
                zoneId = nil
                lib.hideTextUI()
            end,
            inside = function()
                if cache.vehicle and allowAccess then
                    if not lib.isTextUIOpen() then
                        lib.showTextUI(locale('textUI.tune'), {
                            icon = 'fa-solid fa-car',
                            position = 'left-center',
                        })
                    end
                    if IsControlJustPressed(0, 38) then
                        SetEntityVelocity(cache.vehicle, 0.0, 0.0, 0.0)
                        lib.hideTextUI()
                        openCustoms()
                    end
                end
            end,
        })

        if not v.hideBlip and v.blip then
            local center = calculatePolyzoneCenter(v.points)
            local blip = AddBlipForCoord(center.x, center.y, center.z)
            SetBlipSprite(blip, v.blip.sprite or 72); SetBlipColour(blip, v.blip.color or 4); SetBlipScale(blip, v.blip.scale or 0.8); SetBlipAsShortRange(blip, true)
            setBlipCategory(blip, "Morph Custom")  -- Tambahkan kategori
            BeginTextCommandSetBlipName('STRING'); AddTextComponentSubstringPlayerName(v.blip.label or 'Customs'); EndTextCommandSetBlipName(blip)
        end
    end
end)

lib.callback.register('morph_cscar:client:zone', function()
    return zoneId
end)

lib.onCache('vehicle', function(vehicle)
    if not zoneId then return end
    if cache.vehicle and not vehicle then
        lib.hideTextUI()
        allowAccess = false
        return
    end
    checkAccess()
end)
