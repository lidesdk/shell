-- ///////////////////////////////////////////////////////////////////////////////
-- // Name:        core/oop/init.lua
-- // Purpose:     OOP Initialization
-- // Author:      Dario Cano [thdkano (at) gmail (dot) com]
-- // Created:     2016/01/03
-- // Copyright:   (c) 2016 Dario Cano
-- // License:     lide license
-- ///////////////////////////////////////////////////////////////////////////////

local newclass = require 'lide.core.oop.yaci'

local oop = {
	class = function ( sClassName )
		lide.__store_classes = lide.__store_classes or {}		
		local newclass = newclass
	
		-- Guardamos una nueva variable global con el nombre de la clase
		lide.__store_classes[sClassName] = newclass (sClassName)
		--_env = getfenv(1) 
		--_env[sClassName] = lide.__store_classes[sClassName]
		--setfenv(1, _env)
		return lide.__store_classes[sClassName]
	end,
}

return oop