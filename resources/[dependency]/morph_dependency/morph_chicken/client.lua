-- client.lua
local Config = require 'morph_chicken.config'
local isProcessing = false

local busyCategories, categoryIndexes = {}, {}
local function getNextCategoryId() for i = 119, 120 do if not categoryIndexes[i] then categoryIndexes[i] = true; return i end end end
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
        setBlipCategory(blip, "Morph Chicken Farm")
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(data.name)
        EndTextCommandSetBlipName(blip)
    end
end

CreateThread(function() Wait(500) CreateBlips() end)

local function Notify(desc, type)
    lib.notify({ title = 'Chicken Farm Job', description = desc, type = type or 'info', duration = 3000 })
end

local function canCarry(item, amount)
    return lib.callback.await('chicken:server:canCarry', false, item, amount)
end

local function checkItems(item, amount)
    return lib.callback.await('chicken:server:checkItems', false, item, amount)
end

-- Minta izin/sesi ke server sebelum progress bar mulai. Server bakal
-- validasi ulang posisi & tipe kerjaan ini, dan nyimpen jam mulainya
-- buat dicocokin lagi pas reward diklaim nanti.
local function startSession(actionType, isAuto)
    return lib.callback.await('chicken:server:startAction', false, actionType, isAuto)
end

local function processAction(cfg, auto, type)
    if isProcessing then return Notify('Already processing.', 'error') end

    local targetDist = cfg.targetDistance or Config.targetDistance or 3.0

    local plyCoords = GetEntityCoords(cache.ped)
    if #(plyCoords - cfg.coords) > targetDist then
        return Notify('Too far from area.', 'warn')
    end

    local outputItem = cfg.outputItem
    local outputAmount = cfg.outputAmount
    local inputItem = cfg.inputItem
    local inputAmount = cfg.inputAmount or 0

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
    local duration = auto and (type == 'take' and Config.AutoTakeChicken.duration or type == 'meat' and Config.AutoProcessMeat.duration or Config.AutoProcessPack.duration) or cfg.duration
    local stress = auto and (type == 'take' and Config.AutoTakeChicken.stressGain or type == 'meat' and Config.AutoProcessMeat.stressGain or Config.AutoProcessPack.stressGain) or cfg.stressGain
    local progressLabel = auto and (type == 'take' and Config.AutoTakeChicken.label or type == 'meat' and Config.AutoProcessMeat.label or Config.AutoProcessPack.label) or cfg.progressLabel or cfg.label
    local event = type == 'take' and 'chicken:server:takeReward' or type == 'meat' and 'chicken:server:processMeatReward' or 'chicken:server:processPackReward'
    local waitTime = auto and (type == 'take' and Config.AutoTakeChicken.waitTime or type == 'meat' and Config.AutoProcessMeat.waitTime or Config.AutoProcessPack.waitTime) or 0

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

        -- Wajib dapet sesi valid dari server dulu sebelum progress bar
        -- jalan. Kalau server nolak (misal posisi dianggap di luar
        -- jangkauan), auto langsung dihentikan daripada maksa lanjut.
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
    local targetLabel = cfg.targetLabel or (cfg.label and cfg.label:gsub('%.%.%.', ''):gsub('ing', '')) or 'Interact'
    local targetDist = cfg.targetDistance or Config.targetDistance or 3.0

    exports.morph_tget:addBoxZone({
        coords = cfg.coords,
        size = cfg.zoneSize or vec3(5, 5, 5),
        rotation = cfg.zoneRotation or 0,
        debug = Config.debugPoly,
        options = {
            {
                label = targetLabel,
                icon = cfg.icon or 'fa-solid fa-hand',
                onSelect = function()
                    if isProcessing then return Notify('Already processing.', 'error') end
                    processAction(cfg, false, type)
                end,
                distance = targetDist,
                canInteract = function() return not isProcessing end
            },
            {
                label = 'Auto ' .. targetLabel,
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

setupZone(Config.TakeChicken, 'take')
setupZone(Config.ProcessChicken, 'meat')
setupZone(Config.PackChicken, 'pack')

AddEventHandler('onResourceStop', function()
    isProcessing = false
end)