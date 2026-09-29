-- client.lua
local Config = require 'morph_hunting.config'

local function Notify(desc, type, duration)
    lib.notify({ title = 'Hunting Job', description = desc, type = type or 'info', duration = duration or 3000 })
end

local Helper = {
    notify = Notify,
    emote = { start = function(n) exports["morph_emote"]:EmoteCommandStart(n, 0) end, stop = function() exports["morph_emote"]:EmoteCancel() end },
    stress = function(a) TriggerServerEvent('hud:server:GainStress', a) end,
    progress = function(d, l) return lib.progressBar({ duration = d, label = l, useWhileDead = false, canCancel = true, disable = { move = true, car = true, combat = true } }) end,
    cb = { await = function(n, ...) return lib.callback.await(n, false, ...) end }
}

-- Minta izin/sesi ke server sebelum progress bar mulai. Server bakal
-- validasi ulang posisi (masih di area hunting) dan nyimpen jam
-- mulainya buat dicocokin lagi pas reward diklaim nanti. Ini juga yang
-- mastiin 1 deer id cuma bisa diklaim sekali.
local function startSession(deerId)
    return Helper.cb.await('hunting:server:startAction', deerId)
end

local busyCategories, categoryIndexes = {}, {}
local function getNextCategoryId()
    for i = 74, 75 do
        if not categoryIndexes[i] then
            categoryIndexes[i] = true
            return i
        end
    end
    return nil
end

local function setBlipCategory(blip, name)
    local id = busyCategories[name] or getNextCategoryId()
    if not id then return end
    if not busyCategories[name] then
        busyCategories[name] = id
        AddTextEntry("BLIP_CAT_" .. id, name)
    end
    SetBlipCategory(blip, id)
end
exports('setBlipCategory', setBlipCategory)

local function CreateBlips()
    local blip = AddBlipForCoord(Config.StartHunting.coords.x, Config.StartHunting.coords.y, Config.StartHunting.coords.z)
    SetBlipSprite(blip, 141)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.7)
    SetBlipColour(blip, 5)
    SetBlipAsShortRange(blip, true)
    setBlipCategory(blip, "Morph Jobs")
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Hunting Job")
    EndTextCommandSetBlipName(blip)
end

CreateThread(function()
    Wait(500)
    CreateBlips()
end)

local isHunting = false
local isButchering = false
local huntingCooldownTimer = 0
local lodgeZone = nil

local deerList = {}
local deerBlips = {}
local deerTargets = {}
local deerMovementThreads = {}
local nextDeerId = 0
local activeDeerCount = 0

local function GetGroundPosition(coords)
    local found, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 100.0, 0)
    if found and groundZ > -1000 then
        return vec3(coords.x, coords.y, groundZ + 0.02)
    end
    return vec3(coords.x, coords.y, coords.z + 0.5)
end

local function GenerateDeerPosition()
    local center = Config.Deer.spawnCenter
    local radius = Config.Deer.spawnRadius
    local minDist = Config.Deer.minDistBetweenDeer
    for _ = 1, 30 do
        local angle = math.random() * 2 * math.pi
        local dist = math.random() * radius
        local newPos = vec3(center.x + math.cos(angle) * dist, center.y + math.sin(angle) * dist, center.z)
        local groundPos = GetGroundPosition(newPos)
        local valid = true
        for _, deer in pairs(deerList) do
            if deer and DoesEntityExist(deer) and #(groundPos - GetEntityCoords(deer)) < minDist then
                valid = false
                break
            end
        end
        if valid then return groundPos end
    end
    return GetGroundPosition(vec3(center.x + math.random() * 50 - 25, center.y + math.random() * 50 - 25, center.z))
end

local function GenerateRandomTargetPos(deer)
    local center = Config.Deer.spawnCenter
    local radius = Config.Deer.spawnRadius
    local deerPos = GetEntityCoords(deer)
    for _ = 1, 15 do
        local angle = math.random() * 2 * math.pi
        local dist = math.random() * (radius * 0.5)
        local newPos = vec3(deerPos.x + math.cos(angle) * dist, deerPos.y + math.sin(angle) * dist, deerPos.z)
        local groundPos = GetGroundPosition(newPos)
        if #(groundPos - center) < radius then return groundPos end
    end
    return GetGroundPosition(vec3(deerPos.x + math.random() * 30 - 15, deerPos.y + math.random() * 30 - 15, deerPos.z))
