print('\n > Lide :) ' .. app.getWorkDir(), arg[0])
-- Define paths:
local access_token  = nil, '59748697161850409f398caca1ba17b07e16af87'

app.folders = { install, libraries, ourclibs, ourlibs }	

if lide.platform.getOSName() == 'Windows' then

	app.folders.install   = 'c:\\lidesdk'
	app.folders.libraries = 'c:\\lidesdk\\libraries'
	lide_installfolder    = 'C:\\lidesdk\\bin\\libs'
	app.folders.ourclibs  = '.\\win_clibs'

	package.path  = '.\\?.lua;' ..
					'.\\win_lua\\?.lua;'

	package.cpath = '.\\?.dll;' ..
					'.\\win_clibs\\?.dll;'

elseif lide.platform.getOSName() == 'Linux' then

	app.folders.install   = app.getWorkDir() .. ''
	app.folders.libraries = app.getWorkDir() .. '/libraries'
	app.folders.ourclibs  = './lnx_clibs'
	
	package.cpath = './?.so;' ..
					'./lnx_clibs/?.so;'

	package.path  = './?.lua;' ..
					'./lnx_lua/?.lua;'
end

local sqldatabase = require 'sqldatabase.init'
local github      = require 'github'
lide.zip 		  = require 'lide_zip'

local function update_database ( access_token )
	local db_content, errcode, errmsg  = github.get_file ( 'lidesdk/repos/libraries.db', nil, access_token)

	if db_content then
		-- if folder doesnt exist create it (todo)
		local repos_db = io.open(app.folders.libraries..'/repos.db', 'w+b')
		if repos_db:write(db_content) then
			repos_db:close()
			-- OK SUccess
		else
			--any error writeing file
		end
	else
		print('[lide.github]: ', errmsg)
	end
end

local libraries_stable = sqldatabase:new(app.folders.libraries..'/repos.db', 'sqlite3')

if ( arg[1] == 'search' and arg[2] ) then
	local text_to_search = arg[2]
		
	print '> Searching...'
	
	update_database ( access_token );

	--wx.wxSleep(0.01)

	local libraries_stable = sqldatabase:new(app.folders.libraries..'/repos.db', 'sqlite3')

	local tbl = libraries_stable:select('select * from libraries_stable where package_name like "%'..text_to_search..'%"')
	
	if #tbl > 0 then
		for i, row in pairs( tbl ) do
			if type(row) == 'table' then
				local num_repo_version  = tonumber(tostring(row.package_version:gsub('%.', '')));
				
				if lide.folder.doesExists(app.folders.libraries..'/'..row.package_name) then
					local local_package_version = io.open(app.folders.libraries..'/'..row.package_name..'/'..row.package_name..'.manifest'):read('*l')
					local num_local_version = tonumber(tostring(local_package_version:gsub('%.', '')));
					if ( num_repo_version > num_local_version ) then
						str_tag = '(UPDATE)'
					end
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
	local _package_name  = arg[2]
	local _query_install = 'select * from libraries_stable where package_name like "%s" limit 1'
	
	print('> Search '.. _package_name)
	
	update_database(access_token);
	
	wx.wxSleep(0.01)

	if # libraries_stable:select ( _query_install:format(_package_name) ) == 0 then
		print 'No matches!'
		return false
	end

	local _package_name    = libraries_stable:select(_query_install:format(_package_name))[1].package_name
	local _package_version = libraries_stable:select(_query_install:format(_package_name))[1].package_version
	local _package_file    = app.folders.libraries..'/'.._package_name..'.zip'


	if # libraries_stable:select('select * from libraries_stable where package_name like "%'.._package_name..'%" limit 1') > 0 then
		print(('> Found! %s %s'):format(_package_name, _package_version));
	end
	
	local github_path = libraries_stable:select(_query_install:format(_package_name))[1].package_url
	
	local content = github.get_file ( github_path, nil, access_token )
	
	io.open(_package_file, 'w+b'):write(content):close()

	print('\t> Installing...')	

	if lide.folder.doesExists(app.folders.libraries..'/'.._package_name) then
		print (('\t> The package %s is already installed.'):format(_package_name))
		return false
	end

	lide.zip.extract(_package_file, app.folders.libraries ..'/'.._package_name)

	print('\t> All done!')
	
	wx.wxSleep(0.01)
	
	io.popen ('rm -rf "' .. app.folders.libraries ..'/'.._package_name..'.zip"');

	print(('New library installed %s %s'):format(_package_name, _package_version))

elseif ( arg[1] == 'remove' and arg[2] ) then
	local _package_version
	local _package_name = arg[2]
	
	if lide.folder.doesExists(app.folders.libraries ..'/'.._package_name) then
		_package_version = io.open(app.folders.libraries ..'/'.._package_name..'/'.._package_name ..'.manifest'):read('*l')
		
		print('\t> Deleting files!')
		
		io.popen ('rm -rf "' .. app.folders.libraries ..'/'.._package_name..'"');

		print(('Library "%s %s" is successfully removed.'):format(_package_name, _package_version))
	else
		print (('The package "%s" doesn\'t installed.'):format(_package_name))
	end
end
