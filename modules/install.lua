local _package_name  = arg[2]
local _query_install = 'select * from lua_packages where package_name like "%s" limit 1'

repository.repos = repository.repos or {}

local _SourceFolder = app.folders.sourcefolder
local _ReposFile    = _SourceFolder .. '\\lide.repos'


repository.update_repos ( _ReposFile, _SourceFolder .. '\\libraries' )

for repo_name, repo in pairs( repository.repos ) do
	local tbl = repo.sqldb : select('select * from lua_packages where package_name like "%'.._package_name..'%"') 
	if #tbl > 0 then
		for i, row in pairs( tbl ) do
			if type(row) == 'table' then
				local num_repo_version  = tonumber(tostring(row.package_version:gsub('%.', '')));
	
				if # repo.sqldb:select ( _query_install:format(_package_name) ) == 0 then
					print ('Package "'.._package_name..'" does not exists on cloud repos.\n\nPlease go to: http://github.com/lidesdk/repos')
					
					return false
				end
				
				local _package_name    = repo.sqldb:select(_query_install:format(_package_name))[1].package_name
				local _package_version = repo.sqldb:select(_query_install:format(_package_name))[1].package_version
					
				if lide.folder.doesExists(app.folders.libraries ..'/'.. _package_name) then
					print (('The package %s is already installed.'):format(_package_name))
					
					return false
				end

				if # repo.sqldb:select('select * from lua_packages where package_name like "%'.._package_name..'%" limit 1') > 0 then
					print(('> Found! %s %s'):format(_package_name, _package_version));
				end

				print('> installing...')	
				
				lide.mktree ( app.folders.libraries .. '/'.._package_name )

--				repository.download(_package_name, app.folders.libraries .. '/'.._package_name .. '/'.._package_name .. '.zip')
				zip_package = app.folders.libraries .. '\\'.._package_name .. '\\'.._package_name .. '.zip'
				
				repository.download_package(_package_name, zip_package)
				repository.install_package (_package_name, zip_package)

				print('> OK: '.._package_name..' successful installed.')

				break
			end
		end
	else
		print 'No matches.'
	end
end