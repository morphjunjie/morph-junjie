-- client.lua

local cfgFile = require 'morph_rcjob.config'
-- 'config' di bawah tetap bisa diakses config.dropLocation, config.pickupLocations, dst
-- lewat metatable __index ke 'shared', jadi sisa kode di file ini nggak perlu diubah.
local config = setmetatable(cfgFile.client, { __index = cfgFile.shared })

local isLoggedIn = LocalPlayer.state.isLoggedIn

local carryPackage = nil
local packageCoords = nil
local onDuty = false

local entranceTargetID = 'entranceTarget'
local exitTargetID = 'exitTarget'
local deliveryTargetID = 'deliveryTarget'
local dutyTargetID = 'dutyTarget'
local pickupTargetID = 'pickupTarget'

local exitZone = nil
local deliveryZone = nil
local dutyZone = nil
local pickupZone = nil

local busyCats, catIdx = {}, {}

local function notify(msg, type) exports.morph_junjie:Notify(msg, type, 3000) end

local function getNextId()
    for i = 74, 75 do if not catIdx[i] then catIdx[i] = true; return i end end
end

local function setBlipCategory(blip, name)
    local id = busyCats[name] or getNextId()
    if not id then return print("No category IDs left") end
    if not busyCats[name] then busyCats[name] = id; AddTextEntry("BLIP_CAT_"..id, name) end
    SetBlipCategory(blip, id)
end
exports('setBlipCategory', setBlipCategory)
Blip = { setBlipCategory = setBlipCategory }

-- Minta izin/sesi ke server sebelum progress bar pickup/drop mulai.
-- Server bakal validasi posisi & nyimpen jam mulainya, buat dicocokin
-- lagi pas reward diklaim (anti skip-animasi/instant-claim).
local function startSession(actionType)
    return lib.callback.await('morph_rcjob:server:startAction', false, actionType)
end

local function createZone(data)
    if config.useTarget then return exports.morph_tget:addBoxZone(data) else return lib.zones.box(data) end
end

local function removeZone(zone, id)
    if not zone then return end
    if config.useTarget then exports.morph_tget:removeZone(id) else zone:remove() end
    return nil
end

local function destroyPickupTarget() pickupZone = removeZone(pickupZone, pickupTargetID) end
local function destroyExitTarget() exitZone = removeZone(exitZone, exitTargetID) end
local function destroyDutyTarget() dutyZone = removeZone(dutyZone, dutyTargetID) end
local function destroyDeliveryTarget() deliveryZone = removeZone(deliveryZone, deliveryTargetID) end
local function destroyInsideZones() destroyPickupTarget(); destroyExitTarget(); destroyDutyTarget(); destroyDeliveryTarget() end

local function registerEntranceTarget()
    local coords = vector3(config.outsideLocation.x, config.outsideLocation.y, config.outsideLocation.z)
    local data = { name = entranceTargetID, coords = coords, rotation = config.outsideLocation.w, size = vec3(4.7, 1.7, 3.75), debug = config.debugPoly }
    if config.useTarget then
        data.options = { { icon = 'fa-solid fa-door-open', type = 'client', event = 'morph_rcjob:client:target:enterLocation', label = locale("text.enter_warehouse"), distance = 1 } }
        createZone(data)
    else
        data.onEnter = function() lib.showTextUI(locale("text.point_enter_warehouse")) end
        data.onExit = function() lib.hideTextUI() end
        data.inside = function() if IsControlJustReleased(0, 38) then TriggerEvent('morph_rcjob:client:target:enterLocation'); lib.hideTextUI() end end
        createZone(data)
    end
end

