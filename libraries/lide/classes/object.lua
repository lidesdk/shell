-- /////////////////////////////////////////////////////////////////////////////
-- // Name:        classes/object.lua
-- // Purpose:     Object class
-- // Author:      Dario Cano [thdkano@gmail.com]
-- // Created:     2014/08/24
-- // Copyright:   (c) 2014 Dario Cano
-- // License:     lide license
-- /////////////////////////////////////////////////////////////////////////////
--
-- Class constructor:
--
--  object Object:new ( string sObjectName, number nObjectID )
--
--  	sObjectName    	The object name
--		nObjectID     	The object identificator
--
--
-- Class methods:
--
-- 		number	  getID( ) 						Gets the object identificator.
--		boolean	  setID( number nID ) 			Sets the object identificator.
--		string 	  getName( ) 					Returns object's name.
--		boolean   setName( string Name ) 		Sets object's name.
--		string 	  __tostring()					Metamethod.

-- import functions:
local isString = lide.core.base.isstring
local isNumber = lide.core.base.isnumber

-- define the class:
local Object = class 'Object' : global ( false )


function Object:Object ( sObjectName, nObjectID )
	nObjectID = nObjectID or lide.core.base.newid ()
	
	-- Check if the args are the required type:
	isString(sObjectName) ; isNumber(nObjectID)

	-- Define class values:
	protected {
		Name = sObjectName,
		ID   = nObjectID,
	}
end


--- define class methods
---
Object:virtual 'getID'
function Object:getID ()
	return self.ID
end

Object:virtual 'setID'
function Object:setID ( nID )	
	self.ID = isNumber(nID) 

	if ( self.ID == nID ) then return true else return false end
end

Object:virtual 'getName'
function Object:getName ()
	return self.Name
end

Object:virtual 'setName'
function Object:setName ( sName )
	self.Name = isString(sName)

	if ( self.Name == sName ) then return true else return false end
end

--- define class meta-methods
---
function Object:__tostring ( )
	local str   = ('[%s: %s]')
	local stype = getmetatable(self).__type

	return str:format(stype or 'object', tostring(self.Name))
end

return Object