fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author "sobing4413"

version "1.0"

ui_page 'html/index.html'

files {'html/**'}

shared_scripts {
    'shared/vehicles.lua',
	'shared/cores.lua',
    'shared/fuels.lua',
    'shared/keys.lua',
	'shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'shared/config.lua'
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
	'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}