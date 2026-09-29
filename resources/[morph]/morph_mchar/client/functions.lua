local particleHandle = 0
local effectName = nil
local effectChild = nil
local timeLoop = false
local rainLevel = 0.0
local clearPedsLoop = false

function UMShutDownNui()
    DoScreenFadeOut(0)
    SetNui(false)
    while true do
        if IsScreenFadedOut() then
            break
        end
        Wait(0)
    end
    lib.callback.await("um-multi:bucket:setRandomBucket")
    SetPlayerAndCamera()
end

function SetNui(a)
    SetNuiFocus(a, a)
    Debug("NUI: " .. tostring(a))
end

function ModelJoat(a)
    if a == "mp_m_freemode_01" or a == "mp_f_freemode_01" then
        local h = joaat(a)
        return h or a
    else
        local n = tonumber(a)
        if n ~= nil then
            return tonumber(a)
        else
            local h = joaat(a)
            return h or a
        end
    end
end

function SetModel(a)
    a = ModelJoat(a)
    RequestModel(a)
    while true do
        if HasModelLoaded(a) then
            break
        end
        RequestModel(a)
        Wait(0)
    end
    SetPlayerModel(cache.playerId, a)
    SetModelAsNoLongerNeeded(a)
end

function SetTimeMultiCharacter(a)
    if not Config.TimeSettings.SyncStatus then
        if not Config.PerformanceMode then
            timeLoop = a
            if timeLoop then
                TriggerEvent("qb-weathersync:client:DisableSync")
            else
                TriggerEvent("qb-weathersync:client:EnableSync")
            end
            if Config.TimeSettings.Weather == "RAIN" then
                rainLevel = 0.3
            elseif Config.TimeSettings.Weather == "THUNDER" then
                rainLevel = 0.5
            end
            CreateThread(function()
                while true do
                    if not timeLoop then
                        break
                    end
                    SetRainLevel(rainLevel)
                    SetWeatherTypePersist(Config.TimeSettings.Weather)
                    SetWeatherTypeNow(Config.TimeSettings.Weather)
                    SetWeatherTypeNowPersist(Config.TimeSettings.Weather)
                    NetworkOverrideClockTime(Config.TimeSettings.Time, 0, 0)
                    Wait(0)
                end
            end)
        end
    end
end

function RandomParticleEffect()
    local i = math.random(1, #Effect.List)
    return Effect.List[i]
end

function RandomCheckEffect()
    if not Config.Effects.Random then
        effectName = Config.Effects.Single.pName
        effectChild = Config.Effects.Single.pNameChild
    else
        local e = RandomParticleEffect()
        effectName = e.pName
        effectChild = e.pNameChild
    end
    return effectName, effectChild
end

function Particle()
    if not Config.PerformanceMode then
        if Config.Effects.Status then
            local n, c = RandomCheckEffect()
            effectChild = c
            effectName = n
            if DoesParticleFxLoopedExist(particleHandle) then
                RemoveParticleFx(particleHandle, false)
            end
            RequestNamedPtfxAsset(effectName)
            while true do
                if HasNamedPtfxAssetLoaded(effectName) then
                    break
                end
                Wait(10)
            end
            UseParticleFxAssetNextCall(effectName)
            if not DoesParticleFxLoopedExist(particleHandle) then
                particleHandle = StartParticleFxLoopedOnEntity(
                    effectChild, cache.ped, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.1, false, false, false
                )
            end
        end
    end
end

function AnimationPlay()
    if not Config.Coords.Single.anim then
        if not Config.Coords.Single.scenario then
            goto default_flow
        end
        if Config.Coords.Random then
            goto default_flow
        end
    end
    if Config.Coords.Single.anim then
        Animation.Export(Config.Coords.Single.anim)
    else
        TaskStartScenarioInPlace(cache.ped, Config.Coords.Single.scenario, 0, true)
    end
    do return end
    ::default_flow::
    if not Config.Animation.Status then
        if not Config.Animation.Scenario.Status then
            return
        end
    end
    if Config.Animation.Status then
        if Config.Animation.Random then
            local i = math.random(1, #Animation.List)
            local a = Animation.List[i]
            Animation.Export(a)
        else
            Animation.Export(Config.Animation.Single)
        end
    else
        if Config.Animation.Scenario.Status then
            if Config.Animation.Scenario.Random then
                local i = math.random(1, #Animation.ScenarioList)
                local s = Animation.ScenarioList[i]
                TaskStartScenarioInPlace(cache.ped, s, 0, true)
            else
                TaskStartScenarioInPlace(cache.ped, Config.Animation.Scenario.Single, 0, true)
            end
        end
    end
end

function ClearPeds(a)
    if not Config.CleanZone then
        return
    end
    clearPedsLoop = a
    CreateThread(function()
        while true do
            if not clearPedsLoop then
                break
            end
            Wait(0)
            local p = PlayerPedId()
            local pos = GetEntityCoords(p)
            ClearAreaOfPeds(pos.x, pos.y, pos.z, 100.0, false)
        end
    end)
end

function HideRadar(a)
    Config.CustomHud(a)
    if not Config.HideRadar then
        return
    end
    if a then
        DisplayRadar(false)
    else
        DisplayRadar(true)
    end
end

function DefaultRandomCoords()
    local i = math.random(1, #DefaultSpawnCoords)
    return DefaultSpawnCoords[i]
end