fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'morph_chat'
author 'Jaramiyo'
version '1.0.0'
description 'Cute cacao + rose chat for FiveM by Jaramiyo (RP types, role tags, 3D /me /do, emojis)'

shared_scripts {
    'config.lua',
    'locales/*.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'html/fonts/*.ttf',
}
