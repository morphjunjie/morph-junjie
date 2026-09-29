-- client.lua
local Config = require 'morph_tailor.config'

local function Notify(desc, type, duration)
    lib.notify({ title = 'Tailor Job', description = desc, type = type or 'info', duration = duration or 3000 })
end

local Helper = {
    notify = Notify,
    emote = { start = function(n) exports["morph_emote"]:EmoteCommandStart(n, 0) end, stop = function() exports["morph_emote"]:EmoteCancel() end },
    stress = function(a) TriggerServerEvent('hud:server:GainStress', a) end,
    progress = function(d, l) return lib.progressBar({ duration = d, label = l, useWhileDead = false, canCancel = true, disable = { move = true, car = true, combat = true } }) end,
    cb = { await = function(n, ...) return lib.callback.await(n, false, ...) end }
}

-- Minta izin/sesi ke server sebelum progress bar mulai. Server bakal
-- validasi ulang posisi (dan, khusus take, cooldown cotton milik
-- player ini) dan nyimpen jam mulainya buat dicocokin lagi pas reward
-- diklaim nanti.
local function startSession(actionType, isAuto, index)
    return Helper.cb.await('tailor:server:startAction', actionType, isAuto, index)
end

local busyCategories, categoryIndexes = {}, {}
local function getNextCategoryId() for i = 128, 129 do if not categoryIndexes[i] then categoryIndexes[i] = true; return i end end end

local function setBlipCategory(blip, name)
    local id = busyCategories[name] or getNextCategoryId()
    if not id then return end
    if not busyCategories[name] then busyCategories[name] = id; AddTextEntry("BLIP_CAT_" .. id, name) end
    SetBlipCategory(blip, id)
end
exports('setBlipCategory', setBlipCategory)

local function CreateBlips()
    for _, data in ipairs(Config.Blips) do
        local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
        SetBlipSprite(blip, data.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, data.scale)
        SetBlipColour(blip, data.colour)
        SetBlipAsShortRange(blip, true)
        setBlipCategory(blip, "Morph Tailor")
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(data.name)
        EndTextCommandSetBlipName(blip)
    end
end

CreateThread(function() Wait(500); CreateBlips() end)

local isInField = false
local cottonProps = {}
local minedCotton = {}
local isTaking = false

-- Forward declare, sama pola kayak mining/lumberjack, biar RespawnCotton
-- (yang didefinisikan duluan) bisa manggil SpawnCotton dengan bener --
-- sebelumnya SpawnCotton dideklarasikan 'local' di bawah RespawnCotton,
-- jadi RespawnCotton manggil variabel GLOBAL yang nggak pernah ada dan
-- selalu error tiap kali cotton mau respawn.
local SpawnCotton

local function LoadPropModel()
    local model = Config.CottonField.propModel
    if type(model) == "string" then model = joaat(model) end
    lib.requestModel(model, 5000)
    return model
end

local function DeleteCotton(index)
    if cottonProps[index] and DoesEntityExist(cottonProps[index]) then
        exports.morph_tget:removeLocalEntity(cottonProps[index], 'cotton_prop_' .. index)
        DeleteEntity(cottonProps[index])
        cottonProps[index] = nil
    end
end

local function RespawnCotton(index)
    local pos = Config.CottonField.spawnPoints[index]
    SetTimeout(Config.CottonField.respawnTime, function()
        if isInField and minedCotton[index] then
            minedCotton[index] = nil
            SpawnCotton(index, pos)
        end
    end)
end

