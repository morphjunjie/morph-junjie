fx_version 'cerulean'
game 'gta5'

author '`Stressy'
description 'Stressy Billing System'
version '1.0.0'

shared_scripts {
    '@morph_ui/init.lua',
    'shared/*.lua',
    '@morph_junjie/modules/lib.lua',
}

server_scripts {
    'bridge/sv_bridge.lua',
    'server/*.lua',
    '@morph_db/lib/MySQL.lua',
}

client_scripts {
    'bridge/cl_bridge.lua',
    'client/*.lua',
    '@morph_junjie/modules/playerdata.lua',
}

lua54 'yes'