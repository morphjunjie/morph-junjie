fx_version 'cerulean'
game 'gta5'

description 'morph_vehicles'
repository 'https://github.com/Qbox-project/morph_vehicles'
version '1.4.2'

server_scripts {
    '@morph_ui/init.lua',
    '@morph_junjie/modules/lib.lua',
    '@morph_db/lib/MySQL.lua',
    'server/main.lua',
}

server_only 'yes'
lua54 'yes'
use_experimental_fxv2_oal 'yes'
