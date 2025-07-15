fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

description 'qr-Spawn - Modern ox_lib Integration'
version '2.0.0'

shared_scripts {
	'@ox_lib/init.lua',
	'config.lua',
	'locale.lua'
}

client_scripts {
	'client.lua',
	'language_selector.lua'
}
server_script 'server.lua'

dependencies {
	'qr-core',
	'ox_lib'
}

lua54 'yes'