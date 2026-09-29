Config = Config or {}

----------------------------------------------------------------------------------------------------
-- # BACKGROUND SECTION # --
----------------------------------------------------------------------------------------------------
-- Allows you to set the preferred background Color from a list of available options.
Config.Background = "background_pink" -- Default: background_red

-- Available Options --
-- background_blue
-- background_darkblue
-- background_darkerblue
-- background_darkgreen
-- background_green
-- background_other
-- background_pink
-- background_projectsloth
-- background_red
-- background_yellow

-- Allows you to change the opacity of the Background
Config.Opacity = 25

----------------------------------------------------------------------------------------------------
-- # HEADER and OPTIONS SECTION # --
----------------------------------------------------------------------------------------------------

Config.Header = {
    -- LEFT MENU CONFIG
    ["TITLE"] = "~p~MORPH ARCADIA DREAM DISTRICT",
    ["SUBTITLE"] = "This little Script was made by M.A.D. District <3",

    ["MAP"] = "Map Morph",
    ["GAME"] = "Exit Game",
    ["LEAVE"] = "Return to Server List",
    ["QUIT"] = "Return to Desktop",
    ["INFO"] = "Information",
    ["STATS"] = "Statistics",
    ["SETTINGS"] = "Morph Settings",
    ["GALLERY"] = "Gallery Morph",
    ["KEYBIND"] = "Morph Keybinds",
    ["EDITOR"] = "Morph Editor",

    -- RIGHT MENU CONFIG
    ["SERVER_NAME"] = "~p~MORPH ARCADIA DREAM DISTRICT",
    ["SERVER_TEXT"] = "~p~Where the Neon Never Sleeps.",
    ["SERVER_DISCORD"] = "~p~https://discord.gg/muvdUGg7dP",
}

--Allows you to Change the Colour ( Use this Website: https://rgbacolorpicker.com/ )
Config.RGBA = {
    LINE = { -- Line over the Options (Royal Purple)
        ["RED"] = 124,
        ["GREEN"] = 77,
        ["BLUE"] = 255,
        ["ALPHA"] = 255,
    },
    STYLE = { -- Pause Menu Options (Royal Purple)
        ["RED"] = 124,
        ["GREEN"] = 77,
        ["BLUE"] = 255,
        ["ALPHA"] = 200,
    },
    WAYPOINT = { -- Waypoint (Royal Purple Bright Accent)
        ["RED"] = 179,
        ["GREEN"] = 136,
        ["BLUE"] = 255,
        ["ALPHA"] = 255,
    },
}