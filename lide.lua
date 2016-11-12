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
    	else
    		break
    	end
    	idx = 1 + idx
 	end
  	return variables
end

function globals( ... )
	return _G
end

function printl ( str )
	local pr1, pr2  = str:find('%$');
	local pr3, pr4  = str:find('%$', pr1+2);
	local var_name  = str:sub(pr1 +1, pr3 -1);
	local var_value = locals (1)  [var_name] or upvalues(1) [var_name]  or globals() [var_name]
	
	if not var_value then
		assert( false, ('La variable "%s" no existe.'):format (var_name) )
	end
	
	print( str:sub(1, pr1-1) .. var_value .. str:sub(pr4 +1, #str))
end

-- print('\n > Lide :) ' .. app.getWorkDir(), arg[0])
lide_cmd_libs  = '/datos/Proyectos/lide/commandline/lnx_lua'
--lide_cmd_clibs = '/datos/Proyectos/lide/commandline/lnx_clibs'

package.path = lide_cmd_libs .. '/?.lua'

-- lide.new.string ''

require 'lide.core.init'

app = lide.app

-- Define paths:
local access_token  = nil -- github acces token

app.folders = { install, libraries, ourclibs, ourlibs }	

app.folders.sourcefolder = arg[0]:sub(1, #arg[0] - 9, #arg[0])

if lide.platform.getOSName() == 'Windows' then

	app.folders.install   = 'c:\\lidesdk'
	app.folders.libraries = 'c:\\lidesdk\\libraries'
	lide_installfolder    = 'C:\\lidesdk\\bin\\libs'
	app.folders.ourclibs  = '.\\win_clibs'

	package.path  = '.\\?.lua;' ..
					'.\\win_lua\\?.lua;'

	package.cpath = '.\\?.dll;' ..
					'.\\win_clibs\\?.dll;'

elseif lide.platform.getOSName() == 'Linux' then

	app.folders.install   = app.folders.sourcefolder
	app.folders.libraries = app.folders.sourcefolder .. '/libraries'
	app.folders.ourclibs  = app.folders.sourcefolder .. '/lnx_clibs'

	package.cpath = app.folders.sourcefolder .. '/?.so;' ..
					app.folders.sourcefolder .. '/lnx_clibs/?.so;'
	package.path  = app.folders.sourcefolder .. '/?.lua;' ..
					app.folders.sourcefolder .. '/lnx_lua/?.lua;'
end


local sqldatabase = require 'sqldatabase.init'
local github      = require 'github'
lide.zip 		  = require 'lide_zip'

local function update_database ( access_token )
	local db_content, errcode, errmsg  = github.get_file ( 'lidesdk/repos/libraries.db', nil, access_token)

	if db_content then
		-- if folder doesnt exist create it (todo)
		local repos_db = io.open(app.folders.libraries..'/repos.db', 'w+b')
		if repos_db:write(db_content) then
			repos_db:close()
			-- OK SUccess
		else
			--any error writeing file
		end
	else
		print('[lide.github]: ', errmsg)
	end
end

local libraries_stable = sqldatabase:new(app.folders.libraries..'/repos.db', 'sqlite3')

local function run_sandbox ( filename, env, req, ... )
	local env   = env or {
		rawget = rawget,
		xpcall = xpcall,
		next = next,
		loadfile = loadfile,
		error = error,
		rawlen = rawlen,
		loadstring = loadstring,
		bit32 = bit32,
		setmetatable = setmetatable,
		_VERSION = _VERSION,
		coroutine = coroutine,
		select = select,
		utf8 = utf8,
		assert = assert,
		pcall = pcall,
		arg = arg,
		pairs = pairs,
		debug = debug,
		math = math,
		type = type,
		dofile = dofile,
		os = os,
		load = load,
		string = string,
		tonumber = tonumber,
		table = table,		
		require = require,
		unpack = unpack,
		getmetatable = getmetatable,
		module = module,
		tostring = tostring,
		rawequal = rawequal,
		print = print,
		rawset = rawset,
		io = io,
		collectgarbage = collectgarbage,
		ipairs = ipairs,

		package = {
			path  = '',
			cpath = '',
		},
	}

	local chunk = loadfile(filename)
	
	if not chunk then
		print 'syntax error'
		os.exit()
	end

	do  -- Usar una copia separada del Lide que se está ejecutando:
		local function run_chunk ( ... )
			env._G = env
			env.lide, errm = require 'lide.init'
			env.package.path  = app.folders.libraries ..'/?.lua;' ..
							'./?.lua'
			
			if lide.platform.getOSName() == 'Linux' then
				env.package.cpath = app.folders.libraries ..'/?.so;'
			elseif lide.platform.getOSName() == 'Windows' then
				env.package.cpath = app.folders.libraries ..'/?.dll;'
			end
			
			env.app = {}
			--env.app.modules = {}
			
			setfenv(chunk, env);
			return chunk (...)
		end

		local exec, errm = pcall(run_chunk, ...)
		if not exec then
			return false, errm
		else
			return true
		end
	end
end

if ( arg[1] == '-l' ) then
    print '[lide.error] Please import using require inside the lua file.'
    
    os.exit()

elseif arg[1] and ( lide.file.doesExists(arg[1]) ) then	
	local ran, errr = run_sandbox( arg[1] )
	if not ran then
		print ('[lide.error: sandbox] '.. tostring((errr)))
	end
end

if ( arg[1] == 'search' and arg[2] ) then
	local text_to_search = arg[2]
		
	print '> Searching...'
	
	update_database ( access_token );

	--wx.wxSleep(0.01)

	local libraries_stable = sqldatabase:new(app.folders.libraries..'/repos.db', 'sqlite3')

	local tbl = libraries_stable:select('select * from libraries_stable where package_name like "%'..text_to_search..'%"')
	
	if #tbl > 0 then
		for i, row in pairs( tbl ) do
			if type(row) == 'table' then
				local num_repo_version  = tonumber(tostring(row.package_version:gsub('%.', '')));
				
				if lide.folder.doesExists(app.folders.libraries..'/'..row.package_name) then
					local local_package_version = io.open(app.folders.libraries..'/'..row.package_name..'/'..row.package_name..'.manifest'):read('*l')
					local num_local_version = tonumber(tostring(local_package_version:gsub('%.', '')));
					if ( num_repo_version > num_local_version ) then
						str_tag = '(UPDATE)'
					end
				end

				print(
					('\n%s [%s] %s\n\t%s\n'):format(row.package_name, row.package_version, str_tag or '', row.package_description)
				)
			end
		end
		
	else
		print 'No matches!'
	end

elseif ( arg[1] == 'install' and arg[2] ) then
	local _package_name  = arg[2]
	local _query_install = 'select * from libraries_stable where package_name like "%s" limit 1'
	
	print('> Search '.. _package_name)
	
	update_database(access_token);
	
	--wx.wxSleep(0.01)

	if # libraries_stable:select ( _query_install:format(_package_name) ) == 0 then
		print 'No matches!'
		return false
	end

	local _package_name    = libraries_stable:select(_query_install:format(_package_name))[1].package_name
	local _package_version = libraries_stable:select(_query_install:format(_package_name))[1].package_version
	local _package_file    = app.folders.libraries..'/'.._package_name..'.zip'

	if lide.folder.doesExists(app.folders.libraries..'/'.._package_name) then
		print (('\t> The package %s is already installed.'):format(_package_name))
		return false
	end

	if # libraries_stable:select('select * from libraries_stable where package_name like "%'.._package_name..'%" limit 1') > 0 then
		print(('> Found! %s %s'):format(_package_name, _package_version));
	end
	
	local github_path = libraries_stable:select(_query_install:format(_package_name))[1].package_url
	
	local content = github.get_file ( github_path, nil, access_token )
	
	local zip_file = io.open(_package_file, 'w+b');

	if zip_file:write(content) then
		zip_file:close();
	end

	print('\t> Installing...')	

	lide.zip.extract(_package_file, app.folders.libraries ..'/'.._package_name)

	print('\t> All done!')
	
	--wx.wxSleep(0.01)
	
	io.popen ('rm -rf "' .. app.folders.libraries ..'/'.._package_name..'.zip"');

	print(('New library installed %s %s'):format(_package_name, _package_version))

elseif ( arg[1] == 'remove' and arg[2] ) then
	local _package_version
	local _package_name = arg[2]
	
	if lide.folder.doesExists(app.folders.libraries ..'/'.._package_name) then
		_package_version = io.open(app.folders.libraries ..'/'.._package_name..'/'.._package_name ..'.manifest'):read('*l')
		
		print('\t> Deleting files!')
		
		io.popen ('rm -rf "' .. app.folders.libraries ..'/'.._package_name..'"');
		io.popen ('rm -rf "' .. app.folders.libraries ..'/'.._package_name..'".zip');

		print(('Library "%s %s" is successfully removed.'):format(_package_name, _package_version))
	else
		print (('The package "%s" doesn\'t installed.'):format(_package_name))
	end
end

