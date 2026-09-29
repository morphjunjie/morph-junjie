local Config = lib.require('morph_pizzajob.config')
local isHired, holdingPizza, pizzaDelivered, activeOrder = false, false, false, false
local pizzaProp, startZone, pizzaCar, currZone, bossZone, returnBlip, returnBlipActive = false
local animDict = 'anim@scripted@freemode@ig9_pizza@male@'
local pizzaModel = `prop_pizza_box_01`
local finishCooldownTimer = 0

-- progres delivery, dipakai buat gating tombol "Finish Work"
local deliveriesCompleted = 0
local minDeliveries = 0

local busyCategories = {}
local categoryIndexes = {}

local function getNextCategoryId()
    for i = 74, 75 do
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
        if not categoryId then print("No available category IDs left.") return end
        busyCategories[categoryName] = categoryId
        AddTextEntry("BLIP_CAT_" .. categoryId, categoryName)
    end
    SetBlipCategory(blip, categoryId)
end

exports('setBlipCategory', setBlipCategory)
Blip = {}
Blip.setBlipCategory = setBlipCategory

local pizzajobBlip = AddBlipForCoord(Config.BossCoords.x, Config.BossCoords.y, Config.BossCoords.z)
SetBlipSprite(pizzajobBlip, 267)
SetBlipAsShortRange(pizzajobBlip, true)
SetBlipScale(pizzajobBlip, 0.6)
SetBlipColour(pizzajobBlip, 2)
setBlipCategory(pizzajobBlip, 'Morph Jobs')
BeginTextCommandSetBlipName('STRING')
AddTextComponentString('Pizza Job')
EndTextCommandSetBlipName(pizzajobBlip)

local function doEmote(bool)
    if bool then
        lib.requestModel(pizzaModel)
        local coords = GetEntityCoords(cache.ped)
        pizzaProp = CreateObject(pizzaModel, coords.x, coords.y, coords.z, true, true, true)
        AttachEntityToEntity(pizzaProp, cache.ped, GetPedBoneIndex(cache.ped, 28422), 0.0100, -0.1000, -0.1590, 20.0000007, 0.0, 0.0, true, true, false, true, 0, true)
        lib.playAnim(cache.ped, 'anim@heists@box_carry@', 'idle', 5.0, 5.0, -1, 51, 0, 0, 0, 0)
        SetModelAsNoLongerNeeded(pizzaModel)
    else
        if DoesEntityExist(pizzaProp) then
            DetachEntity(pizzaProp, true, false)
            DeleteEntity(pizzaProp)
            pizzaProp = nil
            ClearPedTasksImmediately(cache.ped)
        end
    end
    holdingPizza = bool
end

local function getPosRelHeading(root, forwardOffset, sideOffset)
    -- fallback to 0 if a delivery location is missing a heading (.w), instead of crashing math.rad(nil)
    local heading = root.w and math.rad(root.w) or 0
    local forwardX = math.cos(heading)
    local forwardY = math.sin(heading)
    local rightX = -math.sin(heading)
    local rightY = math.cos(heading)

    return vec3(root.x + (forwardX * forwardOffset) + (rightX * sideOffset), root.y + (forwardY * forwardOffset) + (rightY * sideOffset), root.z)
end

