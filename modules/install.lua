local _package_name    = arg[2]
local _package_version = arg[3]

repository.repos = repository.repos or {}

local _SourceFolder = app.folders.sourcefolder
local _ReposFile    = _SourceFolder .. '\\lide.repos'


repository.update_repos ( _ReposFile, _SourceFolder .. '\\libraries' )

local n = 0; for repo_name, repo in pairs( repository.repos ) do
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
				
				--local package_name    = repo.sqldb:select(_query_install:format(_package_name))[1].package_name
				local _package_version = (_package_version or tbl[1].package_version)
				local package_prefix   = tbl[1].package_prefix
				
				if lide.folder.doesExists(app.folders.libraries ..'/'.. _package_name) then
					print (('The package %s is already installed.'):format(_package_name))
					
					return false
				end

				if # tbl > 0 then
					print(('> Found! %s %s'):format(_package_name, _package_version));
				end

				n = n + 1
				
				print('> installing...')	
								
				lide.folder.create ( app.folders.libraries .. '/'.._package_name )

				zip_package = app.folders.libraries .. '/'.._package_name .. '/'.._package_name .. '.zip'
				
				repository.download_package(_package_name, zip_package, _package_version, nil_access_token)
				
				local _install_package, lasterror = repository.install_package (_package_name, zip_package, package_prefix)
				
				if _install_package then
					print('> OK: '.._package_name..' successful installed.')
				else
					lide.folder.remove_tree ( app.folders.libraries .. '/'.._package_name )

					print('> [package.install] ERROR: ' .. lasterror)
					--repository.remove(_package_name)
				end
				break
			end
		end
	end
end

if n <= 0 then print '> No matches.' end