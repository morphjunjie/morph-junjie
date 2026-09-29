fx_version 'cerulean'
game 'gta5'

name 'morph_policejob'
description 'Police system for Qbox'
repository 'https://github.com/Qbox-project/morph_policejob'
version '1.0.0'

morph_ui 'locale'

shared_scripts {
    '@morph_ui/init.lua',
    '@morph_junjie/modules/lib.lua'
}

client_scripts {
    '@morph_junjie/modules/playerdata.lua',
    'client/*.lua'
}

server_scripts {
    '@morph_db/lib/MySQL.lua',
    'server/*.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/vue.min.js',
    'html/script.js',
    'html/fingerprint.png',
    'html/main.css',
    'config/client.lua',
    'config/shared.lua',
    'locales/*.json'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'