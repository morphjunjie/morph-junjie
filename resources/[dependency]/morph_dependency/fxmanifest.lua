fx_version 'cerulean'
game 'gta5'

name 'M.A.D. District'
description 'Morph Dependency'
version '9.9.9'

ui_page '**/html/index.html'

morph_ui 'locale'

shared_scripts {
    '@morph_ui/init.lua',
    '@morph_junjie/modules/lib.lua',
    '**/config.lua',
}

server_scripts {
    '@morph_db/lib/MySQL.lua',
    '**/bridge/server/**.lua',
    '**/server.lua',
    '**/sv_dropped.lua',
    '**/sv_config.lua',
    '**/sv_pizzajob.lua',
    '**/server/*.lua'
}

client_scripts {
    '@morph_junjie/modules/playerdata.lua',
    '@morph_zone/client.lua',
    '@morph_zone/ComboZone.lua',
    '**/bridge/client/**.lua',
    '**/client/*.lua',
    '**/cl_pizzajob.lua',
    '**/cl_dropped.lua',
    '**/client.lua'
}

files {
    'locales/*.json'
}

dependencies {
    '/onesync',
    'morph_ui',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'