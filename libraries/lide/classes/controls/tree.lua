-- /////////////////////////////////////////////////////////////////////////////
-- // Name:        controls/tree.lua
-- // Purpose:     Tree class
-- // Author:      Dario Cano [thdkano@gmail.com]
-- // Created:     07/20/2014
-- // Copyright:   (c) 2014 Dario Cano
-- // License:     lide license
-- /////////////////////////////////////////////////////////////////////////////

-- import libraries
local check = lide.core.base.check

TR_SINGLE 	 		 		= wx.wxTR_SINGLE
TR_NO_LINES  	 		 	= wx.wxTR_NO_LINES
TR_MULTIPLE  	 		 	= wx.wxTR_MULTIPLE
TR_EXTENDED  	 		 	= wx.wxTR_EXTENDED
TR_HIDE_ROOT  	 		 	= wx.wxTR_HIDE_ROOT
TR_ROW_LINES  	 		 	= wx.wxTR_ROW_LINES
TR_NO_BUTTONS 	 			= wx.wxTR_NO_BUTTONS
TR_HAS_BUTTONS   			= wx.wxTR_HAS_BUTTONS
TR_EDIT_LABELS   		 	= wx.wxTR_EDIT_LABELS
TR_TWIST_BUTTONS 		 	= wx.wxTR_TWIST_BUTTONS
TR_LINES_AT_ROOT 		 	= wx.wxTR_LINES_AT_ROOT
TR_DEFAULT_STYLE 		 	= wx.wxTR_DEFAULT_STYLE
TR_FULL_ROW_HIGHLIGHT 	    = wx.wxTR_FULL_ROW_HIGHLIGHT
TR_HAS_VARIABLE_ROW_HEIGHT  = wx.wxTR_HAS_VARIABLE_ROW_HEIGH

-- define class TreeItem:
local TreeItem = class "TreeItem"

function TreeItem:TreeItem( ItemText, ItemID, ItemType, ItemData, wxObj)
	self.ID    = ItemID   --> Identificator
	self.Text  = ItemText
	self.Data  = ItemData
	self.Type  = ItemType or "normal" --> string normal or root
	self.wxObj = wxObj
end

-- define class Tree:
--local Tree = Control : subclassof 'Tree'
local Tree = class 'Tree' : subclassof 'Control' : global (false)

