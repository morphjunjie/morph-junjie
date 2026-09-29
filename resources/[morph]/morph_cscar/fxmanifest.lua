fx_version 'cerulean'
game 'gta5'

author 'Jorn#0008'
description 'morph_cscar'
repository 'https://github.com/Qbox-project/morph_cscar'
version '0.1.0'

morph_ui 'locale'

shared_script '@morph_ui/init.lua'

client_scripts {
    '@morph_junjie/modules/playerdata.lua',
    '@morph_junjie/modules/lib.lua',
    'client/utils.lua',
    'client/menus/main.lua',
    'client/zones.lua',
}

server_scripts {
    '@morph_db/lib/MySQL.lua',
    'server/main.lua'
}

files {
    'locales/*.json',
    'config/*.lua',
    'client/**/*.lua',
    'carcols_gen9.meta',
    'carmodcols_gen9.meta',
}

data_file 'CARCOLS_GEN9_FILE' 'carcols_gen9.meta'
data_file 'CARMODCOLS_GEN9_FILE' 'carmodcols_gen9.meta'

lua54 'yes'
use_experimental_fxv2_oal 'yes'
