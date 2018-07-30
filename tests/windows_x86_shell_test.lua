local LIDE_PATH

if os.getenv 'LIDE_PATH' then
	LIDE_PATH = os.getenv 'LIDE_PATH'
end

-- Run standard internal tests:
io.stdout : write '[lide shell] execution tests: '

	assert(io.popen '.\\lide.bat --test' :read '*a' == '[lide test] all ok.\n')

io.stdout : write '\t[OK]\n'

-- Test if luasql, lfs are on stable repo with search:
io.stdout : write '[lide shell] package search: '
	
	 searchline = io.popen '.\\lide.bat search luasql' :read '*l'
	 assert( searchline:sub (1, searchline : find '/' ) == 'stable/')
	 searchline = io.popen '.\\lide.bat search lfs' :read '*l'
	 assert( searchline:sub (1, searchline : find '/' ) == 'stable/')

io.stdout : write '\t[OK]\n'

-- Test installation of lfs (1.4.20 for windows):
io.stdout : write '[lide shell] package install: '
	install_package = io.popen (LIDE_PATH .. '/lide.bat install lfs 1.4.20') :read '*a'   
	assert(type(io.open(LIDE_PATH .. '/libraries/windows/x86/clibs/lfs.dll', 'rb')) == 'userdata')

io.stdout : write '\t[OK]\n'