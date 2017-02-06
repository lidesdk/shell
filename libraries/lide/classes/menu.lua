-- /////////////////////////////////////////////////////////////////////////////////////////////////
-- // Name:        lide/classes/widgets/menu.lua
-- // Purpose:     Menu Class
-- // Author:      Dario Cano [thdkano@gmail.com]
-- // Created:     2014/07/23
-- // Copyright:   (c) 2014 Dario Cano
-- // License:     lide license
-- /////////////////////////////////////////////////////////////////////////////////////////////////
--
-- Class constructor:
--
--  object Textbox:new { 
--  	string Name  ,		The control name.
--		object Parent,		The control parent.
--		string Text  , 		The Textbox text.
--	}
-- 
--
-- import functions:
local isString  = lide.core.base.isstring
local isNumber  = lide.core.base.isnumber
local isBoolean = lide.core.base.isboolean
local newID     = lide.core.base.newid

-- import libraries
local check = lide.core.base.check


-- import required classes
local Object = lide.classes.object
local Store  = lide.classes.store
local Item   = lide.classes.item

-- define menu constants:
enum {
	MENU_ITEM_NORMAL = wx.wxITEM_NORMAL,
	MENU_ITEM_CHECK  = wx.wxITEM_CHECK,
	MENU_ITEM_RADIO  = wx.wxITEM_RADIO,
	
	MENU_ID_EXIT  	  = wx.wxID_EXIT,
	MENU_ID_ABOUT 	  = wx.wxID_ABOUT,
	MENU_ID_SEPARATOR = wx.wxID_SEPARATOR,
	
	-- wxGTK only:,
	MENU_STYLE_TEAROFF = wx.wxMENU_TEAROFF,
}

-- define class Menu:
local Menu = class 'Menu' : subclassof 'Object'

function Menu:Menu( fields )
	if fields.Style then isNumber(fields.Style) end
	if fields.Title then isString(fields.Title) end
	
	check.fields {
		'string Name', 'string Text'
	}

	private {
		Title = fields.Title or '',
		Style = fields.Style or -1,
		wxObj = '.none.',
		Text  = fields.Text
	}

	self.super:init( fields.Text, fields.ID )

	self.Store = Store:new ()
	
	self.wxObj = wx.wxMenu( self.Title, self.Style )
end

-- reimplements wxObj:
function Menu:getwxObj( ... )
	return self.wxObj
end

function Menu:getText( )
	return self.Text
end

function Menu:addSeparator()
 	self.wxObj:AppendSeparator()
end

function Menu:addItem( sText, nID, sHelpStr, sShortcut)
	--if not Text then error "el primer argumento debe ser un string."  return false end
	--if Shortcut then Text = Text .."\t".. Shortcut end
	--
	--ID = ID or lide.newid()
	--
	----self.Items[ID] = 
	--
	--return self.wxObj:Append(ID, Text or '', Help or '')
	local objItem = Item:new { 
		ID = nID and isNumber(nID) or newID(), Enabled = true,
		Text = sText, HelpString = sHelpStr or '', Shortcut = sShortcut or ''
	}

	-- wxMenuItem* Append(int id, const wxString& item, const wxString& helpString = "", wxItemKind kind = wxITEM_NORMAL )
	local wxObj = self:getwxObj():Append(objItem:get 'ID', objItem:get 'Text', objItem:get 'HelpString')
	
	-- Store the wxObject referenced to this item tool
	objItem:add ('wxObj', wxObj )
	
	-- add to the internal store:
	return self.Store:add ( objItem ) --> return the index in the internal Store	
end

-- void Enable(int id, bool enable ); 
function Menu:setEnabled( nID, bEnable )
	isBoolean(bEnable); isNumber(nID)
	
	-- Update de internal item store:
	self.Store : get { ID = nID } : set ('Enabled', bEnable) --> get by ID == nID or nil

	self.wxObj:Enable(nID, bEnable)
end


