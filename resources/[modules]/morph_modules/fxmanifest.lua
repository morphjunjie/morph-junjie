fx_version 'cerulean'
game 'gta5'

name 'M.A.D. District'
description 'Morph Modules'
version '8.8.8'

morph_ui 'locale'


shared_scripts {
    '@morph_ui/init.lua',
    '@morph_junjie/modules/lib.lua',
    '**/config.lua',
    '**/shared.lua',
    '**/shared/*.lua'
}

server_scripts {
    '@morph_junjie/modules/playerdata.lua',
    '@morph_db/lib/MySQL.lua',
    'morph_courierjob/sv_config.lua',
    'morph_courierjob/bridge/server/**.lua',
    'morph_courierjob/sv_courierjob.lua',
    '**/server.lua',
    '**/bridge/server/**.lua',
    '**/server/*.lua',
    '**/bridge/sv_bridge.lua',
    '**/sv_config.lua', 
}

client_scripts {
    '@morph_junjie/modules/playerdata.lua',
    '@morph_zone/client.lua',
    '@morph_zone/ComboZone.lua',
    'morph_courierjob/bridge/client/**.lua',
    'morph_courierjob/cl_courierjob.lua',
    '**/client/*.lua',
    '**/client.lua',
    '**/bridge/cl_bridge.lua',
    '**/bridge/client/**.lua',
    "morph_ip/lib/common.lua",
    "morph_ip/lib/observers/*.lua",
    "morph_ip/client.lua",
    "morph_ip/gtav/*.lua",
    "morph_ip/gta_online/*.lua",
    "morph_ip/dlc_high_life/*.lua",
    "morph_ip/dlc_heists/*.lua",
    "morph_ip/dlc_executive/*.lua",
    "morph_ip/dlc_finance/*.lua",
    "morph_ip/dlc_bikers/*.lua",
    "morph_ip/dlc_import/*.lua",
    "morph_ip/dlc_gunrunning/*.lua",
    "morph_ip/dlc_smuggler/*.lua",
    "morph_ip/dlc_doomsday/*.lua",
    "morph_ip/dlc_afterhours/*.lua",
    "morph_ip/dlc_casino/*.lua",
    "morph_ip/dlc_cayoperico/*.lua",
    "morph_ip/dlc_tuner/*.lua",
    "morph_ip/dlc_security/*.lua",
    "morph_ip/gta_mpsum2/*.lua",
    "morph_ip/dlc_drugwars/*.lua",
    "morph_ip/dlc_mercenaries/*.lua",
    "morph_ip/dlc_chopshop/*.lua",
    "morph_ip/dlc_bounties/*.lua",
    "morph_ip/dlc_agents/*.lua",
    "morph_ip/dlc_money/*.lua",
    "morph_ip/dlc_mansions/*.lua"
}

files {
    'locales/*.json',
    '**/config/*.lua',
    '**/LockPart1.png',
    '**/LockPart2.png',
}

dependencies {
    '/onesync',
    'morph_ui',
    'morph_sound',
    'morph_junjie'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'