--////////////////////////////////////////////////////////////////////
--// Name:        lide.lua
--// Purpose:     Lua interpreter with lide framework integrated
--// Created:     2017/09/24
--// Copyright:   (c) 2017 Hernan Dario Cano [dcanohdev@gmail.com]
--// License:     GNU GENERAL PUBLIC LICENSE
--////////////////////////////////////////////////////////////////////

assert(os.getenv 'LIDE_PATH', '[lide shell] Please define `LIDE_PATH` variable.');

io.stdout:setvbuf 'no'

local LIDE_PATH     = os.getenv('LIDE_PATH')
local _LIDE_VERSION = '0.1'

package.path  = LIDE_PATH .. '/libraries/?.lua;'; -- set package.path only to libraries folder

--
-- First load only lide.core to determine the current platform and set package.path and package.cpath
--
local lide = require 'lide.core.init'

local normalize_path   = lide.platform.normalize_path;
local CURRENT_PLATFORM = lide.platform.get_osname();
local CURRENT_ARCH     = lide.platform.get_osarch();

if CURRENT_PLATFORM == 'linux' then
   	package.cpath = LIDE_PATH .. ('/clibs/linux/%s/?.so;'):format(CURRENT_ARCH)
	package.path  = LIDE_PATH .. ('/lua/linux/%s/?.lua;' ):format(CURRENT_ARCH) ..
					LIDE_PATH .. ('/lua/?.lua;') .. package.path

elseif CURRENT_PLATFORM == 'windows' then
	package.cpath = LIDE_PATH .. ('/clibs/windows/%s/?.dll;'):format(CURRENT_ARCH) ..
					LIDE_PATH .. ('/clibs/windows/?.dll;') .. package.cpath;
	
	package.path  = LIDE_PATH .. ('/lua/windows/%s/?.lua;'  ):format(CURRENT_ARCH) ..
					LIDE_PATH .. ('/lua/?.lua;') .. package.path
end

--
-- Then load lide.base namespace to manage files and folders correctly
--

lide = require 'lide.base.init'

--
-- Define local functions that will be used on this app
--

local function trim ( str )
	repeat str = str:gsub ('  ', '')
	until not str:find ' '
	return str
end

function lide.mktree ( src_file ) -- make only tree of dirs of this file
	local sep,INIT = '\\', ''
	
	if lide.platform.get_osname() == 'linux' then 
		INIT = '/'
		sep  = '/' 
	end

	if not lfs.attributes(src_file) then
		
		local _path = '' for path in src_file:delimi (sep) do
			if _path == '' then
				_path = _path .. path
			else
				_path = _path .. '/' .. path
				if not lfs.attributes(_path) then
					lfs.mkdir(INIT .. _path)
				end
			end
		end
	end
end

function locals(lvel)
   	local variables = {}
   	local idx = 1
   	while true do
    	local ln, lv = debug.getlocal(2 +(lvel or 0), idx)
      	if ln ~= nil then
      		variables[ln] = lv
    	else
      		break
    	end
    	idx = 1 + idx
  	end
  	
  	return variables
end

function upvalues()
  	local variables = {}
  	local idx = 1
  	local func = debug.getinfo(2 + (lvel or 0), "f").func
  	
  	while true do
    	local ln, lv = debug.getupvalue(func, idx)
    	if ln ~= nil then
    		variables[ln] = lv
    		break
    	end
    	idx = 1 + idx
 	end
  	return variables
end

function globals( ... )
	return _G
end

local function file_getline ( filename, nline )
	local n = 0; for line in io.lines(filename) do
		n = n+1; 
		if n == nline then
			return line
		end
	end
	return false
end

app = lide.app

-- Define paths:
local access_token  = os.getenv 'GITHUB_TOKEN'

app.folders = { install, libraries, ourclibs, ourlibs }	

app.folders.sourcefolder = normalize_path( os.getenv 'LIDE_PATH' )
app.folders.libraries    = normalize_path( os.getenv 'LIDE_PATH' .. '/libraries')

