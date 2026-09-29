Config = {}
Config.Debug = true
Config.Currency = '$'
Config.PricePerMinute = 5
Config.MinMinutes = 1
Config.MaxMinutes = 15
Config.BikeModel = 'scorcher'
Config.RentalRadius = 2.0
Config.DepositPercent = 0.3
Config.RentalLocations = { vector3(-778.39, -1277.08, 5.15), vector3(1540.94, 3783.7, 34.21), vector3(-275.73, 6639.33, 7.51) }
Config.Target = {
    { Coords = vector3(-778.39, -1277.08, 5.15), Size = vec3(2, 2, 2), Heading = 0, Label = 'Port Authority' },
    { Coords = vector3(1540.94, 3783.7, 34.21), Size = vec3(2, 2, 2), Heading = 0, Label = 'Sandy Shores Rental' },
    { Coords = vector3(-275.73, 6639.33, 7.51), Size = vec3(2, 2, 2), Heading = 0, Label = 'Paleto Bay Rental' }
}
Config.SpawnLocations = {
    vector4(-779.24, -1280.42, 5.0, 171.73),
    vector4(1542.47, 3780.75, 34.05, 210.1),
    vector4(-274.23, 6635.8, 7.4, 225.77)
}
Config.UI = { Image = 'https://docs.fivem.net/vehicles/scorcher.webp' }
Config.DiscordWebhook = "https://discord.com/api/webhooks/1521613177295732827/8pqZPh7EVBr3RTGI-h_nUSZ_JVHf24_RyOExqszPzXjQIMW0A61J4Hd5syvfiHkSTmWQ" -- Isi dengan webhook URL jika ingin log ke Discord