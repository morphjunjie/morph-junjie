fx_version 'cerulean'
game 'gta5'

description 'morph_rdmenu'
repository 'https://github.com/Qbox-project/morph_rdmenu'
version '0.1.0'
morph_ui 'locale'


shared_scripts {
    '@morph_ui/init.lua',
    '@morph_junjie/modules/lib.lua',
}

client_scripts {
    '@morph_junjie/modules/playerdata.lua',
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
}

files {
    'config/client.lua',
    'locales/*.json',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
