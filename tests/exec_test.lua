io.stdout : write '[lide commandline] execution tests: '

assert(io.popen 'lide.bat --test' :read '*a' == '[lide test] all ok.')

-- Test if luasql is on stable repo with search:
-- searchline = io.popen 'lide.bat search luasql' :read '*l' 
-- assert( searchline:sub (1, searchline : find '/' ) == 'stable/')


io.stdout : write '[OK]'