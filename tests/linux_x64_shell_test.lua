local LIDE_PATH

if os.getenv 'LIDE_PATH' then
	LIDE_PATH = os.getenv 'LIDE_PATH'
end

-- Run standard internal tests:
io.stdout : write '[lide shell] execution tests: '

	assert(io.popen './lide.sh --test' :read '*a' == '[lide test] all ok.\n')

io.stdout : write '\t[OK]\n'

-- Test if luasql, lfs are on stable repo with search:
io.stdout : write '[lide shell] package search: '
	
	 searchline = io.popen './lide.sh search luasql' :read '*l'
	 assert( searchline:sub (1, searchline : find '/' ) == 'stable/')
	 searchline = io.popen './lide.sh search lfs' :read '*l'
	 assert( searchline:sub (1, searchline : find '/' ) == 'stable/')

io.stdout : write '\t[OK]\n'

-- Test installation of lfs (1.7.0 for linux):
io.stdout : write '[lide shell] package install: '
	install_package = io.popen ('./lide.sh install lfs 1.7.0') :read '*a'
	io.stdout : write ('\n' .. install_package)
	
	print(LIDE_PATH .. '/libraries/linux/x64/clibs/lfs.so')
	os.execute ('ls ' ..LIDE_PATH .. '/libraries/linux/x64/clibs/lfs.so')

	assert(type(io.open(LIDE_PATH .. '/libraries/linux/x64/clibs/lfs.so', 'rb')) == 'userdata')

io.stdout : write '\t[OK]\n'