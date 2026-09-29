fx_version 'cerulean'
game 'gta5'

name 'morph_vshop'
description 'Vehicle shop system for Qbox'
repository 'https://github.com/Qbox-project/morph_vshop'
version '1.0.0'

morph_ui 'locale'

shared_script {
    '@morph_ui/init.lua',
    '@morph_junjie/modules/lib.lua',
}

client_scripts {
    '@morph_junjie/modules/playerdata.lua',
    'client/main.lua',
}

server_scripts {
    '@morph_db/lib/MySQL.lua',
    'server/main.lua',
    'server/utils.lua',
    'server/finance.lua'
}

files {
    'client/vehicles.lua',
    'config/client.lua',
    'config/shared.lua',
    'locales/*.json'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'