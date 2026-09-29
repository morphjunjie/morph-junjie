fx_version 'cerulean'
game 'gta5'

description 'morph_amjob'
repository 'https://github.com/Qbox-project/morph_amjob'
version '1.0.0'

morph_ui 'locale'

dependencies {
    'morph_junjie',
	'morph_medical',
    'morph_ui',
	'morph_inv'
}

shared_scripts {
	'@morph_ui/init.lua',
	'@morph_junjie/modules/lib.lua',
}

client_scripts {
	'@morph_junjie/modules/playerdata.lua',
	'client/*.lua',
}

server_scripts {
	'server/*.lua',
}

files {
	'locales/*.json',
	'config/client.lua',
	'config/shared.lua',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'