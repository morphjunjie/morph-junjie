-- client.lua
local Config = require 'morph_jobgarages.config'
local QBX = exports.morph_junjie

local currentVehicle = nil
local isSpawning = false

local function GetPlayerInfo()
    local playerData = QBX:GetPlayerData() or LocalPlayer.state
    if not playerData or not playerData.job then return nil end
    return {
        job = playerData.job.name,
        grade = playerData.job.grade.level or 0,
        onduty = playerData.job.onduty,
    }
end

local function LoadModel(model)
    local hash = joaat(model)
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        while not HasModelLoaded(hash) do Wait(10) end
    end
    return hash
end

local function ApplyVehicleUpgrades(veh)
    SetVehicleModKit(veh, 0)
    SetVehicleMod(veh, 11, 3, false)
    SetVehicleMod(veh, 12, 3, false)
    SetVehicleMod(veh, 13, 3, false)
    SetVehicleMod(veh, 15, 3, false)
    SetVehicleMod(veh, 16, 3, false)
    ToggleVehicleMod(veh, 18, true)
    SetVehicleTyresCanBurst(veh, false)
    SetVehicleWheelType(veh, 0)
    SetVehicleMod(veh, 23, 1, false)
    SetVehicleMod(veh, 24, 1, false)
    SetVehicleEngineHealth(veh, 1000.0)
    SetVehicleBodyHealth(veh, 1000.0)
    SetVehiclePetrolTankHealth(veh, 1000.0)
    SetVehicleOilLevel(veh, 100.0)
    SetVehicleFixed(veh)
    SetVehicleDeformationFixed(veh)
    SetVehicleUndriveable(veh, false)
    SetVehicleEngineOn(veh, true, true, true)
    SetVehicleFuelLevel(veh, Config.FuelAmount)
    Entity(veh).state.fuel = Config.FuelAmount
end

local function SpawnVehicle(model, jobName, spawnType, vehicleData)
    if isSpawning then return end
    isSpawning = true
    
    local jobConfig = Config.Jobs[jobName]
    if not jobConfig then isSpawning = false return end
    
    local spawnLoc = spawnType == 'heli' and jobConfig.heliSpawn or jobConfig.groundSpawn
    local hash = LoadModel(model)
    
    if currentVehicle and DoesEntityExist(currentVehicle) then
        DeleteEntity(currentVehicle)
        currentVehicle = nil
    end
    
    local veh = CreateVehicle(hash, spawnLoc.x, spawnLoc.y, spawnLoc.z, spawnLoc.w, true, false)
    local plate = jobConfig.platePrefix .. tostring(math.random(1000, 9999))
    
    SetVehicleNumberPlateText(veh, plate)
    SetVehicleDirtLevel(veh, 0.0)
    SetVehicleOnGroundProperly(veh)
    
    ApplyVehicleUpgrades(veh)
    
    -- Set livery dari vehicleData
    if vehicleData and vehicleData.livery then
        SetVehicleLivery(veh, vehicleData.livery)
    end
    
    -- Delay set livery biar pasti ke-apply
    SetTimeout(500, function()
        if DoesEntityExist(veh) and vehicleData and vehicleData.livery then
            SetVehicleLivery(veh, vehicleData.livery)
        end
    end)
    
    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
    
    TriggerEvent('vehiclekeys:client:SetOwner', plate)
    
    currentVehicle = veh
    local netId = NetworkGetNetworkIdFromEntity(veh)
    lib.callback.await('morph_jobgarage:server:registerVehicle', false, netId)
    
    SetModelAsNoLongerNeeded(hash)
    isSpawning = false
end

