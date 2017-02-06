-- /////////////////////////////////////////////////////////////////////////////////////////////////
-- // Name:        classes/event.lua
-- // Purpose:     Event class
-- // Author:      Dario Cano [thdkano@gmail.com]
-- // Created:     2014/08/24
-- // Copyright:   (c) 2014 Dario Cano
-- // License:     lide license
-- /////////////////////////////////////////////////////////////////////////////////////////////////

-- Class constructor:
--
--  object Event:new ( string sEventName, object oEventSender, function fDefEventHandler )
--
--  	sEvtName      	The event name
--		oEvtSender    	The object associated to the event (usually a 'Widget')
--		fEvtHandler   	The event handler function (that is called when you call Event:call(...)).
--
--
-- Class methods:
--
-- 		object 	  getSender( ) 						Gets the object associated to the event.
--		boolean	  setSender( object Sender ) 		Sets the object associated to the event.
--		function  getHandler( ) 					Returns the event handler function.
--		boolean   setHandler( function Handler ) 	Sets the event handler function.
--		...		  call( ... ) 						Call the event handler.


-- define local functions:

local function format_lua_error ( err_str )
	local err_str, errordesc = err_str or ''
	
	local N1, N2 = err_str:find(':%d+:')
	if not N1 or not N2 then return {} end
	return {
		errorline = err_str:sub(N1 +1, N2 -1),
		errordesc = err_str:sub(N2 +2, #err_str),
		filename  = err_str:sub(1, N1-1)
	}
end

local function eventHandler_error( oEvent, errmsg , level)
	local t = format_lua_error(errmsg)
	local eventName = oEvent:getName() or 'event [no-name]'

	errmsg = '%s\n\n[%s]\n'
	.. '[line:%d] in event handler execution of event \'%s\''
	print ( errmsg:format(t.errordesc, t.filename, t.errorline, eventName, level)  )
	error()
    --lide.core.error.lperr(errmsg:format(t.errordesc, t.filename, t.errorline, eventName, level))
    --error( errmsg:format(t.errordesc, t.filename, t.errorline, eventName, level) , 3)
end

-- import required classes
local Object = lide.classes.object


-- import required functions
local isString   = lide.core.base.isstring
local isObject   = lide.core.base.isobject
local isFunction = lide.core.base.isfunction
local isBoolean  = lide.core.base.isboolean


-- declare class
local Event = class 'Event' : subclassof 'Object' 
	: global (false)	-- not global by default

-- define class constructor
function Event:Event ( sEvtName, oEvtSender, fDefEvtHandler )
  	-- call Object class constructor:
	self.super : init ( sEvtName, lide.core.base.newid() )
	
	fDefEvtHandler = fDefEvtHandler or lide.core.base.voidf

	-- define class values:
	protected {
		Sender  = isObject(oEvtSender), 	  	--> Who sends the event?
		Handler = isFunction(fDefEvtHandler), 	--> Default event handler
	}

	-- sett ype:
	getmetatable(self).__type = 'event'
end


-- define class getters/setters:

function Event:getSender ( )
	return self.Sender
end

function Event:setSender ( oEvtSender )
	self.Sender = isObject(oEvtSender)
	if ( self.Sender == oEvtSender ) then return true else return false end
end

function Event:getHandler ( )
	return self.Handler
end

function Event:setHandler ( fEvtHandler )
	self.Handler = isFunction(fEvtHandler)
	if ( self.Handler == fEvtHandler ) then return true else return false end
end


-- define class methods:

function Event:call( ... )
	local exec, result = pcall( self:getHandler(), self, ... )
	
	if (not exec) then eventHandler_error(self, result, 1) end 

	return result -- Retornar el primer valor que devuelve el event handler
end

return Event