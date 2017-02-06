-- /////////////////////////////////////////////////////////////////////////////
-- // Name:        controls/button.lua
-- // Purpose:     Button class
-- // Version:     0.0.0.1
-- // Author:      Dario Cano [thdkano@gmail.com]
-- // Created:     07/07/2014
-- // Copyright:   (c) 2014 Dario Cano
-- // License:     lide license
-- /////////////////////////////////////////////////////////////////////////////
--
-- Class constructor:
--
--  object Button:new { 
--  	string Name  ,		The control name.
--		object Parent,		The control parent.
--		string Text  , 		The button text.
--	}
-- 
--
-- Class methods:
--
-- 		userdata  getwxObj() 								Gets the wxWidgets object.
--		string	  getWidgetType()	 						Returns the widget type identificator.
--		boolean	  setWidgetType()	 						Sets the widget type identificator.
--		number	  getPosX() 								Returns the position related to X.


-- import libraries
local check = lide.core.base.check

-- import local functions:
local isObject = lide.core.base.isobject

-- import required classes
local Control = lide.classes.widgets.control

local Button = class 'Button' : subclassof 'Control'

function Button:Button ( fields )
	-- check for fields required by constructor:
	check.fields { 
	 	'string Name', 'object Parent', 'string Text'
	}
	
	-- define class fields
	private {
		DefaultPosition = { X = -1, Y = -1 }, 
		DefaultSize     = { Width = -1, Height = -1 },
		DefaultFlags    = wx.wxTAB_TRAVERSAL,

		--Parent = fields.Parent
	}

	protected {
		Text  = fields.Text,
	}
	
	-- call Control constructor
	self.super : init ( fields.Name, fields.Parent, fields.PosX or self.DefaultPosition.X, fields.PosY or self.DefaultPosition.Y, fields.Width or self.DefaultSize.Width, fields.Height or self.DefaultSize.Height, fields.ID )
	
	-- create wxWidgets object and store it on self.wxObj:
	-- wxButton(wxWindow *parent, wxWindowID id, const wxString& label, const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxDefaultSize, long style = 0, const wxValidator& validator = wxDefaultValidator, const wxString& name = "wxButton" ); 
	self.wxObj = wx.wxButton(self.Parent:getwxObj(), self.ID, self.Text, wx.wxPoint( self.PosX, self.PosY ), wx.wxSize( self.Width, self.Height ), self.Flags or self.DefaultFlags, wx.wxDefaultValidator, self.Name)

	-- registry event onClick
	getmetatable(self) .__events['onClick'] = {
		data = wx.wxEVT_COMMAND_BUTTON_CLICKED,
		args = lide.core.base.voidf
	}

	self:initializeEvents {
		'onEnter', 'onLeave', 'onMotion', 'onMoving', 'onMove',

		'onLeftUp', 'onLeftDown', 'onLeftDoubleClick',

		'onClick' --> Buton Class' onClick
	}
end

return Button