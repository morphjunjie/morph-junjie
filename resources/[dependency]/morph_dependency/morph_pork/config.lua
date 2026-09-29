-- config.lua
return {
    debugPoly = false,

    Blips = {
        {
            coords = vec3(2386.04, 5045.72, 46.38),
            sprite = 106,
            scale = 0.6,
            colour = 5,
            name = 'Pork Farm'
        },
        {
            coords = vec3(992.87, -2161.81, 30.62),
            sprite = 497,
            scale = 0.6,
            colour = 3,
            name = 'Pork Processing'
        },
        {
            coords = vec3(983.72, -2119.24, 30.59),
            sprite = 478,
            scale = 0.6,
            colour = 5,
            name = 'Pork Packing'
        }
    },

    Job = {
        MenuCoords = vec3(2386.04, 5045.72, 46.38),
        PigModel = `a_c_pig`,
        SpawnCenter = vec3(2378.16, 5053.11, 46.44),
        SpawnRadius = 5.0,
        MaxPigs = 10,
        CatchChance = 80,
        RespawnTime = 15000,
        StressGain = 0.7,
        RewardMin = 1,
        RewardMax = 1,
        RewardItem = 'pork',
        requiredItem = 'sack',
        durabilityLoss = 3,
        AutoStopDistance = 60.0,
        targetDistance = 2.5,
        zoneSize = vec3(1, 1, 2),
        icon = 'fa-solid fa-piggy-bank',
        targetLabel = 'Pork Farm'
    },

    ProcessMeat = {
        coords = vec3(992.87, -2161.81, 30.62),
        inputItem = 'pork',
        inputAmount = 1,
        outputItem = 'pork_meat',
        outputAmount = 2,
        maxStack = 500,
        duration = 6000,
        stressGain = 0.10,
        targetLabel = 'Processing Pork',
        progressLabel = 'Processing Pork...',
        zoneSize = vec3(5, 5, 5),
        icon = 'fa-solid fa-drumstick-bite',
        targetDistance = 3.5
    },

    AutoProcessMeat = {
        duration = 8000,
        stressGain = 0.15,
        label = 'Auto Processing Pork...',
        waitTime = 1000
    },

    ProcessPack = {
        coords = vec3(983.72, -2119.24, 30.59),
        inputItem = 'pork_meat',
        inputAmount = 2,
        outputItem = 'pork_packing',
        outputAmount = 3,
        maxStack = 500,
        duration = 9000,
        stressGain = 0.13,
        targetLabel = 'Packing Pork',
        progressLabel = 'Packing Pork...',
        zoneSize = vec3(5, 13, 5),
        icon = 'fa-solid fa-boxes',
        targetDistance = 6.0
    },

    AutoProcessPack = {
        duration = 12000,
        stressGain = 0.17,
        label = 'Auto Packing Pork...',
        waitTime = 1000
    },

    maxStackLimit = 500
}