local function initScene(rootCoords, side)
    local isHeeled = not IsPedMale(cache.ped)
    local animPlayer = isHeeled and 'action_01_heeled' or 'action_01_player'
    local animPizza = 'action_01_pizza'
    local animCam = side == 'left' and 'action_01_cam_alt' or 'action_01_cam'

    if not DoesEntityExist(pizzaProp) then return false end

    lib.requestAnimDict(animDict)

    local scenePos = getPosRelHeading(rootCoords, Config.offsetF, Config.offsetS)
    local sceneHeading = (rootCoords.w or 0) + Config.offsetH

    DetachEntity(pizzaProp, true, true)
    ClearPedTasksImmediately(cache.ped)
    SetEntityCoordsNoOffset(pizzaProp, scenePos.x, scenePos.y, scenePos.z, false, false, false)
    SetEntityCollision(pizzaProp, false, false)
    SetEntityAsMissionEntity(pizzaProp, true, true)

    local scene = NetworkCreateSynchronisedScene(scenePos.x, scenePos.y, scenePos.z, 0.0, 0.0, sceneHeading, 2, false, false, 1.0, 0.0, 1.0 )

    NetworkAddPedToSynchronisedScene(cache.ped, scene, animDict, animPlayer, 1000.0, -1000.0, 5, 0, 1000.0, 0)
    NetworkAddEntityToSynchronisedScene(pizzaProp, scene, animDict, animPizza, 1000.0, -1000.0, 5)

    local cam = CreateCam('DEFAULT_ANIMATED_CAMERA', true)
    PlayCamAnim(cam, animCam, animDict, scenePos.x, scenePos.y, scenePos.z, 0.0, 0.0, sceneHeading, false, 2)

    NetworkStartSynchronisedScene(scene)
    RenderScriptCams(true, false, 3000, true, false)
    FreezeEntityPosition(cache.ped, true)

    local duration = 6000
    local endTime = GetGameTimer() + duration

    while GetGameTimer() < endTime do
        Wait(0)
        DisableAllControlActions(0)
        DisableAllControlActions(1)
        DisableAllControlActions(2)
    end

    FreezeEntityPosition(cache.ped, false)
    ClearPedTasks(cache.ped)

    RenderScriptCams(false, true, 1000, true, false)
    if DoesCamExist(cam) then
        DestroyCam(cam, false)
    end

    if DoesEntityExist(pizzaProp) then
        DeleteEntity(pizzaProp)
        pizzaProp = nil
    end
    holdingPizza = false

    RemoveAnimDict(animDict)

    return true
end

local function resetJob()
    if currZone then
        exports.morph_tget:removeZone(currZone)
        currZone = nil
    end
    RemoveBlip(JobBlip)
    if returnBlip then
        RemoveBlip(returnBlip)
        returnBlip = nil
        returnBlipActive = false
    end
    isHired = false
    holdingPizza = false
    pizzaDelivered = false
    activeOrder = false
    deliveriesCompleted = 0
    minDeliveries = 0
    if DoesEntityExist(pizzaProp) then
        DeleteEntity(pizzaProp)
        pizzaProp = nil
    end
    if startZone then startZone:remove() startZone = nil end
    if bossZone then
        exports.morph_tget:removeZone(bossZone)
        bossZone = nil
    end
end

local function TakePizza()
    if IsPedInAnyVehicle(cache.ped, false) or IsEntityDead(cache.ped) or holdingPizza then
        return
    end

    local pos = GetEntityCoords(cache.ped)

    if #(pos - vec3(currentDelivery.x, currentDelivery.y, currentDelivery.z)) >= 30.0 then
        return DoNotification('You\'re not close enough to the customer\'s house!', 'error')
    end

    doEmote(true)
end

local function PullOutVehicle(netid, data)
    pizzaCar = lib.waitFor(function()
        if NetworkDoesEntityExistWithNetworkId(netid) then
            return NetToVeh(netid)
        end
    end, 'Could not load entity in time.', 1000)

    if pizzaCar == 0 then
        return DoNotification('Error spawning the vehicle.', 'error')
    end

    SetVehicleNumberPlateText(pizzaCar, 'PIZZA'..tostring(math.random(1000, 9999)))
    SetVehicleEngineOn(pizzaCar, true, true, true)
    SetVehicleColours(pizzaCar, 111, 111)
    SetVehicleDirtLevel(pizzaCar, 1)
    handleVehicleKeys(pizzaCar)
    isHired = true
    deliveriesCompleted = data.deliveriesCompleted or 0
    minDeliveries = data.minDeliveries or 0
    NextDelivery(data)
    Wait(500)
    
    if Config.FuelScript.enable then
        if Config.FuelScript.script == 'morph_fuel' then
            Entity(pizzaCar).state:set('fuel', 100.0, true)
        else
            Entity(pizzaCar).state.fuel = 100
        end
    else
        Entity(pizzaCar).state.fuel = 100
    end

    exports.morph_tget:addEntity(netid, {
        {
            icon = 'fa-solid fa-pizza-slice',
            label = 'Take Pizza',
            onSelect = TakePizza,
            canInteract = function()
                return isHired and activeOrder and not holdingPizza
            end,
            distance = 2.5
        },
        {
            icon = 'fa-solid fa-pizza-slice',
            label = 'Return Pizza',
            onSelect = function()
                doEmote(false)
            end,
            canInteract = function()
                return isHired and activeOrder and holdingPizza
            end,
            distance = 2.5
        },
    })
