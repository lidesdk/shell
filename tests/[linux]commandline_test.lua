LIDE_PATH = (os.getenv 'LIDE_PATH')

-- Run standard internal tests:
io.stdout : write '[lide commandline] execution tests: '

	assert(io.popen ('./lide.sh --test') :read '*a':sub(1,19) == '[lide test] all ok.')

io.stdout : write '\t[OK]\n'

-- Test if luasql, lfs are on stable repo with search:
io.stdout : write '[lide commandline] package search: '
	
	searchline = io.popen ('./lide.sh search lanes') :read '*l'
	assert( searchline:sub (1, searchline : find '/' ) == 'stable/')
	searchline = io.popen ('./lide.sh search lanes') :read '*l'
	assert( searchline:sub (1, searchline : find '/' ) == 'stable/')

io.stdout : write '\t[OK]\n'

--

io.stdout : write '[lide commandline] package install: '
	install_package = io.popen ('./lide.sh install lanes') :read '*a'
    assert(type(io.open(LIDE_PATH .. '/libraries/linux/x64/clibs/lanes/core.so', 'rb')) == 'userdata')

io.stdout : write '\t[OK]\n'


PACKAGE = 'lanes'

TABLES  = { assert_type = 'table', 'ABOUT' }

FUNCTIONS = { assert_type = 'function',
	'linda', 'genatomic', 'now_secs', 'genlock', 'threads',
	'timers', 'set_thread_priority', 'gen', 'timer', 'nameof', 'require', 'set_singlethreaded'
}

USERDATA = { assert_type = 'userdata',
	'cancel_error', 'timer_lane'
}

local results = require (PACKAGE) . configure { demote_full_userdata = true }

function assertfields ( TYPE, PACKAGE, LOADED )
	local assert_msg  = "Error %s %s doesn't exists"
	for _,tbl_name in pairs(TYPE) do
		if tbl_name ~= TYPE.assert_type then
			assert(
				type(results [tbl_name]) == TYPE.assert_type, assert_msg:format(tbl_name, TYPE.assert_type)
			)
		end
	end
end

io.stdout : write ('[lide commandline] package load: ' .. PACKAGE)

assertfields ( TABLES   , PACKAGE , results)
assertfields ( FUNCTIONS, PACKAGE , results)
assertfields ( USERDATA , PACKAGE , results)

io.stdout : write '\t[OK]\n'