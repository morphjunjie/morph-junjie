-- client.lua
local Config = require 'morph_lumberjack.config'
local isInArea = false
local trees = {}
local minedTrees = {}
local isChopping = false

local ChopTree
local SpawnTree

local busyCategories, categoryIndexes = {}, {}
local function getNextCategoryId() for i = 111, 112 do if not categoryIndexes[i] then categoryIndexes[i] = true; return i end end end
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
        setBlipCategory(blip, "Morph Lumberjack")
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(data.name)
        EndTextCommandSetBlipName(blip)
    end
end

CreateThread(function() Wait(500) CreateBlips() end)

local function Notify(desc, type)
    lib.notify({ title = 'Lumberjack Job', description = desc, type = type or 'info', duration = 3000 })
end

-- Minta izin/sesi ke server sebelum progress bar mulai. Server bakal
-- validasi ulang posisi (dan, khusus chop, cooldown tree milik player
-- ini) dan nyimpen jam mulainya buat dicocokin lagi pas reward
-- diklaim nanti.
local function startSession(actionType, isAuto, index)
    return lib.callback.await('lumberjack:server:startAction', false, actionType, isAuto, index)
end

local function GetGroundPosition(coords)
    local found, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 100.0, 0)
    return found and groundZ > -1000 and vec3(coords.x, coords.y, groundZ + 0.02) or vec3(coords.x, coords.y, coords.z + 0.5)
end

local function LoadModel(model)
    lib.requestModel(model, 5000)
    return model
end

local function DeleteTree(index)
    if trees[index] and DoesEntityExist(trees[index]) then
        exports.morph_tget:removeLocalEntity(trees[index], 'chop_tree_' .. index)
        DeleteEntity(trees[index])
        trees[index] = nil
    end
end

local function RespawnTree(index)
    local pos = Config.Tree.spawnPoints[index]
    SetTimeout(Config.Tree.respawnTime, function()
        if isInArea and minedTrees[index] then
            minedTrees[index] = nil
            SpawnTree(index, pos)
        end
    end)
end

function SpawnTree(index, pos)
    if minedTrees[index] then return end
    if trees[index] and DoesEntityExist(trees[index]) then return end
    local model = LoadModel(Config.Tree.treeModel)
    local groundPos = GetGroundPosition(pos)
    local obj = CreateObject(model, groundPos.x, groundPos.y, groundPos.z, false, false, false)
    if not obj or obj == 0 then return end
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
    if pos.w then SetEntityHeading(obj, pos.w) end
    trees[index] = obj
    exports.morph_tget:addLocalEntity(obj, {
        {
            name = 'chop_tree_' .. index,
            label = 'Chopping Tree',
            icon = 'fa-solid fa-tree',
            distance = Config.targetDistance,
            onSelect = function() ChopTree(index) end
        }
    })
end

local function SpawnAllTrees()
    for i, pos in ipairs(Config.Tree.spawnPoints) do
        if not minedTrees[i] and not trees[i] then
            SpawnTree(i, pos)
            Wait(800)
        end
    end
end

local function ClearAllTrees()
    for i in pairs(trees) do DeleteTree(i) end
    trees = {}
end

function ChopTree(index)
    if isChopping then return Notify('Already chopping.', 'error') end
    if minedTrees[index] then return Notify('Tree already chopped.', 'error') end
    if not trees[index] or not DoesEntityExist(trees[index]) then return Notify('Tree not found.', 'error') end
    local dist = #(GetEntityCoords(cache.ped) - GetEntityCoords(trees[index]))
    if dist > Config.targetDistance then return Notify('Too far from tree.', 'warn') end

    local axe = lib.callback.await('lumberjack:server:checkAxe', false)
    if not axe or not axe.has then return Notify('Need an axe.', 'error') end
    if axe.durability <= 20 and axe.durability > 0 then Notify('Axe durability: ' .. axe.durability .. '%', 'warning') end
    if axe.durability <= 0 then return Notify('Axe is broken.', 'error') end
    if not lib.callback.await('lumberjack:server:canCarry', false, Config.Items.woodLog, Config.Tree.maxWood) then return Notify('Inventory full.', 'error') end

    if not startSession('chop', false, index) then
        return Notify('Could not start chopping here.', 'error')
    end

    isChopping = true
    exports["morph_emote"]:EmoteCommandStart("axe2", 0)
    local success = lib.progressBar({
        duration = Config.Tree.progressTime,
        label = 'Chopping Tree...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true }
    })
    exports["morph_emote"]:EmoteCancel()
    isChopping = false

    if not success then return Notify('Cancelled.', 'error') end
    TriggerServerEvent('hud:server:GainStress', Config.Tree.stressGain)
    DeleteTree(index)
    minedTrees[index] = true
    RespawnTree(index)
    TriggerServerEvent('lumberjack:server:chopTree', index, axe.slot, axe.durability)
    Notify('Tree chopped successfully!', 'success')
