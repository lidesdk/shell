-- /////////////////////////////////////////////////////////////////////////////////////////////////
-- // Name:        lide/http/init.lua
-- // Purpose:     Initialize Lide Network framework
-- // Author:      Hernan Dario Cano [dario.canohdz@gmail.com]
-- // Created:     2016/10/16
-- // Copyright:   (c) 2016 Hernan D. Cano
-- // License:     MIT License/X11 license
-- /////////////////////////////////////////////////////////////////////////////////////////////////
--
-- GNU/Linux Lua version:   5.1.5
-- Windows x86 Lua version: 5.1.4

local isString = lide.core.base.isstring
local requests = require 'requests' 

local http = { get, put, post,
	download, test_connection
}

function http.test_connection ( url )
	isString(url);

	local exec, errm = pcall(requests.get, url)
	if not exec or errm.status_code ~= 200 then
		return false, errm.status
	else
		return true;
	end	
end

function http.download ( url, dest )
	isString(url); isString(dest);
	
	-- check tempfile path
	local file, errm = io.open ( dest, 'w+b');
	if not file then		
		local msg_error = '[lide.http] File error ' .. (  ':' and errm or 'there is a problem in the path of destination file.')
		error (msg_error, 3)
	end

	local connection, errm = http.test_connection(url);

	if connection then
		local response = requests.get(url);
		local file_content = response.text
		local temp_file = dest
		
		file:write(file_content); file:flush();
		file:close();
	else
		local msg_error = '[lide.http] No connection ' .. (  ':' and errm or 'there is a problem in the url.')
		error (msg_error, 2);
	end
end

function http.get ( ... )
	return requests.get(...);
end

function http.head ( ... )
	return requests.head(...);
end

function http.post ( ... )
	return requests.post(...);
end

function http.put ( ... )
	return requests.put(...);
end

function http.delete ( ... )
	return requests.delete(...);
end

function http.connect ( ... )
	return requests.connect(...);
end

function http.options ( ... )
	return requests.options (...);
end

function http.trace ( ... )
	return requests.trace (...);
end

function http.patch ( ... )
	return requests.patch (...);
end

return http