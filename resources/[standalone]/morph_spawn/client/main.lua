local config = require 'config.client'
local spawns
local previewCam
local scaleform
local buttonsScaleform
local currentButtonId = 1
local previousButtonId = 1

local FLOAT_HEIGHT = 0.7
local FLOATING_ALPHA = 120

local function setupCamera()
    previewCam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', -24.77, -590.35, 90.8, -2.0, 0.0, 160.0, 45.0, false, 2)
    SetCamActive(previewCam, true)
    RenderScriptCams(true, false, 1, true, true)
end

local function stopCamera()
    SetCamActive(previewCam, false)
    DestroyCam(previewCam, true)
    RenderScriptCams(false, false, 1, true, true)

    BeginScaleformMovieMethod(scaleform, 'CLEANUP')
    EndScaleformMovieMethod()
end

local function managePlayer()
    SetEntityCoords(cache.ped, -21.58, -583.76, 86.31, false, false, false, false)
    FreezeEntityPosition(cache.ped, true)
    DisplayRadar(false)

    SetTimeout(500, function()
        DoScreenFadeIn(5000)
    end)
end

local function createSpawnArea()
    for i = 1, #spawns, 1 do
        local spawn = spawns[i]
        BeginScaleformMovieMethod(scaleform, 'ADD_AREA')
        ScaleformMovieMethodAddParamInt(i)
        ScaleformMovieMethodAddParamFloat(spawn.coords.x)
        ScaleformMovieMethodAddParamFloat(spawn.coords.y)
        ScaleformMovieMethodAddParamFloat(500.0)
        ScaleformMovieMethodAddParamInt(255)
        ScaleformMovieMethodAddParamInt(0)
        ScaleformMovieMethodAddParamInt(0)
        ScaleformMovieMethodAddParamInt(100)
        EndScaleformMovieMethod()
    end
end

local function setupInstructionalButton(index, control, text)
    BeginScaleformMovieMethod(buttonsScaleform, 'SET_DATA_SLOT')

    ScaleformMovieMethodAddParamInt(index)

    ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(2, control, true))

    BeginTextCommandScaleformString('STRING')
    AddTextComponentSubstringKeyboardDisplay(text)
    EndTextCommandScaleformString()

    EndScaleformMovieMethod()
end

local function setupInstructionalScaleform()
    DrawScaleformMovieFullscreen(buttonsScaleform, 255, 255, 255, 0, 0)

    BeginScaleformMovieMethod(buttonsScaleform, 'CLEAR_ALL')
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(buttonsScaleform, 'SET_CLEAR_SPACE')
    ScaleformMovieMethodAddParamInt(200)
    EndScaleformMovieMethod()

    setupInstructionalButton(0, 191, 'Submit')
    setupInstructionalButton(1, 187, 'Down')
    setupInstructionalButton(2, 188, 'Up')

    BeginScaleformMovieMethod(buttonsScaleform, 'DRAW_INSTRUCTIONAL_BUTTONS')
    EndScaleformMovieMethod()
end

local function setupMap()
    scaleform = lib.requestScaleformMovie('HEISTMAP_MP', 5000) or 0
    buttonsScaleform = lib.requestScaleformMovie('INSTRUCTIONAL_BUTTONS', 5000) or 0
    CreateThread(function()
        setupInstructionalScaleform()
        createSpawnArea()
        while DoesCamExist(previewCam) do
            DrawScaleformMovie_3d(scaleform, -24.86, -593.38, 91.8, -180.0, -180.0, -20.0, 0.0, 2.0, 0.0, 3.815, 2.27, 1.0, 2)

            HideHudComponentThisFrame(6)
            HideHudComponentThisFrame(7)
            HideHudComponentThisFrame(9)

            DrawScaleformMovieFullscreen(buttonsScaleform, 255, 255, 255, 255, 0)
            Wait(0)
        end

        SetScaleformMovieAsNoLongerNeeded(scaleform)
        SetScaleformMovieAsNoLongerNeeded(buttonsScaleform)
    end)
end

