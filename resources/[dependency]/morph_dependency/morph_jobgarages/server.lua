-- server.lua
local Config = require 'morph_jobgarages.config'
local QBX = exports.morph_junjie

local cooldowns = {}
local spawnedVehicles = {}

local function IsAllowedJob(source)
    local player = QBX:GetPlayer(source)
    if not player then return false end
    
    local job = player.PlayerData.job
    if not job then return false end
    
    if not Config.AllowedJobs[job.name] then return false end
    if not job.onduty then return false end
    
    return true, job
end

local function GetPlayerGrade(source)
    local player = QBX:GetPlayer(source)
    if not player then return 0 end
    return player.PlayerData.job.grade.level or 0
end

lib.callback.register('morph_jobgarage:server:checkAccess', function(source)
    local allowed, job = IsAllowedJob(source)
    if not allowed then
        return { allowed = false, reason = 'Not authorized or not on duty' }
    end
    return { allowed = true, job = job.name, grade = job.grade.level }
end)

lib.callback.register('morph_jobgarage:server:spawnVehicle', function(source, model, jobName, spawnType)
    local src = source
    local allowed, job = IsAllowedJob(src)
    if not allowed then
        return false, 'Not authorized'
    end
    
    if job.name ~= jobName then
        return false, 'Wrong job'
    end
    
    if cooldowns[src] and GetGameTimer() < cooldowns[src] then
        local remaining = math.ceil((cooldowns[src] - GetGameTimer()) / 1000)
        return false, string.format('Wait %d seconds', remaining)
    end
    
    local jobConfig = Config.Jobs[jobName]
    if not jobConfig then return false, 'Invalid job' end
    
    local vehicleData = nil
    for _, category in ipairs(jobConfig.Categories) do
        if category.spawnType == spawnType then
            for _, veh in ipairs(category.vehicles) do
                if veh.model == model then
                    vehicleData = veh
                    break
                end
            end
        end
        if vehicleData then break end
    end
    
    if not vehicleData then
        return false, 'Invalid vehicle'
    end
    
    local playerGrade = GetPlayerGrade(src)
    if vehicleData.grade and playerGrade < vehicleData.grade then
        return false, string.format('Requires grade %d', vehicleData.grade)
    end
    
    if spawnedVehicles[src] then
        local oldNetId = spawnedVehicles[src].netId
        if oldNetId then
            local oldVeh = NetworkGetEntityFromNetworkId(oldNetId)
            if DoesEntityExist(oldVeh) then
                DeleteEntity(oldVeh)
            end
        end
        spawnedVehicles[src] = nil
    end
    
    cooldowns[src] = GetGameTimer() + Config.Cooldown
    
    return true, {
        model = model,
        spawnType = spawnType,
        platePrefix = jobConfig.platePrefix,
    }
end)

lib.callback.register('morph_jobgarage:server:registerVehicle', function(source, netId)
    spawnedVehicles[source] = { netId = netId }
    return true
end)

lib.callback.register('morph_jobgarage:server:deleteVehicle', function(source)
    if spawnedVehicles[source] then
        local netId = spawnedVehicles[source].netId
        if netId then
            local veh = NetworkGetEntityFromNetworkId(netId)
            if DoesEntityExist(veh) then
                DeleteEntity(veh)
            end
        end
        spawnedVehicles[source] = nil
    end
    return true
end)

AddEventHandler('playerDropped', function()
    local src = source
    if spawnedVehicles[src] then
        local netId = spawnedVehicles[src].netId
        if netId then
            local veh = NetworkGetEntityFromNetworkId(netId)
            if DoesEntityExist(veh) then
                DeleteEntity(veh)
            end
        end
        spawnedVehicles[src] = nil
    end
    cooldowns[src] = nil
end)