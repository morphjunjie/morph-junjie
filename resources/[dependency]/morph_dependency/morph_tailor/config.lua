-- config.lua
return {
    debugPoly = false,
    targetDistance = 3.5,

    CottonField = {
        coords = vector3(2046.98, 3520.4, 42.23),
        propModel = `prop_tree_lficus_03`,
        requiredItem = 'scissors',
        durabilityLoss = 4.3, -- berapa persen durability hilang tiap memotong kapas
        duration = 8000,
        stressGain = 0.5,
        outputItem = 'cotton',
        outputMin = 3,
        outputMax = 5,
        inDistance = 70.0,
        outDistance = 80.0,
        respawnTime = 120000, -- waktu respawn cotton (ms)
        spawnPoints = {           
            vector4(2041.72, 3525.67, 41.72, 305.02),
            vector4(2056.86, 3523.03, 42.83, 259.51),
            vector4(2088.9, 3526.16, 42.58, 99.02),
            vector4(2080.44, 3507.63, 42.94, 99.47),
            vector4(2067.83, 3496.06, 43.34, 71.99),
            vector4(2037.05, 3484.04, 43.0, 259.97),
            vector4(2020.18, 3511.57, 41.29, 242.35),
            vector4(2033.29, 3498.62, 41.74, 86.6),
            vector4(2037.47, 3535.13, 40.81, 167.96),
            vector4(2054.32, 3541.57, 41.83, 294.8),
            vector4(2066.23, 3539.9, 41.93, 220.7),
            vector4(2072.85, 3524.84, 42.46, 97.4),
            vector4(2048.76, 3495.49, 42.7, 211.48),
            vector4(2023.48, 3523.37, 41.5, 160.98),
            vector4(2048.75, 3508.64, 42.3, 239.53),
            vector4(2085.4, 3545.29, 42.14, 149.0),
            vector4(2071.89, 3558.13, 41.76, 136.36),
            vector4(2034.94, 3552.93, 39.2, 292.01),
            vector4(2026.57, 3544.77, 41.5, 143.75),
            vector4(2002.24, 3510.81, 40.77, 307.04),
            vector4(2013.86, 3493.3, 41.8, 211.27),
            vector4(2089.71, 3489.17, 44.2, 208.56),
            vector4(2102.46, 3496.94, 44.18, 306.34),
        }
    },

    ProcessCotton = {
        coords = vector3(717.71, -961.84, 30.4),
        inputItem = 'cotton',
        inputAmount = 2,
        outputItem = 'fabric',
        outputAmount = 1,
        duration = 7000,
        stressGain = 0.7,
        label = 'Processing Cotton...'
    },

    AutoProcessCotton = {
        duration = 9000,
        stressGain = 0.11,
        label = 'Auto Processing Cotton...'
    },

    ProcessClothes = {
        coords = vector3(712.9, -970.03, 30.4),
        inputItem = 'fabric',
        inputAmount = 2,
        outputItem = 'clothes',
        outputAmount = 1,
        duration = 9000,
        stressGain = 0.9,
        label = 'Making Clothes...'
    },

    AutoProcessClothes = {
        duration = 12000,
        stressGain = 0.13,
        label = 'Auto Making Clothes...'
    },

    Blips = {
        { coords = vector3(2046.98, 3520.4, 42.23), sprite = 836, colour = 2, scale = 0.8, name = 'Tree Cotton' },
        { coords = vector3(715.19, -965.16, 30.4), sprite = 366, colour = 2, scale = 0.8, name = 'Clothes Making' },
    }
}