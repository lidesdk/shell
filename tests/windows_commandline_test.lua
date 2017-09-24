-- Run standard internal tests:
io.stdout : write '[lide commandline] execution tests: '

	assert(io.popen '.\\lide.bat --test' :read '*a' == '[lide test] all ok.\n')

io.stdout : write '\t[OK]\n'

-- Test if luasql, lfs are on stable repo with search:
io.stdout : write '[lide commandline] search tests: '
	
	searchline = io.popen '.\\lide.bat search luasql' :read '*l'
	assert( searchline:sub (1, searchline : find '/' ) == 'stable/')
	searchline = io.popen '.\\lide.bat search lfs' :read '*l'
	assert( searchline:sub (1, searchline : find '/' ) == 'stable/')

io.stdout : write '\t[OK]\n'

--
