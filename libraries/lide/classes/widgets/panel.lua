-- /////////////////////////////////////////////////////////////////////////////
-- // Name:        objects/panel.lua
-- // Purpose:     Panel class
-- // Author:      Dario Cano [thdkano@gmail.com]
-- // Created:     2014/09/08
-- // Copyright:   (c) 2014 Dario Cano
-- // License:     lide license
-- /////////////////////////////////////////////////////////////////////////////
--
-- Class constructor:
--
--  object Panel:new { 
--  	string Name  ,		The panel name.
--		object Parent,		The panel parent.
--	}
--
--

-- import libraries
local check = lide.core.base.check

-- import local functions:
local isObject  = lide.core.base.isobject
local isBoolean = lide.core.base.isboolean

-- import required classes
local Widget = lide.classes.widget

-- define class constructor
local Panel = class 'Panel' : subclassof 'Widget' : global (false)

function Panel:Panel ( fields )
	-- check for fields required by constructor:
	check.fields { 
	 	'string Name', 'object Parent'
	}

	-- define class fields
	private {
		DefaultPosition = { X = -1, Y = -1 }, 
		DefaultSize     = { Width = -1, Height = -1 },
		DefaultFlags    = wx.wxTAB_TRAVERSAL,

		-- Para guardar el FocusedObject, lo inicializamos con un boolean false
		FocusedObject   = false,
	}
	
	-- call Widget constructor
	self.super:init( fields.Name, 'widget', fields.PosX or self.DefaultPosition.X, fields.PosY or self.DefaultPosition.Y, fields.Width or self.DefaultSize.Width, fields.Height or self.DefaultSize.Height, fields.ID, fields.Parent )

	-- create wxWidgets object and store it on self.wxObj:
	-- wxPanel(wxWindow* parent, wxWindowID id, const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxDefaultSize, long style = wxTAB_TRAVERSAL, const wxString& name = "wxPanel" );
	self.wxObj = wx.wxPanel(self.Parent:getwxObj(), self.ID, wx.wxPoint( self.PosX, self.PosY ), wx.wxSize( self.Width, self.Height ), self.Flags or self.DefaultFlags, self.Name)

	-- initialize events:
	self:initializeEvents {
	    'onEnter', 'onLeave', 'onMotion'

		--'onRightUp' , 'onRightDown' , 'onRightDoubleClick' ,
		--'onLeftUp'  , 'onLeftDown'  , 'onLeftDoubleClick'  ,
		--'onMiddleUp', 'onMiddleDown', 'onMiddleDoubleClick',

		--'onMouseWheel',

		--'onKeyDown', 'onKeyUp',
	}
end

function Panel:getFocusedObject()
	return self.FocusedObject or false, 'This panel doesn\'t have a focused object.'
end

function Panel:setFocusedObject( oFocusObject )
	isObject( oFocusObject )

	if oFocusObject:setFocus() then
		self.FocusedObject = oFocusObject
	end

	return (self.FocusedObject == oFocusObject) or false
end


-- void SetSizer(wxSizer* sizer, bool deleteOld=true );  --> wxWindow
function Panel:setSizer( oSizer, bDeleteOld )
	isObject(oSizer)
	if bDeleteOld ~= nil then isBoolean(bDeleteOld) end
	self.wxObj:SetSizer( oSizer:getwxObj(), bDeleteOld)
	--self.wxObj:SetSize ( self.wxObj:GetSize().Width-1, self.wxObj:GetSize().Height-1 )
	--self.wxObj:SetSize ( self.wxObj:GetSize().Width+1, self.wxObj:GetSize().Height+1 )
end

return Panel
