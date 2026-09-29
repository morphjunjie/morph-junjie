DamageConfig = {}

DamageConfig.Weapons = {

    -- Unarmed
    { weapon_name = 'weapon_unarmed', damage_multiplier = 0.41 },

    -- Melee
    { weapon_name = 'weapon_flashlight', damage_multiplier = 0.25 },
    { weapon_name = 'weapon_wrench', damage_multiplier = 0.26 },
    { weapon_name = 'weapon_knuckle', damage_multiplier = 0.27 },
    { weapon_name = 'weapon_nightstick', damage_multiplier = 0.02 },
    { weapon_name = 'weapon_bottle', damage_multiplier = 0.28 },
    { weapon_name = 'weapon_bat', damage_multiplier = 0.30 },
    { weapon_name = 'weapon_crowbar', damage_multiplier = 0.30 },
    { weapon_name = 'weapon_golfclub', damage_multiplier = 0.30 },
    { weapon_name = 'weapon_poolcue', damage_multiplier = 0.30 },
    { weapon_name = 'weapon_hammer', damage_multiplier = 0.31 },
    { weapon_name = 'weapon_knife', damage_multiplier = 0.34 },
    { weapon_name = 'weapon_dagger', damage_multiplier = 0.35 },
    { weapon_name = 'weapon_switchblade', damage_multiplier = 0.35 },
    { weapon_name = 'weapon_hatchet', damage_multiplier = 0.37 },
    { weapon_name = 'weapon_machete', damage_multiplier = 0.38 },
    { weapon_name = 'weapon_battleaxe', damage_multiplier = 0.39 },
    { weapon_name = 'weapon_stone_hatchet', damage_multiplier = 0.40 },

    -- Handguns
    { weapon_name = 'weapon_snspistol', damage_multiplier = 0.37 },
    { weapon_name = 'weapon_snspistol_mk2', damage_multiplier = 0.43 },
    { weapon_name = 'weapon_ceramicpistol', damage_multiplier = 0.44 },
    { weapon_name = 'weapon_vintagepistol', damage_multiplier = 0.58 },
    { weapon_name = 'weapon_pistol', damage_multiplier = 0.43 },
    { weapon_name = 'weapon_pistolxm3', damage_multiplier = 0.43 },
    { weapon_name = 'weapon_combatpistol', damage_multiplier = 0.40 },
    { weapon_name = 'weapon_heavypistol', damage_multiplier = 0.59 },
    { weapon_name = 'weapon_appistol', damage_multiplier = 0.31 },
    { weapon_name = 'weapon_pistol50', damage_multiplier = 0.37 },
    { weapon_name = 'weapon_marksmanpistol', damage_multiplier = 0.48 },
    { weapon_name = 'weapon_pistol_mk2', damage_multiplier = 0.49 },
    { weapon_name = 'weapon_revolver', damage_multiplier = 0.16 },
    { weapon_name = 'weapon_revolver_mk2', damage_multiplier = 0.19 },
    { weapon_name = 'weapon_navyrevolver', damage_multiplier = 0.27 },
    { weapon_name = 'weapon_doubleaction', damage_multiplier = 0.33 },
    { weapon_name = 'weapon_stungun', damage_multiplier = 0.00 },

    -- SMG
    { weapon_name = 'weapon_minismg', damage_multiplier = 0.59 },
    { weapon_name = 'weapon_machinepistol', damage_multiplier = 0.71 },
    { weapon_name = 'weapon_microsmg', damage_multiplier = 0.67 },
    { weapon_name = 'weapon_smg', damage_multiplier = 0.85 },
    { weapon_name = 'weapon_smg_mk2', damage_multiplier = 0.72 },
    { weapon_name = 'weapon_tecpistol', damage_multiplier = 0.69 },
    { weapon_name = 'weapon_assaultsmg', damage_multiplier = 0.53 },
    { weapon_name = 'weapon_combatpdw', damage_multiplier = 0.25 },

    -- Rifles
    { weapon_name = 'weapon_advancedrifle', damage_multiplier = 0.55 },
    { weapon_name = 'weapon_carbinerifle', damage_multiplier = 0.56 },
    { weapon_name = 'weapon_carbinerifle_mk2', damage_multiplier = 0.57 },
    { weapon_name = 'weapon_assaultrifle', damage_multiplier = 0.58 },
    { weapon_name = 'weapon_assaultrifle_mk2', damage_multiplier = 0.59 },
    { weapon_name = 'weapon_specialcarbine', damage_multiplier = 0.59 },
    { weapon_name = 'weapon_specialcarbine_mk2', damage_multiplier = 0.60 },
    { weapon_name = 'weapon_bullpuprifle', damage_multiplier = 0.57 },
    { weapon_name = 'weapon_bullpuprifle_mk2', damage_multiplier = 0.58 },
    { weapon_name = 'weapon_militaryrifle', damage_multiplier = 0.61 },
    { weapon_name = 'weapon_heavyrifle', damage_multiplier = 0.23 },
    { weapon_name = 'weapon_tacticalrifle', damage_multiplier = 0.61 },
    { weapon_name = 'weapon_servicecarbine', damage_multiplier = 0.60 },

    -- Shotguns
    { weapon_name = 'weapon_sawnoffshotgun', damage_multiplier = 0.31 },
    { weapon_name = 'weapon_pumpshotgun', damage_multiplier = 0.64 },
    { weapon_name = 'weapon_pumpshotgun_mk2', damage_multiplier = 0.23 },
    { weapon_name = 'weapon_bullpupshotgun', damage_multiplier = 0.70 },
    { weapon_name = 'weapon_assaultshotgun', damage_multiplier = 0.66 },
    { weapon_name = 'weapon_heavyshotgun', damage_multiplier = 0.68 },
    { weapon_name = 'weapon_dbshotgun', damage_multiplier = 0.70 },
    { weapon_name = 'weapon_autoshotgun', damage_multiplier = 0.67 },
    { weapon_name = 'weapon_combatshotgun', damage_multiplier = 0.69 },
    { weapon_name = 'weapon_musket', damage_multiplier = 0.70 },

    -- Machine Guns
    { weapon_name = 'weapon_mg', damage_multiplier = 0.62 },
    { weapon_name = 'weapon_gusenberg', damage_multiplier = 0.60 },
    { weapon_name = 'weapon_combatmg', damage_multiplier = 0.65 },
    { weapon_name = 'weapon_combatmg_mk2', damage_multiplier = 0.68 },

    -- Snipers
    { weapon_name = 'weapon_marksmanrifle', damage_multiplier = 0.70 },
    { weapon_name = 'weapon_marksmanrifle_mk2', damage_multiplier = 0.72 },
    { weapon_name = 'weapon_sniperrifle', damage_multiplier = 0.75 },
    { weapon_name = 'weapon_precisionrifle', damage_multiplier = 0.77 },
    { weapon_name = 'weapon_heavysniper', damage_multiplier = 0.79 },
    { weapon_name = 'weapon_heavysniper_mk2', damage_multiplier = 0.80 },

    -- Heavy Weapons
    { weapon_name = 'weapon_grenadelauncher', damage_multiplier = 0.75 },
    { weapon_name = 'weapon_rpg', damage_multiplier = 0.80 },
    { weapon_name = 'weapon_minigun', damage_multiplier = 0.70 },
    { weapon_name = 'weapon_railgun', damage_multiplier = 0.80 },
    { weapon_name = 'weapon_hominglauncher', damage_multiplier = 0.78 },
    { weapon_name = 'weapon_firework', damage_multiplier = 0.30 },
    { weapon_name = 'weapon_emplauncher', damage_multiplier = 0.00 },

    -- Throwables
    { weapon_name = 'weapon_grenade', damage_multiplier = 0.75 },
    { weapon_name = 'weapon_stickybomb', damage_multiplier = 0.78 },
    { weapon_name = 'weapon_proxmine', damage_multiplier = 0.77 },
    { weapon_name = 'weapon_pipebomb', damage_multiplier = 0.75 },
    { weapon_name = 'weapon_molotov', damage_multiplier = 0.55 },
    { weapon_name = 'weapon_flare', damage_multiplier = 0.20 },
    { weapon_name = 'weapon_smokegrenade', damage_multiplier = 0.00 },
    { weapon_name = 'weapon_snowball', damage_multiplier = 0.00 },

    -- Others
    { weapon_name = 'weapon_petrolcan', damage_multiplier = 0.00 },
    { weapon_name = 'weapon_fireextinguisher', damage_multiplier = 0.00 },
    { weapon_name = 'weapon_hazardcan', damage_multiplier = 0.00 },
}