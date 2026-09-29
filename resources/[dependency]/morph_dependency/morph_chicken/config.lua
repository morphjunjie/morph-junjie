-- config.lua
return {
    debugPoly = false,

    Blips = {
        {
            coords = vec3(-69.1, 6249.44, 31.08),
            sprite = 89,
            scale = 0.6,
            colour = 5,
            name = 'Chicken Farm'
        },
        {
            coords = vec3(-87.82, 6232.38, 31.83),
            sprite = 497,
            scale = 0.6,
            colour = 3,
            name = 'Chicken Processing'
        },
        {
            coords = vec3(-102.84, 6209.77, 30.04),
            sprite = 478,
            scale = 0.6,
            colour = 5,
            name = 'Chicken Packing'
        }
    },

    TakeChicken = {
        coords = vec3(-69.1, 6249.44, 31.08),
        inputItem = nil,
        inputAmount = 0,
        outputItem = 'chicken',
        outputMin = 1,
        outputMax = 3,
        outputAmount = 1,
        maxStack = 500,
        duration = 5000,
        stressGain = 0.7,
        targetLabel = 'Take Chicken',
        progressLabel = 'Taking Chicken...',
        zoneSize = vec3(5, 5, 5),
        zoneRotation = 0,
        icon = 'fa-solid fa-drumstick-bite',
        targetDistance = 3.0
    },

    AutoTakeChicken = {
        duration = 6000,
        stressGain = 0.10,
        label = 'Auto Taking Chicken...',
        waitTime = 1000
    },

    ProcessChicken = {
        coords = vec3(-87.82, 6232.38, 31.83),
        inputItem = 'chicken',
        inputAmount = 1,
        outputItem = 'chicken_meat',
        outputAmount = 2,
        maxStack = 500,
        eggItem = 'chicken_eggs',
        eggMin = 2,
        eggMax = 4,
        eggChance = 40,
        duration = 6000,
        stressGain = 0.8,
        targetLabel = 'Cut Chicken',
        progressLabel = 'Cutting Chicken...',
        zoneSize = vec3(8, 8, 8),
        zoneRotation = 0,
        icon = 'fa-solid fa-cut',
        targetDistance = 3.0
    },

    AutoProcessMeat = {
        duration = 7000,
        stressGain = 0.13,
        label = 'Auto Cutting Chicken...',
        waitTime = 1000
    },

    PackChicken = {
        coords = vec3(-102.84, 6209.77, 30.04),
        inputItem = 'chicken_meat',
        inputAmount = 2,
        outputItem = 'pack_chicken',
        outputAmount = 4,
        maxStack = 500,
        duration = 7000,
        stressGain = 0.8,
        targetLabel = 'Pack Chicken',
        progressLabel = 'Packing Chicken...',
        zoneSize = vec3(8, 8, 8),
        zoneRotation = 3,
        icon = 'fa-solid fa-boxes',
        targetDistance = 4.5
    },

    AutoProcessPack = {
        duration = 8000,
        stressGain = 0.15,
        label = 'Auto Packing Chicken...',
        waitTime = 1000
    },

    maxStackLimit = 500
}