end

local function LoadDeerModel()
    local model = Config.Deer.model
    if not HasModelLoaded(model) then lib.requestModel(model, 5000) end
    return model
end

local function UpdateDeerBlip(id)
    local blip = deerBlips[id]
    local deer = deerList[id]
    if blip and DoesBlipExist(blip) and deer and DoesEntityExist(deer) then
        local coords = GetEntityCoords(deer)
        SetBlipCoords(blip, coords.x, coords.y, coords.z)
    end
end

local function CreateDeerBlip(id)
    local deer = deerList[id]
    if not deer or not DoesEntityExist(deer) then return end
    local coords = GetEntityCoords(deer)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 141)
    SetBlipScale(blip, 0.6)
    SetBlipColour(blip, 2)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Morph Deer Hunting")
    EndTextCommandSetBlipName(blip)
    deerBlips[id] = blip
end

local function RemoveDeerBlip(id)
    local blip = deerBlips[id]
    if blip and DoesBlipExist(blip) then RemoveBlip(blip) end
    deerBlips[id] = nil
end

local function RemoveDeerTarget(id)
    if deerTargets[id] then
        local deer = deerList[id]
        if deer then exports.morph_tget:removeLocalEntity(deer, 'hunt_deer_' .. id) end
        deerTargets[id] = nil
    end
end

local function StopDeerMovement(id)
    local thread = deerMovementThreads[id]
    if thread then TerminateThread(thread) end
    deerMovementThreads[id] = nil
end

local function DestroyDeer(id, deleteEntity)
    StopDeerMovement(id)
    RemoveDeerTarget(id)
    RemoveDeerBlip(id)
    local deer = deerList[id]
    if deleteEntity and deer and DoesEntityExist(deer) then DeleteEntity(deer) end
    if deerList[id] then deerList[id] = nil activeDeerCount = activeDeerCount - 1 end
end

local function canStartHunting()
    return not (huntingCooldownTimer > 0 and GetGameTimer() < huntingCooldownTimer)
end

local function ButcherDeer(id)
    if isButchering then return Notify('Already butchering.', 'error') end
    local deer = deerList[id]
    if not deer or not DoesEntityExist(deer) then return Notify('Deer already butchered.', 'error') end
    if not IsEntityDead(deer) then return Notify('You need to kill the deer first.', 'error') end
    if #(GetEntityCoords(cache.ped) - GetEntityCoords(deer)) > Config.targetDistance then return Notify('Too far from deer.', 'warn') end
    if not HasPedGotWeapon(cache.ped, GetHashKey(Config.StartHunting.requiredItem), false) then return Notify('You need a knife.', 'error') end
    if not Helper.cb.await('hunting:server:canCarry', Config.Butcher.meatItem, Config.Butcher.meatMax) then return Notify('Inventory full.', 'error') end

    if not startSession(id) then
        return Notify('Could not start butchering here.', 'error')
    end

    isButchering = true
    StopDeerMovement(id)
    Helper.emote.start("mechanic4")
    local success = Helper.progress(Config.Butcher.duration, 'Butchering Deer...')
    Helper.emote.stop()
    if success then
        Helper.stress(Config.Butcher.stressGain)
        TriggerServerEvent('hunting:server:butcherDeer', id)
        DestroyDeer(id, true)
        Notify('Deer butchered successfully!', 'success')
    else
        Notify('Butchering cancelled.', 'error')
    end
    isButchering = false
end

