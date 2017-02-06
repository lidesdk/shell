-- /////////////////////////////////////////////////////////////////////////////
-- // Name:        classes/widget.lua
-- // Purpose:     Widget class
-- // Author:      Dario Cano [thdkano@gmail.com]
-- // Created:     2014/07/23
-- // Copyright:   (c) 2014 Dario Cano
-- // License:     lide license
-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--
-- Class constructor:
--
--  object Widget:new ( string sWidgetName, string sWidgetType, number nPosX, number nPosY, number nWidth, number nHeight, number nID )
--
--  	string sWidgetName    	The widget name
--		string sWidgetType  	The widget type identificator
--		number nPosX			Position related to X
--		number nPosY			Position related to Y
--		number nWidth			Width of the widget
--		number nHeight			Height of the widget
--		number nID 				The object identificator
--		object oParent 			The Widget Parent
--
-- Class methods:
--
-- 		userdata  getwxObj() 								Gets the wxWidgets object.
--		string	  getWidgetType()	 						Returns the widget type identificator.
--		boolean	  setWidgetType()	 						Sets the widget type identificator.
--		number	  getPosX() 								Returns the position related to X.
--		boolean	  setPosX( number nPosX )					Sets the position related to X.
--		number	  getPosY() 								Returns the position related to Y.
--		boolean	  setPosY( number nPosY )					Sets the position related to Y.
--		number	  getWidth() 								Returns the width of the widget.
--		boolean	  setWidth( number nWidth )					Sets the width of the widget.
--		number	  getHeight() 								Returns the height of the widget.
--		boolean	  setHeight( number nHeight )				Sets the height of the widget.
-- 		nil 	  initializeEvents( string sEventNames ) 	Copy events from super class Widget to the child class.
--	    boolean   getVisible()								Returns true if the widget is visible, false otherwise.
--		nil		  setVisible( bVisible )					Sets the visibility of the widget.
--		boolean   getEnabled()
--		nil       setEnabled

-- import local functions:
local isString  = lide.core.base.isstring
local isNumber  = lide.core.base.isnumber
local isObject  = lide.core.base.isobject
local isBoolean = lide.core.base.isboolean

-- import local classes:
local Object   = lide.classes.object
local Event    = lide.classes.event


-- define the class:
local Widget = class 'Widget' : subclassof 'Object' : global ( false )

function Widget:Widget ( sWidgetName, sWidgetType, nPosX, nPosY, nWidth, nHeight, nID, oParent )
	self.super:init( sWidgetName, nID )
	
	-- Check if oParent exists, because toplevel windows are widgets without parent
	-- Parent check must be in control class
	if oParent then	isObject(oParent) end

	protected {
		WidgetType = isString(sWidgetType),
		PosX  = isNumber(nPosX) , PosY = isNumber(nPosY),
		Width = isNumber(nWidth), Height = isNumber(nHeight),

		wxObj  = '.none.', -- initialize the wxObject fied
		Parent = oParent, -- initialize the widget parent fied
	}
end

-- define class getters/setters:

Widget:virtual 'getwxObj'

function Widget:getwxObj()
	return self.wxObj
end

Widget:virtual 'getParent'

function Widget:getParent( )
	return self.Parent
end

function Widget:getWidgetType( )
	return self.WidgetType
end

function Widget:setWidgetType( sType )
	self.WidgetType = isString(sType)
	if ( self.WidgetType == sType ) then return true else return false end
end

function Widget:getPosX (  )
	return self.wxObj : GetPosition() . X
end

function Widget:setPosX ( nPosX )
	self.PosX = isNumber(nPosX)
	self.wxObj:Move( wx.wxPoint( nPosX, self.wxObj:GetPosition().Y ) )
	if ( self.PosX == nPosX ) then return true else return false end
end

function Widget:getPosY (  )
	return self.wxObj : GetPosition() . Y
end

function Widget:setPosY ( nPosY )
	self.PosY = isNumber(nPosY)
	self.wxObj:Move( wx.wxPoint( self.wxObj:GetPosition().X, nPosY ) )
	if ( self.PosY == nPosY ) then return true else return false end
end

Widget:virtual 'getWidth'
function Widget:getWidth (  )
	return self.wxObj : GetSize() . Width
end

Widget:virtual 'setWidth'
function Widget:setWidth ( nWidth )
	self.Width = isNumber(nWidth)
	self.wxObj:SetSize( wx.wxSize( nWidth, self.wxObj:GetSize().Height ) )
	if ( self.wxObj:GetSize().Width == nWidth ) then return true else return false end
end

Widget:virtual 'getHeight'
function Widget:getHeight (  )
	return self.wxObj : GetSize() . Height
end

Widget:virtual 'setHeight'
function Widget:setHeight ( nHeight )
	self.Height = isNumber(nHeight)
	self.wxObj:SetSize( wx.wxSize( self.wxObj:GetSize().Width, nHeight ) )
	if ( self.wxObj:GetSize().Height == nHeight ) then return true else return false end
end

Widget:virtual 'getVisible'
function Widget:getVisible( )
	return self.getwxObj():IsShown()
end

Widget:virtual 'setVisible'
function Widget:setVisible( bVisible )
	if isBoolean(bVisible) then
		self:getwxObj() :Show()
	else
		self:getwxObj() :Hide()
	end
end

Widget:virtual 'getEnabled'
function Widget:getEnabled()
	return self.wxObj:IsEnabled()
end

Widget:virtual 'setEnabled'
function Widget:setEnabled( bEnabled )
	if (bEnabled == nil) then
		bEnabled = true
	end

	self.Enabled = bEnabled
	
	return self:getwxObj():Enable( bEnabled )
end

