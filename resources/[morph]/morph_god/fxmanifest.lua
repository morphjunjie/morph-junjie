fx_version 'cerulean'

game "gta5"

author "Project Sloth & OK1ez"
version '1.1.7'
description 'Admin Menu'
repository 'https://github.com/Project-Sloth/morph_god'

lua54 'yes'

ui_page 'html/index.html'
-- ui_page 'http://localhost:5173/' --for dev

client_script {
  'client/**',
}

server_script {
  "server/**",
  "@morph_db/lib/MySQL.lua",
}

shared_script {
  '@morph_ui/init.lua',
  "shared/**",
}

files {
  'html/**',
  'data/ped.lua',
  'data/object.lua',
  'data/locations.lua',

  'locales/*.json',
}

morph_ui 'locale' -- v3.8.0 or above