function Tree:Tree( fields )
	-- check for fields required by constructor:
	check.fields { 
	 	'string Name', 'object Parent', --'string Text'
	}

	-- define class fields
	private {
		DefaultPosition = { X = -1, Y = -1 }, 
		DefaultSize     = { Width = -1, Height = -1 },
		DefaultFlags    = TR_DEFAULT_STYLE,
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
--	self.super:init( Properties, "Tree") --> call Control's constructor	
--	
--	-- Define specific control properties:
--	Properties.Flags = Properties.Flags or TR_DEFAULT_STYLE --> set platform specific default style
--	self.Images = Properties.Images

	-- add specific control events:
	-- self.Events.OnActivated  = wx.wxEVT_COMMAND_TREE_ITEM_ACTIVATED
	-- self.Events.OnDelete     = wx.wxEVT_COMMAND_TREE_DELETE_ITEM
	-- self.Events.OnCollapsed  = wx.wxEVT_COMMAND_TREE_ITEM_COLLAPSED
	
	-- self.Events.OnKey 		 = wx.wxEVT_COMMAND_TREE_KEY_DOWN -- realmente no tiene diferencia...
	-- self.Events.OnRightClick = wx.wxEVT_COMMAND_TREE_ITEM_RIGHT_CLICK
	-- self.Events.OnMenu 		 = wx.wxEVT_COMMAND_TREE_ITEM_MENU

	--
	
	-- Create current wxObj:
	self.wxObj = wx.wxTreeCtrl( self.Parent:getwxObj(), self.ID, wx.wxPoint( self.PosX, self.PosY ), wx.wxSize( self.Width, self.Height ), self.Flags, self.Validator, self.Name)
--	
--	self:InitWidgetEvents { 
--		-- MouseButtons:
--		"OnLeftUp"	 , "OnLeftDown"  , "OnLeftDoubleClick",
--		"OnRightUp"  , "OnRightDown" , "OnRightDoubleClick",
--		"OnMiddleUp" , "OnMiddleDown", "OnMiddleDoubleClick",
--
--		-- MouseActions:
--		"OnEnter"	, "OnLeave",
--		"OnSize" 	, "OnSizing",
--		"OnMotion",
--		
--		--> MouseWheel:	
--		"OnMouseWheel",
--	}
--
--	self:InitTreeEvents {
--		"OnItemActivated",
--		"OnItemDeleted",
--		"OnItemCollapsed",
--		"OnItemExpanded",
--		"OnItemRightClick",
--		"OnItemMenu",
--		"OnKeyDown",
--		"OnItemSelected",
--	} 		--> Initialize Tree events
--
	if (self.Images == true) then
		self.ImageList = wx.wxImageList(16,16)
		self.wxObj:SetImageList(self.ImageList)
	end

	-- Create Items table for internal porpuses:
	self.Items = { root = nil }
end
--[[

function Tree:InitTreeEvents( tEventNames )
	--* See Widget:InitWidgetEvents() for more info... 

	local tEvents = {
		OnItemActivated	= { 
			data = wx.wxEVT_COMMAND_TREE_ITEM_ACTIVATED,
			args = function ( event )
				local ItemID, ItemObject, ItemText
				local CurrentItem = event:GetItem()
				
				for item_id, item_object in pairs(self.Items) do
					if (CurrentItem:GetValue() == item_object.wxObj:GetValue()) then
						ItemID 	   = item_id
						ItemObject = item_object
						break
					end
				end
				ItemText = ItemObject.Text

				return ItemID, ItemText
			end
		},
		
		OnItemDeleted = { 
			data = wx.wxEVT_COMMAND_TREE_DELETE_ITEM,
			args = function ( event )
				local ItemID, ItemObject, ItemText
				local CurrentItem = event:GetItem()
				
				for item_id, item_object in pairs(self.Items) do
					if (CurrentItem:GetValue() == item_object.wxObj:GetValue()) then
						ItemID 	   = item_id
						ItemObject = item_object
						break
					end
				end
				ItemText = ItemObject.Text
				
				return ItemID, ItemText
			end
		},
		
		OnItemCollapsed = { 
			data = wx.wxEVT_COMMAND_TREE_ITEM_COLLAPSED,
			args = function ( event )
				local ItemID, ItemObject, ItemText
				local CurrentItem = event:GetItem()
				
				for item_id, item_object in pairs(self.Items) do
					if (CurrentItem:GetValue() == item_object.wxObj:GetValue()) then
						ItemID 	   = item_id
						ItemObject = item_object
						break
					end
				end
				ItemText = ItemObject.Text
				
				return ItemID, ItemText
			end
		},

		OnItemExpanded = { 
			data = wx.wxEVT_COMMAND_TREE_ITEM_EXPANDED,
			args = function ( event )
				local ItemID, ItemObject, ItemText
				local CurrentItem = event:GetItem()
				
				for item_id, item_object in pairs(self.Items) do
					if (CurrentItem:GetValue() == item_object.wxObj:GetValue()) then
						ItemID 	   = item_id
						ItemObject = item_object
						break
					end
				end
				ItemText = ItemObject.Text
				
				return ItemID, ItemText
			end
		},

		OnItemRightClick = { 
			data = wx.wxEVT_COMMAND_TREE_ITEM_RIGHT_CLICK,
			args = function ( event )
				local ItemID, ItemObject, ItemText
				local CurrentItem = event:GetItem()
				
				for item_id, item_object in pairs(self.Items) do
					if (CurrentItem:GetValue() == item_object.wxObj:GetValue()) then
						ItemID 	   = item_id
						ItemObject = item_object
						break
					end
				end
				ItemText = ItemObject.Text
			
				return ItemID, ItemText
			end
		},
		
		OnItemMenu = { 
			data = wx.wxEVT_COMMAND_TREE_ITEM_MENU,
			args = function ( event )
				local ItemID, ItemObject, ItemText
				local CurrentItem = event:GetItem()
				
				for item_id, item_object in pairs(self.Items) do
					if (CurrentItem:GetValue() == item_object.wxObj:GetValue()) then
						ItemID 	   = item_id
						ItemObject = item_object
						break
					end
				end
				ItemText = ItemObject.Text
			
				return ItemID, ItemText
			end
		},

		OnKeyDown = { 
			data = wx.wxEVT_COMMAND_TREE_KEY_DOWN,
			args = function ( event )
				local KeyCode = event:GetKeyCode()
				return KeyCode
			end
		},

		OnItemSelected = { 
			data = wx.wxEVT_COMMAND_TREE_SEL_CHANGED,
			args = function ( event )
				local ItemID, ItemObject, ItemText
				local CurrentItem = event:GetItem()
				
				for item_id, item_object in pairs(self.Items) do
					if (CurrentItem:GetValue() == item_object.wxObj:GetValue()) then
						ItemID 	   = item_id
						ItemObject = item_object
						break
					end
				end
				ItemText = ItemObject.Text

				return ItemID, ItemText
			end
		},
	}
	
	local exec, err_msg = pcall( lide.hand_event, self, tEvents, tEventNames)
	if (not exec) then lide.print_error(err_msg) end	
end]]

-- wxTreeItemId AddRoot(const wxString& text, int image = -1, int selImage = -1, %ungc wxLuaTreeItemData* data = NULL ); 
function Tree:addRoot( Text, Image )
 	-- if this is a tree with images:
 	nImage = -1

 	if self.Images then
		if Image then
			nImage = self.ImageList:Add(wx.wxBitmap(Image))
		end
		if selImage then
			nSelImage = self.ImageList:Add(wx.wxBitmap(selImage))
		end
	end

 	local wxItem = self.wxObj:AddRoot(Text, nImage)
 	local Item   = TreeItem:new(Text, "root", "root", ItemData or "nodata", wxItem)
 	
 	self.Items['root'] = Item
 	--return ItemID -- not implemented yet
end

-- wxTreeItemId AppendItem(const wxTreeItemId& parent, const wxString& text, int image = -1, int selImage = -1, %ungc wxLuaTreeItemData* data = NULL ); 
function Tree:addItem( Text, ItemID, ParentItem, Image, selImage )
	if not ParentItem then
		ParentItem = "root"
	end

	-- if this is a tree with images:
 	nImage    = -1
 	nSelImage = -1

 	if self.Images then
		if Image then
			nImage = self.ImageList:Add(wx.wxBitmap(Image))
		end
		if selImage then
			nSelImage = self.ImageList:Add(wx.wxBitmap(selImage))
		end
	end

 	local wxItem = self.wxObj:AppendItem(self.Items[ParentItem]['wxObj'], Text, nImage, nSelImage)
 	local Item   = TreeItem:new(Text, ItemID, "normal", ItemData or "nodata", wxItem, nImage, nSelImage)
	
	self.Items[ItemID] = Item
end

--wxTreeItemId InsertItem(const wxTreeItemId& parent, const wxTreeItemId& previous, const wxString& text, int image = -1, int selImage = -1, %ungc wxLuaTreeItemData* data = NULL ); 
--!wxTreeItemId InsertItem(const wxTreeItemId& parent, size_t before, const wxString& text, int image = -1, int selImage = -1, %ungc wxLuaTreeItemData* data = NULL ); 

function Tree:insertItem( Text, ItemID, ParentItem, PreviousItemID, Image, selImage )
	-- if this is a tree with images:
 	nImage    = -1
 	nSelImage = -1

 	if self.Images then
		if Image then
			nImage = self.ImageList:Add(wx.wxBitmap(Image))
		end
		if selImage then
			nSelImage = self.ImageList:Add(wx.wxBitmap(selImage))
		end
	end

	ParentItem     = self.Items[ParentItem]['wxObj']
	PreviousItemID = self.Items[PreviousItemID]['wxObj']
	
	local wxItem = self.wxObj:InsertItem(ParentItem, PreviousItemID, Text, nImage, nSelImage)
	local Item   = TreeItem:new(Text, ItemID, "normal", "nodata", wxItem)
		
	self.Items[ItemID] = Item
end

-- void EditLabel(const wxTreeItemId& item ); 
-- %win void EndEditLabel(const wxTreeItemId& item, bool discardChanges = false ); 
function Tree:editItemText( ItemID )
	self.wxObj:EditLabel (self.Items[ItemID]['wxObj'])
end


-- void Collapse(const wxTreeItemId& item ); 
function Tree:collapse( ItemID )
	self.wxObj:Collapse (self.Items[ItemID]['wxObj'])
end

-- void CollapseAll( ); 
function Tree:collapseAll()
	self.wxObj:CollapseAll ()
end

-- void CollapseAllChildren(const wxTreeItemId& item ); 
function Tree:collapseAllChildren( ItemID )
	self.wxObj:CollapseAllChildren(self.Items[ItemID]['wxObj'])
end

-- void CollapseAndReset(const wxTreeItemId& item ); 
function Tree:collapseAndReset( ItemID )
	self.wxObj:CollapseAndReset(self.Items[ItemID]['wxObj'])
end

-- void Delete(const wxTreeItemId& item ); 
function Tree:delete( ItemID )
	self.wxObj:Delete(self.Items[ItemID]['wxObj'])
end

-- void DeleteAllItems( ); 
function Tree:deleteAllItems()
	self.wxObj:Delete()
end

-- void DeleteChildren(const wxTreeItemId& item ); 
function Tree:deleteChildren( ItemID )
	self.wxObj:DeleteChildren(self.Items[ItemID]['wxObj'])
end

-- void Expand(const wxTreeItemId& item ); 
function Tree:expand( ItemID )
	self.wxObj:Expand(self.Items[ItemID]['wxObj'])
end

-- void ExpandAll( );  -- %dont-works
function Tree:expandAll()
	self.wxObj:ExpandAll()
end

-- void ExpandAllChildren(const wxTreeItemId& item ); 
function Tree:expandAllChildren( ItemID )
	self.wxObj:ExpandAllChildren(self.Items[ItemID]['wxObj'])
end

--void EnsureVisible(const wxTreeItemId& item ); 
function Tree:ensureVisible( ItemID )
	self.wxObj:EnsureVisible(self.Items[ItemID]['wxObj'])
end

--size_t GetChildrenCount(const wxTreeItemId& item, bool recursively = true) const; 
function Tree:getChildrenCount( ItemID, Recursively )
	if (Recursively == nil) then
		Recursively = true
	end

	return self.wxObj:GetChildrenCount(self.Items[ItemID]['wxObj'], Recursively)
end

--int GetCount() const; 
function Tree:getCount()
	return self.wxObj:GetCount()
end

--int GetIndent() const; 
function Tree:getIndent()
	return self.wxObj:GetIndent()
end

-- wxString GetItemText(const wxTreeItemId& item) const; 
function Tree:getItemText( ItemID )
	return self.wxObj:GetItemText(self.Items[ItemID]['wxObj'])
end

-- wxTreeItemId GetSelection() const; 
function Tree:getSelection()
	local CurrentSelection =  self.wxObj:GetSelection()
	for item_id, item_object in pairs(self.Items) do
		if (CurrentSelection:GetValue() == item_object.wxObj:GetValue()) then
			return item_id, item_object
		end
	end
end

-- bool IsBold(const wxTreeItemId& item) const; 
function Tree:isBold( ItemID )
	return self.wxObj:IsBold(self.Items[ItemID]['wxObj'])
end

-- bool IsExpanded(const wxTreeItemId& item) const; 
function Tree:isExpanded( ItemID )
	return self.wxObj:IsExpanded(self.Items[ItemID]['wxObj'])
end

-- bool IsSelected(const wxTreeItemId& item) const; 
function Tree:isSelected( ItemID )
	return self.wxObj:IsSelected(self.Items[ItemID]['wxObj'])
end

-- bool IsVisible(const wxTreeItemId& item) const; 
function Tree:isVisible( ItemID )
	return self.wxObj:IsVisible(self.Items[ItemID]['wxObj'])
end

-- bool ItemHasChildren(const wxTreeItemId& item) const; 
function Tree:itemHasChildren( ItemID )
	return self.wxObj:ItemHasChildren(self.Items[ItemID]['wxObj'])
end

--bool IsEmpty() const; 
function Tree:isEmpty()
	return self.wxObj:IsEmpty()
end

-- void ScrollTo(const wxTreeItemId& item ); 
function Tree:scrollTo( ItemID )
	self.wxObj:ScrollTo(self.Items[ItemID]['wxObj'])
end

--void SelectItem(const wxTreeItemId& item, bool select = true ); 
function Tree:selectItem( ItemID, Select )
	if (Select == nil) then
		Select = true
	end

	self.wxObj:SelectItem(self.Items[ItemID]['wxObj'], Select)
end

-- void SetIndent(int indent ); 
function Tree:setIndent( IndentValue )
	self.wxObj:SetIndent(IndentValue)
end

-- void SetItemBold(const wxTreeItemId& item, bool bold = true ); 
function Tree:setItemBold( ItemID, Bold )
	if (Bold == nil) then
		Bold = true
	end

	self.wxObj:SetItemBold(ItemID, Bold)
end

-- void SetItemDropHighlight(const wxTreeItemId& item, boolhighlight = true ); 
function Tree:setItemDropHighlight( ItemID, Highlight )
	if (Highlight == nil) then
		Highlight = true
	end

	self.wxObj:SetItemDropHighlight(self.Items[ItemID]['wxObj'], Highlight)
end

-- void SetItemText(const wxTreeItemId& item, const wxString& text ); 
function Tree:setItemText( ItemID, ItemText )
	self.wxObj:SetItemText(self.Items[ItemID]['wxObj'], ItemText)
end

-- void SortChildren(const wxTreeItemId& item ); 
function Tree:sortChildren( ItemID )
	self.wxObj:SortChildren(self.Items[ItemID]['wxObj'])
end

-- void Toggle(const wxTreeItemId& item ); 
function Tree:toggle( ItemID )
	self.wxObj:Toggle(self.Items[ItemID]['wxObj'])
end

-- void ToggleItemSelection(const wxTreeItemId& item ); 
function Tree:toggleItemSelection( ItemID )
	self.wxObj:ToggleItemSelection(self.Items[ItemID]['wxObj'])
end

-- void Unselect( ); 
function Tree:unselect( )
	self.wxObj:Unselect()
end

-- void UnselectAll( ); 
function Tree:unselectAll( )
	self.wxObj:UnselectAll()
end

-- void UnselectItem(const wxTreeItemId& item ); 
function Tree:unselectItem( ItemID )
	self.wxObj:UnselectItem(self.Items[ItemID]['wxObj'])
end

-- class %delete wxTreeEvent : public wxNotifyEvent 
-- {
-- %wxEventType wxEVT_COMMAND_TREE_BEGIN_DRAG // EVT_TREE_BEGIN_DRAG(id, fn ); 
-- %wxEventType wxEVT_COMMAND_TREE_BEGIN_LABEL_EDIT // EVT_TREE_BEGIN_LABEL_EDIT(id, fn ); 
-- %wxEventType wxEVT_COMMAND_TREE_BEGIN_RDRAG // EVT_TREE_BEGIN_RDRAG(id, fn ); 
-- %wxEventType wxEVT_COMMAND_TREE_END_DRAG // EVT_TREE_END_DRAG(id, fn ); 
-- %wxEventType wxEVT_COMMAND_TREE_END_LABEL_EDIT // EVT_TREE_END_LABEL_EDIT(id, fn ); 
-- %wxEventType wxEVT_COMMAND_TREE_GET_INFO // EVT_TREE_GET_INFO(id, fn ); 
-- %wxEventType wxEVT_COMMAND_TREE_ITEM_COLLAPSING // EVT_TREE_ITEM_COLLAPSING(id, fn ); 
-- %wxEventType wxEVT_COMMAND_TREE_ITEM_EXPANDING // EVT_TREE_ITEM_EXPANDING(id, fn ); 
-- %wxEventType wxEVT_COMMAND_TREE_ITEM_MIDDLE_CLICK // EVT_TREE_ITEM_MIDDLE_CLICK(id, fn ); 
-- %wxEventType wxEVT_COMMAND_TREE_SEL_CHANGING // EVT_TREE_SEL_CHANGING(id, fn ); 
-- %wxEventType wxEVT_COMMAND_TREE_SET_INFO // EVT_TREE_SET_INFO(id, fn ); 
-- %wxEventType wxEVT_COMMAND_TREE_ITEM_GETTOOLTIP // EVT_TREE_ITEM_GETTOOLTIP(id, fn ); 

-- wxTreeEvent(wxEventType commandType = wxEVT_NULL, int id = 0 ); 

-- int GetKeyCode() const; 
-- wxTreeItemId GetItem() const; 
-- wxKeyEvent GetKeyEvent() const; 
-- const wxString& GetLabel() const; 
-- wxTreeItemId GetOldItem() const; 
-- wxPoint GetPoint() const; 
-- bool IsEditCancelled() const; 
-- void SetToolTip(const wxString& tooltip ); 
-- }; 
-- enum wxTreeItemIcon 
-- {
-- wxTreeItemIcon_Normal, 
-- wxTreeItemIcon_Selected, 
-- wxTreeItemIcon_Expanded, 
-- wxTreeItemIcon_SelectedExpanded, 
-- wxTreeItemIcon_Max 
-- }; 

-- #define wxTREE_HITTEST_ABOVE 
-- #define wxTREE_HITTEST_BELOW 
-- #define wxTREE_HITTEST_NOWHERE 
-- #define wxTREE_HITTEST_ONITEMBUTTON 
-- #define wxTREE_HITTEST_ONITEMICON 
-- #define wxTREE_HITTEST_ONITEMINDENT 
-- #define wxTREE_HITTEST_ONITEMLABEL 
-- #define wxTREE_HITTEST_ONITEMRIGHT 
-- #define wxTREE_HITTEST_ONITEMSTATEICON 
-- #define wxTREE_HITTEST_TOLEFT 
-- #define wxTREE_HITTEST_TORIGHT 
-- #define wxTREE_HITTEST_ONITEMUPPERPART 
-- #define wxTREE_HITTEST_ONITEMLOWERPART 
-- #define wxTREE_HITTEST_ONITEM 

-- %wxchkver_2_9 #define wxTREE_ITEMSTATE_NONE // not state (no display state image) 
-- %wxchkver_2_9 #define wxTREE_ITEMSTATE_NEXT // cycle to the next state 
-- %wxchkver_2_9 #define wxTREE_ITEMSTATE_PREV // cycle to the previous state 

-- // %override [wxTreeItemId, wxTreeItemIdValue cookie] wxTreeCtrl::GetFirstChild(const wxTreeItemId& item ); 
-- // C++ Func: wxTreeItemId GetFirstChild(const wxTreeItemId& item, wxTreeItemIdValue& cookie) const; 
-- wxTreeItemId GetFirstChild(const wxTreeItemId& item) const; 
-- //void AssignButtonsImageList(wxImageList* imageList ); 
-- void AssignImageList(%ungc wxImageList* imageList ); 
-- void AssignStateImageList(%ungc wxImageList* imageList ); 
-- bool GetBoundingRect(const wxTreeItemId& item, wxRect& rect, bool textOnly = false) const; 
-- //wxImageList* GetButtonsImageList() const; 
-- //wxTextCtrl* GetEditControl() const; // MSW only 
-- wxTreeItemId GetFirstVisibleItem() const; 
-- wxImageList* GetImageList() const; 
-- wxColour GetItemBackgroundColour(const wxTreeItemId& item) const; 
-- wxLuaTreeItemData* GetItemData(const wxTreeItemId& item) const; 
-- wxFont GetItemFont(const wxTreeItemId& item) const; 
-- int GetItemImage(const wxTreeItemId& item, wxTreeItemIcon which = wxTreeItemIcon_Normal) const; 
-- wxColour GetItemTextColour(const wxTreeItemId& item) const; 
-- wxTreeItemId GetLastChild(const wxTreeItemId& item) const; 
-- // %override [wxTreeItemId, wxTreeItemIdValue cookie] wxTreeCtrl::GetNextChild(const wxTreeItemId& item, long cookie ); 
-- // C++ Func: wxTreeItemId GetNextChild(const wxTreeItemId& item, wxTreeItemIdValue& cookie) const; 
-- wxTreeItemId GetNextChild(const wxTreeItemId& item, wxTreeItemIdValue& cookie) const; 
-- wxTreeItemId GetNextSibling(const wxTreeItemId& item) const; 
-- wxTreeItemId GetNextVisible(const wxTreeItemId& item) const; 
-- %wxchkver_2_4 wxTreeItemId GetItemParent(const wxTreeItemId& item) const; 
-- wxTreeItemId GetPrevSibling(const wxTreeItemId& item) const; 
-- wxTreeItemId GetPrevVisible(const wxTreeItemId& item) const; 
-- wxTreeItemId GetRootItem() const; 

-- bool GetQuickBestSize() const; 
-- //!%wxchkver_2_6|%wxcompat_2_4 int GetItemSelectedImage(const wxTreeItemId& item) const; // obsolete function 

-- // %override [size_t, Lua table of wxTreeItemIds] wxTreeCtrl::GetSelections( ); 
-- // C++ Func: size_t GetSelections(wxArrayTreeItemIds& selection) const; 
-- size_t GetSelections() const; 

-- wxImageList* GetStateImageList() const; 

-- // %override [wxTreeItemId, int flags] wxTreeCtrl::HitTest(const wxPoint& point ); 
-- // C++ Func: wxTreeItemId HitTest(const wxPoint& point, int& flags ); 
-- wxTreeItemId HitTest(const wxPoint& point ); 

-- //int OnCompareItems(const wxTreeItemId& item1, const wxTreeItemId& item2 ); 
-- wxTreeItemId PrependItem(const wxTreeItemId& parent, const wxString& text, int image = -1, int selImage = -1, %ungc wxLuaTreeItemData* data = NULL ); 

-- //void SetButtonsImageList(wxImageList* imageList ); 

-- void SetImageList(wxImageList* imageList ); 
-- void SetItemBackgroundColour(const wxTreeItemId& item, const wxColour& col ); 

-- void SetItemData(const wxTreeItemId& item, %ungc wxLuaTreeItemData* data ); 
-- void SetItemFont(const wxTreeItemId& item, const wxFont& font ); 
-- void SetItemHasChildren(const wxTreeItemId& item, bool hasChildren = true ); 
-- void SetItemImage(const wxTreeItemId& item, int image, wxTreeItemIcon which = wxTreeItemIcon_Normal ); 
-- %wxchkver_2_9 void SetItemState(const wxTreeItemId& item, int state); 

-- void SetItemTextColour(const wxTreeItemId& item, const wxColour& col ); 
-- void SetQuickBestSize(bool quickBestSize ); 
-- void SetStateImageList(wxImageList* imageList ); 
-- // void SetWindowStyle(long styles) - see wxWindow 

return Tree