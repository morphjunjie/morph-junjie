-- config.lua
return {
    debugPoly = false,
    targetDistance = 3.5,

    Blips = {
        { coords = vector3(-713.76, 5362.08, 63.15), sprite = 285, colour = 5, scale = 0.7, name = 'Tree Area' },
        { coords = vector3(-551.67, 5329.86, 74.44), sprite = 467, colour = 5, scale = 0.7, name = 'Wood Processing' },
        { coords = vector3(-533.19, 5293.11, 73.64), sprite = 478, colour = 5, scale = 0.7, name = 'Packing Area' },
    },

    Tree = {
        coords = vector3(-713.76, 5362.08, 63.15),
        inDistance = 150.0,
        outDistance = 200.0,
        requiredItem = 'axe',
        durabilityLoss = 4, -- berapa persen durability hilang tiap nebang pohon
        minWood = 2,
        maxWood = 4,
        progressTime = 8000,
        respawnTime = 120000, -- waktu respawn pohon (ms)
        treeModel = `prop_tree_birch_05`,
        fruitChance = 45,       -- % peluang dapet buah pas nebang (0-100)
        fruitMin = 2,
        fruitMax = 4,
        fruits = { 'orange', 'apple' }, -- salah satu dipilih random tiap kali kena chance
        spawnPoints = {
            vector4(-708.79, 5364.42, 63.24, 279.76),
            vector4(-715.86, 5363.07, 62.54, 67.65),
            vector4(-725.04, 5361.56, 61.35, 130.3),
            vector4(-725.6, 5351.38, 63.34, 175.62),
            vector4(-732.86, 5350.18, 62.82, 131.88),
            vector4(-736.12, 5358.73, 61.32, 9.03),
            vector4(-735.4, 5368.03, 59.15, 246.84),
            vector4(-730.94, 5363.33, 60.72, 117.65),
            vector4(-726.29, 5372.73, 59.16, 307.4),
            vector4(-716.15, 5373.39, 60.1, 155.04),
            vector4(-711.56, 5384.66, 57.47, 266.81),
            vector4(-705.95, 5381.52, 58.94, 62.67),
            vector4(-720.57, 5391.31, 54.94, 6.14),
            vector4(-729.27, 5387.33, 54.84, 44.77),
            vector4(-733.85, 5380.83, 55.95, 157.32),
            vector4(-712.77, 5347.44, 67.21, 8.27),
            vector4(-718.92, 5338.88, 68.2, 172.74),
            vector4(-728.14, 5334.37, 68.08, 211.39),
            vector4(-742.61, 5342.67, 63.13, 345.85),
            vector4(-745.35, 5354.04, 60.93, 35.02),
            vector4(-744.96, 5365.7, 58.87, 358.53),
            vector4(-742.49, 5378.31, 55.11, 356.94),
            vector4(-737.3, 5390.73, 52.04, 338.28),
            vector4(-727.2, 5398.17, 51.88, 34.18),
            vector4(-713.83, 5398.11, 53.29, 268.91),
            vector4(-692.39, 5386.06, 57.15, 117.35),
            vector4(-688.53, 5373.56, 60.95, 247.11),
            vector4(-690.54, 5364.95, 64.41, 98.85),
            vector4(-695.97, 5357.94, 66.35, 67.2),
            vector4(-705.31, 5354.76, 66.16, 106.46),
        }
    },

    ProcessLog = {
        coords = vector3(-551.67, 5329.86, 74.44),
        inputItem = 'wood_log',
        inputAmount = 2,
        outputItem = 'wood_plank',
        outputAmount = 4,
        progressTime = 8000,
        stressGain = 0.5,
        label = 'Processing Logs...'
    },

    AutoProcessLog = {
        duration = 12000,
        stressGain = 0.8,
        label = 'Auto Processing Logs...'
    },

    ProcessPlank = {
        coords = vector3(-533.19, 5293.11, 73.64),
        inputItem = 'wood_plank',
        inputAmount = 4,
        outputItem = 'wood_crate',
        outputAmount = 2,
        progressTime = 9000,
        stressGain = 0.6,
        label = 'Packing Crates...'
    },

    AutoProcessPlank = {
        duration = 12000,
        stressGain = 0.10,
        label = 'Auto Packing Crates...'
    },

    Items = {
        axe = 'axe',
        woodLog = 'wood_log',
        woodPlank = 'wood_plank',
        woodCrate = 'wood_crate',
        orange = 'orange',
        apple = 'apple',
    }
}