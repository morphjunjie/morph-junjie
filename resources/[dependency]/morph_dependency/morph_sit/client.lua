-- ======================================================
-- MORPH SIT - CLIENT SCRIPT
-- ======================================================

local SitConfig = require 'morph_sit.config'

if type(SitConfig) ~= "table" then
    print(("^1ERROR: Failed to load SitConfig | Type: %s^7"):format(type(SitConfig)))
    return
end

local sitting = false
local localEntity = nil
local attachedEntity = nil

-- ======================================================
-- OX TARGET SETUP
-- ======================================================
if SitConfig.morph_tget then
    if not SitConfig.chairs or type(SitConfig.chairs) ~= "table" then
        print("^1ERROR: SitConfig.chairs invalid^7")
        return
    end
    
    if #SitConfig.chairs == 0 then
        print("^3WARNING: SitConfig.chairs is empty^7")
    end
    
    local options = {
        {
            label = SitConfig.targetName or "Sit",
            name = "nvsit",
            icon = SitConfig.targetIcon or "fas fa-chair",
            iconColor = "orange",
            distance = 1.5,
            canInteract = function() return not sitting end,
            onSelect = function(data) return sit(data.entity, data.coords) end
        },
        {
            label = SitConfig.targetNameStandUp or "Stand Up",
            name = "nvstandup",
            icon = SitConfig.targetIcon or "fas fa-chair",
            iconColor = "orange",
            distance = 1.5,
            canInteract = function() return sitting end,
            onSelect = function(data) ExecuteCommand('neveradev:sit:stand_up') end
        }
    }
    
    if exports.morph_tget then
        exports.morph_tget:addModel(SitConfig.chairs, options)
        print(("^2[Morph Sit] Added %d chair models^7"):format(#SitConfig.chairs))
    else
        print("^1ERROR: morph_tget export not found^7")
    end
end

print(("^2[Morph Sit] Client Ready | Models: %d^7"):format(#(SitConfig.chairs or {})))

-- ======================================================
-- SIT FUNCTION
-- ======================================================
function sit(entity, newCoords)
    if not entity then return end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local entityCoords = GetEntityCoords(entity)
    local name = GetEntityArchetypeName(entity)
    local heading = GetEntityHeading(entity) + 180.0
    
    if string.find(name, "bench") then
        entityCoords = newCoords
    end
    
    if name == "prop_table_01_chr_b" then
        heading = heading + 90
    end
    
    localEntity = entity
    FreezeEntityPosition(localEntity, true)
    
    local direction = vector3(playerCoords.x - entityCoords.x, playerCoords.y - entityCoords.y, 0.0)
    local distance = #(playerCoords - entityCoords)
    local moveCoords = entityCoords + (playerCoords - entityCoords) * (1.0 / distance)
    
    if GetEntityArchetypeName(entity) == "apa_mp_h_yacht_barstool_01" then
        playerCoords = vec3(playerCoords.x, playerCoords.y, playerCoords.z + 0.25)
        TaskStartScenarioAtPosition(playerPed, "PROP_HUMAN_SEAT_BENCH", entityCoords.x, entityCoords.y, playerCoords.z - 0.5, heading, 0, true, true)
    else
        TaskStartScenarioAtPosition(playerPed, "PROP_HUMAN_SEAT_BENCH", entityCoords.x, entityCoords.y, playerCoords.z - 0.5, heading, 0, true, true)
    end
    
    if SitConfig.firstPersonOnSit then
        Citizen.Wait(1000)
        SetFollowPedCamViewMode(4)
    end
    
    sitting = true
end

-- ======================================================
-- STAND UP COMMANDS
-- ======================================================
RegisterKeyMapping('neveradev:sit:stand_up_x', 'Sit - Stand Up (X)', 'keyboard', "X")
RegisterKeyMapping('neveradev:sit:stand_up_space', 'Sit - Stand Up (Space)', 'keyboard', "SPACE")

RegisterCommand('neveradev:sit:stand_up_x', function() ExecuteCommand('neveradev:sit:stand_up') end)
RegisterCommand('neveradev:sit:stand_up_space', function() ExecuteCommand('neveradev:sit:stand_up') end)

RegisterCommand('neveradev:sit:stand_up', function()
    if sitting then
        sitting = false
        local playerPed = PlayerPedId()
        ClearPedTasks(playerPed)
        TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_STAND_IDLE", 0, true)
        
        if localEntity then
            FreezeEntityPosition(localEntity, false)
            localEntity = nil
        end
        
        if attachedEntity ~= nil then
            DetachEntity(PlayerPedId(), true, false)
            attachedEntity = nil
        end
        
        Citizen.Wait(500)
        SetFollowPedCamViewMode(1)
    end
end)

-- ======================================================
-- RESOURCE HANDLERS
-- ======================================================
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() and sitting then
        ExecuteCommand('neveradev:sit:stand_up')
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        print("^2[Morph Sit] Started successfully^7")
    end
end)