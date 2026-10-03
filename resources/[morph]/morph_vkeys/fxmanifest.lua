fx_version 'cerulean'
game 'gta5'

description 'vehicle key management system'
repository 'https://github.com/Qbox-project/morph_vkeys'
version '1.0.3'

morph_ui 'locale'

shared_scripts {
    '@morph_ui/init.lua',
    '@morph_junjie/modules/lib.lua',
    'shared/types.lua',
    'shared/vehicle-config.lua',
    'bridge/qb/shared.lua',
}

client_scripts {
    '@morph_junjie/modules/playerdata.lua',
    'client/functions.lua',
    'client/searchkeys.lua',
    'client/keyfob.lua',
    'client/main.lua',
    'client/autolock.lua',
    'client/carjack.lua',
    'bridge/qb/client.lua',
}

server_scripts {
    '@morph_db/lib/MySQL.lua',
    'server/version.lua',
    'server/keys.lua',
    'server/main.lua',
    'server/commands.lua',
    'bridge/qb/server.lua',
}

files {
    'locales/*.json',
    'config/client.lua',
    'config/shared.lua'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
provide 'qb-vehiclekeys'