end

local function ShowReturnBlip()
    if returnBlip then
        RemoveBlip(returnBlip)
        returnBlip = nil
    end
    returnBlip = AddBlipForCoord(Config.BossCoords.x, Config.BossCoords.y, Config.BossCoords.z)
    SetBlipSprite(returnBlip, 1)
    SetBlipDisplay(returnBlip, 4)
    SetBlipScale(returnBlip, 0.8)
    SetBlipColour(returnBlip, 1)
    SetBlipAsShortRange(returnBlip, true)
    SetBlipRoute(returnBlip, true)
    SetBlipRouteColour(returnBlip, 1)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Return to Pizza Shop')
    EndTextCommandSetBlipName(returnBlip)
    returnBlipActive = true
end

local function finishWork()
    local ped = cache.ped
    local pos = GetEntityCoords(ped)

    local finishspot = vec3(Config.BossCoords.x, Config.BossCoords.y, Config.BossCoords.z)
    if #(pos - finishspot) > 10.0 or not isHired then return end

    local success = lib.callback.await('morph_pizzajob:server:clockOut', false)
    if success then
        -- baru dilepas target-entity-nya kalau clock out beneran berhasil,
        -- biar kalau gagal (misal belum penuhi minimal delivery) mobil
        -- tetap bisa dipakai buat lanjut kerja
        if pizzaCar then
            exports.morph_tget:removeEntity(NetworkGetNetworkIdFromEntity(pizzaCar), {'Take Pizza', 'Return Pizza'})
        end

        RemoveBlip(JobBlip)
        if returnBlip then
            RemoveBlip(returnBlip)
            returnBlip = nil
            returnBlipActive = false
        end
        doEmote(false)
        isHired, activeOrder = false, false
        deliveriesCompleted = 0
        minDeliveries = 0
        DoNotification('You ended your shift.', 'success')
        pizzaCar = nil
        
        if Config.finishCooldown and Config.finishCooldown > 0 then
            finishCooldownTimer = GetGameTimer() + Config.finishCooldown
            DoNotification(string.format('You must wait %d seconds before starting a new shift.', Config.finishCooldown / 1000), 'info')
        end
    end
end

local function canStartJob()
    if finishCooldownTimer > 0 and GetGameTimer() < finishCooldownTimer then
        local remaining = math.ceil((finishCooldownTimer - GetGameTimer()) / 1000)
        DoNotification(string.format('Please wait %d seconds before starting a new shift.', remaining), 'error')
        return false
    end
    return true
end

local function deliverPizza()
    if holdingPizza and isHired and not pizzaDelivered then
        pizzaDelivered = true

        local side = math.random(2) == 1 and 'right' or 'left'
        local success = initScene(currentDelivery, side)

        if success then
            local paid, data = lib.callback.await('morph_pizzajob:server:Payment', false)
            if not paid then
                pizzaDelivered = false
                return
            end

            deliveriesCompleted = deliveriesCompleted + 1

            RemoveBlip(JobBlip)
            exports.morph_tget:removeZone(currZone)
            currZone = nil
            activeOrder = false
            pizzaDelivered = false

            -- server only returns `data` when there's an actual next delivery
            -- assigned as data.current. previously this checked #data.locations
            -- > 0, but that count is AFTER the next delivery is popped out of
            -- the list, so it was 0 even when there was still one more
            -- delivery to do, causing it to show the return blip too early
            if data then
                NextDelivery(data)
            else
                ShowReturnBlip()
                DoNotification('All deliveries completed! Return the vehicle.', 'info')
            end
        else
            pizzaDelivered = false
            DoNotification('Delivery scene failed to play.', 'error')
        end
    else
        DoNotification('You need the pizza box from the car.', 'error')
    end
