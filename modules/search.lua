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

repository.update();

local tbl = repository.libraries_stable:select('select * from libraries_stable where package_name like "%'..text_to_search..'%"')

if #tbl > 0 then
	for i, row in pairs( tbl ) do
		if type(row) == 'table' then
			local num_repo_version  = tonumber(tostring(row.package_version:gsub('%.', '')));

			print(
				('stable/%s %s %s\n%s'):format(row.package_name, row.package_version, str_tag or '', row.package_description)
			)
		end
	end
else
	print 'No matches.'
end