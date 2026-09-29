-- config.lua
return {
    debugPoly = false,
    targetDistance = 3.0,
    autoStopDistance = 700.0,
    cooldown = 60000,

    StartHunting = {
        coords = vector3(-769.15, 5596.65, 33.61),
        requiredItem = 'WEAPON_KNIFE',
    },

    Deer = {
        model = `a_c_deer`,
        spawnCenter = vector3(-868.23, 5197.7, 114.49),  -- <-- TAMBAHIN INI
        spawnRadius = 300.0,
        maxDeer = 15,
        minDistBetweenDeer = 25.0,
    },

    Butcher = {
        duration = 15000,
        stressGain = 0.18,
        meatItem = 'deer_meat',
        meatMin = 4,
        meatMax = 7,
        skinItem = 'deer_skin',
        skinMin = 2,
        skinMax = 4,
    }
}