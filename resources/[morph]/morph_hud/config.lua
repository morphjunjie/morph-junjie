Config = {}

Config.DefaultHudSettings = {
    bar_style            = 'hexagon-w',
    is_res_style_active  = true,
    vehicle_hud_style   = 3,

    mini_map = {
        onlyInVehicle      = true,
        style              = 'rectangle',
        editableByPlayers  = true
    },

    compass = {
        active             = true,
        onlyInVehicle      = true,
        editableByPlayers  = true
    },

    cinematic = { active = true },

    vehicle_info = { kmH = true },

    client_info = {
        active = true,

        server_info = {
            active              = true,
            name                = 'ㅤ',
            image               = 'Morph_empire.png',
            showOnlinePlayers   = true,
        },

        bank            = { active = true },
        cash            = { active = true },
        job             = { active = true },
        gang            = { active = true },
        player_source   = { active = true },
        radio           = { active = true },
        time            = { active = true },
        weapon          = { active = true },
        real_time       = { active = false },
        extra_currency  = { active = false },
    },

    music_info         = { active = true },
    navigation_widget  = { active = true },

    bar_colors = {
        armor           = '#1D4ED8',
        health          = '#CF4E5B',
        hunger          = '#FFC400',
        oxygen          = '#00FFA3',
        stamina         = '#C4FF48',
        stress          = '#6b21a8',
        thirst          = '#00c2ff',
        vehicle_engine  = '#C4FF48',
        voice           = '#FFFFFF',
        vehicle_nitro   = '#cf654e',
    },
}

Config.MoneySettings = {
    isMoneyItem = true,
    itemName    = 'money',

    extra_currency = {
        type = 'item',
        name = 'markedbills',
    }
}

Config.ToggleSettingsMenu = {
    active  = true,
    key     = 'I',
    command = 'hudsettings',
}

Config.ToggleSeatBelt = {
    active      = true,
    key         = 'B',
    ejectSpeed  = 100,
    warning     = false,
}

Config.ToggleVehicleEngine = {
    active = false,
    key    = 'G',
}

Config.ToggleCinematicMode = {
    active  = true,
    key     = nil,
    command = 'cinematic',
}

Config.ResetHudPositions = {
    active  = true,
    command = 'resethudpos',
}

Config.HideGTAHudComponents = false
Config.HavePostalMap       = true

Config.RefreshTimes = {
    hud                = 200,
    vehicle            = 100,
    requestPlayerCount = 30000,
}

Config.BarColors = {
    '#CF4E5B', '#CF4E75', '#CF4EAB', '#A888DE', '#6b21a8',
    '#7FCF4E', '#C4FF48', '#FFC400', '#FF9900', '#CF654E',
    '#1d4ed8', '#00C2FF', '#4EB0CF', '#4ECFA1', '#00FFA3',
    '#A68A7B', '#FFFFFF', '#7A7A7A', '#4B4B4B', '#00000057'
}

Config.ElectricVehicles = {
    'Imorgon', 'Neon', 'Raiden', 'Cyclone', 'Voltic', 'Voltic2',
    'Tezeract', 'Dilettante', 'Dilettante2', 'Airtug', 'Caddy',
    'Caddy2', 'Caddy3', 'Surge', 'Khamelion', 'RCBandito'
}

Config.Stress = {
    enabled        = true,
    minForShaking = 50,
    disableForLEO = true,

    add = {
        shooting = 8.8,
        damaged  = 0.5,

        drivingFast = {
            active = true,
            amount = 0.18,
        },

        minForSpeeding            = 80,
        minForSpeedingUnbuckled   = 100,

        whitelistedWeapons = {
            "weapon_petrolcan",
            "weapon_hazardcan",
            "weapon_fireextinguisher",
        },
    },

    blurIntensity = {
        { min = 50, max = 60,  intensity = 1500 },
        { min = 60, max = 70,  intensity = 2000 },
        { min = 70, max = 80,  intensity = 2500 },
        { min = 80, max = 90,  intensity = 2700 },
        { min = 90, max = 100, intensity = 3000 },
    },

    effectInterval = {
        { min = 50, max = 60,  timeout = math.random(50000, 60000) },
        { min = 60, max = 70,  timeout = math.random(40000, 50000) },
        { min = 70, max = 80,  timeout = math.random(30000, 40000) },
        { min = 80, max = 90,  timeout = math.random(20000, 30000) },
        { min = 90, max = 100, timeout = math.random(15000, 20000) },
    },
}

Config.RelaxZones = {
    {
        name = "relax_area_1",
        points = {
            vector2(-1796.07, -1235.09),
            vector2(-1856.37, -1184.90),
            vector2(-1886.59, -1221.21),
            vector2(-1826.26, -1271.31),
        },
        minZ         = 1.0,
        maxZ         = 50.0,
        stressRemove = 2.5,
        interval     = 25000
    }
}