local function TakeCotton(index)
    if isTaking then return Notify('Already taking cotton.', 'error') end
    if minedCotton[index] then return Notify('Cotton already taken.', 'error') end
    if not cottonProps[index] or not DoesEntityExist(cottonProps[index]) then return Notify('Cotton not found.', 'error') end
    local dist = #(GetEntityCoords(cache.ped) - GetEntityCoords(cottonProps[index]))
    if dist > Config.targetDistance then return Notify('Too far from cotton.', 'warn') end

    local scissor = lib.callback.await('tailor:server:checkScissors', false)
    if not scissor or not scissor.has then return Notify('Need scissors.', 'error') end
    if scissor.durability <= 20 and scissor.durability > 0 then Notify('Scissors durability: ' .. scissor.durability .. '%', 'warning') end
    if scissor.durability <= 0 then return Notify('Scissors are broken.', 'error') end
    if not lib.callback.await('tailor:server:canCarry', false, Config.CottonField.outputItem, Config.CottonField.outputMax) then return Notify('Inventory full.', 'error') end

    if not startSession('take', false, index) then
        return Notify('Could not start taking cotton here.', 'error')
    end

    isTaking = true
    exports["morph_emote"]:EmoteCommandStart("garden", 0)
    local success = lib.progressBar({
        duration = Config.CottonField.duration,
        label = 'Taking Cotton...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true }
    })
    exports["morph_emote"]:EmoteCancel()
    isTaking = false

    if not success then return Notify('Cancelled.', 'error') end
    TriggerServerEvent('hud:server:GainStress', Config.CottonField.stressGain)
    DeleteCotton(index)
    minedCotton[index] = true
    RespawnCotton(index)
    TriggerServerEvent('tailor:server:takeCotton', index, scissor.slot, scissor.durability)
    Notify('Cotton taken successfully!', 'success')
end

function SpawnCotton(index, pos)
    if minedCotton[index] then return end
    if cottonProps[index] and DoesEntityExist(cottonProps[index]) then return end
    local model = LoadPropModel()
    local obj = CreateObject(model, pos.x, pos.y, pos.z, false, false, false)
    if not obj or obj == 0 then return end
    SetModelAsNoLongerNeeded(model)
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
    if pos.w then SetEntityHeading(obj, pos.w) end
    cottonProps[index] = obj
    exports.morph_tget:addLocalEntity(obj, {
        {
            name = 'cotton_prop_' .. index,
            label = 'Taking Cotton',
            icon = 'fa-solid fa-leaf',
            distance = Config.targetDistance,
            onSelect = function() TakeCotton(index) end
        }
    })
end

local function SpawnAllCotton()
    for i, pos in ipairs(Config.CottonField.spawnPoints) do
        if not minedCotton[i] and not cottonProps[i] then
            SpawnCotton(i, pos)
            Wait(700)
        end
    end
end

local function ClearAllCotton()
    for i in pairs(cottonProps) do DeleteCotton(i) end
    cottonProps = {}
end

lib.zones.sphere({
    coords = Config.CottonField.coords,
    radius = Config.CottonField.inDistance,
    onEnter = function()
        if isInField then return end
        isInField = true
        SpawnAllCotton()
    end,
    onExit = function()
        if not isInField then return end
        isInField = false
        ClearAllCotton()
    end
})

