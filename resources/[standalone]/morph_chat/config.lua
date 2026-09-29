Config = {}

-- Framework for the role tags (job based). 'auto', 'esx', 'qb', 'qbox' or 'standalone'.
-- Standalone still gives tags by ACE group (see Config.Tags).
Config.Framework = 'auto'

-- UI language: 'en' or 'es'.
Config.Locale = 'en'

-- Key to open the chat. Players can rebind it in FiveM settings (Key Bindings).
Config.OpenKey = 'T'

-- Where the chat sits. 'top-left', 'top-right' or 'bottom-left'.
Config.Position = 'top-left'

-- The chat fades out after this many ms of no activity, and comes back on a new
-- message or when you open it.
Config.FadeDelay = 12000

-- How many messages are kept in the log (older ones drop off).
Config.MaxMessages = 60

-- Show a small timestamp on each message.
Config.Timestamps = true

-- Cute synthesised sounds (message / mention). Players can also mute it themselves.
Config.Sounds = true

-- Default colour for a name with no role tag.
Config.DefaultNameColor = '#f6eae6'

-- Role tags. Key is a framework job name OR an ACE group (add_ace group.admin ...).
-- The tag shows as a coloured pill next to the name, and the name takes its colour.
Config.Tags = {
    ['admin']     = { label = 'ADMIN',    color = '#d9738f', ace = 'morph_chat.admin' },
    ['mod']       = { label = 'MOD',      color = '#f4d778', ace = 'morph_chat.mod' },
    ['police']    = { label = 'POLICE',   color = '#77c9e6' },
    ['ambulance'] = { label = 'EMS',      color = '#8fd6a4' },
    ['mechanic']  = { label = 'MECHANIC', color = '#8fd6a4' },
    ['taxi']      = { label = 'TAXI',     color = '#f4b06a' },
}

-- Roleplay message types. proximity is the range in metres a message reaches
-- (0 = whole server). /report always goes to staff only.
Config.Types = {
    me     = { proximity = 20.0 },
    ['do'] = { proximity = 20.0 },
    ooc    = { proximity = 0.0 },
    ad     = { proximity = 0.0 },
    report = { proximity = 0.0, staffAce = 'morph_chat.staff' },
    dm     = { proximity = 0.0 },
}

-- Floating /me and /do text above the player's head.
Config.HeadText = {
    enabled  = true,
    range    = 20.0,   -- who can see it, in metres
    duration = 8000,   -- how long it stays, in ms
    height   = 0.35,   -- how far above the head bone it floats. Lower = closer to the head.
}

-- Anti-spam: minimum ms between two messages from the same player. The
-- 'morph_chat.staff' ace bypasses it.
Config.AntiSpam = {
    enabled  = true,
    cooldown = 700,
}

-- Emoji picker. Add or remove freely.
Config.Emojis = {
    '🌸', '✿', '💖', '❤️', '✨', '🥺', '😊', '😳', '😢', '🙈',
    '🔥', '👍', '😂', '🎉', '⭐', '😎', '💅', '🤍', '👀', '💫',
}
