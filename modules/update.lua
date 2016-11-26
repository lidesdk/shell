--- Para los modulos se permiten las siguientes funciones especiales:
--- print( 'Texto $var_name') || var_name es el nombre de una variable real.
---

-- Update repos
repository.update() 

-- download package
--repository.remove  ('luasql', app.folders.libraries .. '/luasql.zip')
--repository.download('luasql', app.folders.libraries .. '/luasql.zip')
--repository.install ('luasql', app.folders.libraries .. '/luasql.zip')

function compare_versions ( ver1, ver2 )
	for i = 1, 3 do
		if tonumber(ver1 : delim '%.' [i]) == tonumber(ver2 : delim '%.' [i]) then
			if tonumber(ver1 : delim '%.' [2]) == tonumber(ver2 : delim '%.' [2]) then
				if tonumber(ver1 : delim '%.' [3]) == tonumber(ver2 : delim '%.' [3]) then
			--		print '0 Versions are the same'
					return 0
				end
			end		
		elseif tonumber(ver1 : delim '%.' [i]) > tonumber(ver2 : delim '%.' [i]) then
			--print '1 Version1 is major'
			return 1
		elseif tonumber(ver1 : delim '%.' [i]) < tonumber(ver2 : delim '%.' [i]) then
			--print '2 Version2 is major'
			return 2
		end
	end
-- 0  ver1 == ver2
-- 1  ver1 > ver 2
-- 2  ver1 < ver 2
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
				local local_version = file_getline ( app.folders.libraries ..'/'..package_name .. '/' .. package_name ..'.manifest', 1 )
				local cloud_version = repository.libraries_stable:select(('select * from libraries_stable where package_name like "%s" limit 1'):format(package_name))[1].package_version
				
				print('> cloud repo version: ' .. cloud_version)
				print('> package.manifest version: ' .. local_version)

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
					print 'yout version is major than lide repos'
				end
			end		
		end		
	end
end