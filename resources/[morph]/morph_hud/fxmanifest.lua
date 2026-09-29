fx_version 'cerulean'
lua54 'yes'
game 'gta5'
name '0r-hud-v3'
author 'M.A.D. District.'
version '1.0.5'
description 'Hud modern by M.A.D. District.'

work_with 'ESX/QB latest version'

shared_scripts {
	'@morph_ui/init.lua',
	'config.lua',
	'shared/init.lua',
}

client_script {
	'client.lua',
	'@morph_zone/client.lua',        -- tambahkan morph_zone
    '@morph_zone/BoxZone.lua',       -- BoxZone untuk kotak
    '@morph_zone/CircleZone.lua',    -- CircleZone kalau dibutu
	'client/main.lua',
}

server_script {
	'server.lua',
	'server/main.lua',
}

ui_page 'ui/build/index.html'

files {
	'data/*.lua',
	'locales/*.json',
	'modules/**/client.lua',
	'modules/bridge/**/client.lua',
	'ui/build/index.html',
	'ui/build/**/*',
}

dependencies { 'morph_ui', 'morph_sound' }