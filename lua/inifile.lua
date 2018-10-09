-- ///////////////////////////////////////////////////////////////////
-- // Name:      inifile.lua
-- // Purpose:   Inifile parser 1.0
-- // Created:   2018/10/09
-- // Copyright: (c) 2018 Hernan Dario Cano [dcanohdev[at]gmail.com]
-- // License:   GNU GENERAL PUBLIC LICENSE
-- ///////////////////////////////////////////////////////////////////

local inifile = {}

-- Delimit string to table: 
function string.delim(str, d)
   local a,t,c,b = 0, {}
   
   repeat
      b = str:find(d or '|', a)
      if b then
         c = str:sub(a, b-1)
         a = b +1
      else
         c = str:sub(a, #str)
      end
      t[#t+1] = c
   until b == nil 
   return t
   ---------------------------------------
   -- usage: 
   -- t = string.delim "thedary|thd" 
   -- t = string.delim("thedary, dario, cano",',')
   ---------------------------------------
end

local function trim2(s)
	return s:match "^%s*(.-)%s*$"
end

function inifile.parse ( inistring )
	
	local h_list, h1, h2, h_name = {}; 
	repeat
		--- Extract headers:
		h1 = inistring:find ('%[', h2);
		h2 = inistring:find ('%]', h1);
		
		if h1 and h2 then
			h_name = inistring:sub(h1+1, h2-1);
			h_list[#h_list+1] = '%['.. h_name .. '%]'
		end
	until not h1

	local _initable = {};

	for k,v in pairs(h_list) do
		if h_list[k] then
			local si1, se1, si2, se2;
			local section_str;

			si1, se1 = inistring:find ( h_list[k] );       -- SectionEnd1
			if h_list[k+1] then
				si2, se2 = inistring:find ( h_list[k+1] ); --SectionInit2, SectionEnd2
			else
				se2 = #inistring
				si2 = se2
			end

			--- Si es el ultimo:
			if (si2 == #inistring) then
				section_str = (inistring:sub(se1+1, si2));
			else
				section_str = (inistring:sub(se1+1, si2-1));
			end
				--lide.log('section_str' .. section_str..':::')
			--for _, line in pairs(section_str:delim '\n') do
			for line in section_str:gmatch("[^\r\n]+") do
				if line:gsub(' ', '') ~= '' then
					local line_del = line:delim '=';

					local section_name = h_list[k]:sub(3, #h_list[k]-2);
					local skey_name = trim2(line_del[1]:gsub(' ', ''));
					_initable[section_name] = _initable[section_name] or {}
					_initable[section_name][skey_name] = trim2(line_del[2])
				end
			end
		end
	end

	return _initable
end

function inifile.parse_file ( file )
	local thefile =  io.open(file, 'r');
	local file_content = thefile:read '*a';
	return inifile.parse(file_content);
end

return inifile