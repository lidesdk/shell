-- ///////////////////////////////////////////////////////////////////////////////
-- // Name:        lide.lua
-- // Purpose:     Lua interpreter with lide framework integrated
-- // Created:     2017/09/24
-- // Copyright:   (c) 2017 Hernan Dario Cano [dcanohdev@gmail.com]
-- // License:     GNU GENERAL PUBLIC LICENSE
-- ///////////////////////////////////////////////////////////////////////////////

assert(os.getenv 'LIDE_PATH', '[lide shell] Please define `LIDE_PATH` variable.');

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

app = lide.app

-- Define paths:
local access_token  = os.getenv 'GITHUB_TOKEN'

app.folders = { install, libraries, ourclibs, ourlibs }	

app.folders.sourcefolder = normalize_path( os.getenv 'LIDE_PATH' )
app.folders.libraries    = normalize_path( os.getenv 'LIDE_PATH' .. '/libraries')

-- 
-- load thirdparty libraries that'll be used on this app
--

lide.zip 		  = require 'lide_zip'

local inifile 	  = require 'inifile'
local sqldatabase = require 'sqldatabase.init'
local github      = require 'github'
local http        = require 'http.init'

repository = {}

repository.access_token = access_token

--- 
--- repositore.remove ( string _package_name ) 
---  remove package from lide.
---
function repository.remove ( _package_name )
	local _package_version
	local _osname = lide.platform.get_osname():lower();

	local _manifest_file = ('%s/%s/%s.manifest'):format(app.folders.libraries, _package_name, _package_name)

	if lide.file.doesExists(_manifest_file)
	and lide.folder.doesExists(app.folders.libraries ..'/'.._package_name) then
		
		local package_manifest = inifile.parse_file(_manifest_file)[_package_name]

			for arch_line in package_manifest[_osname] : delimi '|' do -- architectures are delimited by |
				local arch_line = arch_line:delim ':'
				local _files    = trim(arch_line[2] or '') : delim ',' -- files are delimiteed by comma					
				local todel_files = {}

				-- copy file to destination: libraries/windows/x64/luasql/sqlite3.dll
				for _, int_path in pairs(_files) do -- internal_paths
					local file_dst = normalize_path(app.folders.libraries ..'/'.. int_path);
					
					if lide.file.doesExists(file_dst) then
						os.remove(file_dst)
						todel_files[#todel_files] = file_dst
					end
				end

				for _, file in pairs(todel_files) do
					if lide.file.doesExists(file) then
						return false, ('File %s wasn\'t removed'):format(file)
					end
				end
			end
		
		lide.core.folder.delete(normalize_path(app.folders.libraries .. '/' .. _package_name));	

		return true
	else
		return false, ('Error: Package %s is not installed.'):format(_package_name)
	end
end

--- 
--- repositore.download_db ( string url_db_file, string dest_file_path, string access_token ) 
---  download database file
---
--  repository.libraries_stable = sqldatabase:new(app.folders.libraries..'/repos.db', 'sqlite3')
function repository.download_db ( url_db_file, dest_file_path, access_token ) -- repo update
	local a,b = url_db_file:find 'github.com'
	
	github.download_file ( url_db_file:sub(b+2, # url_db_file), dest_file_path, file_ref, repository.access_token )
end

--- 
--- repository.update_repos ( string lide_repos_config_file, string work_download_folder )
---  update all repos
---
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

---
--- repository.download_package ( string _package_name, string _package_file, string access_token )
---   downloadk zip package of lide library
---
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
		-- https://raw.githubusercontent.com/dcano/repos/master/stable/cjson/cjson-2.1.0.zip
		http.download(result_repo.package_url, normalize_path(_package_file))
	else
		local github_package_path = result_repo.package_url
		local content = github.get_file ( github_package_path, ('package.lide'), repository.access_token )
		
		if not content then
			print ('!Error: no se pudo descargar el paquete: ' .. github_package_path)
			return false, '!Error: no se pudo descargar el paquete: ' .. github_package_path
		end

		local zip_file = io.open(normalize_path(_package_file), 'w+b');

		if zip_file:write(content) then
			zip_file:close();
		end
	end


	repository.loaded_repos = loaded_repos
end

---
--- install_package ( string _package_name, string _package_file, string _package_prefix)
---   install package of library from databases
---
function repository.install_package ( _package_name, _package_file, _package_prefix)
	_package_file = normalize_path(_package_file)

	if not lide.file.doesExists(_package_file) then
		return false, '! Error: The package: ' .. tostring(_package_file) .. ' is not downloaded now.'
	end

	local _manifest_file = normalize_path(app.folders.libraries ..'/'.._package_name..'/'.. _package_name ..'.manifest')
	
	if _package_prefix and _package_prefix:gsub(' ', '') ~= '' then
		_package_prefix = _package_prefix ..'/'
	end

	if not lide.zip.extractFile(_package_file, (_package_prefix or '') .. _package_name .. '.manifest', _manifest_file) then
		return false, ('> ERROR: Manifest file "%s" doesn\'t exists into "%s" package'):format((_package_prefix or '') .. _package_name .. '.manifest', _package_file)
	end
	
	local _osname = lide.platform.getOS():lower()
	local _osarch = lide.platform.getArch():lower()

	local _lide_path = os.getenv 'LIDE_PATH'

	local _runtimefolder = normalize_path(_lide_path ..'/bin')
	
	function lide_file_copy ( src_file, dst_file )
		local file_src     = io.open(src_file, 'rb')
		local file_content = file_src : read '*a'
		--lide.lfs.lock(file_src)
		-- only copy new files if file dooesn exist
		if not lide.core.file.doesExists( dst_file ) then
			local file_dst = io.open(dst_file, 'w+b')
			file_dst:write(file_content)
			file_dst:flush()
			file_src:close()

			file_dst:close()
		end
		--lide.lfs.unlock(file_src)
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

	local _arch_runtime_downloads = normalize_path(app.folders.libraries..'/'.._osname..'/'.._osarch..'/runtime')
	
	if not lide.core.file.doesExists( _arch_runtime_downloads ) then
		lide.mktree(_arch_runtime_downloads)
	end

	lide_folder_copy(_arch_runtime_downloads, _runtimefolder)

	------------------------------------------------------------
	------------------------------------------------------------
	local package_manifest = inifile.parse_file(_manifest_file)[_package_name]
		
	if rawget(package_manifest, _osname) then
		local compatible;
		local architectures = package_manifest[_osname] : delim '|'
		
		for _, arch_line in pairs(architectures) do
			
			arch_line = arch_line:gsub(' ', '');

			if not compatible and (tostring(arch_line:sub(1,3)) == _osarch) then
				compatible = true;
			end
		end

		if not compatible then
			return false, '"' .. _package_name .. '" is not available on ' .. _osarch .. ' architecture.'
		end 

		for arch_line in package_manifest[_osname] : delimi '|' do -- architectures are delimited by |
			arch_line = arch_line:delim ':' 
			--local _osname = _osname
			--local _arch   = (arch_line[1] or ''):gsub(' ', '')
			local _files  = (arch_line[2] or ''):gsub(' ', '') : delim ',' -- files are delimiteed by comma					

			-- This step copy file to destination: libraries/windows/x64/luasql/sqlite3.dll
			for _, int_path in pairs(_files) do -- internal_paths
				local file_dst = normalize_path(app.folders.libraries ..'/'.. int_path)
				local a,b       = file_dst:gsub('\\', '/'):reverse():find '/'
				local _filename = file_dst:reverse():sub(1, b) : reverse()
				local _foldernm = file_dst:sub(1, file_dst:find(_filename) -1)
				
				lide.mktree(_foldernm)


				lide.zip.extractFile(_package_file, (_package_prefix or '') .. int_path, file_dst)
			end
		end

		
	elseif not rawget(package_manifest, _osname) then
		return false, '"' .. _package_name .. '" is not available on ' .. _osname .. '.'
	end

	local function install_depends ( package_manifest, _package_name )
		local depends = package_manifest.depends : delim ','
				
		printl '  > installing dependencies for $_package_name$:'
	
		for _, _package_name in pairs( depends ) do

			if lide.folder.doesExists(app.folders.libraries ..'/'.._package_name) then
				printl '  > $_package_name$ is installed now.'
			else
				printl '  > installing $_package_name$' 
				
				local package_zip_file = normalize_path(app.folders.libraries .. '\\'.._package_name .. '\\'.._package_name .. '.zip' ):gsub(' ', '')
				
				lide.mktree (normalize_path(app.folders.libraries .. '\\'.._package_name):gsub(' ', ''))
				
				repository.download_package(_package_name, package_zip_file)			
				
				local install_depend, last_error = repository.install_package (_package_name, package_zip_file)
				
				if not install_depend then
					return false, last_error or 'Dependencies not satisfied: ' .. _package_name
				end
			end
		end

		return true;
	end

	if package_manifest.depends and package_manifest.depends ~= '' then 
		local install_deps, last_error = install_depends(package_manifest, _package_name)
		
		if not install_deps then
			lide.folder.deleteTree(app.folders.libraries ..'/'.._package_name)
			return false, last_error
		end
	end

	return true;
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
		
		-- Ejecutar el interprete apropiado:
		if ( CURRENT_PLATFORM == 'linux' ) then
			local _exec_str  = '%s/bin/%s/%s/lua %s/bin/lide51_src.lua %s'

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
	 
	dofile ( app.folders.sourcefolder .. '/modules/install.lua' )

elseif ( arg[1] == 'update' ) then

	package_args = {} 
	for i= 2, #arg do package_args[#package_args +1] = arg[i] end
	-- emulate env sandbox:
	--inifile = require 'inifile'

	dofile ( app.folders.sourcefolder .. '/modules/update.lua' )

elseif ( arg[1] == 'remove' and arg[2] ) then
	local _package_name = arg[2]
	local repo_rem, last_error = repository.remove(_package_name)
	
	if repo_rem then
		print 'Library is successfully removed.'
	else
		print(last_error)
	end

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