--assert(os.getenv 'LIDE_PATH', '[lide commandline] Declare la variable de entorno LIDE_PATH');
--
--package.path =  os.getenv 'LIDE_PATH' ..'\\?.lua;' 
--			 .. os.getenv 'LIDE_PATH' ..'\\lua\\windows\\?.lua;'
--			 .. os.getenv 'LIDE_PATH' ..'\\libraries\\?.lua;'; 
--
--local LIDE_PATH = os.getenv 'LIDE_PATH'

assert(os.getenv 'LIDE_PATH', '[lide commandline] Declare la variable de entorno LIDE_PATH');
--
package.path =  os.getenv 'LIDE_PATH'..'/libraries/?.lua;' .. package.path
			 --.. os.getenv 'LIDE_PATH' ..'\\lua\\windows\\?.lua;'
--			 .. os.getenv 'LIDE_PATH' ..'\\libraries\\?.lua;'; 
--
local LIDE_PATH      = os.getenv 'LIDE_PATH'
--local LIDE_FRAMEWORK = os.getenv 'LIDE_FRAMEWORK'
local _LIDE_VERSION  = '0.0.01'

--print('A:'.. os.getenv 'LIDE_FRAMEWORK':gsub('lide', '?') ..'\\.lua;' )

require 'lide.core.init'

local CURRENT_PLATFORM = lide.platform.getOSName()

function log ( ... )
	--print(...);
end

local function trim ( str )
	repeat str = str:gsub ('  ', '')
	until not str:find ' '
	return str
end

function lide.mktree ( src_file ) -- make only tree of dirs of this file
	local sep,INIT = '\\', ''
	
	if lide.platform.getOSName() == 'Linux' then 
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

local function normalize_path ( path )
	if lide.platform.getOSName() == 'Windows' then
		return (path:gsub('/', '\\'));
	elseif lide.platform.getOSName() == 'Linux' then
		return tostring(path:gsub('\\', '/'):gsub('//', '/'));
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