local function OpenGroundMenu(jobName)
    local playerInfo = GetPlayerInfo()
    if not playerInfo then return end
    
    local jobConfig = Config.Jobs[jobName]
    if not jobConfig then return end
    
    local playerGrade = playerInfo.grade
    local options = {}
    
    for _, category in ipairs(jobConfig.Categories) do
        if category.spawnType == 'ground' then
            local availableVehicles = {}
            for _, veh in ipairs(category.vehicles) do
                if not veh.grade or playerGrade >= veh.grade then
                    table.insert(availableVehicles, veh)
                end
            end
            
            if #availableVehicles > 0 then
                local subOptions = {}
                for _, veh in ipairs(availableVehicles) do
                    table.insert(subOptions, {
                        title = veh.label,
                        description = string.format('Model: %s | Grade: %d', veh.model, veh.grade or 0),
                        icon = category.icon,
                        onSelect = function()
                            local success, result = lib.callback.await('morph_jobgarage:server:spawnVehicle', false, veh.model, jobName, 'ground')
                            if success then
                                SpawnVehicle(veh.model, jobName, 'ground')
                            end
                        end
                    })
                end
                
                lib.registerContext({
                    id = 'vehicle_menu_' .. jobName .. '_' .. category.id,
                    title = category.label,
                    menu = 'jobgarage_main_' .. jobName,
                    options = subOptions
                })
                
                table.insert(options, {
                    title = category.label,
                    description = string.format('%d vehicles available', #availableVehicles),
                    icon = category.icon,
                    menu = 'vehicle_menu_' .. jobName .. '_' .. category.id,
                })
            end
        end
    end
    
    table.insert(options, {
        title = 'Return Vehicle',
        description = 'Delete your current vehicle',
        icon = 'fa-solid fa-trash',
        onSelect = function()
            if currentVehicle and DoesEntityExist(currentVehicle) then
                DeleteEntity(currentVehicle)
                currentVehicle = nil
                lib.callback.await('morph_jobgarage:server:deleteVehicle', false)
            end
        end
    })
    
    lib.registerContext({
        id = 'jobgarage_main_' .. jobName,
        title = jobConfig.label,
        options = options
    })
    
    lib.showContext('jobgarage_main_' .. jobName)
end

local function OpenHeliMenu(jobName)
    local playerInfo = GetPlayerInfo()
    if not playerInfo then return end
    
    local jobConfig = Config.Jobs[jobName]
    if not jobConfig then return end
    
    local playerGrade = playerInfo.grade
    local options = {}
    
    for _, category in ipairs(jobConfig.Categories) do
        if category.spawnType == 'heli' then
            local availableVehicles = {}
            for _, veh in ipairs(category.vehicles) do
                if not veh.grade or playerGrade >= veh.grade then
                    table.insert(availableVehicles, veh)
                end
            end
            
            if #availableVehicles > 0 then
                for _, veh in ipairs(availableVehicles) do
                    table.insert(options, {
                        title = veh.label,
                        description = string.format('Model: %s | Grade: %d', veh.model, veh.grade or 0),
                        icon = 'fa-solid fa-helicopter',
                        onSelect = function()
                            local success, result = lib.callback.await('morph_jobgarage:server:spawnVehicle', false, veh.model, jobName, 'heli')
                            if success then
                                SpawnVehicle(veh.model, jobName, 'heli')
                            end
                        end
                    })
                end
            end
        end
    end
    
    if #options == 0 then return end
    
    table.insert(options, {
        title = 'Return Helicopter',
        description = 'Delete your current helicopter',
        icon = 'fa-solid fa-trash',
        onSelect = function()
            if currentVehicle and DoesEntityExist(currentVehicle) then
                DeleteEntity(currentVehicle)
                currentVehicle = nil
                lib.callback.await('morph_jobgarage:server:deleteVehicle', false)
            end
        end
    })
    
    lib.registerContext({
        id = 'heli_menu_' .. jobName,
        title = jobConfig.label .. ' - Helicopters',
        options = options
    })
    
    lib.showContext('heli_menu_' .. jobName)
end

CreateThread(function()
    for jobName, jobConfig in pairs(Config.Jobs) do
        exports.morph_tget:addBoxZone({
            coords = jobConfig.groundTarget.coords,
            size = jobConfig.groundTarget.size,
            rotation = jobConfig.groundTarget.rotation,
            debug = false,
            options = {
                {
                    name = jobName .. '_ground_garage',
                    icon = 'fa-solid fa-car',
                    label = jobConfig.label,
                    distance = jobConfig.groundTarget.distance,
                    canInteract = function()
                        local access = lib.callback.await('morph_jobgarage:server:checkAccess', false)
                        return access and access.allowed and access.job == jobName or false
                    end,
                    onSelect = function()
                        OpenGroundMenu(jobName)
                    end
                }
            }
        })
        
        exports.morph_tget:addBoxZone({
            coords = jobConfig.heliTarget.coords,
            size = jobConfig.heliTarget.size,
            rotation = jobConfig.heliTarget.rotation,
            debug = false,
            options = {
                {
                    name = jobName .. '_heli_garage',
                    icon = 'fa-solid fa-helicopter',
                    label = jobConfig.label .. ' - Helicopters',
                    distance = jobConfig.heliTarget.distance,
                    canInteract = function()
                        local access = lib.callback.await('morph_jobgarage:server:checkAccess', false)
                        return access and access.allowed and access.job == jobName or false
                    end,
                    onSelect = function()
                        OpenHeliMenu(jobName)
                    end
                }
            }
        })
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if currentVehicle and DoesEntityExist(currentVehicle) then
            DeleteEntity(currentVehicle)
        end
    end
end)