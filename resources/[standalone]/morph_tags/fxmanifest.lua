fx_version 'cerulean'
game 'gta5'

name 'morph_tags'
author 'Jaramiyo'
description 'Persistent player tags for Qbox, QBCore and ESX.'
version '1.1.0'

shared_scripts {
    'config.lua',
    'locales/*.lua',
    'shared/bridge.lua',
}

server_scripts {
    '@morph_db/lib/MySQL.lua',
    'server/main.lua',
}

client_scripts {
    'client/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'html/assets/*',
    'html/assets/tag-backgrounds/*',
    'html/fonts/*',
}

dependency 'morph_db'
