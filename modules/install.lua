local _package_name  = arg[2]
local _query_install = 'select * from libraries_stable where package_name like "%s" limit 1'

repository.update ();

if # repository.libraries_stable:select ( _query_install:format(_package_name) ) == 0 then
	print ('Package "'.._package_name..'" does not exists on cloud repos.\n\nPlease go to: http://github.com/lidesdk/repos')
	
	return false
end

local _package_name    = repository.libraries_stable:select(_query_install:format(_package_name))[1].package_name
local _package_version = repository.libraries_stable:select(_query_install:format(_package_name))[1].package_version
	
if lide.folder.doesExists(app.folders.libraries ..'/'.. _package_name) then
	print (('The package %s is already installed.'):format(_package_name))
	
	return false
end

if # repository.libraries_stable:select('select * from libraries_stable where package_name like "%'.._package_name..'%" limit 1') > 0 then
	print(('> Found! %s %s'):format(_package_name, _package_version));
end

print('> installing...')	

repository.download(_package_name, app.folders.libraries .. '/'.._package_name..'.zip')

repository.install (_package_name, app.folders.libraries .. '/'.._package_name..'.zip')

print('\n> OK: '.._package_name..' successful installed.')