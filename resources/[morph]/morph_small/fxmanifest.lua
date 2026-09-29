fx_version 'cerulean'
game 'gta5'

name 'morph_small'
description 'Collection of small scripts'
repository 'https://github.com/Qbox-project/morph_notify'
version '1.1.2'

morph_ui 'locale'

loadscreen 'morph_load/index.html'
loadscreen_manual_shutdown 'yes'

shared_scripts {
    '@morph_ui/init.lua',
    '@morph_junjie/modules/lib.lua',
    '**/config.lua',
    '**/shared.lua'
}

client_scripts {
    '@morph_junjie/modules/playerdata.lua',
    '@morph_zone/client.lua',
    '@morph_zone/ComboZone.lua',
    '**/client.lua'
}

server_scripts {
    '**/server.lua',
    '@morph_db/lib/MySQL.lua'
}

files {
    'locales/*.json',
    'morph_load/index.html',
    'morph_load/css/style.css',
    'morph_load/song/music.mp3',
    'morph_load/video/video.mp4',
    'morph_vhand/data/progress.lua',
    'morph_vhand/data/vehicle.lua',
    'morph_vhand/modules/handler.lua',
    '**/config.json',
    '**/config.lua'
}

dependencies {
    'morph_ui',
    'morph_sound',
    'morph_junjie'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'