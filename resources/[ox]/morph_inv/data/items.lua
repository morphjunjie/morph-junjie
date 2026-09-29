return {

    -- food & drink
    ['burger'] = {
        label = 'Burger', description = 'A delicious beef burger with all the fixings. Great for satisfying hunger.', weight = 220,
        client = { status = { hunger = 200000 }, anim = 'eating', prop = 'burger', usetime = 2500, notification = 'You ate a delicious burger' }
    },

    ['water'] = {
        label = 'Water', description = 'A bottle of refreshing spring water. Essential for staying hydrated.', weight = 500,
        client = { status = { thirst = 200000 }, anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' }, prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) }, usetime = 2500, cancel = true, notification = 'You drank some refreshing water' }
    },
    ['grape']      = { label = 'Grape', description = 'Fresh grapes. A healthy fruit.', weight = 440 },
    ['grapejuice'] = { label = 'Grape Juice', description = 'Freshly squeezed grape juice. Rich in flavor.', weight = 310 },
    ['orange']     = { label = 'Orange', description = 'A fresh orange. Great for a quick vitamin boost.', weight = 30, stack = true, close = true },
    ['apple']      = { label = 'Apple', description = 'A crisp apple. An apple a day keeps the doctor away.', weight = 20, stack = true, close = true },

    -- health & medical
    ['bandage']      = { label = 'Bandage', description = 'A sterile bandage for treating minor cuts and wounds.', weight = 115, decay = true, degrade = 1440 },
    ['firstaid']     = { label = 'First Aid Kit', description = 'A comprehensive first aid kit for treating injuries and emergencies.', weight = 500, decay = true, degrade = 1440 },
    ['ifaks_stress'] = { label = 'Ifaks Stress', description = 'Individual First Aid Kit for Stress. Helps reduce anxiety and stress levels.', weight = 150, decay = true, degrade = 1440 },
    ['painkillers']  = { label = 'Painkillers', description = 'Over-the-counter pain relief medication. Relieves minor pain and discomfort.', weight = 170, decay = true, degrade = 1440 },

    -- armor & protection
    ['armour']        = { label = 'Armour', description = 'Standard ballistic armor vest. Provides moderate protection against gunfire.', weight = 3500, stack = false, client = { anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' }, usetime = 4500 } },
    ['medium_armour'] = { label = 'Medium Armour', description = 'Medium-grade armor vest. Balances protection and mobility.', weight = 3000, stack = false, client = { anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' }, usetime = 3500 } },
    ['heavy_armour']  = { label = 'Heavy Armour', description = 'Heavy-duty armor vest. Provides maximum protection but restricts mobility.', weight = 4000, stack = false, client = { anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' }, usetime = 5500 } },

    -- tools & equipment
    ['pickaxe']          = { label = 'Pickaxe', description = 'A sturdy pickaxe used for mining stones.', weight = 500, stack = false, durability = 100 },
    ['axe']              = { label = 'Axe', description = 'A sharp axe used for chopping trees. Durability decreases with each use.', weight = 100, stack = false, durability = 100 },
    ['wrench']           = { label = 'Wrench', description = 'A sturdy wrench for oil changes.', weight = 200, stack = false, durability = 100 },
    ['sack']             = { label = 'Sack', description = 'A sack for catching pigs/animals.', weight = 300, stack = false, durability = 100 },
    ['scissors']         = { label = 'Scissors', description = 'A pair of sharp scissors for cutting fabric and threads.', weight = 150, stack = false, durability = 100 },
    ['shovel']           = { label = 'Shovel', description = 'A durable shovel for digging and excavation work.', weight = 300, durability = 100, stack = false },
    ['drill']            = { label = 'Drill', description = 'A heavy-duty drill for breaking through tough surfaces.', weight = 5000 },
    ['lockpick']         = { label = 'Lockpick', description = 'A set of tools for picking standard locks. Requires skill and patience.', weight = 160 },
    ['advancedlockpick'] = { label = 'Advanced Lockpick', description = 'A professional-grade lockpick set for more complex locking mechanisms.', weight = 500 },
    ['screwdriverset']   = { label = 'Screwdriver Set', description = 'A comprehensive set of screwdrivers for various mechanical and electronic work.', weight = 500 },
    ['electronickit']    = { label = 'Electronic Kit', description = 'A kit containing essential tools and components for electronic repairs.', weight = 500 },
    ['gatecrack']        = { label = 'Gatecrack', description = 'A specialized tool for bypassing electronic gate security systems.', weight = 1000 },
    ['thermite']         = { label = 'Thermite', description = 'A powerful incendiary compound. Use with extreme caution.', weight = 1000 },
    ['diving_gear']      = { label = 'Diving Gear', description = 'Complete scuba diving equipment for underwater exploration.', weight = 30000 },
    ['diving_fill']      = { label = 'Diving Tube', description = 'A refillable oxygen tank for extended underwater excursions.', weight = 3000 },
    ['jerry_can']        = { label = 'Jerrycan', description = 'A heavy-duty fuel container for transporting gasoline or diesel.', weight = 3000 },
    ['nitrous']          = { label = 'Nitrous', description = 'Bottle of nitrous oxide', weight = 1000, stack = false, close = true },
    ['binoculars']       = { label = 'Binoculars', description = 'High-power binoculars for long-distance observation.', weight = 800 },
    ['walking_stick']    = { label = 'Walking Stick', description = 'A sturdy walking stick for support while hiking or exploring.', weight = 1000 },
    ['lighter']          = { label = 'Lighter', description = 'A reliable lighter for starting fires.', weight = 200 },
    ['harness']          = { label = 'Harness', description = 'A safety harness for working at heights or in dangerous conditions.', weight = 200 },
    ['handcuffs']        = { label = 'Handcuffs', description = 'Standard issue handcuffs for law enforcement use.', weight = 200 },

    -- containers & bags
    ['paperbag']            = { label = 'Paper Bag', description = 'A simple brown paper bag. Perfect for carrying items discreetly.', weight = 1, stack = false, close = false, consume = 0 },
    ['backpack']            = { label = 'Backpack', description = 'A spacious backpack for carrying multiple items on the go.', weight = 1, stack = false, close = false, consume = 0 },
    ['bag_empty']           = { label = 'Empty Bag', description = 'An empty bag. For packaging and storing items.', weight = 5, stack = true, close = true },
    ['empty_evidence_bag']  = { label = 'Empty Evidence Bag', description = 'A sealable bag for collecting and preserving evidence.', weight = 200 },
    ['filled_evidence_bag'] = { label = 'Filled Evidence Bag', description = 'A sealed evidence bag containing collected evidence.', weight = 200 },

    -- vehicle items
    ['cleaningkit']       = { label = 'Cleaning Kit', description = 'A microfiber cloth with some soap will let your car sparkle again!', weight = 250, stack = true, close = true, client = { image = 'cleaningkit.png' }, server = { export = 'morph_small.cleaningkit' } },
    ['tirekit']           = { label = 'Tire Kit', description = 'A nice toolbox with stuff to repair your tire', weight = 250, stack = true, close = true, client = { image = 'tirekit.png' }, server = { export = 'morph_small.tirekit' } },
    ['repairkit']         = { label = 'Repairkit', description = 'A nice toolbox with stuff to repair your vehicle', weight = 2500, stack = true, close = true, client = { image = 'repairkit.png' }, server = { export = 'morph_small.repairkit' } },
    ['advancedrepairkit'] = { label = 'Advanced Repairkit', description = 'A nice toolbox with stuff to repair your vehicle', weight = 5000, stack = true, close = true, client = { image = 'advancedrepairkit.png' }, server = { export = 'morph_small.advancedrepairkit' } },

    -- radio & communication
    ['radio']     = { label = 'Radio', description = 'A portable radio for communication with others in the area.', weight = 1000, allowArmed = true, consume = 0, client = { event = 'morph_radio:client:use' } },
    ['jammer']    = { label = 'Radio Jammer', description = 'A powerful device that disrupts all radio signals in the vicinity.', weight = 10000, allowArmed = true, client = { event = 'morph_radio:client:usejammer' } },
    ['radiocell'] = { label = 'AAA Cells', description = 'AAA batteries for powering radios and other electronic devices.', weight = 1000, stack = true, allowArmed = true, client = { event = 'morph_radio:client:recharge' } },

    -- valuables & jewelry
    ['diamond_ring'] = { label = 'Diamond Ring', description = 'A stunning diamond ring. A symbol of love and luxury.', weight = 1500 },
    ['rolex']        = { label = 'Golden Watch', description = 'A luxurious gold watch. The epitome of sophistication.', weight = 1500 },
    ['goldbar']      = { label = 'Gold Bar', description = 'A 10oz gold bar. A valuable asset for any investor.', weight = 1500 },
    ['goldchain']    = { label = 'Golden Chain', description = 'A solid gold chain. A statement piece for any occasion.', weight = 1500 },

    -- drugs & illegal items
    ['cokebaggy']        = { label = 'Bag of Coke', description = 'A small bag of cocaine. Highly illegal and dangerous.', weight = 100 },
    ['coke_brick']       = { label = 'Coke Brick', description = 'A brick of compressed cocaine. For large-scale distribution.', weight = 2000 },
    ['coke_small_brick'] = { label = 'Coke Package', description = 'A packaged amount of cocaine. Ready for transport.', weight = 1000 },
    ['xtc_bag']          = { label = 'Ecstasy Baggy', description = 'A bag containing ecstasy pills. A dangerous and illegal substance.', weight = 100 },
    ['cocaine_leaf']     = { label = 'Cocaine Leaf', description = 'Fresh coca leaves. The raw material for cocaine production.', weight = 1100, stack = true, close = true },
    ['cocaine_powder']   = { label = 'Cocaine Powder', description = 'Processed cocaine powder. Ready for packaging.', weight = 450, stack = true, close = true },
    ['cocaine']          = { label = 'Cocaine', description = 'Pure cocaine. Extremely dangerous and highly valuable.', weight = 146, stack = true, close = true },
    ['cocaine_bag']      = { label = 'Cocaine Bag', description = 'A packaged bag of cocaine. Ready for sale to customers.', weight = 60, stack = true, close = true },
    ['crack_bag']        = { label = 'Crack Baggy', description = 'A bag containing crack cocaine. Highly addictive and dangerous.', weight = 560 },
    ['crack']            = { label = 'Crack', description = 'Crack cocaine. A devastatingly addictive substance.', weight = 500 },
    ['oxycodone']        = { label = 'Oxycodone', description = 'Prescription painkiller. Highly addictive when misused.', weight = 100 },
    ['meth_crystal']     = { label = 'Meth Crystal', description = 'Pure meth crystal. Ready for processing into final product.', weight = 1200, stack = true, close = true, client = { image = 'meth_crystal.png' } },
    ['chemical']         = { label = 'Chemical', description = 'Industrial grade chemicals for meth production.', weight = 1500, stack = true, close = true, client = { image = 'chemical.png' } },
    ['ammonia']          = { label = 'Ammonia', description = 'Ammonia solution for meth production. Handle with care.', weight = 800, stack = true, close = true, client = { image = 'ammonia.png' } },
    ['meth']             = { label = 'Meth', description = 'Processed methamphetamine. Ready to be packed for sale.', weight = 250, stack = true, close = true, client = { image = 'meth.png' } },
    ['meth_bag']         = { label = 'Meth Baggy', description = 'A sealed bag containing methamphetamine. Ready for sale.', weight = 150, stack = true, close = true, client = { image = 'meth_bag.png' } },
    ['meth_tray']        = { label = 'Meth Tray', description = 'Special tray for meth processing. Required for packing operations.', weight = 500, stack = false, close = true, client = { image = 'meth_tray.png' } },
    ['sodium']           = { label = 'Sodium', description = 'Chemical compound used in drug manufacturing.', weight = 200, stack = true, close = true },

    -- weed items
    ['weed_ak47']             = { label = 'AK47 2g', description = 'Premium AK47 strain cannabis. Known for its potent effects.', weight = 200 },
    ['weed_ak47_seed']        = { label = 'AK47 Seed', description = 'A seed of the famous AK47 strain. Can be cultivated into high-quality cannabis.', weight = 100, consume = 1, client = { export = 'morph_weed.placePlant' } },
    ['weed_skunk']            = { label = 'Skunk 2g', description = 'A pungent and potent strain with a strong skunk-like aroma.', weight = 200 },
    ['weed_skunk_seed']       = { label = 'Skunk Seed', description = 'Seed of the Skunk strain. Produces plants with distinct skunky notes.', weight = 1 },
    ['weed_amnesia']          = { label = 'Amnesia 2g', description = 'A powerful sativa strain known for its euphoric and long-lasting effects.', weight = 200 },
    ['weed_amnesia_seed']     = { label = 'Amnesia Seed', description = 'Seed of the legendary Amnesia strain.', weight = 1 },
    ['weed_og-kush']          = { label = 'OGKush 2g', description = 'The classic OG Kush strain. A favorite among cannabis connoisseurs.', weight = 200 },
    ['weed_og-kush_seed']     = { label = 'OGKush Seed', description = 'Seed of the renowned OG Kush strain.', weight = 1 },
    ['weed_white-widow']      = { label = 'White Widow 2g', description = 'The legendary White Widow strain. Covered in resinous trichomes.', weight = 200 },
    ['weed_white-widow_seed'] = { label = 'White Widow Seed', description = 'Seed of the iconic White Widow strain.', weight = 1 },
    ['weed_purple-haze']      = { label = 'Purple Haze 2g', description = 'A psychedelic strain with a distinctive purple hue and euphoric effects.', weight = 200 },
    ['weed_purple-haze_seed'] = { label = 'Purple Haze Seed', description = 'Seed of the exotic Purple Haze strain.', weight = 1 },
    ['weed_brick']            = { label = 'Weed Brick', description = 'A compressed brick of cannabis. Used for bulk transport and storage.', weight = 2000 },
    ['weed_nutrition']        = { label = 'Plant Fertilizer', description = 'Nutrient-rich fertilizer for optimizing plant growth and yield.', weight = 2000 },
    ['joint']                 = { label = 'Joint', description = 'A pre-rolled cannabis joint. Ready to smoke.', weight = 200 },
    ['rolling_paper']         = { label = 'Rolling Paper', description = 'High-quality rolling papers for crafting the perfect joint.', weight = 0 },
    ['scissors_weed']         = { label = 'Weed Scissors', description = 'Sharp scissors used for harvesting weed. Has durability.', weight = 150, durability = 100, stack = false, close = true },
    ['weed_leaf']             = { label = 'Weed Leaves', description = 'Freshly harvested cannabis leaves. Needs to be processed and cured.', weight = 650, stack = true, close = true },
    ['weed']                  = { label = 'Weed', description = 'Dried and processed cannabis. Ready for packaging and sale.', weight = 310, stack = true, close = true },
    ['weed_bag']              = { label = 'Weed Baggy', description = 'A sealed bag containing premium quality cannabis.', weight = 150, stack = true, close = true },

    -- phone
    ['phone_black']  = { label = 'Phone',        weight = 190, stack = false, consume = 0, server = { export = 'morph_phone.usePhone_black' } },
    ['phone_blue']   = { label = 'Blue Phone',   weight = 190, stack = false, consume = 0, server = { export = 'morph_phone.usePhone_blue' } },
    ['phone_green']  = { label = 'Green Phone',  weight = 190, stack = false, consume = 0, server = { export = 'morph_phone.usePhone_green' } },
    ['phone_orange'] = { label = 'Orange Phone', weight = 190, stack = false, consume = 0, server = { export = 'morph_phone.usePhone_orange' } },
    ['phone_pink']   = { label = 'Pink Phone',   weight = 190, stack = false, consume = 0, server = { export = 'morph_phone.usePhone_pink' } },
    ['phone_purple'] = { label = 'Purple Phone', weight = 190, stack = false, consume = 0, server = { export = 'morph_phone.usePhone_purple' } },
    ['phone_red']    = { label = 'Red Phone',    weight = 190, stack = false, consume = 0, server = { export = 'morph_phone.usePhone_red' } },
    ['phone_yellow'] = { label = 'Yellow Phone', weight = 190, stack = false, consume = 0, server = { export = 'morph_phone.usePhone_yellow' } },

    -- electronics
    ['tablet']      = { label = 'Tablet', description = 'A portable tablet for work, entertainment, and browsing.', weight = 250, stack = false },
    ['cryptostick'] = { label = 'Crypto Stick', description = 'A USB device for storing and securing cryptocurrency wallets.', weight = 100 },
    ['trojan_usb']  = { label = 'Trojan USB', description = 'A USB drive loaded with trojan software. Used for cyber infiltration.', weight = 100 },
    ['toaster']     = { label = 'Toaster', description = 'A standard kitchen toaster. Makes perfect toast every time.', weight = 5000 },
    ['small_tv']    = { label = 'Small TV', description = 'A compact television set. Great for small spaces.', weight = 100 },

    -- keys & access cards
    ['lab_key']          = { label = 'Lab Key', description = 'A key granting access to a restricted laboratory facility.', weight = 50, stack = false },
    ['security_card_01'] = { label = 'Security Card A', description = 'Level A security access card. Grants access to basic security areas.', weight = 100 },
    ['security_card_02'] = { label = 'Security Card B', description = 'Level B security access card. Provides access to restricted zones.', weight = 100 },
    ['key_g']            = { label = 'Keys G', description = 'A golden key that grants access to restricted areas.', weight = 50, stack = true, close = true },

    -- identification & documents
    ['id_card']         = { label = 'Identification Card', description = 'Official government-issued ID card. Provides proof of identity.', weight = 0, decay = true, degrade = 43800 },
    ['driver_license']  = { label = 'Drivers License', description = 'A valid drivers license. Required to operate motor vehicles.', weight = 0, decay = true, degrade = 43800 },
    ['weaponlicense']   = { label = 'Weapon License', description = 'A license authorizing the legal ownership and carrying of firearms.', weight = 0, decay = true, degrade = 43800 },
    ['lawyerpass']      = { label = 'Lawyer Pass', description = 'A pass granting access to legal facilities and court buildings.', weight = 0, decay = true, degrade = 43800 },
    ['contract']        = { label = 'Contract', description = 'A legal document outlining terms and agreements between parties.', weight = 15 },
    ['ticket']          = { label = 'Ticket', description = 'A ticket required to purchase a license at the government office.', weight = 10, stack = false },

    -- mining resources
    ['stone']          = { label = 'Stone', description = 'A rough, unprocessed stone straight from the mine. Needs to be washed before it can be used.', weight = 1393 },
    ['washed_stone']   = { label = 'Washed Stone', description = 'Clean stone ready for smelting. The impurities have been removed.', weight = 363 },
    ['copper_ore']     = { label = 'Copper Ore', description = 'A common ore containing copper. Can be smelted into copper bars.', weight = 113 },
    ['iron_ore']       = { label = 'Iron Ore', description = 'A sturdy ore containing iron. Essential for crafting tools and weapons.', weight = 263 },
    ['aluminum_ore']   = { label = 'Aluminum Ore', description = 'A lightweight ore containing aluminum. Perfect for lightweight components.', weight = 261 },
    ['gold_ore']       = { label = 'Gold Ore', description = 'A precious ore containing gold. Highly valued by jewelers and collectors.', weight = 313 },
    ['diamond_ore']    = { label = 'Diamond Ore', description = 'An extremely rare ore containing diamonds. The ultimate prize for any miner.', weight = 225 },
    ['platinum_ore']   = { label = 'Platinum Ore', description = 'A rare ore containing platinum. Highly sought after for its rarity and value.', weight = 300 },
    ['silver_ore']     = { label = 'Silver Ore', description = 'A valuable ore containing silver. Used in jewelry and currency.', weight = 300 },
    ['coal_ore']       = { label = 'Coal Ore', description = 'A black, combustible mineral used as fuel in furnaces and smelting processes.', weight = 187 },
    ['raw_ruby']       = { label = 'Raw Ruby', description = 'An uncut ruby gemstone. Worth a fortune when properly cut and polished.', weight = 137 },
    ['raw_sapphire']   = { label = 'Raw Sapphire', description = 'An uncut sapphire gemstone. Its deep blue color is highly sought after.', weight = 278 },
    ['raw_emerald']    = { label = 'Raw Emerald', description = 'An uncut emerald gemstone. Its vibrant green hue makes it a collector favorite.', weight = 146 },
    ['raw_amethyst']   = { label = 'Raw Amethyst', description = 'An uncut amethyst gemstone. Known for its striking purple color.', weight = 321 },
    ['raw_topaz']      = { label = 'Raw Topaz', description = 'An uncut topaz gemstone. Its golden-yellow color is highly prized in jewelry.', weight = 173 },
    ['raw_opal']       = { label = 'Raw Opal', description = 'An uncut opal gemstone. Its unique play of colors makes it a rare and valuable find.', weight = 303 },
    ['raw_tourmaline'] = { label = 'Raw Tourmaline', description = 'An uncut tourmaline gemstone. Known for its wide range of colors and striking appearance.', weight = 271 },
    ['raw_peridot']    = { label = 'Raw Peridot', description = 'An uncut peridot gemstone. Its bright green color is highly valued in jewelry making.', weight = 164 },
    ['raw_citrine']    = { label = 'Raw Citrine', description = 'An uncut citrine gemstone. Its warm yellow to orange hues make it a popular choice for jewelry.', weight = 244 },
    ['raw_garnet']     = { label = 'Raw Garnet', description = 'An uncut garnet gemstone. Known for its deep red color and durability.', weight = 417 },

    -- oil mining
    ['crude_oil'] = { label = 'Crude Oil', description = 'Unrefined petroleum extracted from the ground. Needs to be processed into usable fuel.', weight = 1000 },
    ['processed_oil'] = { label = 'Processed Oil', description = 'Refined oil ready for use in various applications.', weight = 469 },
    ['oil_barrel']    = { label = 'Oil Barrel', description = 'A barrel containing refined oil. Used for storage and transportation.', weight = 511 },
    
    -- wood resources
    ['wood_log']   = { label = 'Wood Log', description = 'Raw wood logs obtained from chopping trees. Can be processed into wood planks.', weight = 1482 },
    ['wood_plank'] = { label = 'Wood Plank', description = 'Processed wood planks. Used for crafting wood crates and furniture.', weight = 382 },
    ['wood_crate'] = { label = 'Wood Crate', description = 'Sturdy wooden crate. Used for storage and delivery of goods.', weight = 152 },

    -- tailor items
    ['cotton']  = { label = 'Cotton', description = 'Freshly picked cotton from the field.', weight = 1175 },
    ['fabric']  = { label = 'Fabric', description = 'Processed cotton fabric, ready for tailoring.', weight = 447 },
    ['clothes'] = { label = 'Clothes', description = 'Finished clothes, ready to be sold.', weight = 180 },

    -- fishing items
    ['basic_rod']       = { label = 'Fishing rod', description = 'A basic fishing rod for beginners. Gets the job done.', stack = false, weight = 250 },
    ['graphite_rod']    = { label = 'Graphite rod', description = 'A lightweight graphite rod for sensitive bite detection.', stack = false, weight = 350 },
    ['titanium_rod']    = { label = 'Titanium rod', description = 'A premium titanium fishing rod for the serious angler.', stack = false, weight = 450 },
    ['worms']           = { label = 'Worms', description = 'Live worms for fishing bait. A classic choice for many fish species.', weight = 10 },
    ['artificial_bait'] = { label = 'Artificial bait', description = 'Synthetic fishing bait that mimics real prey. Reusable and effective.', weight = 30 },
    ['anchovy']         = { label = 'Anchovy', description = 'A small, oily fish often used as bait for larger catches.', weight = 20 },
    ['grouper']         = { label = 'Grouper', description = 'A prized game fish known for its delicious, firm flesh.', weight = 3500 },
    ['haddock']         = { label = 'Haddock', description = 'A popular white fish with delicate, flaky meat.', weight = 500 },
    ['mahi_mahi']       = { label = 'Mahi Mahi', description = 'A colorful, fast-swimming fish prized for its mild, sweet flavor.', weight = 3500 },
    ['piranha']         = { label = 'Piranha', description = 'A sharp-toothed predatory fish found in South American waters.', weight = 1500 },
    ['red_snapper']     = { label = 'Red Snapper', description = 'A popular game fish with a bright red color and delicious taste.', weight = 2500 },
    ['salmon']          = { label = 'Salmon', description = 'A highly prized fish known for its pink flesh and rich flavor.', weight = 1000 },
    ['shark']           = { label = 'Shark', description = 'A powerful apex predator. A challenge for any fisherman.', weight = 7500 },
    ['trout']           = { label = 'Trout', description = 'A freshwater fish popular among sport fishermen. Beautiful and flavorful.', weight = 750 },
    ['tuna']            = { label = 'Tuna', description = 'A large, powerful fish known for its meaty, flavorful flesh.', weight = 10000 },

    -- pork farm
    ['pork']         = { label = 'Pork', description = 'Fresh pork meat straight from processing.', weight = 816 },
    ['pork_meat']    = { label = 'Pork Meat', description = 'Butchered pork meat ready for cooking or selling.', weight = 358 },
    ['pork_packing'] = { label = 'Packaged pork', description = 'Packaged pork products. Ready for distribution.', weight = 163 },

    -- hunting job
    ['deer_meat'] = { label = 'Deer Meat', description = 'Fresh deer meat, ready to be cooked or sold.', weight = 682 },
    ['deer_skin'] = { label = 'Deer Skin', description = 'Tanned deer skin, used for crafting and clothing.', weight = 261 },

    -- chicken farm
    ['chicken']      = { label = 'Chicken', description = 'A fresh chicken from the farm.', weight = 871 },
    ['chicken_meat'] = { label = 'Chicken Meat', description = 'Freshly cut chicken meat, ready for packing.', weight = 404 },
    ['chicken_eggs'] = { label = 'Chicken Eggs', description = 'Fresh eggs collected from the chickens.', weight = 15 },
    ['pack_chicken'] = { label = 'Packaged chicken', description = 'Ready to sell pack of chicken meat.', weight = 203 },

    -- coral & marine items
    ['antipatharia_coral'] = { label = 'Antipatharia', description = 'Black coral specimen. Rare and valuable.', weight = 1000 },
    ['dendrogyra_coral']   = { label = 'Dendrogyra', description = 'Pillar coral specimen. Protected and highly prized.', weight = 1000 },

    -- metals & materials
    ['steel']      = { label = 'Steel', description = 'A robust metal alloy. Essential for crafting and construction.', weight = 100 },
    ['rubber']     = { label = 'Rubber', description = 'Natural or synthetic rubber. Used in various manufacturing processes.', weight = 100 },
    ['metalscrap'] = { label = 'Metal Scrap', description = 'Assorted scrap metal. Can be recycled and repurposed.', weight = 100 },
    ['iron']       = { label = 'Iron', description = 'Base metal. Widely used in manufacturing and construction.', weight = 100 },
    ['copper']     = { label = 'Copper', description = 'Versatile metal. Excellent conductor of electricity.', weight = 100 },
    ['aluminum']   = { label = 'Aluminium', description = 'Lightweight and durable metal. Perfect for various applications.', weight = 100 },
    ['plastic']    = { label = 'Plastic', description = 'Versatile polymer material. Used in countless products.', weight = 100 },
    ['glass']      = { label = 'Glass', description = 'Transparent material. Used in windows, containers, and lenses.', weight = 100 },

    -- fireworks
    ['firework1'] = { label = '2Brothers', description = 'A spectacular firework display. Burns bright and loud.', weight = 1000 },
    ['firework2'] = { label = 'Poppelers', description = 'Colorful popping fireworks. Fun for celebrations.', weight = 1000 },
    ['firework3'] = { label = 'WipeOut', description = 'Intense fireworks show. A crowd favorite.', weight = 1000 },
    ['firework4'] = { label = 'Weeping Willow', description = 'Beautiful weeping willow pattern firework. A mesmerizing display.', weight = 1000 },

    -- ammo boxes
    ['ammo-9-box']       = { label = '9mm Ammo Box', description = 'A sealed box containing 50 rounds of 9mm ammunition', weight = 500, stack = true, close = true, client = { image = 'ammo-9-box.png', usetime = 2500 }, server = { export = 'morph_modules.ammobox' }, metadata = { ammo_count = 50 } },
    ['ammo-45-box']      = { label = '.45 ACP Ammo Box', description = 'A sealed box containing 50 rounds of .45 ACP ammunition', weight = 550, stack = true, close = true, client = { image = 'ammo-45-box.png', usetime = 2500 }, server = { export = 'morph_modules.ammobox' }, metadata = { ammo_count = 50 } },
    ['ammo-rifle-box']   = { label = 'Rifle Ammo Box', description = 'A sealed box containing 50 rounds of rifle ammunition', weight = 600, stack = true, close = true, client = { image = 'ammo-rifle-box.png', usetime = 2500 }, server = { export = 'morph_modules.ammobox' }, metadata = { ammo_count = 50 } },
    ['ammo-rifle2-box']  = { label = 'Advanced Rifle Ammo Box', description = 'A sealed box containing 50 rounds of advanced rifle ammunition', weight = 620, stack = true, close = true, client = { image = 'ammo-rifle2-box.png', usetime = 2500 }, server = { export = 'morph_modules.ammobox' }, metadata = { ammo_count = 50 } },
    ['ammo-shotgun-box'] = { label = 'Shotgun Shell Box', description = 'A sealed box containing 25 shotgun shells', weight = 700, stack = true, close = true, client = { image = 'ammo-shotgun-box.png', usetime = 2500 }, server = { export = 'morph_modules.ammobox' }, metadata = { ammo_count = 25 } },
    ['ammo-sniper-box']  = { label = 'Sniper Ammo Box', description = 'A sealed box containing 25 rounds of sniper ammunition', weight = 800, stack = true, close = true, client = { image = 'ammo-sniper-box.png', usetime = 2500 }, server = { export = 'morph_modules.ammobox' }, metadata = { ammo_count = 25 } },
    ['ammo-22-box']      = { label = '.22 LR Ammo Box', description = 'A sealed box containing 100 rounds of .22 LR ammunition', weight = 300, stack = true, close = true, client = { image = 'ammo-22-box.png', usetime = 2500 }, server = { export = 'morph_modules.ammobox' }, metadata = { ammo_count = 100 } },
    ['ammo-50-box']      = { label = '.50 Cal Ammo Box', description = 'A sealed box containing 20 rounds of .50 caliber ammunition', weight = 1000, stack = true, close = true, client = { image = 'ammo-50-box.png', usetime = 2500 }, server = { export = 'morph_modules.ammobox' }, metadata = { ammo_count = 20 } },

    -- miscellaneous
    ['garbage'] = { label = 'Garbage', description = 'Miscellaneous waste and discarded items.', weight = 0 },
    ['panties'] = {
        label = 'Knickers', description = 'A pair of intimate apparel. Why is this in your inventory?', weight = 10, consume = 0,
        client = { status = { thirst = -100000, stress = -25000 }, anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' }, prop = { model = `prop_cs_panties_02`, pos = vec3(0.03, 0.0, 0.02), rot = vec3(0.0, -13.5, -1.5) }, usetime = 2500 }
    },
    ['parachute'] = { label = 'Parachute', description = 'A deployed parachute. Essential for safe landings from high altitudes.', weight = 8000, stack = false, client = { anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' }, usetime = 1500 } },

    ['clothing']     = { label = 'Clothing', description = 'Various clothing items for personal use or trade.', consume = 0 },
    ['money']        = { label = 'Money', description = 'Cash money. The universal currency.', weight = 0 },
    ['black_money']  = { label = 'Dirty Money', description = 'Illegitimate funds. Needs to be laundered before use.', weight = 0 },
    ['markedbills']  = { label = 'Marked Bills', description = 'Tracer-marked bills. Used for stings and investigations.', weight = 0, stack = true, close = true },
    ['trash']        = { label = 'Trash', description = 'Assorted garbage and discarded items.', weight = 70 },
    ['trash_can']    = { label = 'Trash Can', description = 'A container full of trash. Perfect for rummaging.', weight = 67 },
    ['empty_can']    = { label = 'Empty Can', description = 'An empty beverage can. Recyclable.', weight = 500 },
    ['empty_bottle'] = { label = 'Empty Bottle', description = 'An empty glass bottle. Can be recycled or repurposed.', weight = 30 },
    ['paper']        = { label = 'Paper', description = 'A blank sheet of paper. Useful for writing notes.', weight = 15 },
    ['trash_bread']  = { label = 'Trash Bread', description = 'Discarded bread. Probably not safe to eat.', weight = 58 },
    ['trash_burger'] = { label = 'Trash Burger', description = 'A discarded burger. Definitely not safe to eat.', weight = 75 },
    ['trash_chips']  = { label = 'Trash Chips', description = 'Discarded potato chips. Probably stale.', weight = 500 },
    ['stickynote']   = { label = 'Sticky Note', description = 'A sticky note for quick reminders and messages.', weight = 0 }
}