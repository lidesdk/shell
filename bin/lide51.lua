--////////////////////////////////////////////////////////////////////
--// Name:        lide.lua
--// Purpose:     Lua interpreter with lide framework integrated
--// Created:     2018/08/22
--// Copyright:   (c) 2018 Hernan Dario Cano [dcanohdev@gmail.com]
--// License:     GNU GENERAL PUBLIC LICENSE
--///////////////////////////////////////////////////////////////////



--- Get the name of the operating system.
---		Returns one lowercase string: OS Name like "linux"
---
function lide_platform_get_osname ()
	if (package.config:sub(1,1) == '\\') and os.getenv 'OS' == 'Windows_NT' then
		return 'windows';
	elseif (package.config:sub(1,1) == '/') and io.popen 'uname -s':read '*l' == 'Linux' then
		return 'linux';
	else
		return 'other';
	end
end

---
-- Get the architecture of current binaries (OS)
--    string 'x86', 'x64', 'arm'
---
function lide_platform_get_osarch ()
	local _osname = lide_platform_get_osname():lower()

	if (_osname == 'windows') then
		--- 
		-- Windows support contains: "x86" architectures:
		---		
		return tostring ( os.getenv 'PROCESSOR_ARCHITECTURE' 
			: gsub ('AMD64', 'x64')):sub(1,3);

	elseif (_osname == 'linux') then
		--- 
		-- Linux support contains: "x86", "x64" and "arm" architectures:
		---

		return io.popen 'uname -m' : read '*a'
			   : gsub ('x86_64' , 'x64')
			   : gsub ('i686'   , 'x86')
			   : gsub ('aarch64', 'arm64'):sub(1,5)
			   : gsub ('armv7l' , 'arm32'):sub(1,5);
end

local function normalize_path ( path )
	if ( lide_platform_get_osname() == 'windows' ) then
		return (path:gsub('/', '\\'));
	elseif ( lide_platform_get_osname() == 'linux' ) then
		return tostring(path:gsub('\\', '/'):gsub('//', '/'));
	end
end


local file = arg[1]

do
	local _current_osname = lide_platform_get_osname():lower();
	local _current_osarch = lide_platform_get_osarch():lower();
	local _current_osext  = '?'

	local LIDE_PATH = os.getenv 'LIDE_PATH'

	if _current_osname == 'linux' then
		_current_osext = '.so';
	elseif _current_osname == 'windows' then
		_current_osext = '.dll';
	end

	package.path  = LIDE_PATH .. '/libraries/lua/?.lua;' ..
					LIDE_PATH .. '/libraries/lua/?/init.lua;' ..
					LIDE_PATH .. '/libraries/?.lua;' ..
					'?.lua;'  ..

					LIDE_PATH .. ('/libraries/%s/%s/lua/?.lua;'):format(_current_osname, _current_osarch) .. 
					LIDE_PATH .. ('/libraries/%s/%s/lua/?/init.lua;'):format(_current_osname, _current_osarch) .. 
					package.path;

	package.cpath = LIDE_PATH .. ('/clibs/%s/%s/?%s;'):format(_current_osname, _current_osarch, _current_osext) ..
					LIDE_PATH .. ('/libraries/%s/%s/clibs/?%s;'):format(_current_osname, _current_osarch, _current_osext) ..
					LIDE_PATH .. ('/libraries/%s/%s/clibs/?/core%s;'):format(_current_osname, _current_osarch, _current_osext) ..
					package.cpath;

	package.path  = normalize_path(package.path);
	package.cpath = normalize_path(package.cpath);
	----------------------------------------------------------------------------------------
	local yeee, eqq = pcall(dofile, file)
	if not (yeee) then
		error(eqq)
	end
end