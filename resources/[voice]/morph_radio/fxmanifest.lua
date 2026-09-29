fx_version 'cerulean'
game 'gta5'

author 'Master Mind'
version '0.2.1'
description 'A beautiful Radio Resource for FiveM'
repository 'https://github.com/SOH69/morph_radio'

lua54 'yes'

ui_page 'build/index.html'
-- ui_page 'http://localhost:3000/' --for dev

shared_script {
    '@morph_ui/init.lua',
    'shared/**'
}

client_script {
    '@morph_junjie/modules/playerdata.lua',
    'client/interface.lua',
    'client/function.lua',
    'client/event.lua',
    'client/nui.lua'
}

server_script {
    'server/main.lua',
}

files {
    'build/**',
    'locales/*.json'
}

dependencies {
    'morph_voice',
    'morph_ui',
    '/onesync'
}
