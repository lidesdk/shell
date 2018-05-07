-- ///////////////////////////////////////////////////////////////////////////////
-- // Name:        repos-api.lua
-- // Purpose:     Define Lua repositories API
-- // Created:     2018/05/06
-- // Copyright:   (c) 2018 Hernan Dario Cano [dcanohdev@gmail.com]
-- // License:     GNU GENERAL PUBLIC LICENSE
-- ///////////////////////////////////////////////////////////////////////////////

reposapi    = { repos = {} }
luasql      = require 'luasql.sqlite3'
github      = require 'github'
inifile     = require 'inifile'
sqldatabase = require 'sqldatabase.init'
http        = require 'http.init'
lide_zip    = require 'lide_zip'

local normalize_path   = lide.platform.normalize_path;

app.folders.libraries = app.folders.libraries
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

--
--- reposapi.download_db ( string url_db_file, string dest_file_path, string access_token ) 
---  Download database file
--
function reposapi.download_db ( url_db_file, dest_file_path, access_token ) -- repo update
	local a,b = url_db_file:find 'github.com'
	
	github.download_file ( url_db_file:sub(b+2, # url_db_file), dest_file_path, file_ref, reposapi.access_token )
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
				reposapi.download_db (repo.url, normalize_path(work_folder .. '/'..repo_name..'.db'))
			else
				print 'There\'s a problem with repo url.\n'
				print ('[lide]: '.. repo_name .. ' ' .. tostring(repo.url))
			end	
		end
		return parsed
	end
end

--
--- reposapi.get_installed_package ( 'lanes' )
---  Returns a representation of package using lua tables.
--
function reposapi.get_installed_package ( _packagename )
	local _manifest_file   = ('%s/%s/%s.manifest'):format(app.folders.libraries, _packagename, _packagename);
	local package_manifest = inifile.parse_file(_manifest_file)[_packagename]

	return package_manifest
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
		-- https://raw.githubusercontent.com/dcano/repos/master/stable/cjson/cjson-2.1.0.zip
		http.download(result_repo.package_url, normalize_path(_package_file))
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
	_package_file = normalize_path(_package_file)

	if not lide.file.doesExists(_package_file) then
		return false, '! Error: The package: ' .. tostring(_package_file) .. ' is not downloaded now.'
	end

	local _manifest_file = normalize_path(app.folders.libraries ..'/'.._package_name..'/'.. _package_name ..'.manifest')
	
	if _package_prefix and _package_prefix:gsub(' ', '') ~= '' then
		_package_prefix = _package_prefix ..'/'
	end
	
	if not lide_zip.extractFile(_package_file, (_package_prefix or '') .. _package_name .. '.manifest', _manifest_file) then
		return false, ('> ERROR: Manifest file "%s" doesn\'t exists into "%s" package'):format((_package_prefix or '') .. _package_name .. '.manifest', _package_file)
	end
	
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
	local package_manifest = inifile.parse_file(_manifest_file)[_package_name]
	local _package_version  = inifile.parse_file(_manifest_file)['version']

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
			return false, '"' .. _package_name .. '" '.. _package_version..' is not available on ' .. _osarch .. ' architecture.'
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
				local _foldernm = file_dst:sub(1, (file_dst:find(_filename) or 0) -1)
				
				lide.mktree(_foldernm)


				lide_zip.extractFile(_package_file, (_package_prefix or '') .. int_path, file_dst)
			end
		end

		
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
				
		printl '  > installing dependencies for $_package_name$:'
	
		for _, _package_name in pairs( depends ) do

			if lide.folder.doesExists(app.folders.libraries ..'/'.._package_name) then
				printl '  > $_package_name$ is installed now.'
			else
				printl '  > installing $_package_name$' 
				
				local package_zip_file = normalize_path(app.folders.libraries .. '\\'.._package_name .. '\\'.._package_name .. '.zip' ):gsub(' ', '')
				
				lide.mktree (normalize_path(app.folders.libraries .. '\\'.._package_name):gsub(' ', ''))
				
				reposapi.download_package(_package_name, package_zip_file)			
				
				local install_depend, last_error = reposapi.install_package (_package_name, package_zip_file)
				
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

--
--- reposapi.update_package (_packagenam, '1.0.0')
---  Update package to determined version
--
function reposapi.update_package ( _packagename, _packagever )
	-- Check current version for compatibility
	-- Download the latest version
	-- Apply the patch.	
	
	local _manifest_file = normalize_path(app.folders.libraries ..'/'.._packagename..'/'.. _packagename ..'.manifest')
--[[
	lide.folder.create ( app.folders.libraries .. '/'.._packagename )

	zip_package = app.folders.libraries .. '/'.._packagename .. '/'.._packagename .. '.zip'
	
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

	local installed_db = sqldatabase:new(app.folders.libraries .. '/linux/x64/installed.db', 'sqlite3')
	local lualibs = installed_db : select('select * from lua_packages where package_name like "'.._packagename..'" limit 1');

	for bcompat_ver in inifile.parse_file(_manifest_file)[_packagename]['compatibility']:delimi ',' do
		if (bcompat_ver == lualibs[1]['package_version']) then
			IS_COMPATIBLE = true
			break;
		end
	end
	
	if (IS_COMPATIBLE) then
		local loaded_repos = {};
		for repo_name, repo in pairs(reposapi.repos) do
		
			loaded_repos[repo_name] = sqldatabase:new(repo.path, 'sqlite3')
			
			--- Si encuentra el paquete en el primer repositorio: ese es
			if loaded_repos[repo_name]:select(_query_install:format(_packagename, _packagever))[1] then
				result_repo = loaded_repos[repo_name]:select(_query_install:format(_packagename, _packagever))[1]
				break
			end
		end

		lide.folder.create ( app.folders.libraries .. '/'.._packagename )
		
		zip_package = app.folders.libraries .. '/'.._packagename .. '/'.._packagename .. '.zip'
		
		reposapi.download_package(_packagename, zip_package, _packagever, nil_access_token)

		local package_prefix = result_repo.package_prefix

		reposapi.remove 'package_name'

		local _install_package, lasterror = reposapi.install_package ( _packagename, zip_package, package_prefix)
		
		if _install_package then
			print('> OK: '.._packagename..' successful installed.')
		else
			lide.folder.remove_tree ( app.folders.libraries .. '/'.._packagename )

			print('> [package.install] ERROR: ' .. lasterror)
			--reposapi.remove(_packagename)
		end

	else
		print (('[package.update] error: Current version isn\'t compatible with %s %s'):format(_packagename, _packagever))
		error()
	end
end

return reposapi