fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'

name 'morph_fuel'
author 'Overextended'
version '1.5.4'
repository 'https://github.com/overextended/morph_fuel'
description 'Fuel management system with morph_inv support'

dependencies {
	'morph_ui',
	'morph_inv',
}

shared_scripts {
	'@morph_ui/init.lua',
	'config.lua'
}

server_scripts {
	'server.lua'
}

client_script 'client/init.lua'

files {
	'locales/*.json',
	'data/stations.lua',
	'client/*.lua',
}

morph_uis {
	'math',
	'locale',
}
