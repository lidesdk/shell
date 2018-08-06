local _package_name    = package_args[1]
local _package_version = package_args[2]

local _SourceFolder = app.folders.sourcefolder
local _ReposFile    = _SourceFolder .. '/lide.repos'

local reposapi = require 'repos-api'

function reposapi_get_package ( name )
	local result = reposapi.installed : select (('select package_name, package_version from lua_packages where package_name like "%s"') : format (name) )

	if (# result == 0) then
		return false, ('%s is not installed'):format(name)
	else
		return result[1]
	end
end


local package_data = reposapi_get_package ( _package_name );

if not package_data then
	print (('> %s is not installed.'):format(_package_name))
else
	_package_version = package_data.package_version;
	
	print (('> installed %s %s'):format(_package_name, _package_version))
	print '> removing files...'
	
	-- remove package:
	reposapi.remove_package (_package_name);
	
	print (('> OK: %s successfully removed.'):format(_package_name))
end