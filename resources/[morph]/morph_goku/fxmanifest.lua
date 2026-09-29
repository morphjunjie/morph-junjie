fx_version 'cerulean'
game 'gta5'

description 'morph_goku'
repository 'https://github.com/Qbox-project/morph_goku'
version '0.1.0'

morph_ui 'locale'

shared_scripts {
    '@morph_ui/init.lua',
    '@morph_junjie/modules/lib.lua',
}

server_scripts {
    '@morph_db/lib/MySQL.lua',
    'server/*.lua',
}

client_scripts {
    'client/*.lua',
}

files {
    'locales/*.json',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
