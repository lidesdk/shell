--- Get the name of the operating system.
---		Returns one string: OS Name like "Linux"
---
--- string getOSVersion( nil )
function lide_platform_getOSName( ... )
	if (package.config:sub(1,1) == '\\') and os.getenv 'OS' == 'Windows_NT' then
		return 'windows';
	elseif (package.config:sub(1,1) == '/') and io.popen 'uname -s':read '*l' == 'Linux' then
		return 'linux';
	else
		return 'other';
	end
end

-- Get architecture of current OS
-- string 'x86', 'x64'
function lide_platform_getArch ()
	local _osname = lide_platform_getOSName():lower()
	if (_osname == 'windows') then
		return os.getenv 'PROCESSOR_ARCHITECTURE' 
	elseif (_osname == 'linux') then
		return io.popen 'uname -m' : read '*a' : gsub ('x86_64', 'x64') : gsub ( 'i686', 'x86' ):sub(1,3);
	end
end

local function normalize_path ( path )
	if lide_platform_getOSName() == 'windows' then
		return (path:gsub('/', '\\'));
	elseif lide_platform_getOSName() == 'linux' then
		return tostring(path:gsub('\\', '/'):gsub('//', '/'));
	end
end


local file = arg[1]

do
	local _currentOSName = lide_platform_getOSName():lower();
	local _currentArch   = lide_platform_getArch():lower();

	local lide_path = os.getenv 'LIDE_PATH'

	package.path  = lide_path .. '\\libraries\\lua\\?.lua;' ..
	lide_path .. '\\libraries\\lua\\?\\init.lua;' ..
	lide_path .. '\\libraries\\?.lua;' ..

	lide_path .. '\\libraries\\'.._currentOSName..'\\'.._currentArch..'\\lua\\?.lua;' .. 
	lide_path .. '\\libraries\\'.._currentOSName..'\\'.._currentArch..'\\lua\\?\\init.lua;'
	
	--dofile(file)
	


	----------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------
	-- ?.lua;?/init.lua
	-- lua/?.lua;lua/?/init.lua
	-- ?.dll
	-- clibs/?.dll

	--package.cpath = lide_path .. '\\libraries\\?.dll;' .. package.cpath
	--package.path  = lide_path .. '\\libraries\\?.lua;' .. package.path
	
	if _currentOSName == 'linux' then
		local LIDE_PATH = os.getenv 'LIDE_PATH'

		package.cpath = LIDE_PATH .. '/clibs/linux/x64/?.so;' .. 
						LIDE_PATH .. '\\libraries\\'.._currentOSName.. '\\'.._currentArch..'\\clibs\\?.so;' .. 
						LIDE_PATH .. '\\libraries\\'.._currentOSName..'\\'.._currentArch..'\\clibs\\?\\core.so;' .. package.cpath 
	
	--else
	--	package.cpath  = lide_path .. '\\libraries\\' .._currentOSName.. '\\'.._currentArch..'\\clibs\\?.dll;'
	end

	package.path  = normalize_path(package.path);
	package.cpath = normalize_path(package.cpath);

	--print('a')
	--lide = require 'lide.base.init'
	----------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------

	local x, e = pcall(dofile, file)
	
	if not x then
		print(e)
	end
end