local function SpawnDeer()
    if not isHunting then return end
    if activeDeerCount >= Config.Deer.maxDeer then return end
    local model = LoadDeerModel()
    local spawnPos = GenerateDeerPosition()
    local deer = CreatePed(28, model, spawnPos.x, spawnPos.y, spawnPos.z, math.random(0, 360), true, false)
    SetModelAsNoLongerNeeded(model)
    if not deer or deer == 0 then return end
    SetEntityAsMissionEntity(deer, true, true)
    SetEntityInvincible(deer, false)
    SetPedFleeAttributes(deer, 0, false)
    SetPedCombatAttributes(deer, 0, true)
    nextDeerId = nextDeerId + 1
    local id = nextDeerId
    deerList[id] = deer
    activeDeerCount = activeDeerCount + 1
    TaskGoToCoordAnyMeans(deer, GenerateRandomTargetPos(deer), 2.0, 0, 0, 0, 0)
    CreateDeerBlip(id)
    exports.morph_tget:addLocalEntity(deer, {
        { name = 'hunt_deer_' .. id, label = 'Butcher Deer', icon = 'fa-solid fa-cut', distance = Config.targetDistance, onSelect = function() ButcherDeer(id) end }
    })
    deerTargets[id] = true
    CreateThread(function()
        while isHunting and deer and DoesEntityExist(deer) do Wait(1000) UpdateDeerBlip(id) end
    end)
    deerMovementThreads[id] = CreateThread(function()
        while isHunting and deer and DoesEntityExist(deer) do
            Wait(8000)
            if deer and DoesEntityExist(deer) and not IsEntityDead(deer) and not IsPedInAnyVehicle(deer, false) then
                TaskGoToCoordAnyMeans(deer, GenerateRandomTargetPos(deer), 2.0, 0, 0, 0, 0)
            end
        end
        deerMovementThreads[id] = nil
    end)
end

local function StartHunting()
    if isHunting then return Notify('Already hunting.', 'error') end
    if not canStartHunting() then return Notify(string.format('Wait %ds.', math.ceil((huntingCooldownTimer - GetGameTimer()) / 1000)), 'error') end
    isHunting = true
    Notify('Hunting started!', 'success')
    CreateThread(function()
        for i = 1, Config.Deer.maxDeer do
            if not isHunting then break end
            Wait(500)
            SpawnDeer()
        end
    end)
end

local function StopHunting(silent)
    if not isHunting then return end
    isHunting = false
    for id in pairs(deerList) do DestroyDeer(id, true) end
    deerList, deerBlips, deerTargets, deerMovementThreads = {}, {}, {}, {}
    activeDeerCount = 0
    if Config.cooldown and Config.cooldown > 0 then
        huntingCooldownTimer = GetGameTimer() + Config.cooldown
        if not silent then Notify(string.format('Stopped. Wait %ds.', Config.cooldown / 1000), 'info') end
    elseif not silent then Notify('Stopped.', 'info') end
end

local function StartAutoStopMonitor()
    CreateThread(function()
        while true do
            Wait(10000)
            if isHunting and #(GetEntityCoords(cache.ped) - Config.StartHunting.coords) > Config.autoStopDistance then
                StopHunting(true)
                Notify('Left area. Stopped.', 'warn')
            end
        end
    end)
end
StartAutoStopMonitor()

local function OpenHuntingMenu()
    local startDisabled = isHunting or not canStartHunting()
    local startDesc = isHunting and 'Already hunting' or (not canStartHunting() and string.format('Cooldown %ds', math.ceil((huntingCooldownTimer - GetGameTimer()) / 1000)) or 'Begin hunting')
    lib.registerContext({
        id = 'hunting_main_menu',
        title = 'Hunting Lodge',
        options = {
            { title = 'Start Hunting', description = startDesc, icon = 'fa-solid fa-play', disabled = startDisabled, onSelect = StartHunting },
            { title = 'Stop Hunting', description = 'Stop and remove deer', icon = 'fa-solid fa-stop', disabled = not isHunting, onSelect = function() StopHunting(false) end }
        }
    })
    lib.showContext('hunting_main_menu')
end

local function setupLodgeZone()
    if lodgeZone then exports.morph_tget:removeZone(lodgeZone) lodgeZone = nil end
    lodgeZone = exports.morph_tget:addBoxZone({
        coords = Config.StartHunting.coords,
        debug = Config.debugPoly or false,
        size = vec3(0.8, 0.5, 1.0),
        options = { { label = 'Hunting Lodge', icon = 'fa-solid fa-tree', distance = 3.0, canInteract = function() return true end, onSelect = OpenHuntingMenu } }
    })
end

CreateThread(setupLodgeZone)
AddEventHandler('onResourceStart', setupLodgeZone)
AddEventHandler('onResourceStop', function()
    StopHunting(true)
    if lodgeZone then exports.morph_tget:removeZone(lodgeZone) lodgeZone = nil end
end)