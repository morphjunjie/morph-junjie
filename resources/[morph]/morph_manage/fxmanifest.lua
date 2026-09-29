fx_version 'cerulean'
game 'gta5'

description 'morph_manage'
repository 'https://github.com/Qbox-project/morph_manage'
version '1.4.0'

morph_ui 'locale'

shared_scripts {
    '@morph_ui/init.lua',
}

client_scripts {
    '@morph_junjie/modules/playerdata.lua',
    'client/main.lua',
}

server_scripts {
    '@morph_db/lib/MySQL.lua',
    'server/main.lua',
}

files {
    'config/client.lua',
    'locales/*.json',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'