-- 
-- load thirdparty libraries that'll be used on this app
--

local lide_zip    = require 'lide_zip'
local inifile 	  = require 'inifile'
local sqldatabase = require 'sqldatabase.init'
local github      = require 'github'
local http        = require 'http.init'

require 'lide-log'

---------------------------------------------------------------------------------------------

local framework = {}

function framework.run ( filename, env, req, ... )
	local chunk = loadfile(filename)
	
	if not chunk then	
		print 'syntax error'
		os.exit()
	end

	do  -- Usar una copia separada del Lide que se est?ejecutando:
		
		-- Ejecutar el interprete apropiado:
		if ( CURRENT_PLATFORM == 'linux' ) then
			local _exec_str  = '%s/bin/%s/%s/lua %s/bin/lide51.lua %s'

			os.execute ( 
				_exec_str:format(LIDE_PATH, CURRENT_PLATFORM, CURRENT_ARCH, LIDE_PATH, filename)
				
			);

		elseif ( CURRENT_PLATFORM == 'windows' ) then
			--- Ejecutamos el interprete de lua basado en wxluafreeze:
			---  bin/gui.exe
			---
			--- Este ejecutable contiene todas las librerias necesarias para una correcta ejecucion de
			--- componentes graficos compatibles con wxLua y Lua.

			local _exec_str  = '%s/bin/%s/%s/lidefreeze.exe %s'

			os.execute ( 
				_exec_str:format(LIDE_PATH, CURRENT_PLATFORM, CURRENT_ARCH, filename)
				
			);
		end
	end
end

if ( arg[1] == 'search' and arg[2] ) then

	package_args = {} 
	for i= 2, #arg do package_args[#package_args +1] = arg[i] end
	 
	dofile ( app.folders.sourcefolder .. '/modules/search.lua' )

elseif ( arg[1] == 'install' and arg[2] ) then

	package_args = {} 
	for i= 2, #arg do package_args[#package_args +1] = arg[i] end
	
	dofile ( app.folders.sourcefolder ..   '/modules/install.lua' )

elseif ( arg[1] == 'update' ) then

	package_args = {} 
	for i= 2, #arg do package_args[#package_args +1] = arg[i] end

	dofile ( app.folders.sourcefolder .. '/modules/update.lua' )

elseif ( arg[1] == 'remove' and arg[2] ) then

	package_args = {} 
	for i= 2, #arg do package_args[#package_args +1] = arg[i] end

	dofile ( app.folders.sourcefolder .. '/modules/remove.lua' )

elseif ( arg[1] == '--version' ) then

    io.stdout:write (('Lide framework %s, %s'):format(_LIDE_VERSION, _VERSION))

elseif ( arg[1] == '--help') then
	print [[
Usage: lide [command/option] [arguments]

Possible commands:
  install <package> 	Install a package to runtime
  search  <package> 	Search for packages on lide.repos
  remove  <package>     Remove a package from runtime

Possible options:
  --version		Display compiler version information
  --help		Display this help message
  --test		Execute commandline tests

Examples:
 To install lfs package:
  > lide install lfs
	
 To search for md5 package:
  > lide search md5

For bug reporting instructions, please see:
<https://github.com/lidesdk/shell/issues>.]]

elseif ( arg[1] == '--test' ) then
    io.stdout:write '[lide test] all ok.\n'
else
	if ( arg[1] == '-l' ) then
	    print '[lide.error] Please import using require inside the lua file.'
	    
	    os.exit()
	elseif arg[1] then	
		if lide.file.doesExists(arg[1]) then
			framework.run ( arg[1] )--, { inifile = inifile, repository = repository } )
		else
			local src_file = arg[1]
			
			io.stderr:write '[lide.error: ] "$src_file$" file does not exist.'
			error()
		end
	elseif # arg == 0 then

		-- Execute interactive commandline
		framework.run ( app.folders.sourcefolder .. '/modules/interactive.lua' )
	end
end
