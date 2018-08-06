local _SourceFolder = app.folders.sourcefolder
local _ReposFile    = _SourceFolder .. '\\lide.repos'

local function file_getline ( filename, nline )
	local n = 0; for line in io.lines(filename) do
		n = n+1; 
		if n == nline then
			return line
		end
	end
	return false
end

reposapi = require 'repos-api'

if not http.test_connection 'http://httpbin.org/response-headers' then
	print '[package.lide] No network connection.'

	return false;
end

local text_to_search = tostring(arg[2])
reposapi.update_repos ( _ReposFile, _SourceFolder .. '\\libraries' )

local n = 0; for repo_name, repo in pairs( reposapi.repos ) do
	local tbl = repo.sqldb : select('select * from lua_packages where package_name like "%'..text_to_search..'%" order by package_version desc') 

	if #tbl > 0 then
		local printed = { }
		
		for i, row in pairs( tbl ) do
			if type(row) == 'table' then

				if printed[row.package_name] then
					-- other versions to print:
					printed[row.package_name].versions[#printed[row.package_name].versions +1] = row	
				else
					printed[row.package_name] = row
					printed[row.package_name].versions = {}
				end

				n = n+1
			end
		end

		if printed then		
			for tblname, tblcontent in pairs(printed) do
				print(
					(repo_name..'/%s %s %s %s\n  %s'):format(tblcontent.package_name, tblcontent.package_version, (tblcontent.package_compat or ''), str_tag or '', tblcontent.package_description:sub(1, 70)..'')
				)
				
				if tblcontent.versions[1] then
					local other_versions = '\n'; if tblcontent.versions then
						for _, row in pairs(tblcontent.versions) do
							other_versions = other_versions .. ('    - '..repo_name..'/%s %s %s %s'):format(row.package_name, row.package_version, (row.package_compat or ''), str_tag or '')
						end
					end
					print(other_versions)
				end
			end
		end

	end
end

if n <= 0 then print '> No matches.' end