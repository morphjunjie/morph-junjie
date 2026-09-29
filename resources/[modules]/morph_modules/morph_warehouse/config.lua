return {
    Currency = '$',

    -- Locations where the "Open Storage" target is available.
    -- All locations lead to the same personal storage per player.
    Locations = {
        { label = 'Los Santos', coords = vec3(1159.2, -1642.72, 37.98) },
        { label = 'Sandy Shores', coords = vec3(903.18, 3585.69, 34.37) },
        { label = 'Paleto Bay', coords = vec3(147.32, 6366.97, 32.52) },
    },

    TargetDistance = 2.0,
    TargetSize = vec3(1.5, 1.5, 2.0),

    DailyPrice = 300,
    MaxDays = 30,
    StorageSlots = 50,
    StorageWeight = 500000, -- grams

    -- Items that cannot be deposited into or withdrawn from the storage.
    -- Set to true to blacklist.
    Blacklist = {
        black_money = true,
        markedbills = true,
        money = true,
    },

    -- Leave empty to disable Discord logging
    DiscordWebhook = "https://discord.com/api/webhooks/1543409825982185482/sQD15W54jpGmw0thzt9_NIHxEGVKKMGMnl2SSwGNu5YR8wDGIwVChPii3DcEIHsR8ZW2",
    DiscordUsername = "M.A.D. District",

    DateFormat = '%d/%m/%Y %H:%M',
}