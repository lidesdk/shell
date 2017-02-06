-- /////////////////////////////////////////////////////////////////////////////
-- // Name:        controls/Listbox.lua
-- // Purpose:     Listbox class
-- // Author:      Dario Cano [thdkano@gmail.com]
-- // Modified by: 
-- // Created:     07/19/2014
-- // Copyright:   (c) 2014 Dario Cano
-- // License:     lide license
-- /////////////////////////////////////////////////////////////////////////////

--To implement:
--%wxchkver_2_8 int HitTest(const wxPoint& point) const; 

-- set Listbox constants:

local LB_SINGLE    = wx.wxLB_SINGLE
local LB_MULTIPLE  = wx.wxLB_MULTIPLE
local LB_EXTENDED  = wx.wxLB_EXTENDED 
local LB_HSCROLL   = wx.wxLB_HSCROLL
local LB_ALWAYS_SB = wx.wxLB_ALWAYS_SB
local LB_NEEDED_SB = wx.wxLB_NEEDED_SB
local LB_SORT  	 = wx.wxLB_SORT
local LB_OWNERDRAW = wx.wxLB_OWNERDRAW 


-- define class:
--local Listbox = ItemContainer:subclass "Listbox"

--Listbox:virtual "GetSelections"
--Listbox:virtual "SetChoices"


	-- import libraries
local check = lide.core.base.check

-- import local functions:
local isObject = lide.core.base.isobject

-- import required classes
local Control = lide.classes.widgets.control
local Store   = lide.classes.store
local Item    = lide.classes.item

local Listbox = class 'Listbox' : subclassof 'Control'

function Listbox:Listbox ( fields )
	-- check for fields required by constructor:
	check.fields { 
	 	'string Name', 'object Parent', 
	}
	
	-- define class fields
	private {
		DefaultPosition = { X = -1, Y = -1 }, 
		DefaultSize     = { Width = -1, Height = -1 },
		DefaultFlags    = wx.wxTAB_TRAVERSAL,

		--Parent = fields.Parent
	}

	protected {
		Choices = fields.Choices or wx.wxArrayString
		--Text  = fields.Text,
	}
	
	-- call Control constructor
	self.super : init ( fields.Name, fields.Parent, fields.PosX or self.DefaultPosition.X, fields.PosY or self.DefaultPosition.Y, fields.Width or self.DefaultSize.Width, fields.Height or self.DefaultSize.Height, fields.ID )
	
	-- create wxWidgets object and store it on self.wxObj:
	-- wxButton(wxWindow *parent, wxWindowID id, const wxString& label, const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxDefaultSize, long style = 0, const wxValidator& validator = wxDefaultValidator, const wxString& name = "wxButton" ); 
--		self.wxObj = wx.wxButton(self.Parent:getwxObj(), self.ID, self.Text, wx.wxPoint( self.PosX, self.PosY ), wx.wxSize( self.Width, self.Height ), self.Flags or self.DefaultFlags, wx.wxDefaultValidator, self.Name)

	self.Store = Store:new ()
	
	-- Define specific object properties:

	-- set object position:

	-- add specific control events:
	-- self.Events.OnSelect      = wx.wxEVT_COMMAND_Listbox_SELECTED
	-- self.Events.OnDoubleClick = wx.wxEVT_COMMAND_Listbox_DOUBLECLICKED
	
	-- Create current wxObj:
	--self.wxObj = wx.wxListbox( self.Parent, self.ID, Properties.Text, Properties.Position, Properties.Size, Properties.Choices, Properties.Flags, Properties.Validator, self.Name )
	self.wxObj = wx.wxListBox(self.Parent:getwxObj(), self.ID, wx.wxPoint( self.PosX, self.PosY ), wx.wxSize( self.Width, self.Height ), self.Choices, self.Flags or self.DefaultFlags, wx.wxDefaultValidator, self.Name)

	-- registry event onClick
	getmetatable(self) .__events['onSelected'] = {
		data = wx.wxEVT_COMMAND_LISTBOX_SELECTED,
		args = function ( event )
			local nItem       = tonumber(event:GetInt())
			--local isSelection = event:IsSelection()
			--local itemText    = event:GetString()
			return nItem +1 --, isSelection, itemText
		end
	}

	self:initializeEvents {
		'onEnter', 'onLeave',

		'onSelected'
	}
end

function Listbox:InitListboxEvents( tEventNames )
	--* See Widget:InitWidgetEvents() for more info... 
	local function getLBValues( event )
		local Item, IsSelection, ItemText

		Item        = event:GetInt()
		IsSelection = event:IsSelection()
		ItemText    = event:GetString()
		return Item, IsSelection, ItemText
	end

	local tEvents = {
		OnSelected 	= { 
			data = wx.wxEVT_COMMAND_Listbox_SELECTED,
			args = getLBValues
		},

		OnDoubleClick = {
			data = wx.wxEVT_COMMAND_Listbox_DOUBLECLICKED,
			args = getLBValues
		}
	}
	
	local exec, err_msg = pcall( lide.hand_event, self, tEvents, tEventNames)
	if (not exec) then lide.print_error(err_msg) end	
end

-- void InsertItems(const wxArrayString& items, int pos );
function Listbox:InsertItems( Items, Position )
	self.wxObj:InsertItems(Items, Position)
end

-- void Deselect(int n ); 
function Listbox:Deselect( Item )
	self.wxObj:Deselect(Item)
end

-- bool IsSelected(int n) const; 
function Listbox:IsSelected( Item )
	return self.wxObj:IsSelected( Item )
end

-- // %override [Lua table of int selections] wxListbox::GetSelections( ); 
-- // C++ Func: int GetSelections(wxArrayInt& selections) const; 
-- int GetSelections() const; 
--function Listbox:getSelections()
--	return self.wxObj:GetSelections()
--end

function Listbox:getSelection()
	return self.wxObj:GetSelection()+1
end

-- void SetFirstItem(int n ); 
function Listbox:SetFirstItem( Item )
	self.wxObj:SetFirstItem(Item)
end

--void SetSelection(int n, bool select = true ); 
--void SetStringSelection(const wxString& string, bool select = true ); 
function Listbox:setSelection( Item, Select )
	if (Select == nil) then
		Select = true
	end

	if type(Item) == "string" then
		self.wxObj:SetStringSelection(Item-1, Select)
	elseif type(Item) == "number" then
		self.wxObj:SetSelection(Item-1, Select)
	else
		error(3, "arg 1 must be string or number")
	end
end

--void Set(const wxArrayString& choices ); 
function Listbox:setChoices( tblChoices )
	self.wxObj:Set( tblChoices )
	self.Choices = tblChoices
end

function Listbox:getChoices( )
	return self.Choices
end

function Listbox:getString( nItem )
	return self.wxObj:GetString(nItem-1)
end


return Listbox