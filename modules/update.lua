-- Para los modulos se permiten las siguientes funciones especiales:
--- print( 'Texto $var_name') || var_name es el nombre de una variable real.
---

local _package_name    = arg[2]
local _package_version = arg[3]

local reposapi = require 'repos-api'
local inifile  = require 'inifile'
local compare_versions = reposapi.compare_versions

local _SourceFolder = app.folders.sourcefolder
local _ReposFile    = _SourceFolder .. '/lide.repos'

if not http.test_connection 'http://httpbin.org/response-headers' then
	print '[package.lide] No network connection.'
	
	return false;
end

if not _package_name then
	print '[package.update] Error: please specify package name and version.'

	return false;
end

if _package_version then
	print (('> searching package: %s %s'):format(_package_name, _package_version))
elseif _package_name then
	print (('> checking package: %s'):format(_package_name))
end

reposapi.update_repos ( _ReposFile, _SourceFolder .. '\\libraries' )

if not package_args[1] then
	print '! Update all components.'
elseif package_args[1] then
	if # package_args > 0 then
		local package_name = package_args[1]

		-- --show option:
		if package_args[1] == '--show' and package_args[2] then
			local package_name = package_args[2]
			print '--show $package_name information.'

		elseif package_args[1] == '--show' then
			print '--show all updates'
		else
			if not lide.folder.doesExists(app.folders.libraries ..'/'..package_name) then
				print ('> package "'..package_name..'" is not installed.')
				
				return false
			else
				local local_package = reposapi.installed:select(('select * from lua_packages where package_name like "%s" limit 1'):format(package_name))[1]
				local local_version = local_package.package_version
				
				local cloud_package = reposapi.repos.stable.sqldb:select(('select * from lua_packages where package_name like "%s" order by package_version desc'):format(package_name))[1]

				local cloud_version = cloud_package.package_version

				if _package_version then
					cloud_package = reposapi.repos.stable.sqldb:select(('select * from lua_packages where package_name like "%s" and package_version like "%s" order by package_version desc'):format(package_name, _package_version))
					--print(cloud_package[1].package_version)
					if #cloud_package == 0 then
						print (('> package %s %s doesn\'t exist.'):format(package_name, _package_version))
						error()
					end
				end

				if cloud_package.package_compat then
					for _, compat_arch in pairs(cloud_package.package_compat:gsub('%[', ''):gsub('%]', ''):gsub(' ', '') : delim ',' ) do
						if lide.platform.get_osname() == compat_arch then
							compatible = true
						end
					end
				end
				

				--print('> last version: ' .. cloud_version)
				--print('> local version: ' .. local_version)

				if compare_versions(local_version, cloud_version) == 0 then -- up to date
					print('> package is up to date.')
				elseif compare_versions(local_version, cloud_version) == 2 then
					
					print (
						('> %s package: new version %s'):format(_package_name, cloud_version)
					)
					
					if not compatible then
						print('> not compatible with ' ..  lide.platform.get_osname())
						os.exit()
					end

					print '> installing updates'

					reposapi.update_package ( _package_name, _package_version)
					--print('\n> downloading package '..cloud_version)
					--repository.download(package_name, app.folders.libraries..'/'..package_name..'.zip')
					--print('> installing package '..cloud_version)
					--repository.install (package_name, app.folders.libraries..'/'..package_name..'.zip')
					--print('> all done. ')

					--print('\nNew library installed '..package_name .. ' '.. cloud_version)

				elseif compare_versions(local_version, cloud_version) == 1 then
					print 'Por que tu version es mayor que la de los repositorios de Lide?'
				end
			end		
		end		
	end
end
