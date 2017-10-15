PACKAGE = 'lanes'

TABLES  = { assert_type = 'table', 'ABOUT' }

FUNCTIONS = { assert_type = 'function',
	'linda', 'genatomic', 'now_secs', 'genlock', 'threads',
	'timers', 'set_thread_priority', 'gen', 'timer', 'nameof', 'require', 'set_singlethreaded'
}

USERDATA = { assert_type = 'userdata',
	'cancel_error', 'timer_lane'
}

local results = require 'lanes' . configure { demote_full_userdata = true }

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