-- /////////////////////////////////////////////////////////////////////////////
-- // Name:        controls/Combobox.lua
-- // Purpose:     Combobox class
-- // Author:      Hernán Cano [jhernancanom@gmail.com]
-- // Created:     2014-07-14
-- // Copyright:   (c) 2014 Hernán Cano
-- // License:     lide license
-- /////////////////////////////////////////////////////////////////////////////

-- set Combobox constants:
enum {
	CB_SIMPLE        = wx.wxCB_SIMPLE,       -- Windows only. 
	CB_DROPDOWN      = wx.wxCB_DROPDOWN,     -- MSW and Motif only. 
	CB_READONLY      = wx.wxCB_READONLY,     -- platform-dependent
	CB_SORT          = wx.wxCB_SORT,
}

-- import libraries
local check = lide.core.base.check

-- import local functions:
local isTable   = lide.core.base.istable
local isNumber  = lide.core.base.isnumber
local isString  = lide.core.base.isstring
local isBoolean = lide.core.base.isboolean

-- import required classes
local Control = lide.classes.widgets.control

-- import local functions:

-- TE_PROCESS_ENTER = wx.wxTE_PROCESS_ENTER -- non-implemented yet

-- define class:
local Combobox = class 'Combobox' : subclassof 'Control' : global (false)

function Combobox:Combobox( fields )
	-- check for fields required by constructor:
	check.fields { 
	 	'string Name', 'object Parent', --'string Text'
	}

	-- define class fields
	private {
		DefaultPosition = { X = -1, Y = -1 }, 
		DefaultSize     = { Width = -1, Height = -1 },
		DefaultFlags    = CB_DROPDOWN,
	}

	protected {
		Text  = fields.Text or '',

		Choices   = fields.Choices or wx.wxArrayString,
		Validator = wx.wxDefaultValidator,
		ReadOnly  = - CB_READONLY,
		Flags     = ( fields.Flags or CB_READONLY )
	}
	
	-- call Control constructor
	self.super : init ( fields.Name, fields.Parent, fields.PosX or self.DefaultPosition.X, fields.PosY or self.DefaultPosition.Y, fields.Width or self.DefaultSize.Width, fields.Height or self.DefaultSize.Height, fields.ID )
	
	-- add specific control events:

	if (self.ReadOnly ~= nil) then
		if self.ReadOnly then
			self.Flags = ( self.Flags + CB_READONLY )
		end
	end

	-- Create current wxObj:
	self.wxObj = wx.wxComboBox( self.Parent:getwxObj(), self.ID, self.Text, wx.wxPoint( self.PosX, self.PosY ), wx.wxSize( self.Width, self.Height ), self.Choices, self.Flags or self.DefaultFlags, self.Validator, self.Name )
	
	-- registry event onClick
	getmetatable(self) .__events['onSelected'] = {
		data = wx.wxEVT_COMMAND_COMBOBOX_SELECTED,
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

--function Combobox:InitComboboxEvents( tEventNames )
--	--* See Widget:InitWidgetEvents() for more info... 
--
--	local tEvents = {
--		OnSelected 	= { 
--			data = wx.wxEVT_COMMAND_Combobox_SELECTED,
--			args = function ( event )
--				local SelectionText = event:GetString()
--				local Selection     = event:GetSelection()
--				return Selection, SelectionText
--			end
--		}
--	}
--	
--	local exec, err_msg = pcall( lide.hand_event, self, tEvents, tEventNames)
--	if (not exec) then lide.print_error(err_msg) end	
--end

function Combobox:getText( )
	return self.wxObj:GetValue()
end

-- void SetValue(const wxString& text ); 
function Combobox:setText( sText )
	isString(sText)
	self.wxObj:SetValue(sText)
end

function Combobox:setChoices( tChoices )
	isTable(tChoices)
	
	self:getwxObj():Clear()
	
	for idx, str in pairs(tChoices) do
		self.wxObj:Append(str)
	end
end

-- virtual void SetSelection(int n); //= 0; 
-- bool SetStringSelection(const wxString& s ); 
function Combobox:setSelection( nNewSelection )		
	if type( nNewSelection ) == 'number' then
		self:getwxObj():SetSelection(nNewSelection)
	elseif type( nNewSelection ) == 'string' then
		self:getwxObj():SetStringSelection(nNewSelection)
	else
		isNumber(nNewSelection)
	end
end

function Combobox:getSelection( ... )
	return self.wxObj:GetSelection() +1
end


-- virtual int FindString(const wxString& s, bool bCase = false) const; 
function Combobox:findItem( sText, bCaseSensitive )
	isString(sText) isBoolean(bCaseSensitive)
	return self:getwxObj():FindString(sText, bCaseSensitive or false)
end

function Combobox:clear( ... )
	return self.wxObj:Clear( ... )
end

--function Combobox:setSelected( selection, selectionText) end

return Combobox

-- #define wxCB_DROPDOWN 
-- #define wxCB_READONLY 
-- #define wxCB_SIMPLE 
-- #define wxCB_SORT 

-- class wxCombobox : public wxControl, public wxItemContainer 
-- {
-- wxCombobox( ); 
-- wxCombobox(wxWindow* parent, wxWindowID id, const wxString& value = "", const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxDefaultSize, const wxArrayString& choices = wxLuaNullSmartwxArrayString, long style = 0, const wxValidator& validator = wxDefaultValidator, const wxString& name = "wxCombobox" ); 
-- bool Create(wxWindow* parent, wxWindowID id, const wxString& value = "", const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxDefaultSize, const wxArrayString& choices = wxLuaNullSmartwxArrayString, long style = 0, const wxValidator& validator = wxDefaultValidator, const wxString& name = "wxCombobox" ); 

-- bool CanCopy() const; 
-- bool CanCut() const; 
-- bool CanPaste() const; 
-- bool CanRedo() const; 
-- bool CanUndo() const; 
-- void Copy( ); 
-- void Cut( ); 
-- %wxchkver_2_8 virtual int GetCurrentSelection() const; 
-- long GetInsertionPoint() const; 
-- long GetLastPosition() const; 
-- wxString GetValue() const; 
-- void Paste( ); 
-- void Redo( ); 
-- void Replace(long from, long to, const wxString& text ); 
-- void Remove(long from, long to ); 
-- void SetInsertionPoint(long pos ); 
-- void SetInsertionPointEnd( ); 
-- void SetSelection(long from, long to ); 
-- void Undo( ); 
-- }; 