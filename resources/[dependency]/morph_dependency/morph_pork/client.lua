-- client.lua
local Config = require 'morph_pork.config'
local isWorking = false
local isBusy = false
local spawnedPigs = {}
local pigCount = 0
local uiShownByPig = false
local sackInfo = { hasSack = false, durability = 0, slot = nil }
local isProcessing = false

local busyCategories, categoryIndexes = {}, {}
local function getNextCategoryId() for i = 125, 133 do if not categoryIndexes[i] then categoryIndexes[i] = true; return i end end end
local function setBlipCategory(blip, name) local id = busyCategories[name] or getNextCategoryId() if not id then return end if not busyCategories[name] then busyCategories[name] = id; AddTextEntry("BLIP_CAT_" .. id, name) end SetBlipCategory(blip, id) end
exports('setBlipCategory', setBlipCategory)

local function CreateBlips()
    for _, data in ipairs(Config.Blips) do
        local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
        SetBlipSprite(blip, data.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, data.scale)
        SetBlipColour(blip, data.colour)
        SetBlipAsShortRange(blip, true)
        setBlipCategory(blip, "Morph Pork Farm")
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(data.name)
        EndTextCommandSetBlipName(blip)
    end
end

CreateThread(function() Wait(500) CreateBlips() end)

local function Notify(desc, type)
    lib.notify({ title = 'Pork Farm Job', description = desc, type = type or 'info', duration = 3000 })
end

local function canCarry(item, amount)
    return lib.callback.await('pig:server:canCarry', false, item, amount)
end

local function checkItems(item, amount)
    return lib.callback.await('pig:server:checkItems', false, item, amount)
end

-- Minta izin/sesi ke server sebelum progress bar mulai. Server bakal
-- validasi ulang posisi & tipe kerjaan, dan nyimpen jam mulainya buat
-- dicocokin lagi pas reward diklaim nanti.
local function startSession(actionType, isAuto)
    return lib.callback.await('pig:server:startAction', false, actionType, isAuto)
end

local function CheckSackStatus()
    local data = lib.callback.await('pig:server:checkSack', false)
    if data then
        sackInfo.hasSack = true
        sackInfo.durability = data.durability
        sackInfo.slot = data.slot
    else
        sackInfo.hasSack = false
        sackInfo.durability = 0
        sackInfo.slot = nil
    end
    return sackInfo.hasSack
end

local function ClearPigs()
    for _, v in ipairs(spawnedPigs) do
        if DoesEntityExist(v) then DeleteEntity(v) end
    end
    spawnedPigs = {}
    pigCount = 0
end

local function SpawnPig()
    if not isWorking or pigCount >= Config.Job.MaxPigs then return end
    
    local model = Config.Job.PigModel
    lib.requestModel(model)
    
    local spawnPos = Config.Job.SpawnCenter + vec3(
        math.random(-Config.Job.SpawnRadius, Config.Job.SpawnRadius),
        math.random(-Config.Job.SpawnRadius, Config.Job.SpawnRadius),
        0
    )
    
    local pig = CreatePed(28, model, spawnPos.x, spawnPos.y, spawnPos.z, math.random(0, 360), true, false)
    SetEntityAsMissionEntity(pig, true, true)
    SetEntityInvincible(pig, true)
    SetBlockingOfNonTemporaryEvents(pig, true)
    table.insert(spawnedPigs, pig)
    pigCount = pigCount + 1
    
    SetTimeout(800, function()
        if DoesEntityExist(pig) then
            TaskSmartFleeCoord(pig, spawnPos.x + math.random(-50, 50), spawnPos.y + math.random(-50, 50), spawnPos.z, 100.0, -1, true, true)
        end
    end)
end

local function SpawnAllPigs()
    if not isWorking then return end
    
    ClearPigs()
    local spawned = 0
    
    while spawned < Config.Job.MaxPigs and isWorking do
        SpawnPig()
        spawned = spawned + 1
        
        if spawned < Config.Job.MaxPigs then
            Wait(300)
        end
    end
end

local function RespawnPig()
    if not isWorking then return end
    if pigCount >= Config.Job.MaxPigs then return end
    
    Wait(Config.Job.RespawnTime)
    if isWorking and pigCount < Config.Job.MaxPigs then
        SpawnPig()
    end
end