local function registerExitTarget()
    local coords = vector3(config.insideLocation.x, config.insideLocation.y, config.insideLocation.z)
    local data = { name = exitTargetID, coords = coords, rotation = 0.0, size = vec3(1.7, 4.7, 3.75), debug = config.debugPoly }
    if config.useTarget then
        data.options = { { icon = 'fa-solid fa-door-open', type = 'client', event = 'morph_rcjob:client:target:exitLocation', label = locale("text.exit_warehouse"), distance = 1 } }
        exitZone = createZone(data)
    else
        data.onEnter = function() lib.showTextUI(locale("text.point_exit_warehouse")) end
        data.onExit = function() lib.hideTextUI() end
        data.inside = function() if IsControlJustReleased(0, 38) then TriggerEvent('morph_rcjob:client:target:exitLocation'); lib.hideTextUI() end end
        exitZone = createZone(data)
    end
end

local function getDutyTargetText()
    return onDuty and (config.useTarget and locale("text.clock_out") or locale("text.point_clock_out")) or (config.useTarget and locale("text.clock_in") or locale("text.point_clock_in"))
end

local function registerDutyTarget()
    local coords = vector3(config.dutyLocation.x, config.dutyLocation.y, config.dutyLocation.z)
    local data = { name = dutyTargetID, coords = coords, rotation = 0.0, size = vec3(1.8, 2.65, 2.0), distance = 1.0, debug = config.debugPoly }
    if config.useTarget then
        data.options = { { icon = 'fa-solid fa-clock', type = 'client', event = 'morph_rcjob:client:target:toggleDuty', label = getDutyTargetText(), distance = 1 } }
        dutyZone = createZone(data)
    else
        data.onEnter = function() lib.showTextUI(getDutyTargetText()) end
        data.onExit = function() lib.hideTextUI() end
        data.inside = function() if IsControlJustReleased(0, 38) then TriggerEvent('morph_rcjob:client:target:toggleDuty'); lib.hideTextUI() end end
        dutyZone = createZone(data)
    end
end

local function refreshDutyTarget() destroyDutyTarget(); registerDutyTarget() end

local function registerDeliveryTarget()
    local coords = vector3(config.dropLocation.x, config.dropLocation.y, config.dropLocation.z)
    local data = { name = deliveryTargetID, coords = coords, rotation = 0.0, size = vec3(0.95, 1.25, 2.5), debug = config.debugPoly }
    if config.useTarget then
        data.options = { { icon = 'fa-solid fa-box-open', type = 'client', event = 'morph_rcjob:client:target:dropPackage', label = locale("text.hand_in_package"), distance = 1 } }
        deliveryZone = createZone(data)
    else
        data.onEnter = function() lib.showTextUI(locale("text.point_hand_in_package")) end
        data.onExit = function() lib.hideTextUI() end
        data.inside = function() if carryPackage and IsControlJustReleased(0, 38) then TriggerEvent('morph_rcjob:client:target:dropPackage'); lib.hideTextUI() end end
        deliveryZone = createZone(data)
    end
end

local function RegisterPickupTarget(coords)
    local targetCoords = vector3(coords.x, coords.y, coords.z)
    local data = { name = pickupTargetID, coords = targetCoords, rotation = 0.0, size = vec3(2.4, 2.35, 4.0), debug = config.debugPoly }
    if config.useTarget then
        data.options = { { icon = 'fa-solid fa-box', type = 'client', event = 'morph_rcjob:client:target:pickupPackage', label = locale("text.get_package"), distance = 1 } }
        pickupZone = createZone(data)
    else
        data.onEnter = function() lib.showTextUI(locale("text.point_get_package")) end
        data.onExit = function() lib.hideTextUI() end
        data.inside = function() if onDuty and not carryPackage and IsControlJustReleased(0, 38) then TriggerEvent('morph_rcjob:client:target:pickupPackage'); lib.hideTextUI() end end
        pickupZone = createZone(data)
    end
end

local function playScrapAnim(duration)
    lib.requestAnimDict('mp_car_bomb')
    TaskPlayAnim(cache.ped, 'mp_car_bomb', 'car_bomb_mechanic', 3.0, 3.0, duration, 16, 0, false, false, false)
end

local function stopScrapAnim()
    StopAnimTask(cache.ped, 'mp_car_bomb', 'car_bomb_mechanic', 1.0)
    ClearPedTasks(cache.ped)
end

