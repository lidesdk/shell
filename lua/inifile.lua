local function trim ( str )
	return str:gsub(' ', '')
end

local inifile = {}

function getsections ( file )
	local _inifile = io.open 'config.ini'
	local inifile_content = _inifile:read '*a' 
	local _open = inifile_content : find '%['
	local _end  = inifile_content : find '%]'
	local _sections = {}

	for line in io.lines (file) do
		if line: find '%[' and line: find '%]' then
			_sections[#_sections +1] = line:sub (line: find '%[' +1, line: find '%]' -1)
		end
	end

	return _sections
end

function getvalues ( file, section )
	local found_section, _values
	

	i = 0 for line in io.lines (file) do
		p1 = line: find '%['
		p2 = line: find '%]'
		
     	if p1 and p2 and line:sub(p1, p2) == ('[%s]'):format(section) then
			if line:find(('[%s]'):format(section)) then
				founded = true
			end
		else
			if founded and p1 and p2 then
				re_founded = true
				_values = {}
			end
		end

		if founded and not re_founded then
			_values = _values or {}

			if line:find '=' then
				local _value = trim(line:sub(1, line:find '=' -1))
				local _data  = trim(line:sub(line:find '=' +1, #line))
				_values[ _value ] = _data
			end
		end
	end
	
	return _values
end

inifile = { getvalue = getvalues, getvalues = getvalues, getsections = getsections }

return inifile