end

function NextDelivery(data)
    if activeOrder then return end
    currentDelivery = data.current
    
    if returnBlip then
        RemoveBlip(returnBlip)
        returnBlip = nil
        returnBlipActive = false
    end
    
    JobBlip = AddBlipForCoord(currentDelivery.x, currentDelivery.y, currentDelivery.z)
    SetBlipSprite(JobBlip, 1)
    SetBlipDisplay(JobBlip, 4)
    SetBlipScale(JobBlip, 0.8)
    SetBlipFlashes(JobBlip, true)
    SetBlipAsShortRange(JobBlip, true)
    SetBlipColour(JobBlip, 2)
    SetBlipRoute(JobBlip, true)
    SetBlipRouteColour(JobBlip, 2)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Customer Delivery')
    EndTextCommandSetBlipName(JobBlip)

    currZone = exports.morph_tget:addSphereZone({
        coords = vec3(currentDelivery.x, currentDelivery.y, currentDelivery.z),
        radius = 1.3,
        debug = false,
        options = {
            {
                icon = 'fa-solid fa-pizza-slice',
                label = 'Deliver Pizza',
                onSelect = deliverPizza,
                distance = 1.5,
            },
        }
    })
    activeOrder = true
    DoNotification('You have a new delivery!', 'success')
end

local function startJob()
    if isHired then
        DoNotification('You are already working!', 'error')
        return
    end
    
    if not canStartJob() then
        return
    end
    
    local netid, data = lib.callback.await('morph_pizzajob:server:spawnVehicle', false)
    if netid and data then
        PullOutVehicle(netid, data)
    end
end

local function setupBossZone()
    if bossZone then
        exports.morph_tget:removeZone(bossZone)
        bossZone = nil
    end
    
    bossZone = exports.morph_tget:addBoxZone({
        coords = vec3(Config.BossCoords.x, Config.BossCoords.y, Config.BossCoords.z),
        size = vec3(0.8, 0.5, 1.0),
        rotation = Config.BossCoords.w or 0,
        debug = false,
        options = {
            {
                icon = 'fa-solid fa-pizza-slice',
                label = 'Start Work',
                onSelect = startJob,
                canInteract = function()
                    return not isHired and (finishCooldownTimer == 0 or GetGameTimer() >= finishCooldownTimer)
                end,
                distance = 2.0,
            },
            {
                icon = 'fa-solid fa-pizza-slice',
                label = 'Finish Work',
                onSelect = function()
                    if deliveriesCompleted < minDeliveries then
                        local remaining = minDeliveries - deliveriesCompleted
                        DoNotification(string.format('You need to complete %d more delivery/deliveries first!', remaining), 'error')
                        return
                    end
                    finishWork()
                end,
                canInteract = function()
                    return isHired
                end,
                distance = 2.0,
            },
        }
    })
end

RegisterNetEvent('morph_pizzajob:client:forceComplete', function()
    RemoveBlip(JobBlip)
    if currZone then
        exports.morph_tget:removeZone(currZone)
        currZone = nil
    end
    if returnBlip then
        RemoveBlip(returnBlip)
        returnBlip = nil
        returnBlipActive = false
    end
    activeOrder = false
    pizzaDelivered = false
    ShowReturnBlip()
    DoNotification('All deliveries completed! Return the vehicle.', 'info')
end)

function OnPlayerLoaded()
    setupBossZone()
end

function OnPlayerUnload()
    resetJob()
    finishCooldownTimer = 0
end

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() ~= resource or not hasPlyLoaded() then return end
    setupBossZone()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    resetJob()
    finishCooldownTimer = 0
end)