Widget:virtual 'setFocus'
function Widget:setFocus( )
	self:getwxObj():SetFocus()

	return self:getwxObj():GetParent():FindFocus():GetHandle() == self:getwxObj():GetHandle() or false
end

Widget:virtual 'initializeEvents'

function Widget:initializeEvents ( toLoad )
	local voidf = lide.core.base.voidf
	
	local function getXY ( event )
		local pos = event:GetPosition()
		return pos.X, pos.Y, event
	end
	
	getmetatable(self) .__events['onEnter'] = {
		data = wx.wxEVT_ENTER_WINDOW,
		args = (getXY),
	}
	
	getmetatable(self) .__events['onLeave'] = {--> Cuando el mouse está por encima del widget:{ 
		data = wx.wxEVT_LEAVE_WINDOW,
		args = voidf -- the same as: args = function ( event ) end
	}

	getmetatable(self) .__events['onIdle'] = {
		data = wx.wxEVT_IDLE,
		args = voidf -- the same as: args = function ( event ) end
	}

	getmetatable(self) .__events['onMove'] = {
		data = wx.wxEVT_MOVE,
		args = (getXY)
	}

	getmetatable(self) .__events['onActivate'] = {
		data = wx.wxEVT_ACTIVATE,
		args = function ( event )
			local IsActive = event:GetActive()
			return IsActive
		end
	}

	getmetatable(self) .__events['onMaximize'] = {
		data = wx.wxEVT_MAXIMIZE,
		args = voidf
	}

	getmetatable(self) .__events['onLeftUp'] = {
		data = wx.wxEVT_LEFT_UP,
		args = (getXY)
	}

	getmetatable(self) .__events['onLeftDown'] = {
		data = wx.wxEVT_LEFT_DOWN,
		args = (getXY)
	}
	
	getmetatable(self) .__events['onLeftDoubleClick'] = {
		data = wx.wxEVT_LEFT_DCLICK,
		args = (getXY)
	}

	getmetatable(self) .__events['onRightUp'] = {
		data = wx.wxEVT_RIGHT_UP,
		args = (getXY)
	}

	getmetatable(self) .__events['onRightDown'] = {
		data = wx.wxEVT_RIGHT_DOWN,
		args = (getXY)
	}
	
	getmetatable(self) .__events['onRightDoubleClick'] = {
		data = wx.wxEVT_RIGHT_DCLICK,
		args = (getXY)
	}
	
	getmetatable(self) .__events['onMiddleDoubleClick'] = {
		data = wx.wxEVT_MIDDLE_DCLICK,
		args = (getXY)
	}

	getmetatable(self) .__events['onMiddleDown'] = {
		data = wx.wxEVT_MIDDLE_DOWN,
		args = (getXY)
	}

	getmetatable(self) .__events['onMiddleUp'] = {
		data = wx.wxEVT_MIDDLE_UP,
		args = (getXY)
	}
	
	getmetatable(self) .__events['onMouseWheel'] = {
		data = wx.wxEVT_MOUSEWHEEL,
		args = function ( event )
			local posX, posY = getXY(event)
			local delta    = event:GetWheelDelta() 
			local rotation = event:GetWheelRotation()
			
			return posX, posY, delta, rotation
		end
	}

	getmetatable(self) .__events['onSize'] = {
		data = wx.wxEVT_SIZE,
		args = function ( event )
			local width, height = event:GetSize().Width, event:GetSize().Height
			return width, height
		end
	}
	
	getmetatable(self) .__events['onSizing'] = {
		data = wx.wxEVT_SIZING,
		args = function ( event )
			local width, height = event:GetSize().Width, event:GetSize().Height
			return width, height
		end
	}
	
	getmetatable(self) .__events['onMoving'] = {
		data = wx.wxEVT_MOVING,
		args = (getXY)
	}

	getmetatable(self) .__events['onMotion'] = { 
		data = wx.wxEVT_MOTION,
		args = (getXY)
	}

	getmetatable(self) .__events['onKeyDown'] = {
		data = wx.wxEVT_KEY_DOWN,
		args = function ( event )
			local nKeyCode = event:GetKeyCode()
			return nKeyCode
		end
	}
		
	getmetatable(self) .__events['onKeyUp'] = {
		data = wx.wxEVT_KEY_UP,
		args = function ( event )
			return event:GetKeyCode()
		end,
	}

	getmetatable(self) .__events['onChar'] = {
		data = wx.wxEVT_CHAR,
		args = function ( event )
			local nKeyCode = event:GetKeyCode()
			return nKeyCode
		end
	}
	

	for _, sEvtName in next, toLoad do
		if tostring(sEvtName) and getmetatable(self).__events[sEvtName] then
			
			self[sEvtName] = Event:new ( self:getName() ..'.'..sEvtName, self, lide.core.base.voidf )

			if (getmetatable(self).__events[sEvtName].data == wx.wxEVT_SHOW) then				
				self:getwxObj():Connect(wx.wxEVT_SHOW, function ( event )					
					---
					--- Implementa onHide
					---
					if (event:GetShow() == true) then
						self['onShow']:call( getmetatable(self).__events['onShow'] . args( event ) )
						
					elseif (event:GetShow() == false) then
					    self['onHide']:call( getmetatable(self).__events['onHide'] . args( event ) )					

					end
				end)
			
			else

				self:getwxObj():Connect(getmetatable(self).__events[sEvtName].data, function ( event )
					if self[sEvtName] then
					    self[sEvtName]:call( getmetatable(self).__events[sEvtName] . args( event ) )
					end

					-- HACK TO ON CLOSE EVENT
					if getmetatable(self).__events[sEvtName].data ~= wx.wxEVT_CLOSE_WINDOW then
						event:Skip()
					end
				end)
			end			
		end
	end
end

return Widget