local function getRandomPackage()
    packageCoords = config.pickupLocations[math.random(1, #config.pickupLocations)]
    RegisterPickupTarget(packageCoords)
end

local function pickupPackage()
    local pos = GetEntityCoords(cache.ped, true)
    local boxModel = config.pickupBoxModel
    lib.requestModel(boxModel, 5000)
    lib.playAnim(cache.ped, 'anim@heists@box_carry@', 'idle', 5.0, -1, -1, 50, 0, false, false, false)
    local object = CreateObject(boxModel, pos.x, pos.y, pos.z, true, true, true)
    SetModelAsNoLongerNeeded(boxModel)
    AttachEntityToEntity(object, cache.ped, GetPedBoneIndex(cache.ped, 57005), 0.05, 0.1, -0.3, 300.0, 250.0, 20.0, true, true, false, true, 1, true)
    carryPackage = object
end

local function dropPackage()
    ClearPedTasks(cache.ped)
    DetachEntity(carryPackage, true, true)
    DeleteObject(carryPackage)
    carryPackage = nil
end

local function setLocationBlip()
    local RecycleBlip = AddBlipForCoord(config.outsideLocation.x, config.outsideLocation.y, config.outsideLocation.z)
    SetBlipSprite(RecycleBlip, 365); SetBlipColour(RecycleBlip, 2); SetBlipScale(RecycleBlip, 0.8); SetBlipAsShortRange(RecycleBlip, true)
    setBlipCategory(RecycleBlip, 'Morph Jobs')
    BeginTextCommandSetBlipName('STRING'); AddTextComponentString('Recycle Job'); EndTextCommandSetBlipName(RecycleBlip)
end

local function buildInteriorDesign()
    for _, pickuploc in pairs(config.pickupLocations) do
        local model = GetHashKey(config.warehouseObjects[math.random(1, #config.warehouseObjects)])
        lib.requestModel(model, 5000)
        local obj = CreateObject(model, pickuploc.x, pickuploc.y, pickuploc.z, false, true, true)
        SetModelAsNoLongerNeeded(model); PlaceObjectOnGroundProperly(obj); FreezeEntityPosition(obj, true)
    end
end

local function enterLocation()
    DoScreenFadeOut(500); while not IsScreenFadedOut() do Wait(10) end
    SetEntityCoords(cache.ped, config.insideLocation.x, config.insideLocation.y, config.insideLocation.z)
    buildInteriorDesign(); DoScreenFadeIn(500)
    destroyInsideZones(); registerExitTarget(); registerDutyTarget()
end

local function exitLocation()
    DoScreenFadeOut(500); while not IsScreenFadedOut() do Wait(10) end
    SetEntityCoords(cache.ped, config.outsideLocation.x, config.outsideLocation.y, config.outsideLocation.z + 1)
    DoScreenFadeIn(500); onDuty = false; destroyInsideZones()
    if carryPackage then dropPackage() end
end

-- Kalau player connect/reconnect dan ternyata posisinya udah di dalam
-- warehouse (misal disconnect pas lagi di dalam terus reconnect), zona
-- interior (exit/duty) nggak pernah kebuat karena itu cuma diregister
-- lewat enterLocation() -- jadi player bisa "kejebak" tanpa target apa
-- pun. Fungsi ini ngecek posisi dan otomatis nyiapin ulang zona interior
-- kalau memang ketauan lagi di dalam, tanpa perlu teleport/fade.
local function recoverInteriorIfAlreadyInside()
    local insideCoords = vector3(config.insideLocation.x, config.insideLocation.y, config.insideLocation.z)
    local pos = GetEntityCoords(cache.ped)
    -- radius digedein biar nyakup seluruh area warehouse (pickup/duty/drop
    -- tersebar cukup jauh dari titik insideLocation), z-nya sendiri udah
    -- cukup khas (-39.0) buat mastiin ini emang di dalam interior ini.
    if #(pos - insideCoords) > 60.0 then return end

    buildInteriorDesign()
    destroyInsideZones()
    registerExitTarget()
    registerDutyTarget()
end

local function DrawPackageLocationBlip()
    if not config.drawPackageLocationBlip then return end
    DrawMarker(2, packageCoords.x, packageCoords.y, packageCoords.z + 3, 0, 0, 0, 180.0, 0, 0, 0.5, 0.5, 0.5, 255, 255, 0, 100, false, false, 2, true, nil, nil, false)
end

local function DrawDropLocationBlip()
    if not config.drawDropLocationBlip then return end
    local dropCoords = config.dropLocation
    DrawMarker(2, dropCoords.x, dropCoords.y, dropCoords.z + 1, 0, 0, 0, 180.0, 0, 0, 0.5, 0.5, 0.5, 255, 255, 0, 100, false, false, 2, true, nil, nil, false)
end

RegisterNetEvent('morph_rcjob:client:target:enterLocation', enterLocation)
RegisterNetEvent('morph_rcjob:client:target:exitLocation', exitLocation)

RegisterNetEvent('morph_rcjob:client:target:toggleDuty', function()
    onDuty = not onDuty

    -- kasih tau server statusnya, dipakai buat validasi pickup/drop (anti exploit)
    TriggerServerEvent('morph_rcjob:server:setDuty', onDuty)

    if onDuty then notify(locale("success.you_have_been_clocked_in"), 'success'); getRandomPackage()
    else notify(locale("error.you_have_clocked_out"), 'error'); destroyPickupTarget() end
    if carryPackage then dropPackage() end
    refreshDutyTarget(); destroyDeliveryTarget()
end)

RegisterNetEvent('morph_rcjob:client:target:pickupPackage', function()
    if not pickupZone or carryPackage then return end

    if not startSession('pickup') then
        notify('Could not start pickup here.', 'error')
        return
    end

    local duration = math.random(config.pickupActionDurationMin or 4000, config.pickupActionDurationMax or 6000)
    playScrapAnim(duration)
    if lib.progressBar({ duration = duration, label = locale("text.picking_up_the_package"), useWhileDead = false, canCancel = true, disable = { move = true, car = true, mouse = false, combat = true } }) then
        packageCoords = nil
        stopScrapAnim()
        pickupPackage()
        destroyPickupTarget()
        registerDeliveryTarget()
        -- validasi server: cek onDuty + posisi player beneran deket titik pickup + sesi/durasi valid
        TriggerServerEvent('morph_rcjob:server:pickupPackage')
    else
        stopScrapAnim()
        notify(locale('error.canceled'), 'error')
    end
end)

RegisterNetEvent('morph_rcjob:client:target:dropPackage', function()
    if not carryPackage or not deliveryZone then return end

    if not startSession('drop') then
        notify('Could not start delivery here.', 'error')
        return
    end

    dropPackage()
    local duration = config.deliveryActionDuration or 5000
    playScrapAnim(duration)
    destroyDeliveryTarget()
    if lib.progressBar({ duration = duration, label = locale("text.unpacking_the_package"), useWhileDead = false, canCancel = true, disable = { move = true, car = true, mouse = false, combat = true } }) then
        stopScrapAnim()
        TriggerServerEvent('qbx_recycle:server:getItem')
        getRandomPackage()
    else
        stopScrapAnim()
        notify(locale('error.canceled'), 'error')
    end
end)

CreateThread(function()
    while true do
        if config.drawDropLocationBlip and onDuty and carryPackage then DrawDropLocationBlip(); Wait(0)
        elseif config.drawPackageLocationBlip and onDuty and packageCoords and not carryPackage then DrawPackageLocationBlip(); Wait(0)
        elseif not isLoggedIn then Wait(4000)
        else Wait(1000) end
    end
end)

AddStateBagChangeHandler('isLoggedIn', ('player:%s'):format(cache.serverId), function(_, _, loginState)
    if isLoggedIn == loginState then return end
    isLoggedIn = loginState
    if loginState then recoverInteriorIfAlreadyInside() end
end)

CreateThread(function()
    setLocationBlip()
    registerEntranceTarget()
    if isLoggedIn then recoverInteriorIfAlreadyInside() end
end)