local function CatchPigLogic(entity, idx)
    if isBusy then return end
    isBusy = true

    local plyCoords = GetEntityCoords(cache.ped)
    local distToPig = #(plyCoords - GetEntityCoords(entity))
    if distToPig > Config.Job.targetDistance then
        FreezeEntityPosition(entity, false)
        isBusy = false
        Notify('Too far from pig.', 'warn')
        return
    end

    if not CheckSackStatus() then
        FreezeEntityPosition(entity, false)
        isBusy = false
        Notify('Need a sack to catch pigs.', 'warn')
        return
    end

    if sackInfo.durability <= 20 and sackInfo.durability > 0 then
        Notify(string.format('Sack durability: %d%%', sackInfo.durability), 'warning')
    end

    if sackInfo.durability <= 0 then
        FreezeEntityPosition(entity, false)
        isBusy = false
        Notify('Sack is broken. Get a new one.', 'error')
        return
    end

    if not canCarry(Config.Job.RewardItem, Config.Job.RewardMax) then
        FreezeEntityPosition(entity, false)
        isBusy = false
        Notify('Inventory full.', 'warn')
        return
    end

    if not startSession('catch', false) then
        FreezeEntityPosition(entity, false)
        isBusy = false
        Notify('Could not start catching here.', 'error')
        return
    end

    exports["morph_emote"]:EmoteCommandStart("pickup", 0)
    local progressSuccess = lib.progressBar({
        duration = 4000,
        label = 'Catching Pig...',
        useWhileDead = false,
        canCancel = false,
        disable = { move = true, car = true, combat = true }
    })
    exports["morph_emote"]:EmoteCancel()

    if progressSuccess then
        TriggerServerEvent('hud:server:GainStress', Config.Job.StressGain)

        -- Chance-nya sekarang di-roll server, bukan di sini. Kita cuma
        -- nunggu hasilnya lewat callback.
        local caught = lib.callback.await('pig:server:catchReward', false, sackInfo.slot, sackInfo.durability)

        if caught then
            DeleteEntity(entity)
            table.remove(spawnedPigs, idx)
            pigCount = pigCount - 1
            Notify('Pig caught successfully!', 'success')
            CreateThread(function()
                RespawnPig()
            end)
        else
            FreezeEntityPosition(entity, false)
            TaskSmartFleePed(entity, cache.ped, 30.0, 5000, true, true)
            Notify('Pig escaped. Try again.', 'info')
        end
    else
        FreezeEntityPosition(entity, false)
        Notify('Cancelled.', 'error')
    end

    isBusy = false
end

CreateThread(function()
    while true do
        Wait(5000)
        if isWorking then
            local plyCoords = GetEntityCoords(cache.ped)
            local distToCenter = #(plyCoords - Config.Job.SpawnCenter)
            if distToCenter > Config.Job.AutoStopDistance then
                isWorking = false
                ClearPigs()
                Notify('Left farm area. Job stopped.', 'info')
            end
        end
    end
end)

CreateThread(function()
    while true do
        local sleep = 500
        local nearPig = false

        if isWorking and not isBusy then
            local plyCoords = GetEntityCoords(cache.ped)
            for k, v in ipairs(spawnedPigs) do
                if DoesEntityExist(v) then
                    local distToPig = #(plyCoords - GetEntityCoords(v))
                    if distToPig < Config.Job.targetDistance then
                        nearPig = true
                        sleep = 0
                        if not uiShownByPig then
                            CheckSackStatus()
                            lib.showTextUI(
                                sackInfo.hasSack and 'E - Catch Pig' or 'Need a sack to catch pig',
                                { position = 'left-center', icon = sackInfo.hasSack and 'hand-fist' or 'sack' }
                            )
                            uiShownByPig = true
                        end
                        if IsControlJustReleased(0, 38) then
                            lib.hideTextUI()
                            uiShownByPig = false
                            FreezeEntityPosition(v, true)
                            CatchPigLogic(v, k)
                        end
                        break
                    end
                end
            end
        end

        if not nearPig and uiShownByPig then
            lib.hideTextUI()
            uiShownByPig = false
        end

        Wait(sleep)
    end
end)

