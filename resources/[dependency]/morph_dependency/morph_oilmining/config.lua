-- config.lua
return {
    debugPoly = false,
    targetDistance = 3.5,

    Blips = {
        { coords = vector3(609.55, 2903.57, 39.71), sprite = 415, colour = 1, scale = 0.7, name = 'Oil Field' },
        { coords = vector3(2739.07, 1717.33, 24.54), sprite = 436, colour = 46, scale = 0.7, name = 'Oil Processing' },
        { coords = vector3(2792.5, 1713.5, 24.6), sprite = 436, colour = 69, scale = 0.7, name = 'Barrel Packing' },
    },

    OilPump = {
        coords = vector3(609.55, 2903.57, 39.71),
        inDistance = 150.0,
        outDistance = 200.0,
        requiredItem = 'wrench',
        durabilityLoss = 3,
        minOil = 1,
        maxOil = 3,
        progressTime = 8000,
        respawnTime = 180000,
        pumpModel = `prop_barrel_01a`, -- prop barrel
        spawnPoints = {
            vector4(609.96, 2906.02, 39.78, 330.45),
            vector4(618.22, 2909.85, 39.74, 292.84),
            vector4(626.93, 2905.6, 39.72, 231.66),
            vector4(627.02, 2895.88, 39.72, 180.0),
            vector4(618.0, 2891.5, 39.72, 135.0),
            vector4(609.0, 2895.0, 39.72, 90.0),
            vector4(601.0, 2875.32, 39.45, 209.75),
            vector4(612.47, 2878.71, 39.37, 279.21),
            vector4(601.87, 2890.54, 39.77, 53.8),
            vector4(596.13, 2898.51, 39.7, 45.67),
            vector4(597.07, 2906.23, 40.08, 352.03),
            vector4(585.16, 2902.99, 39.76, 108.55),
            vector4(579.59, 2892.83, 39.33, 122.7),
            vector4(615.7, 2925.92, 40.18, 352.98),
            vector4(628.49, 2935.53, 40.51, 307.32),
            vector4(638.86, 2928.16, 40.26, 223.02),
            vector4(644.19, 2919.52, 41.94, 289.73),
            vector4(651.27, 2903.43, 40.95, 179.72),
            vector4(647.82, 2889.85, 41.11, 163.55),
            vector4(640.58, 2880.4, 39.63, 142.23),
            vector4(631.99, 2870.3, 39.68, 141.39),
            vector4(616.37, 2869.56, 39.21, 91.7),
            vector4(602.98, 2867.13, 39.65, 107.65),
            vector4(593.17, 2869.46, 39.51, 66.2),
            vector4(583.13, 2874.26, 40.29, 60.06),
            vector4(578.41, 2881.99, 39.94, 30.14),
            vector4(574.2, 2895.36, 39.25, 355.61),
            vector4(591.49, 2885.33, 39.48, 265.09),
            vector4(573.56, 2916.57, 40.36, 241.92),
            vector4(586.03, 2921.46, 40.83, 251.95),
            vector4(598.39, 2921.29, 40.78, 211.02),
        }
    },

    ProcessOil = {
        coords = vector3(2739.07, 1717.33, 24.54),
        inputItem = 'crude_oil',
        inputAmount = 2,
        outputItem = 'processed_oil',
        outputAmount = 4,
        progressTime = 8000,
        stressGain = 0.5,
        label = 'Processing Crude Oil...'
    },

    AutoProcessOil = {
        duration = 12000,
        stressGain = 0.8,
        label = 'Auto Processing Oil...'
    },

    ProcessBarrel = {
        coords = vector3(2792.5, 1713.5, 24.6),
        inputItem = 'processed_oil',
        inputAmount = 4,
        outputItem = 'oil_barrel',
        outputAmount = 2,
        progressTime = 9000,
        stressGain = 0.6,
        label = 'Packing Oil Barrels...'
    },

    AutoProcessBarrel = {
        duration = 12000,
        stressGain = 0.10,
        label = 'Auto Packing Barrels...'
    },

    Items = {
        wrench = 'wrench',
        crudeOil = 'crude_oil',
        processedOil = 'processed_oil',
        oilBarrel = 'oil_barrel',
    }
}