--[[
function Menu:AddCheckItem( Text, ID, Help, Shortcut)
	if Shortcut then
		Text = Text .."\t".. Shortcut
	end
	
	-- wxMenuItem* AppendCheckItem(int id, const wxString& item, const wxString& helpString = "" ); 
	self.Items[ID] = self.wxObj:AppendCheckItem(ID, Text, Help or "")
end

function Menu:AddRadioItem( Text, ID, Help, Shortcut)
	if Shortcut then
		Text = Text .."\t".. Shortcut
	end
	
	--wxMenuItem* AppendRadioItem(int id, const wxString& item, const wxString& helpString = "" ); 
	self.Items[ID] = self.wxObj:AppendRadioItem(ID, Text, Help or "")
end


function Menu:AddSubMenu(SubMenu, ID)
 	-- wxMenuItem* Append(int id, const wxString& item, %ungc wxMenu *subMenu, const wxString& helpString = "" ); 
 	ID = tonumber(ID) or newID()
 	SubMenu.wxItem = self.wxObj:Append(ID, SubMenu.Name, SubMenu.wxObj, Help or "")
 	self.Items[ID] = SubMenu.wxItem
end

-- void Break( ); 
function Menu:Break()
	self.wxObj:Break()
end

-- void Check(int id, bool check ); 
function Menu:CheckItem(ID, Check)
	self.wxObj:Check(ID, Check)
end

-- void Delete(int id ); 
-- void Delete(wxMenuItem *item ); 
function Menu:DeleteItem( ID )
	self.wxObj:Delete(ID)
end

-- void Destroy(int id ); 
-- void Destroy(wxMenuItem *item ); 
function Menu:DeleteSubMenu( SubMenu )
	self.wxObj:Destroy(tonumber(SubMenu) or SubMenu.wxItem)
end

-- wxString GetHelpString(int id) const; 
function Menu:GetHelpString( ID )
	return self.wxObj:GetHelpString(ID)
end

-- wxString GetLabel(int id) const; 
function Menu:GetItemText( ID )
	return self.wxObj:GetLabel(ID)
end

-- void SetLabel(int id, const wxString& label ); 
function Menu:SetItemText( ID, Text )
	self.wxObj:SetLabel(ID, Text)
end

-- void Enable(int id, bool enable ); 
function Menu:SetEnabled( ID, Enable )
	self.wxObj:Enable(ID, Enable)
end

-- int FindItem(const wxString& itemString) const; 
function Menu:FindItem( Text )
	return self.wxObj:FindItem(Text)
end

-- size_t GetMenuItemCount() const; 
function Menu:GetMenuItemCount()
	return self.wxObj:GetMenuItemCount()
end

-- wxString GetTitle() const; 
function Menu:GetTitle()
	return self.wxObj:GetTitle()
end

-- void SetTitle(const wxString& title ); 
function Menu:SetTitle( Title )
	self.wxObj:SetTitle(Title)
end

-- void SetHelpString(int id, const wxString& helpString ); 
function Menu:SetItemHelp( ID, Title )
	self.wxObj:SetTitle(ID, Title)
end

-- bool IsEnabled(int id) const; 
function Menu:IsEnabled( ID )
	return self.wxObj:IsEnabled(ID)
end

-- bool IsChecked(int id) const; 
function Menu:IsChecked( ID )
	return self.wxObj:IsChecked(ID)
end

-- wxMenuItem* Insert(size_t pos, int id, const wxString& item, const wxString& helpString = "", wxItemKind kind = wxITEM_NORMAL ); 
-- wxMenuItem* Insert(size_t pos, %ungc wxMenuItem *item ); 
function Menu:InsertItem(Pos, ID, Text, Help, Shortcut)
	if Shortcut then
		Text = Text .."\t".. Shortcut
	end

	self.Items[ID] = self.wxObj:Insert(Pos, ID, Text, Help or "")
end

-- wxMenuItem* InsertCheckItem(size_t pos, int id, const wxString& item, const wxString& helpString = "" ); 
function Menu:InsertCheckItem(Pos, ID, Text, Help, Shortcut)
	if Shortcut then
		Text = Text .."\t".. Shortcut
	end
	
	self.Items[ID] = self.wxObj:InsertCheckItem(Pos, ID, Text, Help or "")
end

-- wxMenuItem* InsertRadioItem(size_t pos, int id, const wxString& item, const wxString& helpString = "" ); 
function Menu:InsertRadioItem(Pos, ID, Text, Help, Shortcut)
	if Shortcut then
		Text = Text .."\t".. Shortcut
	end
	
	--wxMenuItem* AppendRadioItem(int id, const wxString& item, const wxString& helpString = "" ); 
	self.Items[ID] = self.wxObj:InsertRadioItem(Pos, ID, Text, Help or "")
end

-- wxMenuItem* InsertSeparator(size_t pos ); 
function Menu:InsertSeparator(Pos)
 	self.wxObj:InsertSeparator(Pos)
end
]]

return Menu

-- // %override [wxMenuItem* menuItem, wxMenu* ownerMenu] wxMenu::FindItem(int id ); 
-- // C++ Func: wxMenuItem* FindItem(int id, wxMenu **menu = NULL) const; 
-- %override_name wxLua_wxMenu_FindItemById wxMenuItem* FindItem(int id) const; 

-- wxMenuItem* FindItemByPosition(size_t position) const; 
-- wxMenuItemList& GetMenuItems() const; 

-- wxMenuItem* Prepend(int id, const wxString& item, const wxString& helpString = "", wxItemKind kind = wxITEM_NORMAL ); 
-- wxMenuItem* Prepend(%ungc wxMenuItem *item ); 
-- wxMenuItem* PrependCheckItem(int id, const wxString& item, const wxString& helpString = "" ); 
-- wxMenuItem* PrependRadioItem(int id, const wxString& item, const wxString& helpString = "" ); 
-- wxMenuItem* PrependSeparator( ); 
-- %gc wxMenuItem* Remove(wxMenuItem *item ); 
-- %gc wxMenuItem* Remove(int id ); 
-- void UpdateUI(wxEvtHandler* source = NULL) const; 