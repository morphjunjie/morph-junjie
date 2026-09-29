-- client.lua

local cfgFile = require 'morph_wine.config'
-- 'config' bisa akses field client (useTarget, dst) DAN field shared
-- (grapesNeeded, grapeLocations, vineyard, dst) lewat metatable __index.
local config = setmetatable(cfgFile.client, { __index = cfgFile.shared })

local isLoggedIn = LocalPlayer.state.isLoggedIn
local grapeBlips, localCooldowns, grapeZones = {}, {}, {}

local function Notify(desc, type, duration)
    TriggerEvent('morph_ui:notify', { title = 'Vineyard Job', description = desc, type = type or 'info', duration = duration or 3000 })
end

local busyCategories, categoryIndexes = {}, {}

local function setBlipCategory(blip, name)
    if not busyCategories[name] then
        for i = 74, 75 do
            if not categoryIndexes[i] then
                categoryIndexes[i] = true
                busyCategories[name] = i
                AddTextEntry("BLIP_CAT_" .. i, name)
                break
            end
        end
    end
    if busyCategories[name] then SetBlipCategory(blip, busyCategories[name]) end
end

-- Minta izin/sesi ke server sebelum progress bar mulai. Server bakal
-- validasi posisi (dan, khusus 'pick', cooldown titik anggur ini) dan
-- nyimpen jam mulainya buat dicocokin lagi pas reward diklaim.
local function startSession(actionType, index)
    return lib.callback.await('morph_wine:server:startAction', false, actionType, index)
end

local function removeGrapeZone(index)
    if grapeZones[index] then exports.morph_tget:removeZone(grapeZones[index]); grapeZones[index] = nil end
    if grapeBlips[index] then RemoveBlip(grapeBlips[index]); grapeBlips[index] = nil end
end

local function pickProcess(index, coords)
    if localCooldowns[index] then return Notify("Grapes are still growing!", "error") end
    lib.callback('morph_wine:server:checkCanCarryGrapes', false, function(canCarry)
        if not canCarry then
            return Notify("Your inventory is full!", "error")
        end

        if not startSession('pick', index) then
            return Notify("Could not start picking here.", "error")
        end

        lib.playAnim(cache.ped, 'amb@prop_human_bum_bin@idle_a', 'idle_a', 6.0, -6.0, -1, 47, 0, 0, 0, 0)
        if lib.progressBar({
            duration = config.pickDuration or 9000,
            label = "Picking Grapes...",
            useWhileDead = false,
            canCancel = true,
            disable = { move = true, car = true, combat = true }
        }) then
            TriggerServerEvent("morph_wine:server:getGrapes", index)
            localCooldowns[index] = true
            Notify("Grapes picked! They will regrow in 20 seconds.", "success")
            removeGrapeZone(index)
            SetTimeout(config.regrowTime or 20000, function()
                localCooldowns[index] = false
                grapeZones[index] = createGrapeZone(index, coords)
                Notify("Grapes have regrown!", "info")
            end)
        else
            Notify("Cancelled", "error")
        end
        ClearPedTasks(cache.ped)
    end)
end

-- 1 fungsi dipakai buat bikin zone anggur, dipanggil pas setup awal
-- MAUPUN pas regrow -- sebelumnya logic ini di-duplikasi di 2 tempat.
function createGrapeZone(index, coords)
    if config.useTarget then
        return exports.morph_tget:addBoxZone({
            coords = coords,
            size = vec3(1, 1, 1),
            rotation = 40,
            options = { {
                icon = 'fa-solid fa-leaf',
                label = "Pick Grapes",
                onSelect = function() pickProcess(index, coords) end
            } }
        })
    else
        return lib.zones.box({
            coords = coords,
            size = vec3(1, 1, 1),
            rotation = 40,
            onEnter = function() if not localCooldowns[index] then lib.showTextUI("Pick Grapes") end end,
            onExit = function() lib.hideTextUI() end,
            inside = function()
                if IsControlJustReleased(0, 38) and not IsPedInAnyVehicle(cache.ped, true) and not localCooldowns[index] then
                    pickProcess(index, coords)
                end
            end
        })
    end
end

