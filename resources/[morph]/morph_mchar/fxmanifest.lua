fx_version 'cerulean'
game 'gta5'

name "morph_mchar"
author "cr leaks"
version "4.5.6"
description "cr - Multi Character"

ui_page 'web/build/index.html'

files {
	'web/build/index.html',
	'web/build/**',
	'locales/*.lua',
}

shared_scripts {
	'@morph_ui/init.lua',
	'list/*.lua',
	'config.lua',
	'bridge/framework.lua',
}

client_scripts {
	'bridge/clothingexports.lua',
	'client/*.lua',
}

server_scripts {
	'@morph_db/lib/MySQL.lua',
	'server/**',
	'bridge/spawn.lua',
	'bridge/getskin.lua',
}


dependencies {
	'/server:7290',
	'morph_ui',
	'/onesync'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'

