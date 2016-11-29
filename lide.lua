local function normalize_path ( path )
	if lide.platform.getOSName() == 'Windows' then
		return (path:gsub('/', '\\'));
	elseif lide.platform.getOSName() == 'Linux' then
		return (path:gsub('\\', '/'));
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

local function file_getline ( filename, nline )
	local n = 0; for line in io.lines(filename) do
		n = n+1; 
		if n == nline then
			return line
		end
	end
	return false
end

local function print_console ( str, arg2 )
	if arg2 then error('Please give me only one argument', 2) end
	str = str .. ' '
	
	local patt = '$%w.+[1-z][%a][%s]'
	
	if str:match (patt) then
		local var_name  = str:match (patt) : sub (2, #str)-- var_name = var_name:gsub (' ', '')
		local var_value = locals (1)  [var_name] or upvalues(1) [var_name]  or globals() [var_name]
		
		if not var_value then
			assert( false, ('Variable "%s" is not declared.'):format (var_name) )
		end

		io.stdout:write( 
			str:gsub('$'..var_name, var_value or '')
		.. '\n')
	else
		io.stdout:write( str  .. '\n')
	end
end

-- print('\n > Lide :) ' .. app.getWorkDir(), arg[0])
--lide_cmd_clibs = '/datos/Proyectos/lide/commandline/lnx_clibs'

-- lide.new.string ''

app = lide.app

-- Define paths:
local access_token  = os.getenv 'GITHUB_TOKEN'

app.folders = { install, libraries, ourclibs, ourlibs }	

app.folders.sourcefolder = arg[0]:sub(1, #arg[0] - 9, #arg[0])

if lide.platform.getOSName() == 'Windows' then

	app.folders.install   = app.folders.sourcefolder
	app.folders.libraries = app.folders.sourcefolder .. '\\libraries'
	app.folders.ourclibs  = app.folders.sourcefolder .. '\\win_clibs'

	package.cpath = app.folders.sourcefolder .. '\\?.dll;' ..
					app.folders.sourcefolder .. '\\clibs\\windows\\?.dll;'
	package.path  = app.folders.sourcefolder .. '\\?.lua;' ..
					app.folders.sourcefolder .. '\\lua\\?.lua;' ..
					app.folders.sourcefolder .. '\\lua\\windows\\?.lua;'

elseif lide.platform.getOSName() == 'Linux' then

	app.folders.install   = app.folders.sourcefolder
	app.folders.libraries = app.folders.sourcefolder .. '/libraries'
	--app.folders.ourclibs  = app.folders.sourcefolder .. '/lnx_clibs'

	package.cpath = app.folders.sourcefolder .. '/?.so;' ..
					app.folders.sourcefolder .. '/clibs/linux/?.so;'
	package.path  = app.folders.sourcefolder .. '/?.lua;' ..
					app.folders.sourcefolder .. '/lua/linux/?.lua;' ..
					app.folders.sourcefolder .. '/lua/?.lua;'
end

local sqldatabase = require 'sqldatabase.init'
local github      = require 'github'
lide.zip 		  = require 'lide_zip'

repository = {}

repository.access_token = access_token

repository.libraries_stable = sqldatabase:new(app.folders.libraries..'/repos.db', 'sqlite3')

function repository.update ( access_token )
	local db_content, errcode, errmsg  = github.get_file ( 'lidesdk/repos/libraries.db', nil, repository.access_token)

	if db_content then
		-- if folder doesnt exist create it (todo)
		local repos_db = io.open(normalize_path(app.folders.libraries..'/repos.db'), 'w+b')
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

function repository.download ( _package_name, _package_file, access_token )
	local _query_install = 'select * from libraries_stable where package_name like "%s" limit 1'
	
	local github_path = repository.libraries_stable:select(_query_install:format(_package_name))[1].package_url
	
	local content = github.get_file ( github_path, nil, repository.access_token )
	
	local zip_file = io.open(normalize_path(_package_file), 'w+b');

	if zip_file:write(content) then
		zip_file:close();
	end
end

function repository.install ( _package_name, _package_file )
		local function file_copy ( src, dest )
			if not lide.file.doesExists(normalize_path(src)) then
				printl '[lide error] copy: source = $src$ does not exist'
			end
			if lide.platform.getOSName() =='Linux' then
				os.execute (('cp -r "%s" "%s"'):format(src, dest))
			else
				io.popen (('COPY /B /Y "%s" "%s"'):format(normalize_path(src), normalize_path(dest)))
			end
		end

		lide.zip.extract(_package_file, app.folders.libraries ..'/'.._package_name)	
		
		local _man_file = app.folders.libraries ..'/'.._package_name..'/'.. _package_name ..'.manifest'
		
		if file_getline (_man_file, 3) then 
			
			local libs = file_getline (_man_file, 3):delim('|');
			
			for k, v in pairs( libs ) do
				local platform = v:delim ',' [1]
				
				if not lide.folder.doesExists(app.folders.libraries ..'/'..platform..'/lua/'.._package_name) then 
					lide.folder.create(app.folders.libraries ..'/'..platform..'/lua/'.._package_name)
				end

				if not lide.folder.doesExists(app.folders.libraries ..'/'..platform..'/clibs/'.._package_name) then 
					lide.folder.create(app.folders.libraries ..'/'..platform..'/clibs/'.._package_name)
				end

				if v:delim ',' [1] == 'linux_x86' then

					for i = 2, # v:delim ',' do
						local int_path = tostring(v:delim ',' [i])
						
						if int_path:sub(1,6) == 'clibs/' then
							local clibs_folder = normalize_path(app.folders.libraries ..'/'.._package_name .. '/'..platform);
							local file_src = normalize_path(clibs_folder .. '/' .. int_path)
							local file_dst = normalize_path(app.folders.libraries ..'/'..platform..'/'..int_path);
							
							file_copy(file_src, file_dst)
						
						elseif int_path:sub(1,4) == 'lua/' then
							local lualibs_folder = normalize_path(app.folders.libraries ..'/'.._package_name..'/'..platform);
							local file_src = normalize_path(lualibs_folder .. '/' .. int_path)
							local file_dst = normalize_path(app.folders.libraries ..'/'..platform..'/'..int_path);
							
							file_copy(file_src, file_dst)
						end

					end
				elseif v:delim ',' [1] == 'windows_x86' then
					
					for i = 2, # v:delim ',' do
						local int_path = tostring(v:delim ',' [i])
						
						if int_path:sub(1,6) == 'clibs/' then
							local clibs_folder = normalize_path(app.folders.libraries ..'/'.._package_name..'/windows_x86');
							local file_src = normalize_path(clibs_folder .. '/' .. int_path)
							local file_dst = normalize_path(app.folders.libraries ..'/windows_x86/'..int_path);

							file_copy(file_src, file_dst)
						
						elseif int_path:sub(1,4) == 'lua/' then
							local lualibs_folder = normalize_path(app.folders.libraries ..'/'.._package_name..'/windows_x86');
							local file_src = normalize_path(lualibs_folder .. '/' .. int_path)
							local file_dst = normalize_path(app.folders.libraries ..'/windows_x86/'..int_path);
														
							file_copy(file_src, file_dst)
						end

					end
				end
			end
		end

		local function install_depends ( package_manifest )
			local depends = file_getline(package_manifest, 2):delim ','
			for _, _package_name in pairs( depends ) do
				if lide.folder.doesExists(app.folders.libraries ..'/'.._package_name) then
					--> printl '  > Dependencies: $_package_name$ installed'
				else
					print ('  > Installing dependencies: '.. _package_name) 
					repository.download(_package_name, app.folders.libraries .. '/'.._package_name..'.zip')
					repository.install (_package_name, app.folders.libraries .. '/'.._package_name..'.zip')
				end
			end
		end

		if file_getline (_man_file, 2) and file_getline (_man_file, 2) ~= '' then 
			install_depends(_man_file) 
		end
	end

function repository.remove ( _package_name )
	local _package_version
	if lide.folder.doesExists(app.folders.libraries ..'/'.._package_name) then
		--_package_version = io.open(app.folders.libraries ..'/'.._package_name..'/'.._package_name ..'.manifest'):read('*l')
				
		if lide.platform.getOSName() == 'Linux' then
			io.popen ('rm -rf "' .. app.folders.libraries ..'/linux_x86/clibs/'.._package_name..'"');
			io.popen ('rm -rf "' .. app.folders.libraries ..'/linux_x86/lua/'.._package_name..'"');
			io.popen ('rm -rf "' .. app.folders.libraries ..'/'.._package_name..'"');
			io.popen ('rm -rf "' .. app.folders.libraries ..'/'.._package_name..'".zip');
		elseif lide.platform.getOSName() == 'Windows' then
			io.popen ('del /Q /S "' .. normalize_path(app.folders.libraries ..'/windows_x86/lua/'.._package_name..'.lua"'));
			io.popen ('rd /Q /S "' .. normalize_path(app.folders.libraries ..'/windows_x86/lua/'.._package_name..'"'));
			io.popen ('rd /Q /S "' .. normalize_path(app.folders.libraries ..'/windows_x86/clibs/'.._package_name..'"'));
			io.popen ('rd /Q /S "' .. normalize_path(app.folders.libraries ..'/'.._package_name..'"'));
			io.popen ('del /F /Q /S "' .. normalize_path(app.folders.libraries ..'/'.._package_name..'".zip'));
		end

		return true
	else
		last_error = ('The package "%s" doesn\'t installed.'):format(_package_name)
		return false,  last_error
	end
end
local function run_sandbox ( filename, env, req, ... )
	local chunk = loadfile(filename)
	
	if not chunk then
		print 'syntax error'
		os.exit()
	end

	do  -- Usar una copia separada del Lide que se est?ejecutando:
		local _LIDE_BIN = os.getenv 'LIDE_BIN'
		
		if lide.platform.getOSName() == 'Linux' then
			--local exec, errm = pcall(os.execute, (_LIDE_BIN or 'lua5.1') .. [[ -e 'package.cpath = os.getenv 'LIDE_PATH' ..'/libraries/linux_x86/?.so;' package.path = package.path ..";"..os.getenv "LIDE_PATH" .."/libraries?.lua;" require "lide.core.init"']].. ' -l lide.init ' .. filename)
			os.execute( [[lua5.1 -e "package.cpath = os.getenv 'LIDE_PATH' ..'/libraries/linux_x86/?.so' package.path = os.getenv 'LIDE_PATH' ..'/libraries/?.lua'; require 'lide.init' " ]] .. filename )
						

		elseif lide.platform.getOSName() == 'Windows' then			
			os.execute (( [[lua -e "package.cpath = os.getenv 'LIDE_PATH' ..'\\libraries\\?.dll' package.path = os.getenv 'LIDE_PATH' ..'\\libraries\\?.lua'; require 'lide.init' " ]] .. filename ))
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
	 
	dofile ( app.folders.sourcefolder .. '/modules/install.lua' )

elseif ( arg[1] == 'update' ) then

	package_args = {} 
	for i= 2, #arg do package_args[#package_args +1] = arg[i] end
	
	dofile ( app.folders.sourcefolder .. '/modules/update.lua' )

elseif ( arg[1] == 'remove' and arg[2] ) then
	local _package_name = arg[2]
	
	if repository.remove(_package_name) then
		print 'Library is successfully removed.'
	end

else
	if ( arg[1] == '-l' ) then
	    print '[lide.error] Please import using require inside the lua file.'
	    
	    os.exit()
	elseif arg[1] then	
		if lide.file.doesExists(arg[1]) then
			run_sandbox( arg[1] )
		else
			local src_file = arg[1]
			printl '[lide.error: ] "$src_file$" file does not exist.'
		end
	end
end

