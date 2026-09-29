return {
	{
        name = 'debug_crafting',
        label = 'Open Crafting', -- Untuk debug
		items = {
			{
				name = 'lockpick',
				ingredients = {
					scrapmetal = 5,
					WEAPON_HAMMER = 0.05
				},
				duration = 5000,
				count = 2,
			},
		},
		points = {
			vec3(-1147.083008, -2002.662109, 13.180260),
			vec3(-345.374969, -130.687088, 39.009613)
		},
		zones = {
			{
				coords = vec3(-1146.2, -2002.05, 13.2),
				size = vec3(3.8, 1.05, 0.15),
				distance = 1.5,
				rotation = 315.0,
			},
			{
				coords = vec3(-346.1, -130.45, 39.0),
				size = vec3(3.8, 1.05, 0.15),
				distance = 1.5,
				rotation = 70.0,
			},
		},
	},
	{
        name = 'process_meth',
        label = 'Open Crafting Meth',
		items = {
			{
				name = 'meth',
				ingredients = {
					chemical = 4,
					meth_crystal = 6,
					ammonia = 3,
				},
				duration = 27000,
				count = 8,
			},
			{
				name = 'meth_bag',
				ingredients = {
					meth = 8,
					bag_empty = 1,
					sodium = 3,
				},
				duration = 28000,
				count = 3,
			},
		},
		points = {
			vec3(2431.79, 4972.54, 42.74),
		},
		zones = {
			{
				coords = vec3(2431.79, 4972.54, 42.74),
				size = vec3(3.0, 3.0, 3.0),
				distance = 1.5,
			},
		},
	},
	{
        name = 'process_weed',
        label = 'Open Crafting Weed',
		items = {
			{
				name = 'weed',
				ingredients = {
					weed_leaf = 10,
				},
				duration = 13000,
				count = 20,
			},
			{
				name = 'weed_bag',
				ingredients = {
					weed = 25,
					bag_empty = 1,
				},
				duration = 15000,
				count = 6,
			},
		},
		points = {
			vec3(1197.61, -3114.49, 6.06),
		},
		zones = {
			{
				coords = vec3(1197.61, -3114.49, 6.06),
				size = vec3(2.0, 2.0, 2.0),
				distance = 1.5,
			},
		},
	},
	{
        name = 'process_cocaine',
        label = 'Open Crafting Cocaine',
		items = {
			{
				name = 'cocaine_powder',
				ingredients = {
					cocaine_leaf = 10,
				},
				duration = 16000,
				count = 20,
			},
			{
				name = 'cocaine',
				ingredients = {
					cocaine_powder = 15,
					sodium = 5,
				},
				duration = 18000,
				count = 20,
			},
			{
				name = 'cocaine_bag',
				ingredients = {
					cocaine = 25,
					bag_empty = 1,
				},
				duration = 23000,
				count = 5,
			},
		},
		points = {
			vec3(1086.2, -3197.19, -38.63),
		},
		zones = {
			{
				coords = vec3(1086.2, -3197.19, -38.63),
				size = vec3(2.5, 2.5, 2.5),
				distance = 1.5,
			},
		},
	},
	{
        name = 'process_crack',
        label = 'Open Crafting Crack',
		items = {
			{
				name = 'crack_bag',
				ingredients = {
					meth = 10,
					cocaine = 10,
					weed = 10,
					bag_empty = 2,
					sodium = 5,
					chemical = 3,
				},
				duration = 35000,
				count = 4,
			},
		},
		points = {
			vec3(1094.95, -3195.72, -38.92),
		},
		zones = {
			{
				coords = vec3(1094.95, -3195.72, -38.92),
				size = vec3(2.5, 2.5, 2.5),
				distance = 1.5,
			},
		},
	},
}