local stress, hasWeapon, inRelaxZone, w, relaxZoneData, relaxTextShown = 0, false, false, 0, nil, false
local stressCfg = Config.Stress or {}
local speedMultiplier = 3.6
PlayerData = PlayerData or {}

RegisterNetEvent('hud:client:UpdateStress', function(newStress) stress = newStress end)
AddStateBagChangeHandler('stress', ('player:%s'):format(cache.serverId), function(_, _, value) stress = value end)

local function getBlurIntensity(level)
    for _, v in pairs(Config.Stress.blurIntensity) do
        if level >= v.min and level <= v.max then return v.intensity end
    end
    return 1500
end

local function getEffectInterval(level)
    for _, v in pairs(Config.Stress.effectInterval) do
        if level >= v.min and level <= v.max then return v.timeout end
    end
    return 60000
end

CreateThread(function()
    while true do
        local interval = getEffectInterval(stress)
        if stress >= 100 then
            local blur = getBlurIntensity(stress)
            local repeatFall = math.random(2,4)
            local ragdollTime = repeatFall * 1750
            
            TriggerScreenblurFadeIn(1000.0)
            Wait(blur)
            TriggerScreenblurFadeOut(1000.0)
            
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.8)
            Wait(3000)
            StopGameplayCamShaking(false)
            
            if not IsPedRagdoll(cache.ped) and IsPedOnFoot(cache.ped) and not IsPedSwimming(cache.ped) then
                local forward = GetEntityForwardVector(cache.ped)
                SetPedToRagdollWithFall(cache.ped, ragdollTime, ragdollTime, 1, forward.x, forward.y, forward.z, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            end
            Wait(1000)
            
            for _ = 1, repeatFall do
                Wait(750)
                TriggerScreenblurFadeIn(1000.0)
                Wait(blur)
                TriggerScreenblurFadeOut(1000.0)
                
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.8)
                Wait(3000)
                StopGameplayCamShaking(false)
            end
        elseif stress >= Config.Stress.minForShaking then
            local blur = getBlurIntensity(stress)
            TriggerScreenblurFadeIn(1000.0)
            Wait(blur)
            TriggerScreenblurFadeOut(1000.0)
        end
        Wait(interval)
    end
end)

local function blackBars()
    DrawRect(0.0,0.0,2.0,w,0,0,0,255)
    DrawRect(0.0,1.0,2.0,w,0,0,0,255)
end

CreateThread(function()
    while true do
        if w > 0 then
            blackBars()
            DisplayRadar(false)
            SendNUIMessage({ action = 'hudtick', show = false })
            SendNUIMessage({ action = 'car', show = false })
        end
        Wait(0)
    end
end)

local function isWhitelistedWeaponStress(weapon)
    if not weapon then return false end
    local whitelist = Config.Stress.add.whitelistedWeapons
    if not whitelist then return false end
    for _, v in ipairs(whitelist) do
        if weapon == GetHashKey(v) or weapon == v then return true end
    end
    return false
end

local function startWeaponStressThread(weapon)
    if isWhitelistedWeaponStress(weapon) then return end
    hasWeapon = true
    CreateThread(function()
        while hasWeapon do
            if IsPedShooting(cache.ped) and math.random() <= (Config.Stress.add.shooting / 100) then
                TriggerServerEvent('hud:server:GainStress', math.random(5,8))
            end
            Wait(0)
        end
    end)
end

AddEventHandler('morph_inv:currentWeapon', function(weapon)
    hasWeapon = false
    Wait(0)
    if weapon then startWeaponStressThread(weapon.hash) end
end)

AddEventHandler('gameEventTriggered', function(event, data)
    if stressCfg.enabled and stressCfg.add and event == "CEventNetworkEntityDamage" and data[1] == PlayerPedId() then
        TriggerServerEvent("morph_hud:addStress", stressCfg.add.damaged or 1)
    end
end)

if Config.Stress.enabled then
    CreateThread(function()
        while true do
            if LocalPlayer.state.isLoggedIn and cache.vehicle then
                local vehClass = GetVehicleClass(cache.vehicle)
                local speed = GetEntitySpeed(cache.vehicle) * speedMultiplier
                local seatbelt = LocalPlayer.state.seatbelt or false

                if vehClass ~= 13 and vehClass ~= 14 and vehClass ~= 15 and vehClass ~= 16 and vehClass ~= 21 then
                    local minSpeed = 130
                    
                    if speed >= minSpeed then
                        TriggerServerEvent('hud:server:GainStress', math.random(1, 2))
                    end
                end
            end
            Wait(25000)
        end
    end)
end

CreateThread(function()
    for _, zone in ipairs(Config.RelaxZones) do
        morph_zone:Create(zone.points, { name = zone.name, minZ = zone.minZ, maxZ = zone.maxZ, debugPoly = Config.Debug or false }):onPlayerInOut(function(isInside)
            inRelaxZone, relaxZoneData = isInside, isInside and zone or nil
            if isInside and not relaxTextShown then
                lib.showTextUI('Area Relax', { position = "left-center", icon = "brain" })
                relaxTextShown = true
            elseif not isInside and relaxTextShown then
                lib.hideTextUI(); relaxTextShown = false
            end
        end)
    end
end)

CreateThread(function()
    while true do
        if inRelaxZone and relaxZoneData and PlayerData and PlayerData.stress > 0 then
            TriggerServerEvent("hud:server:RelieveStress", relaxZoneData.stressRemove or 2.5)
            StartScreenEffect("SwitchShortNeutralIn", 3000, false)
            Wait(relaxZoneData.interval or 5000)
        else Wait(1000) end
    end
end)

CreateThread(function() while true do if not inRelaxZone then StopScreenEffect("SwitchShortNeutralIn") end; Wait(5000) end end)

local busyCategories, categoryIndexes = {}, {}
local function getNextCategoryId() for i = 50, 51 do if not categoryIndexes[i] then categoryIndexes[i] = true; return i end end end
local function setBlipCategory(blip, name)
    local id = busyCategories[name]
    if not id then 
        id = getNextCategoryId()
        if not id then 
            print("No category IDs left")
            return 
        end
        busyCategories[name] = id
        AddTextEntry("BLIP_CAT_" .. id, name)
        SetBlipCategory(blip, id)
    end
end
exports('setBlipCategory', setBlipCategory); Blip = {}; Blip.setBlipCategory = setBlipCategory

CreateThread(function()
    for _, zone in ipairs(Config.RelaxZones) do
        local x, y = 0, 0
        for _, p in ipairs(zone.points) do x = x + p.x; y = y + p.y end
        x, y = x / #zone.points, y / #zone.points
        local blip = AddBlipForCoord(x, y, zone.minZ or 30.0)
        SetBlipSprite(blip, 197); SetBlipDisplay(blip, 4); SetBlipScale(blip, 0.6); SetBlipColour(blip, 9); SetBlipAsShortRange(blip, true)
        setBlipCategory(blip, "Morph Property")
        BeginTextCommandSetBlipName("STRING"); AddTextComponentString("Area Relax"); EndTextCommandSetBlipName(blip)
    end
end)

CreateThread(function()
    while true do
        Wait(500)
        if IsEntityDead(PlayerPedId()) then
            TriggerServerEvent('morph_consumables:client:OnPlayerDeath')
            while IsEntityDead(PlayerPedId()) do Wait(1000) end
        end
    end
end)