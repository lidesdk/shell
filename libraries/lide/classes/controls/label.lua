-- /////////////////////////////////////////////////////////////////////////////
-- // Name:        lide/classes/controls/label.lua
-- // Purpose:     Label class
-- // Version:     0.0.0.1
-- // Author:      Dario Cano [thdkano@gmail.com]
-- // Created:     07/07/2014
-- // Copyright:   (c) 2014 Dario Cano
-- // License:     lide license
-- /////////////////////////////////////////////////////////////////////////////
--
-- Class constructor:
--
--  object Label:new { 
--  	string Name  ,		The control name.
--		object Parent,		The control parent.
--		string Text  , 		The button text.
--	}
-- 

-- define constants:

enum {
	NO_AUTORESIZE = wx.wxST_NO_AUTORESIZE
}

-- import libraries
local check = lide.core.base.check

-- import local functions:
local isString = lide.core.base.isstring
local isNumber = lide.core.base.isnumber

-- import required classes
local Control = lide.classes.widgets.control

local Label = class 'Label' : subclassof 'Control' : global(false)
local Font  = lide.classes.font

-- set local variables:
local DEFAULT_FLAGS

if lide.platform.getOSName() == 'Linux' then
	DEFAULT_FLAGS = -1
else
	DEFAULT_FLAGS = NO_AUTORESIZE
end

function Label:Label ( fields )
	-- check for fields required by constructor:
	check.fields { 
 	 	'string Name', 'object Parent', 'string Text'
 	}

 	-- define class fields
 	protected {
 		DefaultPosition = { X = 1, Y = 1 }, 
 		DefaultSize     = { Width = 100, Height = 100 },
 		DefaultFlags    = DEFAULT_FLAGS,
 		Flags           = fields.Flags 
 	}
 	
 	private {
 		Text = isString(fields.Text),
 	}
 	-- call Control constructor
	self.super : init ( fields.Name, fields.Parent, fields.PosX or self.DefaultPosition.X, fields.PosY or self.DefaultPosition.Y, fields.Width or self.DefaultSize.Width, fields.Height or self.DefaultSize.Height, fields.ID )
	
	-- create wxWidgets object and store it on self.wxObj:
	--wxStaticText(wxWindow, number, string [, wxPoint, wxSize, number, string])
	self.wxObj = wx.wxStaticText(self:getParent():getwxObj(), self.ID, self.Text, wx.wxPoint( self.PosX, self.PosY ), wx.wxSize( self.Width, self.Height ), self.Flags or self.DefaultFlags, self.Name)
	
	-- get the default font of wxWidgets object
	local defwxFnt = self:getwxObj() : GetFont()

	-- set this value as default font of this class on this platform
	self.DefaultFont = Font :new ( defwxFnt )
	self.DefaultFont:setName(defwxFnt:GetFaceName())	-- set the name of font lide obj

	if fields.Font and isString(fields.Font) then
		self.Font = fields.Font
	else
		self.Font = self.DefaultFont
	end

	--[[x registry event onClick
	getmetatable(self) .__events['onClick'] = {
		data = wx.wxEVT_COMMAND_BUTTON_CLICKED,
		args = lide.core.base.voidf
	}

	self:initializeEvents {
		'onEnter', 'onLeave',
	}]]
	self:initializeEvents {
		'onMotion', 'onLeftDown', 'onLeftUp',
		'onLeftDoubleClick', 
	}
end

function Label:setWrap( nPixels )
	isNumber(nPixels)
	self:getwxObj():Wrap(nPixels)
end

return Label