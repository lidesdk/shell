local LIDE_PATH

if os.getenv 'LIDE_PATH' then
	LIDE_PATH = os.getenv 'LIDE_PATH'
else
	error 'Please define LIDE_PATH first.'
	return false;
end

-- Run standard internal tests:
io.stdout : write '[lide shell] execution tests: '

	assert(io.popen './lide.sh --test' :read '*a' == '[lide test] all ok.\n')

io.stdout : write '\t[OK]\n'

-- Test if luasql, lfs are on stable repo with search:
io.stdout : write '[lide shell] package search: '
	
	 searchline = io.popen (LIDE_PATH .. '/lide.sh search luasql') :read '*l'
	 print(searchline)
	 print(searchline:sub (1, searchline : find '/' ))
	 assert( searchline:sub (1, searchline : find '/' ) == 'stable/')
	 searchline = io.popen (LIDE_PATH .. '/lide.sh search lfs') :read '*l'
	 assert( searchline:sub (1, searchline : find '/' ) == 'stable/')

io.stdout : write '\t[OK]\n'

-- Test installation of lfs (1.7.0 for linux):	
io.stdout : write '[lide shell] package install: '
	install_package = io.popen (LIDE_PATH .. '/lide.sh install lfs 1.7.0') :read '*a'
	assert(type(io.open(LIDE_PATH .. '/libraries/linux/x64/clibs/lfs.so', 'rb')) == 'userdata')

io.stdout : write '\t[OK]\n'
