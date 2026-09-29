local Config = require 'morph_ammo.config'
local Framework = nil
local FrameworkName = nil

local function DetectFramework()
    if Config.Framework ~= 'auto' then
        FrameworkName = Config.Framework
        if FrameworkName == 'qbox' or FrameworkName == 'qbcore' then
            local success, result = pcall(function() return exports['morph_junjie']:GetCoreObject() end)
            if success and result then Framework = result else
                success, result = pcall(function() return exports['qb-core']:GetCoreObject() end)
                if success and result then Framework = result end
            end
        elseif FrameworkName == 'esx' then
            local success, result = pcall(function() return exports['es_extended']:getSharedObject() end)
            if success and result then Framework = result end
        end
    else
        if GetResourceState('morph_junjie') == 'started' then
            FrameworkName = 'qbox'
            local success, result = pcall(function() return exports['morph_junjie']:GetCoreObject() end)
            if success and result then Framework = result end
        elseif GetResourceState('qb-core') == 'started' or GetResourceState('qb_core') == 'started' then
            FrameworkName = 'qbcore'
            local success, result = pcall(function() return exports['qb-core']:GetCoreObject() end)
            if success and result then Framework = result else
                success, result = pcall(function() return exports['qb_core']:GetCoreObject() end)
                if success and result then Framework = result end
            end
        elseif GetResourceState('es_extended') == 'started' then
            FrameworkName = 'esx'
            local success, result = pcall(function() return exports['es_extended']:getSharedObject() end)
            if success and result then Framework = result end
        end
    end
end

local function GetOutputAmmo(boxName) return boxName:gsub(Config.BoxSuffix .. '$', '') end

local function GetAmmoAmount(metadata) return metadata and metadata.ammo_count or Config.DefaultAmount end

local function SendNotification(source, message, type)
    if Config.UseOxLib and GetResourceState('morph_ui') == 'started' then
        TriggerClientEvent('morph_ui:notify', source, { description = message, type = type or 'info' })
    elseif Framework then
        if FrameworkName == 'qbox' or FrameworkName == 'qbcore' then
            TriggerClientEvent('QBCore:Notify', source, message, type or 'primary')
        elseif FrameworkName == 'esx' then
            TriggerClientEvent('esx:showNotification', source, message)
        end
    else
        if GetResourceState('morph_ui') == 'started' then
            TriggerClientEvent('morph_ui:notify', source, { description = message, type = type or 'info' })
        else
            TriggerClientEvent('chat:addMessage', source, { color = {255, 255, 255}, multiline = true, args = {"AmmoBox", message} })
        end
    end
end

local function ProcessAmmoBox(source, itemName, metadata)
    local outputAmmo = GetOutputAmmo(itemName)
    local amount = GetAmmoAmount(metadata)
    local outputItem = exports.morph_inv:Items(outputAmmo)
    if not outputItem then SendNotification(source, Config.Locale.error_no_output, 'error') return false end
    if not exports.morph_inv:CanCarryItem(source, outputAmmo, amount) then SendNotification(source, Config.Locale.error_no_space, 'error') return false end
    if exports.morph_inv:RemoveItem(source, itemName, 1) then
        if exports.morph_inv:AddItem(source, outputAmmo, amount) then
            SendNotification(source, string.format(Config.Locale.success, amount), 'success')
            return true
        else
            exports.morph_inv:AddItem(source, itemName, 1)
            SendNotification(source, Config.Locale.error_generic, 'error')
            return false
        end
    else
        SendNotification(source, Config.Locale.error_generic, 'error')
        return false
    end
end

exports('ammobox', function(event, item, inventory, slot, data)
    if event ~= 'usingItem' then return end
    local source = inventory.id
    if Config.EnableAnimations then TriggerClientEvent('morph_modules:client:playAnimation', source) end
    if Config.UseProgressBar and GetResourceState('morph_ui') == 'started' then
        TriggerClientEvent('morph_modules:client:progressBar', source, item.name, item.metadata)
    else
        SetTimeout(Config.Animation.duration or 2500, function() ProcessAmmoBox(source, item.name, item.metadata) end)
    end
end)

RegisterServerEvent('morph_modules:server:processBox', function(itemName, metadata) ProcessAmmoBox(source, itemName, metadata) end)

CreateThread(function()
    DetectFramework()
    if GetResourceState('morph_inv') ~= 'started' then return end
end)