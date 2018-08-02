local _package_name    = package_args[1]
local _package_version = package_args[2]

local _SourceFolder = app.folders.sourcefolder
local _ReposFile    = _SourceFolder .. '/lide.repos'

local reposapi = require 'repos-api'

function reposapi_get_package ( name )
	local result = reposapi.installed : select (('select package_name from lua_packages where package_name like "%s"') : format (name) )

	if (# result == 0) then
		return false, ('%s is not installed'):format(name)
	else
		return true, result
	end
end

if not reposapi_get_package ( _package_name ) then
	print (('%s is not installed'):format(_package_name))
else
	print '> installed lfs 1.4.20'
	print '> removing files...'
	
	-- remove package:
	reposapi.remove_package (_package_name);
	print '> OK: lfs successfully removed.'
end