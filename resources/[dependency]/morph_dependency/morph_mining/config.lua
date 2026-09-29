-- config.lua

return {
    debugPoly = false, -- shows target zone outlines when true, keep false in production
    targetDistance = 3.5, -- max distance (units) player can be from a rock to mine it

    -- map blips shown at each station
    Blips = {
        { coords = vector3(2947.49, 2789.29, 40.59), sprite = 618, colour = 46, scale = 0.7, name = 'Mining Area' },
        { coords = vector3(1086.11, -2003.22, 31.95), sprite = 467, colour = 3, scale = 0.7, name = 'Stone Washer' },
        { coords = vector3(1111.47, -2009.23, 31.81), sprite = 617, colour = 1, scale = 0.7, name = 'Ore Smelter' },
    },

    Mining = {
        coords = vector3(2947.49, 2789.29, 40.59), -- center of the mining zone (used for the entry/exit sphere)
        inDistance = 70.0, -- radius (units) around coords where rocks spawn/despawn
        outDistance = 100.0, -- currently unused, reserved for a future outer despawn ring
        requiredItem = 'pickaxe', -- morph_inv item name needed to mine
        durabilityLoss = 3.5, -- durability % removed from the pickaxe per successful mine
        minStone = 2, -- min stone given per mine
        maxStone = 3, -- max stone given per mine
        progressTime = 8000, -- mining animation/progress bar duration in ms
        respawnTime = 120000, -- how long (ms) a mined rock stays gone before respawning
        rockModel = `prop_rock_3_a`, -- prop model used for rocks
        -- spawn points for rocks. vector4 includes a heading (w), vector3 spawns with default heading
        spawnPoints = {
            vector4(2950.53, 2790.9, 41.06, 168.59),
            vector3(2941.95, 2785.14, 39.8),
            vector4(2932.77, 2798.66, 41.02, 31.8),
            vector4(2940.59, 2806.31, 41.62, 345.63),
            vector4(2958.66, 2814.53, 42.67, 39.52),
            vector4(2959.78, 2795.14, 40.81, 177.17),
            vector4(2971.05, 2793.49, 40.54, 190.64),
            vector4(2972.68, 2783.26, 39.15, 106.07),
            vector4(2961.37, 2779.83, 40.07, 98.59),
            vector4(2943.96, 2768.99, 39.33, 164.01),
            vector4(2940.46, 2819.71, 43.77, 52.92),
            vector4(2953.26, 2803.34, 41.72, 103.73),
            vector4(2922.2, 2806.08, 42.85, 304.78),
            vector4(2924.72, 2779.03, 43.12, 102.59),
        }
    },

    Washing = {
        coords = vector3(1086.11, -2003.22, 31.95), -- where the wash station box zone is
        inputItem = 'stone', -- item consumed per wash
        inputAmount = 2, -- how much stone consumed per wash
        outputItem = 'washed_stone', -- item given per wash
        outputAmount = 5, -- how much washed_stone given per wash
        maxStack = 500, -- hard cap on outputItem this station will let a player hold
        progressTime = 8000, -- manual wash progress bar duration in ms
        stressGain = 0.15, -- stress added to hud:server:GainStress per manual wash
        label = 'Washing Stone...' -- progress bar label for manual wash
    },

    AutoWash = {
        duration = 10000, -- progress bar duration per cycle when auto washing
        stressGain = 0.11, -- stress added per auto wash cycle
        label = 'Auto Washing Stone...', -- progress bar label for auto wash
        waitTime = 1500 -- currently unused, reserved for a delay between auto cycles
    },

    Smelting = {
        coords = vector3(1111.47, -2009.23, 31.81), -- where the ore smelter box zone is
        inputItem = 'washed_stone', -- item consumed per smelt
        inputAmount = 5, -- how much washed_stone consumed per smelt
        maxStack = 500, -- hard cap on any single ore item a player can receive
        progressTime = 10000, -- manual smelt progress bar duration in ms
        stressGain = 0.10, -- stress added per manual smelt
        label = 'Smelting Ore...', -- progress bar label for manual smelt
        -- possible ore rewards per smelt. each item rolls independently:
        -- chance = % chance (1-100) this specific item drops this smelt
        -- min/max = amount given if it drops
        -- one item is always guaranteed to drop so a smelt never gives nothing
        oreChances = {
            { item = 'copper_ore',   min = 3, max = 7, chance = 35 },
            { item = 'iron_ore',     min = 3, max = 6, chance = 30 },
            { item = 'aluminum_ore', min = 2, max = 5, chance = 25 },
            { item = 'silver_ore',   min = 2, max = 4, chance = 18 },
            { item = 'gold_ore',     min = 2, max = 4, chance = 12 },
            { item = 'platinum_ore', min = 1, max = 3, chance = 8 },
            { item = 'diamond_ore',  min = 1, max = 2, chance = 3 },
            { item = 'coal_ore',     min = 3, max = 7, chance = 40 },
        }
    },

    AutoSmelt = {
        duration = 12000, -- progress bar duration per cycle when auto smelting
        stressGain = 0.13, -- stress added per auto smelt cycle
        label = 'Auto Smelting Ore...', -- progress bar label for auto smelt
        waitTime = 1500 -- currently unused, reserved for a delay between auto cycles
    },

    GemSmelting = {
        enabled = true, -- set false to fully disable the gem smelting station
        coords = vector3(1111.47, -2009.23, 31.81), -- where the gem smelter box zone is
        inputItem = 'washed_stone', -- item consumed per gem smelt
        inputAmount = 15, -- how much washed_stone consumed per gem smelt (manual only, no auto version)
        maxStack = 500, -- hard cap on any single gem item a player can receive
        progressTime = 15000, -- gem smelt progress bar duration in ms
        stressGain = 0.16, -- stress added per gem smelt
        label = 'Smelting Gems...', -- progress bar label for gem smelt
        -- same chance system as oreChances above
        gemChances = {
            { item = 'raw_garnet',     min = 3, max = 5, chance = 25 },
            { item = 'raw_citrine',    min = 2, max = 5, chance = 22 },
            { item = 'raw_peridot',    min = 2, max = 4, chance = 18 },
            { item = 'raw_tourmaline', min = 2, max = 4, chance = 18 },
            { item = 'raw_opal',       min = 2, max = 4, chance = 15 },
            { item = 'raw_topaz',      min = 2, max = 4, chance = 15 },
            { item = 'raw_amethyst',   min = 2, max = 4, chance = 12 },
            { item = 'raw_emerald',    min = 2, max = 3, chance = 8 },
            { item = 'raw_sapphire',   min = 2, max = 3, chance = 7 },
            { item = 'raw_ruby',       min = 2, max = 4, chance = 5 },
        }
    },
}