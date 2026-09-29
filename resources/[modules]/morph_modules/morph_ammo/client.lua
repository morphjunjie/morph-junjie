local Config = require 'morph_ammo.config'
local isProcessing = false

local function StopAnimation()
    if not isProcessing then return end
    isProcessing = false
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    ClearPedSecondaryTask(ped)
end

local function PlayAnimation()
    if not Config.EnableAnimations then return end
    if isProcessing then return end

    isProcessing = true
    local ped = PlayerPedId()
    local animDict = Config.Animation.dict
    local animName = Config.Animation.anim
    local duration = Config.Animation.duration or 2500

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(10)
    end

    TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, duration, Config.Animation.flag or 16, 0, false, false, false)

    SetTimeout(duration, function()
        StopAnimation()
    end)
end

RegisterNetEvent('morph_modules:client:playAnimation', function()
    PlayAnimation()
end)

RegisterNetEvent('morph_modules:client:progressBar', function(itemName, metadata)
    if not Config.UseProgressBar then
        PlayAnimation()
        return
    end

    if lib then
        if lib.progressBar({
            duration = Config.Animation.duration,
            label = 'Opening ammo box...',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true,
            },
            anim = {
                dict = Config.Animation.dict,
                clip = Config.Animation.anim
            },
        }) then
            TriggerServerEvent('morph_modules:server:processBox', itemName, metadata)
        else
            StopAnimation()
            if Config.UseOxLib then
                lib.notify({
                    description = Config.Locale.cancelled,
                    type = 'error'
                })
            end
        end
    else
        PlayAnimation()
        SetTimeout(Config.Animation.duration, function()
            TriggerServerEvent('morph_modules:server:processBox', itemName, metadata)
        end)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    StopAnimation()
end)