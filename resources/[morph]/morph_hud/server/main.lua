local Core = exports.morph_junjie

local methBlock = {}

local resetStress = false

local function isMethBlockActive(src)
    return methBlock[src] and os.time() < methBlock[src]
end

local function removeMethBlock(src)
    methBlock[src] = nil
end

local function resetPlayerStress(src)
    local player = Core:GetPlayer(src)
    if not player then return end
    
    player.Functions.SetMetaData("stress", 0)
    TriggerClientEvent('hud:client:UpdateStress', src, 0)
    
    TriggerClientEvent('morph_ui:notify', src, {
        description = locale('Stress Reset Due to Death'),
        type        = 'info',
        duration    = 2500,
        icon        = 'brain',
        iconColor   = '#0F52BA'
    })
end

RegisterNetEvent('morph_consumables:client:OnPlayerDeath', function()
    local src = source
    if isMethBlockActive(src) then
        removeMethBlock(src)
        print(("Anti-stress dinonaktifkan untuk player %s karena mati"):format(src))
    end
    if resetStress then
        resetPlayerStress(src)
    end
end)

RegisterNetEvent('hud:server:GainStress', function(amount)
    if not Config.Stress.enabled then return end

    local src = source
    local player = Core:GetPlayer(src)
    if not player then return end
    if isMethBlockActive(src) then
        return
    end
    if Config.Stress.disableForLEO and player.PlayerData.job.type == 'leo' then
        return
    end

    local current   = player.PlayerData.metadata.stress or 0
    local newStress = current + amount

    if newStress < 0 then newStress = 0 end
    if newStress > 100 then newStress = 100 end

    player.Functions.SetMetaData("stress", newStress)
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    if newStress >= 50 and newStress < 100 then
        TriggerClientEvent('morph_ui:notify', src, {
            description = locale('Feeling More Stressed!'),
            type        = 'warning',
            duration    = 2500,
            icon        = 'brain',
            iconColor   = '#C53030'
        })
    end
end)

RegisterNetEvent('hud:server:RelieveStress', function(amount)
    if not Config.Stress.enabled then return end

    local src = source
    local player = Core:GetPlayer(src)
    if not player then return end

    local current   = player.PlayerData.metadata.stress or 0
    local newStress = resetStress and 0 or (current - amount)

    if newStress < 0 then newStress = 0 end
    if newStress > 100 then newStress = 100 end

    player.Functions.SetMetaData("stress", newStress)
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)

    TriggerClientEvent('morph_ui:notify', src, {
        description = locale('Feeling More Relaxed!'),
        type        = 'info',
        duration    = 2500,
        icon        = 'brain',
        iconColor   = '#0F52BA'
    })
end)

RegisterNetEvent("morph_consumables:ActivateMethBlock", function()
    local src = source
    methBlock[src] = os.time() + (15 * 60)
end)

AddEventHandler("playerDropped", function()
    removeMethBlock(source)
    print(("Data pemain %s dibersihkan"):format(source))
end)

lib.callback.register('hud:server:IsMethBlockActive', function(source)
    return isMethBlockActive(source)
end)

lib.callback.register('hud:server:GetMethBlockTimeLeft', function(source)
    if isMethBlockActive(source) then
        return methBlock[source] - os.time()
    end
    return 0
end)