io.stdout : write '[lide commandline] execution tests: '
assert(io.popen 'lide.bat --test' :read '*a' == '[lide test] all ok.')
io.stdout : write '[OK]\n'