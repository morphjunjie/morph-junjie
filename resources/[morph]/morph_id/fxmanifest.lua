fx_version 'cerulean'
game 'gta5'

name 'morph_id'
author 'uyuyorum {um}'
version '2.2.3'
license 'GPL-3.0 license'
repository 'https://github.com/alp1x/morph_id'
description 'FiveM Identity Card for QBCore and ESX and QBox'

shared_scripts {
	'@morph_ui/init.lua',
}

morph_ui 'locale'

ui_page 'web/index.html'

files {
	'config.lua',
	'web/index.html',
	'web/assets/**',
	'web/dist/**',
	'locales/*.json',
}


client_scripts {
	'client/*.lua',
}

server_scripts {
	'@morph_db/lib/MySQL.lua',
	'bridge/**',
	'server/*.lua',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
nui_callback_strict_mode 'true'


dependencies {
	'morph_ui'
}