local function processCotton(cfg, auto, type)
    local isCotton = type == 'cotton'
    local checkFunc = isCotton and 'tailor:server:checkProcessCotton' or 'tailor:server:checkProcessClothes'
    local label = auto and (isCotton and Config.AutoProcessCotton.label or Config.AutoProcessClothes.label) or cfg.label
    local processName = isCotton and 'Processing Cotton' or 'Making Clothes'
    local serverEvent = isCotton and 'tailor:server:processCottonReward' or 'tailor:server:processClothesReward'

    local plyCoords = GetEntityCoords(cache.ped)
    local targetCoords = cfg.coords
    if #(plyCoords - targetCoords) > 5.0 then return Notify('Too far from processing area.', 'warn') end

    if not Helper.cb.await('tailor:server:canCarry', cfg.outputItem, cfg.outputAmount) then return Notify('Inventory full.', 'error') end
    if not Helper.cb.await(checkFunc) then return Notify(string.format('Need %d %s.', cfg.inputAmount, cfg.inputItem:gsub('_', ' ')), 'error') end

    local total, maxStack, isCancelled = 0, 500, false
    local duration = auto and (isCotton and Config.AutoProcessCotton.duration or Config.AutoProcessClothes.duration) or cfg.duration
    local stress = auto and (isCotton and Config.AutoProcessCotton.stressGain or Config.AutoProcessClothes.stressGain) or cfg.stressGain

    if auto then Notify('Auto ' .. processName:lower() .. ' started.', 'success') end

    repeat
        local currentOutput = exports.morph_inv:GetItemCount(cfg.outputItem)
        if currentOutput >= maxStack then Notify('Inventory full.', 'error'); break end
        local remainingSpace = maxStack - currentOutput
        if remainingSpace < cfg.outputAmount then Notify(string.format('Need %d free slots to continue.', cfg.outputAmount), 'warn'); break end

        -- Re-check kapasitas beneran (berat/slot) tiap putaran, bukan cuma
        -- sekali di awal. Sebelumnya kalau inventory penuh gara-gara
        -- berat/slot (bukan stack item outputItem nyampe 500), auto job
        -- ga pernah berhenti karena cuma cek currentOutput >= maxStack.
        if not Helper.cb.await('tailor:server:canCarry', cfg.outputItem, cfg.outputAmount) then
            Notify('Inventory full.', 'error')
            break
        end

        local currentCoords = GetEntityCoords(cache.ped)
        if #(currentCoords - targetCoords) > 5.0 then Notify('Moved too far from processing area.', 'warn'); break end

        if not startSession(type, auto, nil) then
            Notify('Could not start action.', 'error'); break
        end

        exports["morph_emote"]:EmoteCommandStart("parkingmeter", 0)
        local progressLabel = auto and string.format('%s (X to Stop)', label) or label
        local success = lib.progressBar({
            duration = duration,
            label = progressLabel,
            useWhileDead = false,
            canCancel = true,
            disable = { move = true, car = true, combat = true }
        })
        exports["morph_emote"]:EmoteCancel()

        if success then
            TriggerServerEvent('hud:server:GainStress', stress)
            TriggerServerEvent(serverEvent)
            total = total + 1
            if not auto then Notify('Completed successfully.', 'success'); break end
        else
            if auto then isCancelled = true; Notify('Auto cancelled.', 'error')
            else Notify('Cancelled.', 'error') end
            break
        end
        Wait(500)
    until not auto or not Helper.cb.await(checkFunc)

    if auto and total > 0 and not isCancelled then
        Notify(string.format('Auto completed. Total batches: %d', total), 'success')
    end
end

exports.morph_tget:addBoxZone({
    coords = Config.ProcessCotton.coords,
    size = vec3(5, 5, 5),
    distance = 3.0,
    rotation = 0,
    debugPoly = Config.debugPoly,
    options = {
        { label = 'Processing Cotton', icon = 'fa-solid fa-hand', onSelect = function() processCotton(Config.ProcessCotton, false, 'cotton') end },
        { label = 'Auto Processing Cotton', icon = 'fa-solid fa-robot', onSelect = function() processCotton(Config.ProcessCotton, true, 'cotton') end }
    }
})

exports.morph_tget:addBoxZone({
    coords = Config.ProcessClothes.coords,
    size = vec3(5, 5, 5),
    distance = 3.0,
    rotation = 0,
    debugPoly = Config.debugPoly,
    options = {
        { label = 'Making Clothes', icon = 'fa-solid fa-tshirt', onSelect = function() processCotton(Config.ProcessClothes, false, 'clothes') end },
        { label = 'Auto Making Clothes', icon = 'fa-solid fa-gears', onSelect = function() processCotton(Config.ProcessClothes, true, 'clothes') end }
    }
})

AddEventHandler('onResourceStop', function()
    ClearAllCotton()
end)