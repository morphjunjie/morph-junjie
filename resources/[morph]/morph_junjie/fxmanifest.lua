fx_version 'cerulean'
game 'gta5'

name 'morph_junjie'
description 'The core resource for the Qbox Framework'
repository 'https://github.com/Qbox-project/morph_junjie'
version '1.23.0'

morph_ui 'locale'

shared_scripts {
    '@morph_ui/init.lua',
    'modules/lib.lua',
    'shared/locale.lua',
    'shared/functions.lua',
}

client_scripts {
    'client/main.lua',
    'client/groups.lua',
    'client/functions.lua',
    'client/loops.lua',
    'client/events.lua',
    'client/character.lua',
    'client/discord.lua',
    'client/vehicle-persistence.lua',
    'bridge/qb/client/main.lua',
}

server_scripts {
    '@morph_db/lib/MySQL.lua',
    'server/motd.lua',
    'server/main.lua',
    'server/groups.lua',
    'server/functions.lua',
    'server/player.lua',
    'server/events.lua',
    'server/commands.lua',
    'server/loops.lua',
    'server/character.lua',
    'server/vehicle-persistence.lua',
    'bridge/qb/server/main.lua',
}

files {
    'modules/*.lua',
    'data/*.lua',
    'shared/gangs.lua',
    'shared/items.lua',
    'shared/jobs.lua',
    'shared/locations.lua',
    'shared/main.lua',
    'shared/vehicles.lua',
    'shared/weapons.lua',
    'bridge/qb/client/functions.lua',
    'bridge/qb/client/drawtext.lua',
    'bridge/qb/client/events.lua',
    'bridge/qb/shared/main.lua',
    'bridge/qb/shared/export-function.lua',
    'config/client.lua',
    'config/shared.lua',
    'locales/*.json'
}

dependencies {
    '/server:10731',
    '/onesync',
    'morph_ui',
    'morph_db',
}

provide 'qb-core'
lua54 'yes'
use_experimental_fxv2_oal 'yes'