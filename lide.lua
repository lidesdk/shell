lide_installfolder    = '/datos/Proyectos/lide_cmd'
lide_libraries_folder = '/datos/Proyectos/lide_cmd/libraries'

access_token  = ''
github_path   = 'lidesdk/repos/libraries/lide.http.zip'

local folders = { libraries = '/datos/Proyectos/lide_cmd/libraries' }

package.path = lide_installfolder..'/http/?.lua;' ..
			   lide_installfolder..'/?.lua;' .. package.path

local sqldatabase = require 'sqldatabase.init'
local github      = require 'github'
lide.zip 		  = require 'lide_zip'

local db_content, err = github.get_file ( 'lidesdk/repos/libraries.db', nil, access_token)

if db_content then
	io.open(folders.libraries..'/repos.db', 'w+b') : write(db_content) : close()
else
	print('[lide.github]: ', err)
end

local libraries_stable = sqldatabase:new(folders.libraries..'/repos.db', 'sqlite3')

if ( arg[1] == 'search' and arg[2] ) then
	local text_to_search = arg[2]
	
	print '> Searching...'

	local libraries_stable = sqldatabase:new('libraries.db', 'sqlite3')

	local tbl = libraries_stable:select('select * from libraries_stable where package_name like "%'..text_to_search..'%"')
	
	if #tbl > 0 then
		for i, row in pairs( tbl ) do
			if type(row) == 'table' then
				local local_package_version = io.open(lide_libraries_folder..'/'..row.package_name..'/'..row.package_name..'.manifest'):read('*l')
				local num_repo_version  = tonumber(tostring(row.package_version:gsub('%.', '')));
				local num_local_version = tonumber(tostring(local_package_version:gsub('%.', '')));
				
				if ( num_repo_version > num_local_version ) then
					str_tag = '(UPDATE)'
				end
				print(
					('\n%s [%s] %s\n\t%s\n'):format(row.package_name, row.package_version, str_tag or '', row.package_description)
				)
			end
		end
		
	else
		print 'No matches!'
	end

elseif ( arg[1] == 'install' and arg[2] ) then
	local _package_name    = arg[2]
	local _query = 'select * from libraries_stable where package_name like "%s" limit 1'
	
	print('> Search '.. _package_name)
	
	if # libraries_stable:select ( _query:format(_package_name) ) == 0 then
		print 'No matches!'
		return false
	end

	local _package_name    = libraries_stable:select(_query:format(_package_name))[1].package_name
	local _package_version = libraries_stable:select(_query:format(_package_name))[1].package_version
	local _package_file    = lide_libraries_folder..'/'.._package_name..'.zip'

	if # libraries_stable:select('select * from libraries_stable where package_name like "%'.._package_name..'%" limit 1') > 0 then
		print(('> Found! lide.http %s'):format(_package_version));
	end
	
	local github_path = libraries_stable:select(_query:format(_package_name))[1].package_url
	
	local content = github.get_file ( github_path, nil, access_token )
	
	io.open(_package_file, 'w+b'):write(content):close()

	print('\t> Installing...')	

	if lide.folder.doesExists(folders.libraries..'/'.._package_name) then
		print (('\t> The package %s is already installed.'):format(_package_name))
		return false
	end

	lide.zip.extract(_package_file, lide_libraries_folder ..'/'.._package_name)

	print('\t> All done!')
	
	io.popen (('rm -rf "%s"'):format(_package_file));

	print(('New library installed lide.http %s'):format(_package_version))

elseif ( arg[1] == 'remove' and arg[2] ) then
	local _package_name = arg[2]

	if lide.folder.doesExists(lide_libraries_folder ..'/'.._package_name) then
		io.popen ('rm -rf "' .. lide_libraries_folder ..'/'.._package_name..'"');
	else
		print (('The package "%s" doesn\'t installed.'):format(_package_name))
	end
end