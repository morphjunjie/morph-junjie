local cameraHandle = nil
local randomIndex = nil
local currentPedCoords = nil
local coordMode = nil

function SetCoords()
    if not Config.Coords.Random then
        currentPedCoords = Config.Coords.Single.pedCoords
        if Config.Coords.Single.camCoords then
            coordMode = "single"
        end
    else
        randomIndex = math.random(#Coords.List)
        while true do
            local entry = Coords.List[randomIndex]
            if not entry.scenario then
                if not entry.anim then
                    break
                end
            end
            randomIndex = math.random(#Coords.List)
            Debug("New index: " .. randomIndex, "warn")
        end
        currentPedCoords = Coords.List[randomIndex].pedCoords
        if Coords.List[randomIndex].camCoords then
            coordMode = "random"
        end
    end
    return currentPedCoords
end

function SetPlayerAndCamera()
    local ped = PlayerPedId()
    SetTimeMultiCharacter(true)
    local pos = SetCoords()
    SetEntityCoordsNoOffset(ped, pos.x, pos.y, pos.z, false, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityHeading(ped, pos.w)
    RequestCollisionAtCoord(pos.x, pos.y, pos.z)
    while true do
        if HasCollisionLoadedAroundEntity(ped) then
            break
        end
        RequestCollisionAtCoord(pos.x, pos.y, pos.z)
        Debug("Loading collision...")
        Wait(0)
    end
    SetEntityVisible(ped, false, false)
    Debug("Collision loaded")
    Debug("Player and camera positions set")
    CreateCamera(ped)
end

function CreateCamera(ped)
    local heading = GetEntityHeading(ped) + 180.0
    local camCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.0)
    if coordMode == "single" then
        camCoords = Config.Coords.Single.camCoords
    elseif coordMode == "random" then
        camCoords = Coords.List[randomIndex].camCoords
    end
    Wait(10)
    cameraHandle = CreateCamWithParams(
        "DEFAULT_SCRIPTED_CAMERA",
        camCoords.x,
        camCoords.y - 0.3,
        camCoords.z + 0.4,
        2.5,
        0.0,
        heading,
        30.0,
        false,
        0
    )
    ShakeCam(cameraHandle, "HAND_SHAKE", 0.2)
    Debug("Camera created")
    CameraDOF(cameraHandle)
end

function CameraDOF(cam)
    SetCamUseShallowDofMode(cam, true)
    SetCamNearDof(cam, 1.0)
    SetCamFarDof(cam, 20.0)
    SetCamDofStrength(cam, 10.0)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 1, true, true)
    Debug("DOF set")
    Wait(100)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    while true do
        if not GetIsLoadingScreenActive() then
            break
        end
        ShutdownLoadingScreen()
        ShutdownLoadingScreenNui()
        Wait(0)
    end
    Debug("Loading screen off")
    TriggerEvent("morph_mchar:client:GetCharacters")
    DoScreenFadeIn(500)
    while true do
        if IsScreenFadedIn() then
            break
        end
        Wait(0)
    end
    ClearPeds(true)
    HideRadar(true)
end

function SetUseHideDofLoop()
    if Config.PerformanceMode then
        return
    end
    if not cameraHandle then
        return
    end
    CreateThread(function()
        while true do
            if not DoesCamExist(cameraHandle) then
                break
            end
            SetUseHiDof()
            Wait(0)
        end
    end)
end

function ClearAndPlay()
    SendNUIMessage({ ui = false, bgMusic = Config.BackgroundMusic })
    SetNui(false)
    SetTimecycleModifier("default")
    SetCamActive(cameraHandle, false)
    DestroyCam(cameraHandle, true)
    RenderScriptCams(false, false, 1, true, true)
    ClearPeds(false)
    SetTimeMultiCharacter(false)
    FreezeEntityPosition(PlayerPedId(), false)
    HideRadar(false)
    Animation.Stop()
    cameraHandle = nil
    randomIndex = nil
    currentPedCoords = nil
    coordMode = nil
    Debug("Camera and player positions cleared")
    TriggerEvent("um-clearCacheSkin")
end

function CamShake()
    if cameraHandle then
        ShakeCam(cameraHandle, "DEATH_FAIL_IN_EFFECT_SHAKE", 0.5)
    end
end