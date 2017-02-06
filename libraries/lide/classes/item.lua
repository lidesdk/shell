-- /////////////////////////////////////////////////////////////////////////////////////////////////
-- // Name:        lide/classes/item.lua
-- // Purpose:     Item class
-- // Author:      Dario Cano [thdkano@gmail.com]
-- // Modified by: 
-- // Created:     20/03/2016
-- // Copyright:   (c) 2014-2016 Dario Cano
-- // License:     lide license
-- /////////////////////////////////////////////////////////////////////////////////////////////////

-- import functions:
local isString  = lide.core.base.isstring

-- define the class:
local Item = class 'Item' : global(false)

-- define class constructor:
function Item:Item ( fields )
	local allitems = {} for key, value in next, fields do
		allitems[key] = value
	end

	private {
		__allitems = allitems
	}
end

-- define class methods:

-- Obtains the value, the first param is the string key associated to.
function Item:get ( sKey )
	isString(sKey) -- Check if is String, otherwise raises an error
	return self.__allitems[sKey]
end

function Item:set ( sKey, value )
	isString(sKey)
	self.__allitems[sKey] = value
	return self:get(sKey) == value
end

-- Add a new value, the first param is the string key, the second param is the value to store.
function Item:add ( sKey, value )
	isString(sKey) --> the key must be string.

	if self.__allitems[sKey] then				
		error 'This key exists now, please change the name of this key.'
	else
		self.__allitems[sKey] = value
	end

	return # self.__allitems
end

return Item