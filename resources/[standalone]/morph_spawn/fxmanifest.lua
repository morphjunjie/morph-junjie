fx_version 'cerulean'
game 'gta5'

name 'morph_spawn'
description 'Spawn selection for Qbox'
repository 'https://github.com/Qbox-project/morph_spawn'
version '0.1.1'

morph_ui 'locale'

shared_script '@morph_ui/init.lua'

client_script 'client/main.lua'

server_scripts {
    '@morph_db/lib/MySQL.lua',
    'server/main.lua'
}

files {
    'config/client.lua',
    'locales/*.json'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'