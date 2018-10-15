-- ///////////////////////////////////////////////////////////////////////////////
-- // Name:        repos-api.lua
-- // Purpose:     Define Lua repositories API
-- // Created:     2018/05/06
-- // Copyright:   (c) 2018 Hernan Dario Cano [dcanohdev@gmail.com]
-- // License:     GNU GENERAL PUBLIC LICENSE
-- ///////////////////////////////////////////////////////////////////////////////

reposapi    = { repos = { } };
luasql      = require 'luasql.sqlite3'
github      = require 'github'
inifile     = require 'inifile'
sqldatabase = require 'sqldatabase.init'
http        = require 'http.init'
lide_zip    = require 'lide_zip'

local normalize_path   = lide.platform.normalize_path;

app.folders.libraries = app.folders.libraries

local installed_db_path = normalize_path((app.folders.libraries .. '/%s/%s/installed.db'):format(lide.platform.get_osname(), lide.platform.get_osarch()))

lide.mktree(installed_db_path:gsub('installed.db', ''))		

reposapi.access_token = '8dd5e4bcf2440bfad374a37d91d54576be9be695'

--here
reposapi.installed = sqldatabase:new(installed_db_path, 'sqlite3')

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

--
--- local compare_versions ('1.0.0', '2.0.0')
---   Compare versions using semver.
---
---   return 0 if versions are the same, 1 if ver1 is higher than ver2, 2 if ver1 is lower than ver2
--    
local function compare_versions ( ver1, ver2 )
	for i = 1, 3 do
		if tonumber(ver1 : delim '%.' [i]) == tonumber(ver2 : delim '%.' [i]) then
			if tonumber(ver1 : delim '%.' [2]) == tonumber(ver2 : delim '%.' [2]) then
				if tonumber(ver1 : delim '%.' [3]) == tonumber(ver2 : delim '%.' [3]) then
					return 0;
				end

			end
		elseif tonumber(ver1 : delim '%.' [i]) > tonumber(ver2 : delim '%.' [i]) then
			return 1;
		elseif tonumber(ver1 : delim '%.' [i]) < tonumber(ver2 : delim '%.' [i]) then
			return 2;
		end
	end
	-- 0  ver1 == ver2, -- 1  ver1 > ver 2, -- 2  ver1 < ver 2
end

reposapi.compare_versions = compare_versions

local function trim ( str )
	repeat str = str:gsub ('  ', '')
	until not str:find ' '
	return str
end

local function trim2(s)
	return s:match "^%s*(.-)%s*$"
end

