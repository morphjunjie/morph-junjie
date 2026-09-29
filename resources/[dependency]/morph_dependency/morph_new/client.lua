local Helper = {
    notify = function(desc, type) lib.notify({ title = 'Starter Pack', description = desc, type = type or 'info', duration = 3000 }) end,
    alert = function(header, content, confirmLabel, cancelLabel) return lib.alertDialog({ header = header, content = content, centered = true, cancel = cancelLabel ~= nil, labels = { confirm = confirmLabel or 'OK', cancel = cancelLabel } }) end,
    fade = {
        out = function(d) DoScreenFadeOut(d or 800); while not IsScreenFadedOut() do Wait(10) end end,
        enter = function(d) DoScreenFadeIn(d or 800); Wait(1000) end
    }
}

-- Builds the menu options from NewConfig.StarterVehicles so adding a new vehicle only needs a config edit
local function buildStarterOptions()
    local options = {}
    for _, vehicle in ipairs(NewConfig.StarterVehicles) do
        options[#options + 1] = {
            title = vehicle.recommended and (vehicle.label .. ' ⭐ Recommended') or vehicle.label,
            description = vehicle.description,
            image = vehicle.image,
            metadata = {
                { label = 'Type', value = vehicle.type },
                { label = 'Seats', value = vehicle.seats },
                { label = 'Top Speed', value = vehicle.speed }
            },
            onSelect = function()
                local confirmed = Helper.alert(
                    'Confirm Your Choice',
                    string.format('You are about to claim the %s as your starter vehicle. This choice cannot be changed later.', vehicle.label),
                    'Claim Vehicle', 'Cancel'
                )
                if confirmed == 'confirm' then
                    TriggerServerEvent('morph_new:server:claimStarter', vehicle.model)
                end
            end
        }
    end
    return options
end

local function openStarterMenu()
    local playerData = QBX.PlayerData or exports.morph_junjie:GetPlayerData()
    if playerData and playerData.metadata and playerData.metadata.starterpack then
        Helper.notify('You have already claimed your starter pack!', 'error')
        return
    end

    lib.registerContext({
        id = 'starterpack_menu',
        title = 'Choose Your Starter Vehicle',
        options = buildStarterOptions()
    })
    lib.showContext('starterpack_menu')
end

CreateThread(function()
    for _, cfg in ipairs(NewConfig.Zones) do
        exports.morph_tget:addBoxZone({
            coords = cfg.coords.xyz,
            size = vec3(1.5, 1.5, 2),
            rotation = cfg.coords.w,
            debug = false,
            options = { {
                label = 'Claim Starter Pack',
                icon = 'fa-solid fa-gift',
                onSelect = openStarterMenu
            } }
        })
    end
end)

RegisterNetEvent('morph_new:client:teleportGarage', function(garage, vehicleLabel, plate)
    if NewConfig.EnableTeleport then
        local tp = NewConfig.GarageTeleport[garage]
        if tp then
            Helper.fade.out(800)
            local ped = PlayerPedId()
            SetEntityCoords(ped, tp.x, tp.y, tp.z)
            SetEntityHeading(ped, tp.w)
            Helper.fade.enter(800)
        end
    end

    Helper.alert(
        'Welcome to M.A.D. District',
        string.format(
            'Your journey starts now. Your starter vehicle (%s) has been delivered to your garage.\n\nPlate Number: %s\n\nEnjoy exploring!',
            vehicleLabel or 'vehicle',
            plate or 'N/A'
        ),
        'Let\'s Go!'
    )
end)