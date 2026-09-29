fx_version 'cerulean'
game 'gta5'

name 'morph_garages'
description 'Garage system for Qbox'
repository 'https://github.com/Qbox-project/morph_garages'
version '1.1.4'

morph_ui 'locale'

shared_scripts {
    '@morph_ui/init.lua',
    '@morph_junjie/modules/lib.lua',
    'shared/*',
    '@morph_zone/client.lua',
    '@morph_zone/BoxZone.lua',
    '@morph_zone/CircleZone.lua',

}

client_scripts {
    '@morph_junjie/modules/playerdata.lua',
    'client/main.lua',
}

server_scripts {
    '@morph_db/lib/MySQL.lua',
    'server/default-calculate-impound-fee.lua',
    'server/main.lua',
    'server/spawn-vehicle.lua',
}

files {
    'config/client.lua',
    'locales/*.json',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'