local function startDynamicBlips()
    CreateThread(function()
        while true do
            local sleep = 1000
            local pCoords = GetEntityCoords(cache.ped)
            for i, coords in pairs(config.grapeLocations) do
                local dist = #(pCoords - coords)
                local shouldShow = dist < (config.grapeBlipRange or 50.0) and not localCooldowns[i]
                if shouldShow and not grapeBlips[i] then
                    local b = AddBlipForCoord(coords.x, coords.y, coords.z)
                    SetBlipSprite(b, 1)
                    SetBlipScale(b, 0.5)
                    SetBlipColour(b, 2)
                    SetBlipAsShortRange(b, true)
                    BeginTextCommandSetBlipName('STRING')
                    AddTextComponentSubstringPlayerName("Grape")
                    EndTextCommandSetBlipName(b)
                    grapeBlips[i] = b
                    sleep = 0
                elseif not shouldShow and grapeBlips[i] then
                    RemoveBlip(grapeBlips[i])
                    grapeBlips[i] = nil
                    sleep = 0
                end
            end
            Wait(sleep)
        end
    end)
end

local function setLocationsBlip()
    if not config.useBlips then return end
    local v = config.vineyard
    local blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
    SetBlipSprite(blip, v.blipIcon)
    SetBlipScale(blip, 0.6)
    SetBlipColour(blip, 83)
    SetBlipAsShortRange(blip, true)
    setBlipCategory(blip, "Morph Jobs")
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(v.blipName)
    EndTextCommandSetBlipName(blip)
end

local function startProcess(type)
    local isWine = type == 'wine'
    local callback = isWine and 'morph_wine:server:grapeJuicesNeeded' or 'morph_wine:server:grapesNeeded'
    local serverEvent = isWine and 'morph_wine:server:receiveWine' or 'morph_wine:server:receiveGrapeJuice'
    local label = isWine and "Processing Wine..." or "Processing Grape Juice..."
    local needAmount = isWine and config.grapeJuicesNeeded or config.grapesNeeded
    local itemName = isWine and "Grape Juice" or "Grapes"

    lib.callback('morph_wine:server:checkCanCarryProcess', false, function(canCarry)
        if not canCarry then
            return Notify("Your inventory is full!", "error")
        end

        lib.callback(callback, false, function(hasItems)
            if not hasItems then
                return Notify(("You need %d %s to start."):format(needAmount, itemName), "error")
            end

            if not startSession(isWine and 'wine' or 'juice', nil) then
                return Notify("Could not start processing here.", "error")
            end

            if lib.progressBar({
                duration = config.processDuration or 8000,
                label = label,
                useWhileDead = false,
                canCancel = true,
                disable = { car = true, move = true, combat = true },
                anim = { dict = 'mp_car_bomb', clip = 'car_bomb_mechanic' }
            }) then
                TriggerServerEvent(serverEvent)
                Notify("Processing complete!", "success")
            else
                Notify("Cancelled", "error")
            end
        end)
    end)
end

local function processingMenu()
    local grapeCount = config.grapesNeeded or 10
    local juiceCount = config.grapeJuicesNeeded or 20
    lib.registerContext({
        id = 'morph_wine_processing',
        title = 'Vineyard Processing',
        options = {
            {
                title = 'Process Grape Juice',
                description = ('Need %dx Grapes'):format(grapeCount),
                icon = 'bottle-droplet',
                metadata = {
                    { label = 'Duration', value = '~8 seconds' },
                    { label = 'Output', value = '6-10 Grape Juice' }
                },
                onSelect = function() startProcess('juice') end
            },
            {
                title = 'Process Wine',
                description = ('Need %dx Grape Juice'):format(juiceCount),
                icon = 'wine-bottle',
                metadata = {
                    { label = 'Duration', value = '~8 seconds' },
                    { label = 'Output', value = '6-10 Wine' }
                },
                onSelect = function() startProcess('wine') end
            }
        }
    })
    lib.showContext('morph_wine_processing')
end

local function setupInteractions()
    local vData = { coords = config.vineyard.coords, size = vec3(1.6, 1.4, 3.2), rotation = 346.25 }
    if config.useTarget then
        exports.morph_tget:addBoxZone({
            coords = vData.coords,
            size = vData.size,
            rotation = vData.rotation,
            options = { {
                icon = 'fa-solid fa-wine-bottle',
                label = "Vineyard Processing",
                onSelect = processingMenu
            } }
        })
    else
        lib.zones.box({
            coords = vData.coords,
            size = vData.size,
            rotation = vData.rotation,
            onEnter = function() lib.showTextUI("Vineyard Processing") end,
            onExit = function() lib.hideTextUI() end,
            inside = function() if IsControlJustReleased(0, 38) then processingMenu() end end
        })
    end
    for i, coords in pairs(config.grapeLocations) do
        grapeZones[i] = createGrapeZone(i, coords)
    end
end

local function init() setLocationsBlip(); setupInteractions(); startDynamicBlips() end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function() isLoggedIn = true; init() end)
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function() isLoggedIn = false end)
CreateThread(function() if isLoggedIn then init() end end)