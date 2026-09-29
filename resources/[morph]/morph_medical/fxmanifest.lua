fx_version 'cerulean'
game 'gta5'

description 'morph_medical'
repository 'https://github.com/Qbox-project/morph_medical'
version '1.0.0'

morph_ui 'locale'

shared_scripts {
    '@morph_ui/init.lua',
    'shared/**/*.lua',
}

client_scripts {
    '@morph_junjie/modules/playerdata.lua',
    'client/damage/apply-damage-effects.lua',
    'client/damage/damage.lua',
    'client/dead.lua',
    'client/laststand.lua',
    'client/load-unload.lua',
    'client/main.lua',
    'client/setdownedstate.lua',
    'client/wounding.lua',
}

server_scripts {
    'server/main.lua',
}

files {
    'locales/*.json',
    'config/client.lua',
    'config/shared.lua',
}

dependencies {
    'morph_ui',
    'morph_junjie',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