--app.folders.sourcefolder = arg[0]:sub(1, #arg[0] - 9, #arg[0])
app.folders.sourcefolder = normalize_path( os.getenv 'LIDE_PATH' )
--app.folders.libraries =  normalize_path(app.folders.sourcefolder .. '/libraries')
app.folders.libraries =  normalize_path( os.getenv 'LIDE_PATH' .. '/libraries')

if lide.platform.getOSName() == 'Windows' then
--	
--	local arch     = lide.platform.getArch ()         --'x86' -- x64, arm7
--	local platform = lide.platform.getOS () : lower() -- windows, linux, macosx
--
--	lua_dir = (os.getenv 'LIDE_PATH' .. '\\lua\\%s\\%s\\?.lua;'):format(platform, arch) ..
--	          (os.getenv 'LIDE_PATH' .. '\\lua\\%s\\?.lua;'):format(platform) ..
--	          (os.getenv 'LIDE_PATH' .. '\\lua\\?.lua;')  -- Crossplatform: root\lua\package.lua
--
--	clibs_dir=(os.getenv 'LIDE_PATH' .. '\\clibs\\%s\\%s\\?.dll;'):format(platform, arch) ..
--	          (os.getenv 'LIDE_PATH' .. '\\clibs\\%s\\?.dll;'):format(platform)
--
	--package.path   = lua_dir ..
	package.path  = package.path .. ';' .. --  .. 'lua\\?.lua' ..
					 os.getenv 'LIDE_PATH' .. '\\lua\\?.lua;' --..
					 --os.getenv 'LIDE_PATH' .. '\\?.lua'
--
	--package.cpath  = clibs_dir
    package.cpath = package.cpath .. ';' ..
                   os.getenv 'LIDE_PATH' .. '\\clibs\\?.dll;'

	
elseif lide.platform.getOSName() == 'Linux' then

	--app.folders.install   = app.folders.sourcefolder

	--app.folders.ourclibs  = app.folders.sourcefolder .. '/lnx_clibs'
	
--	print ('arch:' .. lide.platform.getArch ())

	--[[package.cpath = app.folders.sourcefolder .. '/?.so;' ..
					app.folders.sourcefolder .. '/env/?.so;' 
					--app.folders.sourcefolder .. ('/clibs/linux/%s/?.so;'):format('x64') .. package.cpath
	package.path  = app.folders.sourcefolder .. '/?.lua;' ..
					app.folders.sourcefolder .. '/lua/linux/?.lua;' ..
					app.folders.sourcefolder .. '/lua/?.lua;' .. package.path]]
end


--local luasql  = require 'luasql.sqlite3'
inifile = require 'inifile'
--io.stdout : write (tostring(inifile)..'\n')
local sqldatabase = require 'sqldatabase.init'
local github      = require 'github'
lide.zip 		  = require 'lide_zip'
local http        = require 'http.init'

--print('github:' .. tostring(github.get_file))
repository = {}

repository.access_token = access_token

--repository.libraries_stable = sqldatabase:new(app.folders.libraries..'/repos.db', 'sqlite3')

function repository.update ( access_token )
	--repos inifile.getsections( _file_configfile )
	--local _db_url = 
	local db_content, errcode, errmsg  = github.get_file ( 'lidesdk/repos/libraries.db', nil, repository.access_token )

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

---function repository.download ( _package_name, _package_file, access_token )
---	local _query_install = 'select * from lua_packages where package_name like "%s" limit 1'
---	
---	local github_path = repository.libraries_stable:select(_query_install:format(_package_name))[1].package_url
---	
---	local content = github.get_file ( github_path, nil, repository.access_token )
---	
---	if not content then
---		print ('!Error: no se pudo descargar el paquete: ' .. github_path)
---		return false
---	end
---
---	local zip_file = io.open(normalize_path(_package_file), 'w+b');
---
---	if zip_file:write(content) then
---		zip_file:close();
---	end
---end

local function ExtractZipAndCopyFiles(zipFilePath, destinationPath)
    local zfile, err
    
    if lide.file.doesExists(zipFilePath) then
    	zfile, err = zip.open(zipFilePath)
    else
    	return false
    end
	
	lide.mktree(destinationPath)

    -- iterate through each file insize the zip file
    for file in zfile:files() do
        --print(destinationPath .. file.filename)

        local currFile, err = zfile:open(file.filename)
        local currFileContents = currFile:read("*a") -- read entire contents of current file
        local hBinaryOutput = io.open(normalize_path(destinationPath ..'\\'.. file.filename), "w+b")
        
        lide.mktree(normalize_path(destinationPath ..'\\'.. file.filename))

        -- write current file inside zip to a file outside zip
        if(hBinaryOutput)then
            hBinaryOutput:write(currFileContents)
            hBinaryOutput:close()
        end
    end
    --zfile:close() !BLOQUEA EL PC
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
			--io.popen ('del /Q /S "' .. normalize_path(app.folders.libraries ..'/windows_x86/lua/'.._package_name..'.lua"'));
			--io.popen ('rd /Q /S "' .. normalize_path(app.folders.libraries ..'/windows_x86/lua/'.._package_name..'"'));
			--io.popen ('rd /Q /S "' .. normalize_path(app.folders.libraries ..'/windows_x86/clibs/'.._package_name..'"'));
			--io.popen ('rd /Q /S "' .. normalize_path(app.folders.libraries ..'/'.._package_name..'"'));
			--io.popen ('del /F /Q /S "' .. normalize_path(app.folders.libraries ..'/'.._package_name..'".zip'));
			lide.core.folder.delete(normalize_path(app.folders.libraries .. '/' .. _package_name));
			lide.core.folder.delete(normalize_path(app.folders.libraries .. '/windows_x86/clibs/' .. _package_name));
			lide.core.folder.delete(normalize_path(app.folders.libraries .. '/windows_x86/lua/' .. _package_name));
		end

		return true
	else
		last_error = ('The package "%s" doesn\'t installed.'):format(_package_name)
		return false,  last_error
	end
end


---------------------------------------------------------------------------------------------------

--repository.libraries_stable = sqldatabase:new(app.folders.libraries..'/repos.db', 'sqlite3')
function repository.download_db ( url_db_file, dest_file_path, access_token ) -- repo update
	local a,b = url_db_file:find 'github.com'
	local db_content, errcode, errmsg  = github.get_file ( url_db_file:sub(b+2, # url_db_file), file_ref, repository.access_token )
	local repos_db

	if db_content then
		if not dest_file_path then
			repos_db, err = io.open(normalize_path(app.folders.libraries..'/repos.db'), 'w+b')
--			print(repos_db, err)
		else
			repos_db, err = io.open(normalize_path(dest_file_path), 'w+b')
--			print(repos_db, err)
		end

		if repos_db:write(db_content) then
			repos_db:close()
			-- OK SUccess
		else
			--any error writeing file
		end
	else
		print 'There\'s a problem with repo url.\n'
		print ('[lide.github]: ', errmsg .. ' - ' .. url_db_file )
	end
end

---- Update all repos:
----- repository.update_repos ( lide_repos_config_file, work_download_folder )
function repository.update_repos ( lide_repos, work_folder )
	work_folder = normalize_path(work_folder)
	lide_repos  = normalize_path(lide_repos) --:gsub(' ', '')

	if inifile.parse_file then
		parsed = inifile.parse_file(lide_repos, 'io')
	elseif inifile.parse then
		parsed = inifile.parse(lide_repos, 'io')
	end


	if parsed then
		for repo_name, repo in next, parsed do
			if repo.url then
				repository.repos[repo_name] = repo
				repository.repos[repo_name].path = normalize_path(work_folder .. '/'..repo_name..'.db')
				repository.repos[repo_name].sqldb = sqldatabase:new(repo.path, 'sqlite3')
				repository.download_db (repo.url, normalize_path(work_folder .. '/'..repo_name..'.db'))
			else
				print 'There\'s a problem with repo url.\n'
				print ('[lide]: '.. repo_name .. ' ' .. tostring(repo.url))
			end	
		end
		return parsed
	end
end

function repository.download_package ( _package_name, _package_file, access_token )
	local rst = {}
	local result_repo
	local loaded_repos = {}
	local _query_install = 'select * from lua_packages where package_name like "%s" limit 1'

	for repo_name, repo in pairs(repository.repos) do
	
		loaded_repos[repo_name] = sqldatabase:new(repo.path, 'sqlite3')
		
		--- Si encuentra el paquete en el primer repositorio: ese es
		if loaded_repos[repo_name]:select(_query_install:format(_package_name))[1] then
			result_repo = loaded_repos[repo_name]:select(_query_install:format(_package_name))[1]
			--return first_repo
			break
		end
	end
	
	if not result_repo then
		return false, 'The package doesn\'t exists in any repo'
	end

	if result_repo.package_url then
		--app = lide.app	
		--print(result_repo.package_url)

		--https://raw.githubusercontent.com/dcano/repos/master/stable/cjson/cjson-2.1.0.zip

		http.download(result_repo.package_url, normalize_path(_package_file))

--		return true
	else
		local github_package_path = result_repo.package_url
		local content = github.get_file ( github_package_path, nil, repository.access_token )
		
		if not content then
			print ('!Error: no se pudo descargar el paquete: ' .. github_package_path)
			return false
		end

		local zip_file = io.open(normalize_path(_package_file), 'w+b');

		if zip_file:write(content) then
			zip_file:close();
		end
	end


	repository.loaded_repos = loaded_repos
end

function repository.install_package ( _package_name, _package_file, _package_prefix)
	_package_file = normalize_path(_package_file)

	if not lide.file.doesExists(_package_file) then
		print ('! Error: el paquete: ' .. tostring(_package_file) .. 'no se pudo instalar.')
		return

	end

	local _manifest_file = normalize_path(app.folders.libraries ..'/'.._package_name..'/'.. _package_name ..'.manifest')
	
	if _package_prefix and _package_prefix:gsub(' ', '') ~= '' then
		_package_prefix = _package_prefix ..'/'
	end

	--print((_package_prefix or '') .. _package_name .. '.manifest')
	

	if not lide.zip.extractFile(_package_file, (_package_prefix or '') .. _package_name .. '.manifest', _manifest_file) then
		print	 (('> ERROR: Manifest file "%s" doesn\'t exists into "%s" package'):format((_package_prefix or '') .. _package_name .. '.manifest', _package_file))
		os.exit()
	end
	
	-- .................
	
	local _osname = lide.platform.getOS():lower()
	local _arch   = lide.platform.getArch():lower()

	local _lide_path = os.getenv 'LIDE_PATH'

	local _runtimefolder = normalize_path(_lide_path ..'/bin')
	
	function lide_file_copy ( src_file, dst_file )
		local file_src     = io.open(src_file, 'rb')
		local file_content = file_src : read '*a'

		-- only copy new files if file dooesn exist
		if not lide.core.file.doesExists( dst_file ) then
			local file_dst = io.open(dst_file, 'w+b')
			file_dst:write(file_content)
			file_dst:flush()
			file_src:close()
			file_dst:close()
		end
	end

	-- funcion para copiar los archivos de una carpeta recursivamente
	function lide_folder_copy( src_folder, dst_folder )
		for file in lide.lfs.dir( src_folder ) do
		    local _file_path = normalize_path(src_folder .. '/' .. file)
		    
		    -- File is the current file or directory name
		    if lide.lfs.attributes (_file_path) . mode ~= 'directory' then
		    	lide_file_copy ( _file_path, normalize_path(dst_folder .. '/'.. file) )
		    end
		end
	end

	------------------------------------------------------------
	------------------------------------------------------------
	-- Runtime Donwloads Folder: 

	local _arch_runtime_downloads = normalize_path(app.folders.libraries..'/'.._osname..'/'.._arch..'/runtime')
	
	if not lide.core.file.doesExists( _arch_runtime_downloads ) then
		lide.mktree(_arch_runtime_downloads)
	end

	lide_folder_copy(_arch_runtime_downloads, _runtimefolder)

	------------------------------------------------------------
	------------------------------------------------------------

	local package_manifest = inifile.parse_file(_manifest_file)[_package_name]
	
	if rawget(package_manifest, lide.platform.getOS():lower()) then
		for arch_line in package_manifest.windows : delimi '|' do -- architectures are delimited by |
			arch_line = arch_line:delim ':' 
			local _osname = lide.platform.getOS():lower()
			local _arch   = arch_line[1]
			local _files  = trim(arch_line[2] or '') : delim ',' -- files are delimiteed by comma					

			--	-- copy file to destination: libraries/windows/x64/luasql/sqlite3.dll
			for _, int_path in pairs(_files) do -- internal_paths
				local file_dst = normalize_path(app.folders.libraries ..'/'.. int_path)
				local a,b       = file_dst:gsub('\\', '/'):reverse():find '/'
				local _filename = file_dst:reverse():sub(1, b) : reverse()
				local _foldernm = file_dst:sub(1, file_dst:find(_filename) -1)
				
				log ('  > ' .. file_dst)

				lide.mktree(_foldernm)
				--print((_package_prefix or '') .. int_path)
				lide.zip.extractFile(_package_file, (_package_prefix or '') .. int_path, file_dst)
			end
		end
	elseif not rawget(package_manifest, lide.platform.getOS():lower()) then
		print ('  ! Error: module ' .. _package_name .. ' is not available on ' .. lide.platform.getOS())
		os.exit()
	end

	local function install_depends ( package_manifest )
		local depends = package_manifest.depends : delim ','

		for _, _package_name in pairs( depends ) do
			local _package_name   = _package_name:gsub(' ', '')
			
			if lide.folder.doesExists(app.folders.libraries ..'/'.._package_name) then
				--> printl '  > Dependencies: $_package_name$ installed'
			else
				print ('  > Installing dependencies: '.. _package_name) 
				
				local package_zip_file = (app.folders.libraries .. '\\'.._package_name .. '\\'.._package_name .. '.zip' ):gsub(' ', '')
				
				lide.mktree ((app.folders.libraries .. '\\'.._package_name):gsub(' ', ''))
				
				repository.download_package(_package_name, package_zip_file)			
				repository.install_package (_package_name, package_zip_file)
			end
		end
	end

	if package_manifest.depends and package_manifest.depends ~= '' then 
		install_depends(package_manifest)
	end
end



















































---------------------------------------------------------------------------------------------

local framework = {}

function framework.run ( filename, env, req, ... )
	local chunk = loadfile(filename)
	
	if not chunk then	
		print 'syntax error'
		os.exit()
	end

	do  -- Usar una copia separada del Lide que se est?ejecutando:
		local _LIDE_BIN = os.getenv 'LIDE_BIN'
		
		if ( CURRENT_PLATFORM == 'Linux' ) then
			--local exec, errm = pcall(os.execute, (_LIDE_BIN or 'lua5.1') .. [[ -e 'package.cpath = os.getenv 'LIDE_PATH' ..'/libraries/linux_x86/?.so;' package.path = package.path ..";"..os.getenv "LIDE_PATH" .."/libraries?.lua;" require "lide.core.init"']].. ' -l lide.init ' .. filename)
			--os.execute( [[lua5.1 -e "package.cpath = os.getenv 'LIDE_PATH' ..'/libraries/linux_x86/?.so' package.path = os.getenv 'LIDE_PATH' ..'/libraries/?.lua'; require 'lide.init' " ]] .. filename )
					--os.execute ('lua5.1 %s'):format(filename)
			
			os.execute ( 
				os.getenv('LIDE_PATH') .. '/bin/linux/x64/lua ' .. filename -- execute lide51 interpreter
			);

		elseif ( CURRENT_PLATFORM == 'Windows' ) then
			--- Ejecutamos el interprete de lua basado en wxluafreeze:
			---  bin/gui.exe
			---
			--- Este ejecutable contiene todas las librerias necesarias para una correcta ejecucion de
			--- componentes graficos compatibles con wxLua y Lua.
			os.execute 'CLS'
			os.execute ( 
				os.getenv('LIDE_PATH') .. '\\bin\\lide51.exe ' .. filename -- execute lide51 interpreter
			)
		end
	end
end

--table.print(framework)

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
	-- emulate env sandbox:
	--inifile = require 'inifile'

	dofile ( app.folders.sourcefolder .. '/modules/update.lua' )

elseif ( arg[1] == 'remove' and arg[2] ) then
	local _package_name = arg[2]
	
	if repository.remove(_package_name) then
		print 'Library is successfully removed.'
	else
		print ('! Library ' .. arg[2] .. ' isn\'t installed now.')
	end

elseif ( arg[1] == '--test' ) then
    io.stdout:write '[lide test] all ok.\n'

elseif ( arg[1] == '--version' ) then

    io.stdout:write (('Lide: %s\nLua: %s'):format(_LIDE_VERSION, _VERSION))

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
 To install luasql package:
  > lide install luasql
	
 To search for md5 package:
  > lide search md5

For bug reporting instructions, please see:
<https://github.com/lidesdk/commandline/issues>.]]

else
	if ( arg[1] == '-l' ) then
	    print '[lide.error] Please import using require inside the lua file.'
	    
	    os.exit()
	elseif arg[1] then	
		if lide.file.doesExists(arg[1]) then
			framework.run ( arg[1] )--, { inifile = inifile, repository = repository } )
		else
			local src_file = arg[1]
			printl '[lide.error: ] "$src_file$" file does not exist.'
		end
	elseif # arg == 0 then

		-- Execute interactive commandline
		framework.run ( app.folders.sourcefolder .. '/modules/interactive.lua' )
	end
end
