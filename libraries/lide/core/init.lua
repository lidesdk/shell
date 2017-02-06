-- ///////////////////////////////////////////////////////////////////////////////
-- // Name:        lide.core.init.lua
-- // Purpose:     Define and initialize framework values
-- // Created:     2016/01/03
-- // Copyright:   (c) 2016 Dario Cano [hdcano@protonmail.com]
-- // License:     lide license
-- ///////////////////////////////////////////////////////////////////////////////

lide = lide or {
	cons   = {}, 	--> This table saves all constants
	errorf = {}, 	--> This table stores all error functions
	
	core   = {
		error  = {},	--> stores all variables related to exceptions control
		base   = {},
		lua    = { type = type },
		file   = {},  --> stores all variables related to file handling
		folder = {},
	},

	classes = {
		widgets  = {},
		controls = {},
	}, 	--> stores all classes

	platform = {},
	app = {}
}

local app = lide.app

if not os.getenv 'LIDE_PATH' then
	print 'Please set LIDE_PATH environment variable.'
	os.exit()
end

-- core functions:

--- Get the name of the operating system.
---		Returns one string: OS Name like "Linux"
---
--- string getOSVersion( nil )

function lide.platform.getOSName( ... )
	if (package.config:sub(1,1) == '/') and io.popen 'uname -s':read '*l' == 'Linux' then
		return 'Linux';
	elseif (package.config:sub(1,1) == '\\') and os.getenv 'OS' == 'Windows_NT' then
		return 'Windows';
	else
		return 'Other';
	end
end

function lide.app.getWorkDir( ... )
	if lide.platform.getOSName() == 'Linux' then
		return io.popen 'echo $PWD' : read '*l'
	elseif lide.platform.getOSName() == 'Windows' then
		return io.popen 'CD' : read '*l'
	else
		lide.core.error.lperr 'this function is not implemented on this platform.'
	end
end

-- if interpreter
if arg and arg[0] then
	local sf = arg[0]:sub(1, #arg[0] , #arg[0])
	local n  = sf:reverse():find (package.config:sub(1,1), 1) or 0
		  sf = sf:reverse():sub (n+1, # sf:reverse()) : reverse()

	_sourcefolder = sf
end

if lide.platform.getOSName() == 'Linux' then
	local _lide_path = os.getenv 'LIDE_PATH'

	package.cpath = ';./?.so;' ..
				    _lide_path .. '/?.so;'
	
elseif lide.platform.getOSName() == 'Windows' then
	local _lide_path = os.getenv 'LIDE_PATH'	
	
	package.cpath = _lide_path .. '\\clibs\\windows\\x86\\?.dll'
	package.path  = _lide_path .. '\\lua\\windows\\x86\\?.lua;' .. package.path
				    --_lide_path .. '\\?.dll;'
	--package.cpath = ';?.dll;.\\?.dll;'
	--package.path  = ';?.lua;.\\?.lua;'
	--print(package.path)
	--lide.lfs = package.loadlib ((_sourcefolder or '.') ..'\\lfs.dll', 'luaopen_lfs') ()
else
	print 'lide: error fatal: plataforma no soportada.'
end

require 'lide.core.thlua'

lide.core.error  = require 'lide.core.error' 	--> exceptions control
lide.core.oop    = require 'lide.core.oop.init'  --> OOP handling
lide.core.base   = require 'lide.core.base'		-->

-- lide platform
lide.platform    = require 'lide.platform.init'

-- lide filesystem:
lide.lfs 		 = require 'lfs'
lide.core.file   = require 'lide.core.file'		--> File Handling
lide.core.folder = require 'lide.core.folder'   --> Folders related


------------------------------------------
lide.folder = lide.core.folder;
lide.file   = lide.core.file;

------------------------------------------
-- base values:

class = lide.core.oop.class
enum  = lide.core.base.enum

return lide, lide.app