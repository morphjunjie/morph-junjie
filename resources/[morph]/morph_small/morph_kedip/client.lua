local isRefreshing = false
local lastUsed = 0
local COOLDOWN = 10 -- Cooldown dalam detik

local function fixTextureLoss()
    local now = GetGameTimer()
    if isRefreshing then
        lib.notify({
            title = 'Fix Texture',
            description = 'Sedang memuat ulang tekstur, harap tunggu...',
            type = 'warning'
        })
        return
    end

    if (now - lastUsed) < (COOLDOWN * 1000) then
        local remaining = math.ceil(((COOLDOWN * 1000) - (now - lastUsed)) / 1000)
        lib.notify({
            title = 'Fix Texture',
            description = ('Tunggu %s detik lagi sebelum menggunakan /kedip kembali.'):format(remaining),
            type = 'error'
        })
        return
    end

    isRefreshing = true
    lastUsed = now

    lib.notify({
        title = 'Fix Texture',
        description = 'Memuat ulang dunia dan tekstur...',
        type = 'inform'
    })

    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(10)
    end

    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local targetEntity = (veh ~= 0 and veh) or ped
    local coords = GetEntityCoords(targetEntity)

    -- Freeze agar tidak jatuh ke void selama reload
    FreezeEntityPosition(targetEntity, true)

    -- Paksa reload scene, collision, dan streaming memory
    ClearFocus()
    SetFocusPosAndVel(coords.x, coords.y, coords.z, 0.0, 0.0, 0.0)
    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    NewLoadSceneStartSphere(coords.x, coords.y, coords.z, 150.0, 0)
    CascadeShadowsClearShadowSampleType()

    -- Tunggu reload engine
    Wait(1500)

    -- Tunggu sampai collision di sekitar ped benar-benar terload
    local timeout = GetGameTimer() + 4000
    while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < timeout do
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        Wait(100)
    end

    NewLoadSceneStop()
    ClearFocus()

    -- Unfreeze kembali
    FreezeEntityPosition(targetEntity, false)

    DoScreenFadeIn(800)

    lib.notify({
        title = 'Fix Texture',
        description = 'Tekstur dan dunia berhasil dimuat ulang!',
        type = 'success'
    })

    isRefreshing = false
end

RegisterNetEvent('morph_kedip:client:fixTexture', function()
    fixTextureLoss()
end)
