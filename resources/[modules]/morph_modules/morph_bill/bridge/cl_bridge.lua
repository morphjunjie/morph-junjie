local Config = lib.require('morph_bill.shared.config')
local Framework = {}
Framework.Type = Config.Framework or 'qbx'

if Framework.Type == 'qbx' then
    Framework.PlayerData = function()
        return QBX.PlayerData
    end
    Framework.PlayerJob = function()
        return QBX.PlayerData.job
    end
elseif Framework.Type == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
    Framework.PlayerData = function()
        local Player = QBCore.Functions.GetPlayerData()
        return Player
    end
    Framework.PlayerJob = function()
        return QBCore.Functions.GetPlayerData().PlayerData.job
    end
elseif Framework.Type == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
    Framework.PlayerData = function()
        return ESX.GetPlayerData()
    end
    Framework.PlayerJob = function()
        return ESX.GetPlayerData().job.name
    end
end

return Framework