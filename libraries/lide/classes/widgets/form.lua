-- ///////////////////////////////////////////////////////////////////////////////
-- // Name:        classes/widgets/form.lua
-- // Purpose:     class Form definition
-- // Author:      Dario Cano [thdkano@gmail.com]
-- // Created:     2016/02/15
-- // Copyright:   (c) 2016 Dario Cano
-- // License:     lide license
-- ///////////////////////////////////////////////////////////////////////////////


-- import required classes:
local Window = lide.classes.widgets.window
local Panel  = lide.classes.widgets.panel

-- define the class:
local Form = class 'Form' : subclassof 'Window' 
	--: global(false)


function Form:Form( fields )
	self.super:init ( fields ) --> Window:init
	
	-- add Panel object to intercept onKey* events and place the controls:		
	self.Panel = Panel:new { Parent = self,
		Name   = self.Name .. '.Panel',
	}
	
	-- Panel fixes:
	self.Panel:getwxObj():SetSize( self:getwxObj():GetSize() )

	-- reference Panel events to Form
	self.onKeyDown 	  = self.Panel.onKeyDown
	self.onKeyUp   	  = self.Panel.onKeyUp
	self.onEnter   	  = self.Panel.onEnter
	self.onLeave   	  = self.Panel.onLeave
	self.onMotion  	  = self.Panel.onMotion
	self.onRightUp 	  = self.Panel.onRightUp
	self.onRightDown  = self.Panel.onRightDown
	self.onRightDoubleClick = self.Panel.onRightDoubleClick
	self.onLeftUp     = self.Panel.onLeftUp
	self.onLeftDown   = self.Panel.onLeftDown
	self.onLeftDoubleClick = self.Panel.onLeftDoubleClick
	self.onMiddleUp   = self.Panel.onMiddleUp
	self.onMiddleDown = self.Panel.onMiddleDown
	self.onMiddleDoubleClick = self.Panel.onMiddleDoubleClick
	self.onMouseWheel = self.Panel.onMouseWheel
end

function Form:getFocusedObject( ... )
	return self.Panel:getFocusedObject( ... )
end

function Form:setFocusedObject( ... )
	return self.Panel:setFocusedObject( ... )
end

return Form