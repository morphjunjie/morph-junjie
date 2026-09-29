fx_version 'cerulean'
game 'gta5'
version '2.1.4'

description 'Renewed Banking'
Author "uShifty#1733"
version '2.1.4'

lua54 'yes'

shared_scripts {
    '@morph_ui/init.lua',
    'config.lua',
}

client_scripts {
    'client/framework.lua',
    'client/main.lua',
    'client/menus.lua',
}

server_scripts {
    '@morph_db/lib/MySQL.lua',
    'server/framework.lua',
    'server/main.lua'
}

ui_page 'web/public/index.html'

files {
  'web/public/index.html',
  'web/public/**/*',
  'locales/*.json'
}

provide 'qb-management'
provide 'esx_society'
