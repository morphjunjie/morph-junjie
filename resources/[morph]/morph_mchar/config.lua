Config = {}

Config.Debug = false
Config.Lang = 'en'
Config.PerformanceMode = false
Config.CleanZone = false
Config.HideRadar = false

Config.Logs = {
    Status = false,
    Logger = 'discord'
}

Config.DeleteButton = true
Config.DefaultSlots = 1
Config.NewPlayerNoApartmentStartCoords = vector4(-1037.74, -2737.87, 20.17, 329.41)

Config.NoSpawnMenuOnlyLastLocation = {
    Status = false,
    gtaVNativeAndCutScene = false,
}

Config.StarterItems = {
    { item = 'burger', amount = 10 },
    { item = 'water', amount = 10 },
    { item = 'phone_black', amount = 1 },
}

Config.CustomHud = function(bool)
    if bool then
        Debug('Hud hidden', 'debug')
    else
        Debug('Hud shown', 'debug')
    end
end

Config.Dob = {
    Lowest = 1900,
    Highest = 2006,
    Notify = {
        invalid = 'Invalid date of birth %s',
        exploit = 'Special character detected %s'
    }
}

Config.CinematicMode = false

Config.BackgroundMusic = {
    Status = true,
    Name = 'bgmusic.mp3',
    Volume = 0.2
}

Config.Pages = {
    Credits = {
        Status = false,
        List = Credits.List
    },
    Store = {
        Status = false,
        URL = 'https://cr5m.com'
    }
}

Config.Coords = {
    Single = Coords.List[5],
    Random = true
}

Config.Effects = {
    Status = true,
    Single = Effect.List[6],
    Random = true
}

Config.Animation = {
    Status = true,
    Single = Animation.List[1],
    Random = true,
    Scenario = {
        Status = false,
        Single = Animation.ScenarioList[2],
        Random = false
    }
}

Config.TimeSettings = {
    SyncStatus = false,
    Time = 21,
    Weather = 'CLEAR'
}

Config.Speech = {
    Status = false,
    Volume = 1,
    Rate = 2,
    Pitch = 0,
    Texts = {
        "Hello [name], how are you today?",
        "I love you [name], maybe you've never heard that before"
    }
}

Config.NewPlayerNoApartmentStartClothingUI = 'qb-clothes:client:CreateFirstCharacter'