local function processAction(cfg, auto, type)
    if isProcessing then return Notify('Already processing.', 'error') end

    local targetDist = cfg.targetDistance

    local plyCoords = GetEntityCoords(cache.ped)
    if #(plyCoords - cfg.coords) > targetDist then
        return Notify('Too far from area.', 'warn')
    end

    local outputItem = cfg.outputItem
    local outputAmount = cfg.outputAmount
    local inputItem = cfg.inputItem
    local inputAmount = cfg.inputAmount

    if inputItem and inputAmount > 0 then
        if not checkItems(inputItem, inputAmount) then
            return Notify(string.format('Need %d %s.', inputAmount, inputItem:gsub('_', ' ')), 'error')
        end
    end

    if not canCarry(outputItem, outputAmount) then
        return Notify('Inventory full.', 'error')
    end

    local currentOutput = exports.morph_inv:GetItemCount(outputItem)
    if currentOutput >= cfg.maxStack then
        return Notify('Inventory full.', 'error')
    end

    isProcessing = true
    local total, isCancelled = 0, false
    local duration = auto and (type == 'meat' and Config.AutoProcessMeat.duration or Config.AutoProcessPack.duration) or cfg.duration
    local stress = auto and (type == 'meat' and Config.AutoProcessMeat.stressGain or Config.AutoProcessPack.stressGain) or cfg.stressGain
    local progressLabel = auto and (type == 'meat' and Config.AutoProcessMeat.label or Config.AutoProcessPack.label) or cfg.progressLabel
    local event = type == 'meat' and 'pig:server:processMeatReward' or 'pig:server:processPackReward'
    local waitTime = auto and (type == 'meat' and Config.AutoProcessMeat.waitTime or Config.AutoProcessPack.waitTime)

    if auto then Notify('Auto started.', 'success') end

    repeat
        if not canCarry(outputItem, outputAmount) then
            Notify('Inventory full. Auto stopped.', 'error')
            break
        end

        local remainingSpace = cfg.maxStack - exports.morph_inv:GetItemCount(outputItem)
        if remainingSpace < outputAmount then
            Notify('Inventory full. Auto stopped.', 'error')
            break
        end

        if inputItem and inputAmount > 0 then
            if not checkItems(inputItem, inputAmount) then
                Notify('Out of materials. Auto stopped.', 'error')
                break
            end
        end

        local currentCoords = GetEntityCoords(cache.ped)
        if #(currentCoords - cfg.coords) > targetDist then
            Notify('Moved too far. Auto stopped.', 'warn')
            break
        end

        if not startSession(type, auto) then
            Notify('Could not start action. Auto stopped.', 'error')
            break
        end

        exports["morph_emote"]:EmoteCommandStart("parkingmeter", 0)
        local success = lib.progressBar({
            duration = duration,
            label = auto and string.format('%s (X to Stop)', progressLabel) or progressLabel,
            useWhileDead = false,
            canCancel = true,
            disable = { move = true, car = true, combat = true }
        })
        exports["morph_emote"]:EmoteCancel()

        if not success then
            isCancelled = true
            Notify(auto and 'Auto cancelled.' or 'Cancelled.', 'error')
            break
        end

        TriggerServerEvent('hud:server:GainStress', stress)
        TriggerServerEvent(event)
        total = total + 1

        if not auto then
            Notify('Completed successfully.', 'success')
            break
        end

        if waitTime > 0 then Wait(waitTime) end
    until false

    isProcessing = false

    if auto and total > 0 and not isCancelled then
        Notify(string.format('Auto completed. Total: %d', total), 'success')
    elseif auto and total == 0 and not isCancelled then
        Notify('Auto stopped. No items processed.', 'warn')
    end
end

local function setupZone(cfg, type)
    local targetDist = cfg.targetDistance

    exports.morph_tget:addBoxZone({
        coords = cfg.coords,
        size = cfg.zoneSize,
        debug = Config.debugPoly,
        options = {
            {
                label = cfg.targetLabel,
                icon = cfg.icon,
                onSelect = function()
                    if isProcessing then return Notify('Already processing.', 'error') end
                    processAction(cfg, false, type)
                end,
                distance = targetDist,
                canInteract = function() return not isProcessing end
            },
            {
                label = 'Auto ' .. cfg.targetLabel,
                icon = 'fa-solid fa-robot',
                onSelect = function()
                    if isProcessing then return Notify('Already processing.', 'error') end
                    processAction(cfg, true, type)
                end,
                distance = targetDist,
                canInteract = function() return not isProcessing end
            }
        }
    })
end

exports.morph_tget:addBoxZone({
    coords = Config.Job.MenuCoords,
    size = Config.Job.zoneSize,
    debug = Config.debugPoly,
    options = {
        {
            label = Config.Job.targetLabel,
            icon = Config.Job.icon,
            distance = 2.0,
            onSelect = function()
                local hasSack = CheckSackStatus()
                local sackStatus = hasSack and string.format('Available (%d%%)', sackInfo.durability) or 'Not Available'
                lib.registerContext({
                    id = 'pork_menu',
                    title = 'Pork Farm',
                    options = {
                        {
                            title = 'Sack Status: ' .. sackStatus,
                            description = hasSack and 'Ready to catch pigs.' or 'Need a sack first.',
                            icon = hasSack and 'fa-solid fa-check-circle' or 'fa-solid fa-times-circle',
                            disabled = true
                        },
                        {
                            title = 'Begin Work',
                            description = hasSack and 'Start catching pigs' or 'Get a sack first',
                            icon = 'fa-solid fa-briefcase',
                            disabled = isWorking or not hasSack,
                            onSelect = function()
                                isWorking = true
                                SpawnAllPigs()
                                Notify('Started working.', 'success')
                            end
                        },
                        {
                            title = 'End Shift',
                            description = 'Stop working and clear all pigs',
                            icon = 'fa-solid fa-sign-out-alt',
                            disabled = not isWorking,
                            onSelect = function()
                                isWorking = false
                                ClearPigs()
                                Notify('Stopped working.', 'info')
                            end
                        }
                    }
                })
                lib.showContext('pork_menu')
            end
        }
    }
})

setupZone(Config.ProcessMeat, 'meat')
setupZone(Config.ProcessPack, 'pack')

AddEventHandler('onResourceStop', function()
    ClearPigs()
    isProcessing = false
end)