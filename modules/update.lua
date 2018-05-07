-- Para los modulos se permiten las siguientes funciones especiales:
--- print( 'Texto $var_name') || var_name es el nombre de una variable real.
---

-- Update repos
--repository.update() 

-- download package
--repository.remove  ('luasql', app.folders.libraries .. '/luasql.zip')
--repository.download('luasql', app.folders.libraries .. '/luasql.zip')
--repository.install ('luasql', app.folders.libraries .. '/luasql.zip')

local _package_name    = arg[2]
local _package_version = arg[3]

local reposapi = require 'repos-api'
local inifile  = require 'inifile'

local _SourceFolder = app.folders.sourcefolder
local _ReposFile    = _SourceFolder .. '/lide.repos'

print('repos-api: ' .. tostring(_ReposFile));

reposapi.update_repos ( _ReposFile, _SourceFolder .. '\\libraries' )

reposapi.update_package ( _package_name, _package_version)

--[[
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
				print ('Module '..package_name..' is not installed.')
				
				return false
			else
				local local_version = inifile.parse_file (app.folders.libraries ..'/'..package_name .. '/' .. package_name ..'.manifest', package_name ) ['version'] --file_getline ( app.folders.libraries ..'/'..package_name .. '/' .. package_name ..'.manifest', 1 )
				local cloud_version = repository.libraries_stable:select(('select * from libraries_stable where package_name like "%s" limit 1'):format(package_name))[1].package_version
				
				print('> last version: ' .. cloud_version)
				print('> local version: ' .. local_version)

				if compare_versions(local_version, cloud_version) == 0 then -- up to date
					print('\npackage is up to date.')
				elseif compare_versions(local_version, cloud_version) == 2 then
					repository.remove  (package_name)

					print('\n> downloading package '..cloud_version)
					repository.download(package_name, app.folders.libraries..'/'..package_name..'.zip')
					print('> installing package '..cloud_version)
					repository.install (package_name, app.folders.libraries..'/'..package_name..'.zip')
					print('> all done. ')

					print('\nNew library installed '..package_name .. ' '.. cloud_version)

				elseif compare_versions(local_version, cloud_version) == 1 then
					print 'Por que tu version es mayor que la de los repositorios de Lide?'
				end
			end		
		end		
	end
end
]]