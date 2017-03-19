local _SourceFolder = app.folders.sourcefolder
local _ReposFile    = _SourceFolder .. '\\lide.repos'

repository.repos = repository.repos or {}

local function file_getline ( filename, nline )
	local n = 0; for line in io.lines(filename) do
		n = n+1; 
		if n == nline then
			return line
		end
	end
	return false
end

local text_to_search = tostring(arg[2])

repository.update_repos ( _ReposFile, _SourceFolder .. '\\libraries' )

local n = 0; for repo_name, repo in pairs( repository.repos ) do
	local tbl = repo.sqldb : select('select * from lua_packages where package_name like "%'..text_to_search..'%"') 
	if #tbl > 0 then
		for i, row in pairs( tbl ) do
			if type(row) == 'table' then
				local num_repo_version  = tonumber(tostring(row.package_version:gsub('%.', '')));
	
				print(
					(repo_name..'/%s %s %s\n%s'):format(row.package_name, row.package_version, str_tag or '', row.package_description)
				)
				n = n+1
			end
		end
	end
end

if n <= 0 then print '> No matches.' end