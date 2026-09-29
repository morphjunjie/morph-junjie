fx_version 'cerulean'
game 'gta5'

author 'Bob_74'
description 'Load and customize your map'
version '2.6.0'

lua54 "yes"

client_scripts {
    -- Core files
    "lib/common.lua",
    "lib/observers/*.lua",
    "client.lua",

    -- GTA V
    "gtav/*.lua",

    -- GTA Online
    "gta_online/*.lua",

    -- DLC High Life
    "dlc_high_life/*.lua",

    -- DLC Heists
    "dlc_heists/*.lua",

    -- DLC Executives & Other Criminals
    "dlc_executive/*.lua",

    -- DLC Finance & Felony
    "dlc_finance/*.lua",

    -- DLC Bikers
    "dlc_bikers/*.lua",

    -- DLC Import/Export
    "dlc_import/*.lua",

    -- DLC Gunrunning
    "dlc_gunrunning/*.lua",

    -- DLC Smuggler's Run
    "dlc_smuggler/*.lua",

    -- DLC Doomsday Heist
    "dlc_doomsday/*.lua",

    -- DLC After Hours
    "dlc_afterhours/*.lua",

    -- DLC Diamond Casino
    "dlc_casino/*.lua",

    -- DLC Cayo Perico Heist
    "dlc_cayoperico/*.lua",

    -- DLC Tuners
    "dlc_tuner/*.lua",

    -- DLC The Contract
    "dlc_security/*.lua",

    -- DLC The Criminal Enterprises
    "gta_mpsum2/*.lua",

    -- DLC Los Santos Drug Wars
    "dlc_drugwars/*.lua",

    -- DLC San Andreas Mercenaries
    "dlc_mercenaries/*.lua",

    -- DLC The Chop Shop
    "dlc_chopshop/*.lua",

    -- DLC Bottom Dollar Bounties
    "dlc_bounties/*.lua",

    -- DLC Agents of Sabotage
    "dlc_agents/*.lua",

    -- DLC Money Fronts
    "dlc_money/*.lua",

    -- DLC A Safehouse in the Hills
    "dlc_mansions/*.lua"
}