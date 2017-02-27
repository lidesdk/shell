local file = arg[1]

do
	local lide_path = os.getenv 'lide_path'


	package.path  = lide_path .. '\\libraries\\lua\\?.lua;' ..
	lide_path .. '\\libraries\\lua\\?\\init.lua;' ..

	lide_path .. '\\libraries\\windows\\x86\\lua\\?.lua;' .. 
	lide_path .. '\\libraries\\windows\\x86\\lua\\?\\init.lua;'
	
	package.cpath  = --lide_path .. '\\libraries\\clibs\\?.lua;' ..
	lide_path .. '\\libraries\\windows\\x86\\clibs\\?.dll;'

	--dofile(file)
	--lide = lide_path .. '\\libraries\\?.lua'

	----------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------
	-- ?.lua;?/init.lua
	-- lua/?.lua;lua/?/init.lua
	-- ?.dll
	-- clibs/?.dll

	package.cpath = lide_path .. '\\libraries\\?.dll;' .. package.cpath
	package.path  = lide_path .. '\\libraries\\?.lua;' .. package.path
	
	lide = require 'lide.init'
	----------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------

	local x, e = pcall(dofile, file)
	
	if not x then
		print(e)
	end
end