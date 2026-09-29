return {
    useTarget = true,
    bankMoney = false,
    ProfitMargin = 1.2,

    market = {
        updateInterval = 60,
        minItemsPerUpdate = 3,
        maxItemsPerUpdate = 8,
        minPercentChange = 5,
        maxPercentChange = 25,
        maxDeviation = 50,
        discord = {
            webhook = 'https://discord.com/api/webhooks/1544876999351337013/4aMGXGigzVf713tb9seeg1IbWtGILrcWKUY_J3Atc-lhscfV3yWVt_rXX29Le3k6KYOW',
            name = 'Pawnshop Market',
            avatar = 'https://cdn.discordapp.com/attachments/1515932806222708890/1544817208536862770/eminence-in-shadow.gif?ex=6a99e2a3&is=6a989123&hm=2409e30727c926bb69eb1913b4f28056f59d9b36e14b933912baeec0d2aece72&',
            roleId = '1515932804947644482'
        }
    },

    pawnLocation = {
        {
            coords = vec3(412.09, 315.06, 103.13),
            size = vector3(1.5, 1.8, 2.0),
            heading = 207.0,
            debugPoly = false,
            distance = 3.0
        }
    },

    pawnItems = {
        -- GEMS
        { item = 'raw_emerald', price = 100 },
        { item = 'raw_sapphire', price = 60 },
        { item = 'raw_ruby', price = 70 },
        { item = 'raw_amethyst', price = 55 },
        { item = 'raw_topaz', price = 65 },
        { item = 'raw_opal', price = 50 },
        { item = 'raw_tourmaline', price = 60 },
        { item = 'raw_peridot', price = 45 },
        { item = 'raw_citrine', price = 55 },
        { item = 'raw_garnet', price = 50 },

        -- ORES
        { item = 'coal_ore', price = 30 },
        { item = 'platinum_ore', price = 50 },
        { item = 'silver_ore', price = 40 },
        { item = 'diamond_ore', price = 55 },
        { item = 'gold_ore', price = 40 },
        { item = 'aluminum_ore', price = 20 },
        { item = 'iron_ore', price = 12 },
        { item = 'copper_ore', price = 10 },

        -- MATERIALS
        { item = 'glass', price = 17 },
        { item = 'copper', price = 12 },
        { item = 'rubber', price = 20 },
        { item = 'aluminum', price = 18 },
        { item = 'steel', price = 18 },
        { item = 'iron', price = 12 },
        { item = 'wood_crate', price = 18 },
        { item = 'metalscrap', price = 8 },
        { item = 'plastic', price = 7 },
        { item = 'cryptostick', price = 12 },
        { item = 'paper', price = 8 },

        -- JOB PRODUCTS
        { item = 'pork_packing', price = 28 },
        { item = 'oil_barrel', price = 28 },
        { item = 'pack_chicken', price = 25 },
        { item = 'wine', price = 16 },
        { item = 'clothes', price = 35 },
        { item = 'chicken_eggs', price = 2 },

        -- HUNTING
        { item = 'deer_meat', price = 6 },
        { item = 'deer_skin', price = 11 },

        -- FOOD & DRINKS
        { item = 'cola', price = 12 },
        { item = 'orange', price = 3 },
        { item = 'apple', price = 3 },

        -- TRASH
        { item = 'empty_can', price = 4 },
        { item = 'empty_bottle', price = 3 },
        { item = 'trash_bread', price = 3 },
        { item = 'trash_chips', price = 3 },
        { item = 'trash_burger', price = 3 },
        { item = 'trash_can', price = 3 },
        { item = 'trash', price = 3 }
    }
}