fx_version 'adamant'
game 'gta5'

files {
	'nui/**',
}

ui_page 'nui/index.html'

client_scripts {
	'config.lua',
	'@vrp/lib/utils.lua',
	'src/client.lua'
}

server_scripts {
	'config.lua',
	'@vrp/lib/utils.lua',
	'src/server.lua'
}

