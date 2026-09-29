fx_version 'cerulean'
game 'gta5'

author 'Morph'
description 'Paket mapping rumah jadi satu resource'
version '1.0.0'

this_is_a_map 'yes'

files {
    'stream/**/*.ytyp',
    'stream/**/*.ymap',
    'stream/**/*.ydr',
    'stream/**/*.ytd',
    'stream/**/*.ymf',
   -- 'stream/**/*.ityp',
    'stream/**/interiorproxies.meta'
}

data_file 'DLC_ITYP_REQUEST' 'stream/**/*.ytyp'
data_file 'INTERIOR_PROXY_ORDER_FILE' 'stream/**/interiorproxies.meta'