end

lib.zones.sphere({
    coords = Config.Tree.coords,
    radius = Config.Tree.inDistance,
    onEnter = function()
        if isInArea then return end
        isInArea = true
        SpawnAllTrees()
    end,
    onExit = function()
        if not isInArea then return end
        isInArea = false
        ClearAllTrees()
    end
})

local function ProcessAction(cfg, auto, type)
    local plyCoords = GetEntityCoords(cache.ped)
    if #(plyCoords - cfg.coords) > 5.0 then return Notify('Too far from area.', 'warn') end
    if not lib.callback.await('lumberjack:server:checkItems', false, cfg.inputItem, cfg.inputAmount) then
        return Notify(string.format('Need %d %s.', cfg.inputAmount, cfg.inputItem:gsub('_', ' ')), 'error')
    end
    if not lib.callback.await('lumberjack:server:canCarry', false, cfg.outputItem, cfg.outputAmount) then
        return Notify('Inventory full.', 'error')
    end

    local total, isCancelled = 0, false
    local duration = auto and (type == 'log' and Config.AutoProcessLog.duration or Config.AutoProcessPlank.duration) or cfg.progressTime
    local stress = auto and (type == 'log' and Config.AutoProcessLog.stressGain or Config.AutoProcessPlank.stressGain) or cfg.stressGain
    local label = auto and (type == 'log' and Config.AutoProcessLog.label or Config.AutoProcessPlank.label) or cfg.label
    local event = type == 'log' and 'lumberjack:server:processLog' or 'lumberjack:server:processPlank'

    if auto then Notify('Auto started.', 'success') end

    repeat
        local current = exports.morph_inv:GetItemCount(cfg.outputItem)
        if current >= 500 then Notify('Inventory full.', 'error'); break end
        if #(GetEntityCoords(cache.ped) - cfg.coords) > 5.0 then Notify('Moved too far.', 'warn'); break end
        if not lib.callback.await('lumberjack:server:checkItems', false, cfg.inputItem, cfg.inputAmount) then
            Notify('Out of materials.', 'error'); break
        end

        if not startSession(type, auto, nil) then
            Notify('Could not start action.', 'error'); break
        end

        exports["morph_emote"]:EmoteCommandStart("mechanic", 0)
        local success = lib.progressBar({
            duration = duration,
            label = auto and string.format('%s (X to Stop)', label) or label,
            useWhileDead = false,
            canCancel = true,
            disable = { move = true, car = true, combat = true }
        })
        exports["morph_emote"]:EmoteCancel()
        if not success then isCancelled = true; break end
        TriggerServerEvent('hud:server:GainStress', stress)
        TriggerServerEvent(event)
        total = total + 1
        if not auto then Notify('Completed successfully.', 'success'); break end
        Wait(1500)
    until false

    if auto and total > 0 and not isCancelled then
        Notify(string.format('Auto completed. Total: %d', total), 'success')
    elseif isCancelled and auto then
        Notify('Auto cancelled.', 'error')
    end
end

exports.morph_tget:addBoxZone({
    coords = Config.ProcessLog.coords,
    size = vec3(5, 5, 5),
    options = {
        { label = 'Processing Logs', icon = 'fa-solid fa-hand', onSelect = function() ProcessAction(Config.ProcessLog, false, 'log') end },
        { label = 'Auto Processing Logs', icon = 'fa-solid fa-robot', onSelect = function() ProcessAction(Config.ProcessLog, true, 'log') end }
    }
})

exports.morph_tget:addBoxZone({
    coords = Config.ProcessPlank.coords,
    size = vec3(5, 5, 5),
    options = {
        { label = 'Packing Crates', icon = 'fa-solid fa-hand', onSelect = function() ProcessAction(Config.ProcessPlank, false, 'plank') end },
        { label = 'Auto Packing Crates', icon = 'fa-solid fa-robot', onSelect = function() ProcessAction(Config.ProcessPlank, true, 'plank') end }
    }
})

AddEventHandler('onResourceStop', function()
    ClearAllTrees()
end)