--
--- reposapi.download_db ( string url_db_file, string dest_file_path, string access_token ) 
---  Download database file
--
function reposapi.download_db ( url_db_file, dest_file_path, access_token ) -- repo update
	local a,b = url_db_file:find 'github.com'
	
	github.download_file ( url_db_file:sub(b+2, # url_db_file), dest_file_path, file_ref, reposapi.access_token )
end

--- 
--- reposapi.remove ( string _package_name ) 		
---  remove package from lide.
---
function reposapi.remove_package ( _package_name )
	-- 
	local _osname = lide.platform.get_osname():lower();

	--local _manifest_file = normalize_path('%s/%s/%s.manifest'):format(app.folders.libraries, _package_name, _package_name)
	--local _package_file  = normalize_path('%s/%s/%s.zip'):format(app.folders.libraries, _package_name, _package_name)

	--local _manifest_contents, errmsg = lide.zip.getInternalFileContent ( _package_file, (_package_prefix or 'lfs-package.lide/') .. _package_name .. '.manifest' );

--[[	local package_manifest  = inifile.parse (_manifest_contents)[_package_name]
	local _package_version  = inifile.parse (_manifest_contents)[_package_name]['version']


	if lide.file.doesExists(_manifest_file)
	and 
	lide.folder.doesExists(app.folders.libraries ..'/'.._package_name) then
		
		local package_manifest = inifile.parse_file(_manifest_file)[_package_name]

			if not package_manifest[_osname] then
				return false, ('Error: Package %s %s is not available on %s platform.'):format(_package_name, package_manifest ['version'], _osname)
			end

			for arch_line in package_manifest[_osname] : delimi '|' do -- architectures are delimited by |
				local arch_line = arch_line:delim ':'

				local _files    = trim(arch_line[2] or '') : delim ',' -- files are delimiteed by comma					
				]]

				local _files_line = reposapi.installed : select (('select package_files from lua_packages where package_name like "%s"') : format (_package_name) ) [1] . package_files
				local _files      = trim(_files_line or '') : delim ','
				local todel_files = {}

				-- copy file to destination: libraries/windows/x64/luasql/sqlite3.dll
				for _, int_path in pairs(_files) do -- internal_paths
					local file_dst = normalize_path(app.folders.libraries ..'/'.. int_path);
					
					if lide.file.doesExists(file_dst) then
						lide.file.remove(file_dst)
						todel_files[#todel_files] = file_dst
					end
				end

				for _, file in pairs(todel_files) do
					if lide.file.doesExists(file) then
						return false, ('File %s wasn\'t removed'):format(file)
					end
				end
		--	end
		
		lide.core.folder.delete(normalize_path(app.folders.libraries .. '/' .. _package_name));	
		
		reposapi.installed: exec (('DELETE FROM lua_packages WHERE package_name LIKE "%s"'):format (_package_name))

	--	return true
	--else
	--	return false, ('Error: Package %s is not installed.'):format(_package_name)
	--end
end



--- 
--- reposapi.update_repos ( string lide_repos_config_file, string work_download_folder )
---  Update all repos
---
function reposapi.update_repos ( lide_repos, work_folder )
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
				reposapi.repos[repo_name] = repo
				reposapi.repos[repo_name].path = normalize_path(work_folder .. '/'..repo_name..'.db')
				reposapi.repos[repo_name].sqldb = sqldatabase:new(repo.path, 'sqlite3')
				if not lide.file.exists (work_folder..'/'..repo_name .. '.db') then
					lide.log ('[package.lide] Downloading %s db', repo_name)

					reposapi.download_db (repo.url, normalize_path(work_folder .. '/'..repo_name..'.db'))
				end
			elseif not repo.url then
				print 'package.update: There\'s a problem with repo url.\n'
				print ('[lide]: '.. repo_name .. ' ' .. tostring(repo.url))
			end	
		end
		
		local installed_db_path = normalize_path((app.folders.libraries .. '/%s/%s/installed.db'):format(lide.platform.get_osname(), lide.platform.get_osarch()))
		
		lide.mktree(installed_db_path:gsub('installed.db', ''))		

		--here
		reposapi.installed = sqldatabase:new(installed_db_path, 'sqlite3')
		
		if 0 == #reposapi.installed:select "SELECT name FROM sqlite_master WHERE type='table' AND name='lua_packages';" then
			reposapi.installed:exec 'CREATE TABLE "lua_packages" ("package_name" Text, "package_version" Text, "package_files" Text, "package_prefix" Text);'
		end

		return parsed
	end
end

--
--- reposapi.get_installed_package ( 'lanes' )
---  Returns a representation of package using lua tables.
--
--function reposapi.get_installed_package ( _packagename )
--	local _manifest_file   = ('%s/%s/%s.manifest'):format(app.folders.libraries, _packagename, _packagename);
--	local package_manifest = inifile.parse_file(_manifest_file)[_packagename]
--
--	return package_manifest
--end

function reposapi.get_installed_package ( _package_name )
	local installed_db_path = normalize_path((app.folders.libraries .. '/%s/%s/installed.db'):format(lide.platform.get_osname(), lide.platform.get_osarch()))
	
	---lide.mktree(installed_db_path:gsub('installed.db', ''))		

	--here
	reposapi.installed = sqldatabase:new(installed_db_path, 'sqlite3')


	local result = reposapi.installed : select (('select package_name, package_version from lua_packages where package_name like "%s"') : format ( _package_name) )

	if (# result == 0) then
		return false, ('%s is not installed'):format(_package_name)
	else
		return result[1]
	end
end


---
--- reposapi.download_package ( string _package_name, string _package_file, string access_token )
---   downloadk zip package of lide library
---
function reposapi.download_package ( _package_name, _package_file, package_version, access_token )
	local rst = {}
	local result_repo
	local loaded_repos = {}
	local _query_install

	if package_version then
		_query_install = 'select * from lua_packages where package_name like "%s" and package_version like "%s" ORDER BY package_version DESC LIMIT 1'
	else
		_query_install = 'select * from lua_packages where package_name like "%s" ORDER BY package_version DESC LIMIT 1'
	end

	for repo_name, repo in pairs(reposapi.repos) do
	
		loaded_repos[repo_name] = sqldatabase:new(repo.path, 'sqlite3')
		
		--- Si encuentra el paquete en el primer repositorio: ese es
		if loaded_repos[repo_name]:select(_query_install:format(_package_name, package_version))[1] then
			result_repo = loaded_repos[repo_name]:select(_query_install:format(_package_name, package_version))[1]
			break
		end
	end
	
	if not result_repo then
		return false, 'The package doesn\'t exists in any repo'
	end

	if result_repo.package_url then
		lide.log ('[repos-api] result_repo.package_url: ' .. result_repo.package_url)

		http.download(result_repo.package_url, normalize_path(_package_file), function ( ... )
			-- lide.log (...)
		end)
	else
		-- Handle error
	end

	reposapi.loaded_repos = loaded_repos
end

---
--- install_package ( string _package_name, string _package_file, string _package_prefix)
---   install package of library from databases
---
function reposapi.install_package ( _package_name, _package_file, _package_prefix)
	local _package_file = normalize_path(_package_file)

	local _manifest_file = normalize_path(app.folders.libraries ..'/'.._package_name..'/'.. _package_name ..'.manifest')
	
	if type(_package_prefix) == 'string' then
		if _package_prefix and _package_prefix:sub(#_package_prefix,#_package_prefix) ~= '/' then 
			_package_prefix = (_package_prefix .. '/'):gsub('//', '/')
		else
			--_package_prefix = (_package_name .. '-package.lide')
		end
	
		if _package_prefix == '/' then
			_package_prefix = ''
		end
	end

	if not lide.file.doesExists(_package_file) then
		return false, '! Error: The package: ' .. tostring(_package_file) .. ' is not downloaded now.'
	end

--	if not lide_zip.extractFile(_package_file, (_package_prefix or '') .. _package_name .. '.manifest', _manifest_file) then
--		return false, ('> ERROR: Manifest file "%s" doesn\'t exists into "%s" package'):format((_package_prefix or '') .. _package_name .. '.manifest', _package_file)
--	end
	
	local _osname = lide.platform.get_osname():lower()
	local _osarch = lide.platform.get_osarch():lower()

	local _lide_path = os.getenv 'LIDE_PATH'

	local _runtimefolder = normalize_path(_lide_path .. ('/bin/%s/%s'):format(_osname, _osarch));
	
	function lide_file_copy ( src_file, dst_file )
		local file_src     = io.open(src_file, 'rb')
		local file_content = file_src : read '*a'
		--lide.lfs.lock(file_src)
		-- only copy new files if file dooesn exist
		if not lide.core.file.doesExists( dst_file ) then
			local file_dst = io.open(dst_file, 'w+b')
			file_dst:write(file_content)
			file_dst:flush()			

			file_dst:close()
		end

		file_src:close()
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
	--lide.log('[lide.zip] _prefix: ' .. _package_prefix);
	--lide.log('[lide.zip] getInternalFileContent: '.. _package_file );

	local _manifest_contents, errmsg = lide.zip.getInternalFileContent ( _package_file, (_package_prefix or '') .. _package_name .. '.manifest' );
	lide.log(_manifest_contents)
---	lide.log(tostring(('1.22')))
	--lide.log(tostring(inifile.parse (_manifest_contents, 'memory')))

	local package_manifest = inifile.parse (_manifest_contents, 'memory') [_package_name];


--	os.exit())

	--lide.log('[repos-api] package_manifest.repo$: '.. package_manifest);

	--table.foreach(package_manifest, print)

	--lide.log('[repos-api] package_manifest.repo$: '.. package_manifest.repository);	

	local _package_version   = package_manifest ['version']
	if not package_manifest[_osname] then
	   return false, (('This package isn\'t compatible with %s'):format(_osname))
	   
	end
	local _cur_osname_archs  = package_manifest [_osname]:delim '|' -- osname table of architectures
	
	local files_list = {}
	for _, str_files in pairs(_cur_osname_archs) do
		local arch_str  = str_files : delim ':' [1]
		local files_str = str_files : delim ':' [2]

		files_list[arch_str] = files_str; -- 1 = x86:sdasda/dsads/fsdf.txt = 2
	end

	if not package_manifest[_osname] then
		if not compatible then
			return false, '' .. _package_name .. ' '.. _package_version ..' is not available on ' .. _osarch .. ' architecture.'
		end 
	end

	if not package_manifest or not _package_version then
		return false, '[package.install] Wrong manifest file.'
	end

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
			--return false, '"' .. _package_name .. '" '.. _depend_version..' is not available on ' .. _osarch .. ' architecture.'
			return false, '' .. _package_name .. ' '.. _package_version ..' is not available on ' .. _osarch .. ' architecture.'
		end 

		local _package_files ; for arch_line in package_manifest[_osname] : delimi '|' do -- architectures are delimited by |
			arch_line = arch_line:delim ':' 
			--local _osname = _osname
			--local _arch   = (arch_line[1] or ''):gsub(' ', '')
			local _files  = (arch_line[2] or ''):gsub(' ', '') : delim ',' -- files are delimiteed by comma					
			_package_files = arch_line[2]

			-- This step copy file to destination: libraries/windows/x64/luasql/sqlite3.dll
			for _, int_path in pairs(_files) do -- internal_paths
				local file_dst = normalize_path(app.folders.libraries ..'/'.. int_path)
				
				--local a,b       = file_dst:gsub('\\', '/'):reverse():find '/'
				--local _filename = file_dst:reverse():sub(1, b) : reverse() : gsub ('\\', ''):gsub(' ', '')
				--local _foldernm = file_dst:sub(1, (file_dst:find(_filename) -1 or (#file_dst - #_filename) -1))
				local folder, file, ext;

				if lide.platform.get_osname() == 'windows' then
					folder, file, ext = string.match(file_dst, "(.-)([^\\]-([^%.]+))$")
				elseif lide.platform.get_osname() == 'linux' then
					folder, file, ext = string.match(file_dst, "(.-)([^/]-([^%.]+))$")
				end
				
				local _folder_name = folder:sub(1, #folder -1)

				lide.mktree(_folder_name)


				lide_zip.extractFile(_package_file, (_package_prefix or '') .. int_path, file_dst)
			end
		end

		reposapi.installed:exec (('insert into lua_packages values ("%s", "%s", "%s", "%s")'):format(_package_name, tostring(_package_version), tostring(files_list[_osarch]), tostring(_package_prefix)))


	elseif not rawget(package_manifest, _osname) then
		return false, '"' .. _package_name .. '" is not available on ' .. _osname .. '.'
	end

	---
	-- Runtime Downloads Folder: This step copy runtime libraries to specific interpreter directory
	---

	local _arch_runtime_downloads = normalize_path(app.folders.libraries..'/'.._osname..'/'.._osarch..'/runtime')
	
	lide.mktree(_arch_runtime_downloads)

	lide_folder_copy(_arch_runtime_downloads, _runtimefolder)

	local function install_depends ( package_manifest, _package_name )
		local depends = package_manifest.depends : delim ','

		for _, _depend_string in pairs( depends ) do
			local _depend_name, _depend_version
			local a,b = _depend_string:find ' '

			_depend_name    = _depend_string:delim ' '[1]
			_depend_version = _depend_string:delim ' '[2]
			
			lide.log('[repos-api] _depend_name: '   .. _depend_name)
			lide.log('[repos-api] _depend_version:' .. _depend_version)

			if reposapi.get_installed_package(_depend_name) then
				--printl '  > $_depend_name$ is installed now.'
				--io.stdout:write (('%s %s '):format(_depend_name, _depend_version));
			else
				--- print only current installing:
				print (('> %s %s ...'):format(_depend_name, _depend_version));

				local __packag_repo = trim2(package_manifest.repository);
				
				lide.log('__packag_repo: ' .. __packag_repo)

				local _package_prefix = reposapi.repos[__packag_repo] . sqldb : select('select * from lua_packages where package_name like "'.._depend_name..'" ORDER BY package_version DESC LIMIT 1;')
				
				if _package_prefix and _package_prefix[1] then
					_package_prefix = _package_prefix[1].package_prefix
				end
											
				lide.folder.create ( app.folders.libraries .. '/'.._depend_name )

				local zip_package = normalize_path(app.folders.libraries .. '/'.._depend_name .. '/'.._depend_name .. '.zip')
				
				reposapi.download_package(_depend_name, zip_package, _depend_version, nil_access_token)
				
				local _install_package, lasterror = reposapi.install_package (_depend_name, zip_package, _package_prefix or '')
				
				if _install_package then
					--if 0 == #reposapi.installed:select (('select package_name, package_version from lua_packages where package_name like "%s" and package_version like "%s"'):format(_package_name, _depend_version)) then
					--sreposapi.installed:exec (('insert into lua_packages values ("%s", "%s", "%s")'):format(_depend_name, _depend_version, 'package files'))
					--end
					--print('> OK: '.._depend_name..' successful installed.')
					--reposapi.installed:exec (('insert into lua_packages values ("%s", "%s", "%s", "%s")'):format(_package_name, tostring(_package_version), tostring(_package_files), tostring(_package_prefix)))
--					reposapi.installed:exec (('insert into lua_packages values ("%s", "%s", "%s", "%s")'):format(_package_name, tostring(_package_version), tostring(_package_files), tostring(_package_prefix)))
				else
					--lide.folder.remove_tree ( app.folders.libraries .. '/'.._depend_name )

					--print('> [package.install] ERROR: ' .. lasterror)
					return false, last_error or 'Dependencies not satisfied: ' .. _depend_name
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

--
--- reposapi.update_package (_packagenam, '1.0.0')
---  Update package to determined version
--
function reposapi.update_package ( _packagename, _packagever )
	-- Check current version for compatibility
	-- Download the latest version
	-- Apply the patch.	
	
	local IS_COMPATIBLE;

	if not lide.folder.exists(app.folders.libraries .. '/'.._packagename) then
		lide.folder.create ( app.folders.libraries .. '/'.._packagename );
	end

	local zip_package = app.folders.libraries .. '/'.._packagename .. '/'.._packagename .. '.zip'
	
	--print('a' .. tostring(lide.file.exists(zip_package)))

	--reposapi.download_package(_packagename, zip_package, _packagever, nil_access_token)
	--[[
	
	reposapi.download_package(_packagename, zip_package, _packagever, nil_access_token)
	
	local package_prefix = 'package.lide-3.9.4'

	if not (lide_zip.extractFile(zip_package, _packagename ..'-'.. package_prefix ..'/'.. _packagename .. '.manifest', _manifest_file)) then
		print (('> ERROR: Manifest file "%s" doesn\'t exists into "%s" package'):format(_packagename ..'/'.. package_prefix ..'/'.. _packagename .. '.manifest', zip_package) )
	end
	]]
	if package_version then
		_query_install = 'select * from lua_packages where package_name like "%s" and package_version like "%s" ORDER BY package_version DESC LIMIT 1'
	else
		_query_install = 'select * from lua_packages where package_name like "%s" ORDER BY package_version DESC LIMIT 1'
	end

	local installed_db = sqldatabase:new((app.folders.libraries .. '/%s/%s/installed.db'):format(lide.platform.get_osname(), lide.platform.get_osarch()), 'sqlite3')
	local lualibs = installed_db : select('select * from lua_packages where package_name like "'.._packagename..'" limit 1');
	
	local loaded_repos = {};

	--reposapi.download_package(_packagename, zip_package, _packagever, nil_access_token)

		for repo_name, repo in pairs(reposapi.repos) do
		
			loaded_repos[repo_name] = sqldatabase:new(repo.path, 'sqlite3')
			
			--- Si encuentra el paquete en el primer repositorio: ese es
			if loaded_repos[repo_name]:select(_query_install:format(_packagename, _packagever))[1] then
				result_repo = loaded_repos[repo_name]:select(_query_install:format(_packagename, _packagever))[1]
				break
			end
		end	
	
	---
	--- package_prefix ends with '/'
	---

	local package_prefix = result_repo.package_prefix 

	if package_prefix and package_prefix:sub(#package_prefix,#package_prefix) ~= '/' then 
		package_prefix = (package_prefix .. '/'):gsub('//', '/')
	end

	local _internal_path = (package_prefix or '') .. _packagename .. '.manifest'

	reposapi.download_package(_packagename, zip_package..'-temp', _packagever, nil_access_token)
	
	local _manifest_file_content = lide_zip.getInternalFileContent(zip_package..'-temp', _internal_path);
	
	if (_manifest_file_content) then
		if inifile.parse(_manifest_file_content, 'memory')[_packagename]['compatibility'] then
			for bcompat_ver in inifile.parse(_manifest_file_content, 'memory')[_packagename]['compatibility']:delimi ',' do
				if (bcompat_ver == lualibs[1]['package_version']) then
					IS_COMPATIBLE = true
					break;
				end
			end
		else
			IS_COMPATIBLE = false;
		end
	
		lide.file.remove(zip_package..'-temp')
	end

	if (IS_COMPATIBLE) then
		-- remove last version:
		reposapi.remove_package (_packagename)
		--lide.folder.remove_tree ( app.folders.libraries .. '/'.._packagename )

		local zip_package = app.folders.libraries .. '/'.. _packagename ..'/'.._packagename .. '.zip'
		
		-- install new version
		--lide.folder.create ( app.folders.libraries .. '/temp' )
		
		if not lide.folder.exists ( app.folders.libraries .. '/' .. _packagename ) then
			lide.mktree ( app.folders.libraries .. '/' .. _packagename )
		end		
		
		reposapi.download_package(_packagename, zip_package, _packagever, nil_access_token)

		local _install_package, lasterror = reposapi.install_package ( _packagename, zip_package, package_prefix)
		
		if _install_package then
			print('> OK: '.._packagename..' successful installed.')
		else
			if lide.folder.exists (app.folders.libraries .. '/'.._packagename) then
				lide.folder.remove_tree ( app.folders.libraries .. '/'.._packagename )
			end

			print('> [package.install] ERROR: ' .. lasterror)
		end

	else
		print (('[package.update] error: Current version isn\'t compatible with %s %s'):format(_packagename, _packagever))
		error()
	end
end

return reposapi