local function scaleformDetails(index)
    local spawn = spawns[index]
    local arrowStart = {
        vec2(-3150.25, -1427.83),
        vec2(4173.08, 1338.72),
        vec2(-2390.23, 6262.24)
    }

    BeginScaleformMovieMethod(scaleform, 'ADD_HIGHLIGHT')
    ScaleformMovieMethodAddParamInt(index)
    ScaleformMovieMethodAddParamFloat(spawn.coords.x)
    ScaleformMovieMethodAddParamFloat(spawn.coords.y)
    ScaleformMovieMethodAddParamFloat(500.0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(255)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(100)
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, 'COLOUR_AREA')
    ScaleformMovieMethodAddParamInt(index)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(255)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, 'ADD_TEXT')
    ScaleformMovieMethodAddParamInt(index)
    ScaleformMovieMethodAddParamTextureNameString(spawn.label)
    ScaleformMovieMethodAddParamFloat(spawn.coords.x)
    ScaleformMovieMethodAddParamFloat(spawn.coords.y - 500)
    ScaleformMovieMethodAddParamFloat(25 - math.random(0, 50))
    ScaleformMovieMethodAddParamInt(24)
    ScaleformMovieMethodAddParamInt(100)
    ScaleformMovieMethodAddParamInt(255)
    ScaleformMovieMethodAddParamBool(true)
    EndScaleformMovieMethod()

    local randomCoords = arrowStart[math.random(#arrowStart)]

    BeginScaleformMovieMethod(scaleform, 'ADD_ARROW')
    ScaleformMovieMethodAddParamInt(index)
    ScaleformMovieMethodAddParamFloat(randomCoords.x)
    ScaleformMovieMethodAddParamFloat(randomCoords.y)
    ScaleformMovieMethodAddParamFloat(spawn.coords.x)
    ScaleformMovieMethodAddParamFloat(spawn.coords.y)
    ScaleformMovieMethodAddParamFloat(math.random(30, 80))
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, 'COLOUR_ARROW')
    ScaleformMovieMethodAddParamInt(index)
    ScaleformMovieMethodAddParamInt(255)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(100)
    EndScaleformMovieMethod()
end

local function updateScaleform()
    if previousButtonId == currentButtonId then return end

    for i = 1, #spawns, 1 do
        BeginScaleformMovieMethod(scaleform, 'REMOVE_HIGHLIGHT')
        ScaleformMovieMethodAddParamInt(i)
        EndScaleformMovieMethod()

        BeginScaleformMovieMethod(scaleform, 'REMOVE_TEXT')
        ScaleformMovieMethodAddParamInt(i)
        EndScaleformMovieMethod()

        BeginScaleformMovieMethod(scaleform, 'REMOVE_ARROW')
        ScaleformMovieMethodAddParamInt(i)
        EndScaleformMovieMethod()

        BeginScaleformMovieMethod(scaleform, 'COLOUR_AREA')
        ScaleformMovieMethodAddParamInt(i)
        ScaleformMovieMethodAddParamInt(255)
        ScaleformMovieMethodAddParamInt(0)
        ScaleformMovieMethodAddParamInt(0)
        ScaleformMovieMethodAddParamInt(100)
        EndScaleformMovieMethod()
    end

    scaleformDetails(currentButtonId)
end

-- true if the [E] control was just pressed/released, whether or not another
-- resource has that control disabled this frame.
local function isEPressed()
    return IsControlJustReleased(0, 51)
        or IsDisabledControlJustReleased(0, 51)
        or IsControlJustPressed(0, 51)
        or IsDisabledControlJustPressed(0, 51)
end

-- Ped is already floating FLOAT_HEIGHT above coords, frozen and translucent
-- by this point (set in inputHandler). This handles the "press E to land"
-- prompt, then instantly drops the player straight to ground level.
local function descendToGround(coords)
    local ped = cache.ped

    local locationName = "Unknown Location"
    for _, spawn in ipairs(spawns) do
        if spawn.coords.x == coords.x and spawn.coords.y == coords.y and spawn.coords.z == coords.z then
            locationName = spawn.label or "Unknown Location"
            break
        end
    end

    -- Defensive: make sure nothing left NUI focus on, which would eat our
    -- keyboard input and make the wait loop below look "stuck".
    SetNuiFocus(false, false)

    lib.showTextUI(string.format('E - Spawn at %s', locationName), {
        position = 'left-center',
        icon = 'location-dot'
    })

    while true do
        EnableControlAction(0, 51, true)

        if isEPressed() then
            break
        end

        Wait(0)
    end

    lib.hideTextUI()

    -- instant drop straight to ground, no gradual interpolation
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)

    ResetEntityAlpha(ped)
    FreezeEntityPosition(ped, false)
    DisplayRadar(true)

    -- Only now do we consider the player "loaded" - after they've actually
    -- landed, so nothing can steal NUI focus out from under the E prompt.
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
end

local function inputHandler()
    local spawnData

    while DoesCamExist(previewCam) do
        if IsControlJustReleased(0, 188) then
            previousButtonId = currentButtonId
            currentButtonId -= 1

            if currentButtonId < 1 then
                currentButtonId = #spawns
            end

            updateScaleform()
        elseif IsControlJustReleased(0, 187) then
            previousButtonId = currentButtonId
            currentButtonId += 1

            if currentButtonId > #spawns then
                currentButtonId = 1
            end

            updateScaleform()
        elseif IsControlJustReleased(0, 191) then
            DoScreenFadeOut(1000)

            while not IsScreenFadedOut() do
                Wait(0)
            end

            spawnData = spawns[currentButtonId]

            if spawnData.propertyId then
                FreezeEntityPosition(cache.ped, false)
                DisplayRadar(true)
                TriggerServerEvent('morph_properties:server:enterProperty', { id = spawnData.propertyId, isSpawn = true })

                -- Properties handle their own placement, no floating/landing
                -- step, so it's safe to mark the player loaded right away.
                TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
                TriggerEvent('QBCore:Client:OnPlayerLoaded')
            else
                SetEntityCoords(cache.ped, spawnData.coords.x, spawnData.coords.y, spawnData.coords.z + FLOAT_HEIGHT, false, false, false, false)
                SetEntityHeading(cache.ped, spawnData.coords.w or 0.0)
                SetEntityAlpha(cache.ped, FLOATING_ALPHA, false)
                FreezeEntityPosition(cache.ped, true)
                -- OnPlayerLoaded is triggered later, inside descendToGround,
                -- once the player has actually landed.
            end

            DoScreenFadeIn(1000)

            break
        end

        Wait(0)
    end

    stopCamera()

    if spawnData and not spawnData.propertyId then
        descendToGround(spawnData.coords)
    end
end

RegisterNetEvent('qb-spawn:client:setupSpawns', function()
    spawns = {}

    local lastCoords, lastPropertyId = lib.callback.await('morph_spawn:server:getLastLocation')

    if lastCoords then
        spawns[#spawns + 1] = {
            label = locale('last_location'),
            coords = lastCoords,
            propertyId = lastPropertyId
        }
    else
        for i = 1, #config.spawns do
            spawns[#spawns + 1] = config.spawns[i]
        end

        local properties = lib.callback.await('morph_spawn:server:getProperties')
        for i = 1, #properties do
            spawns[#spawns + 1] = properties[i]
        end
    end

    Wait(400)

    managePlayer()
    setupCamera()
    setupMap()

    Wait(400)

    scaleformDetails(currentButtonId)
    inputHandler()
end)