local _package_name    = package_args[1]
local _package_version = package_args[2]

--reposapi.repos = reposapi.repos or {}

local _SourceFolder = app.folders.sourcefolder
local _ReposFile    = _SourceFolder .. '/lide.repos'

local reposapi = require 'repos-api'

lide.log.printlog = false;

lide.log '[package.lide] Test connection'

if not http.test_connection 'http://httpbin.org/response-headers' then
	lide.log '[package.lide] No network connection.'
	
	return false;
else 
	lide.log '[package.lide] Network: Connected.'
end

lide.log '[package.lide] Updating repos'

reposapi.update_repos ( _ReposFile, app.folders.libraries )

local n = 0; for repo_name, repo in pairs( reposapi.repos ) do
	local tbl;

	if _package_version then
		tbl = repo.sqldb : select('select * from lua_packages where package_name like "'.._package_name..'" and package_version like "'.._package_version..'" limit 1')
	else
		tbl = repo.sqldb : select('select * from lua_packages where package_name like "'.._package_name..'" ORDER BY package_version DESC LIMIT 1;')
	end

	if #tbl > 0 then
		for i, row in pairs( tbl ) do
			if type(row) == 'table' then
				--local num_repo_version  = tonumber(tostring(row.package_version:gsub('%.', '')));
	
				--if # repo.sqldb:select ( _query_install:format(_package_name) ) == 0 then
				if (# tbl == 0) then
					print ('Package "'.._package_name..'" does not exists on cloud repos.\n\nPlease go to: http://github.com/lidesdk/repos')
					
					return false
				end
				
				local _package_version = (_package_version or tbl[1].package_version)
				local package_prefix   = tbl[1].package_prefix or ''
				
				--if lide.folder.doesExists(app.folders.libraries ..'/'.. _package_name) then
				if reposapi.get_installed_package(_package_name) then
					print (('The package %s is already installed.'):format(_package_name))
					
					return false
				end

				if # tbl > 0 then
					print(('> Found: %s %s'):format(_package_name, _package_version));
				end

				n = n + 1
				
				lide.folder.create ( app.folders.libraries .. '/'.._package_name )
				
				local zip_package = app.folders.libraries .. '/'.._package_name .. '/'.._package_name .. '.zip'
				
				lide.log ('[package.lide] Downloading package %s %s', _package_name, _package_version)

				reposapi.download_package(_package_name, zip_package, _package_version, nil_access_token)
				
				lide.log ('[package.lide] Installing package %s %s', _package_name, _package_version)

				local _install_package, lasterror = reposapi.install_package (_package_name, zip_package, package_prefix or '')
				
				if _install_package then
					print('> OK: '.._package_name..' '.._package_version..' successful installed.')
				else
					lide.folder.remove_tree ( app.folders.libraries .. '/'.._package_name )

					print('\n> ' .. lasterror)
				end
				break
			end
		end
	end
end

if n <= 0 then print '> No matches.' end