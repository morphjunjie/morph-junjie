NewConfig = {}

NewConfig.Zones = {
    { coords = vector4(-1034.58, -2732.28, 20.17, 148.17) }
}

NewConfig.StarterVehicles = {
    {
        label = 'Karin Asterope',
        type = 'Sedan',
        seats = '4 Seats',
        speed = '145 KMH',
        model = 'asterope',
        image = 'https://docs.fivem.net/vehicles/asterope.webp',
        description = 'Comfortable, fuel-efficient sedan, great for everyday city driving.',
    },
    {
        label = 'Annis Hellion',
        type = 'Off-Road',
        seats = '2 Seats',
        speed = '145 KMH',
        model = 'hellion',
        image = 'https://docs.fivem.net/vehicles/hellion.webp',
        description = 'Off-road vehicle built for players who like extreme terrain.',
        recommended = true,
    },
    {
        label = 'Dinka Blista',
        type = 'Compact',
        seats = '2 Seats',
        speed = '140 KMH',
        model = 'blista',
        image = 'https://docs.fivem.net/vehicles/blista.webp',
        description = 'Agile hatchback, easy to maneuver in tight city traffic.',
    }
}

NewConfig.DefaultGarage = 'airportgarage'
NewConfig.EnableTeleport = true -- true = teleport player to garage after claiming

NewConfig.GarageTeleport = {
    airportgarage = vector4(-1041.43, -2663.18, 13.83, 40.76)
}