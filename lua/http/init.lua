-- /////////////////////////////////////////////////////////////////////////////////////////////////
-- // Name:        lide/http/init.lua
-- // Purpose:     HTTP facilities for Lua / Lide framework
-- // Author:      Hernan Dario Cano [dcanohdev@gmail.com]
-- // Created:     2016/10/16
-- // Copyright:   (c) 2016 Hernan Dario Cano
-- // License:     MIT License/X11 license
-- /////////////////////////////////////////////////////////////////////////////////////////////////
--

local isString   = lide.core.base.isstring
local isTable    = lide.core.base.istable
local isFunction = lide.core.base.isfunction
local requests   = require 'requests' 
local curl       = require 'luacurl'

local http = { get, put, post,
	download, test_connection
}

function http.test_connection ( url )
	isString(url);

	local exec, errm = pcall(requests.get, url)
	if not exec or errm.status_code ~= 200 then
		return false, errm.status
	else
		return errm
	end	
end

function http.download(url, destfile, callback_function)
	isString(url); isString(destfile); isFunction(callback_function)
	
	-- check tempfile path
	local file, errm = io.open ( destfile, 'w+b');
	
	if not file then		
		local msg_error = '[lide.http] File error ' .. (  ':' and errm or 'can\'t access to path of destination file.')
		lide.core.error.lperr (msg_error, 2)
	end

	local c = curl.new()

	assert(c:setopt(curl.OPT_URL, url))

	local t = {} -- this will collect resulting chunks
	c:setopt(curl.OPT_WRITEFUNCTION, function (param, buf)
    	table.insert(t, buf) -- store a chunk of data received
		return #buf
	end)

	c:setopt(curl.OPT_PROGRESSFUNCTION, function(param, dltotal, dlnow)
		if (dltotal ~= 0) then
			if callback_function then
				local percent = dlnow / dltotal * 100
				assert(pcall(callback_function,dlnow, dltotal, percent))
			end
		end
	end)

	c:setopt(curl.OPT_NOPROGRESS, false) -- use this to activate progress
	c:setopt(curl.OPT_SSL_VERIFYPEER, false)
	c:setopt(curl.OPT_FOLLOWLOCATION, true)

	assert(c:perform())
	
	local return_string = table.concat(t) -- return the whole data as a string
	
	file:write(return_string)
	file:flush()
	file:close()
end

function http.get( url, request_table )
	isString(url); 
	if request_table then isTable(request_table); end

	return requests.get(url, request_table);
end

function http.post( url, request_table )
	isString(url); 
	if request_table then isTable(request_table); end
	return requests.post(url, request_table);
end

function http.put( url, request_table )
	isString(url); 
	if request_table then isTable(request_table); end
	return requests.put(url, request_table);
end

function http.delete ( url, request_table )
	isString(url); 
	if request_table then isTable(request_table); end
	return requests.delete(url, request_table);
end

function http.options ( url, request_table )
	isString(url); 
	if request_table then isTable(request_table); end
	return requests.options(url, request_table);
end

function http.head ( url, request_table )
	isString(url); 
	if request_table then isTable(request_table); end
	return requests.head(url, request_table);
end

http.HTTPBasicAuth  = requests.HTTPBasicAuth
http.HTTPDigestAuth = requests.HTTPDigestAuth

return http