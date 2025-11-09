fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'mnr_mining'
description 'Miner job resource'
author 'IlMelons'
version '1.0.0'
repository 'https://www.github.com/Monarch-Development/mnr_mining'

ox_lib 'locale'

files {
    'locales/*.json',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config/zones.lua',
}

client_scripts {
    'bridge/client/**/*.lua',
    'client/*.lua',
}

server_scripts {
    'config/server.lua',
    'server/*.lua',
}

dependencies {
    'mnr_blips'
}