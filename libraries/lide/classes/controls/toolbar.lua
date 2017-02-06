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
--  object Toolbar:new { 
--  	string Name  ,		The panel name.
--		object Parent,		The panel parent.
--	}
--
--

-- %TODO: Toolbar:AddControl
enum {
	-- set toolbar constants:
	TB_FLAT  	   = wx.wxTB_FLAT,
	-- TB_DOCKABLE    = wx.wxTB_DOCKABLE  -- not implemented yet
	TB_HORIZONTAL  = wx.wxTB_HORIZONTAL,
	TB_VERTICAL    = wx.wxTB_VERTICAL,
	-- TB_3DBUTTONS   = wx.wxTB_3DBUTTONS   -- not implemented yet
	TB_TEXT  	   = wx.wxTB_TEXT,
	TB_NOICONS     = wx.wxTB_NOICONS,
	TB_NODIVIDER   = wx.wxTB_NODIVIDER,
	TB_NOALIGN     = wx.wxTB_NOALIGN,
	TB_HORZ_LAYOUT = wx.wxTB_HORZ_LAYOUT,
	TB_HORZ_TEXT   = wx.wxTB_HORZ_TEXT,
}

-- import local functions:
local isNumber = lide.core.base.isnumber
local isString = lide.core.base.isstring
local isObject = lide.core.base.isobject

-- import libraries
local check = lide.core.base.check

-- import required classes
local Control = lide.classes.widgets.control
local Item    = lide.classes.item
local Store   = lide.classes.store

-- define class constructor
local Toolbar = class 'Toolbar' : subclassof 'Control' : global (false)

function Toolbar:Toolbar ( fields )
	-- check for fields required by constructor:
	check.fields { 
	 	'string Name', 'object Parent',
	}

	-- define class fields
	private {
		DefaultPosition = { X = -1, Y = -1 }, 
		DefaultSize     = { Width = -1, Height = -1 },
		DefaultFlags    = wx.wxTB_HORIZONTAL,			
	}
	
	protected {
		Flags = fields.Flags or self.DefaultFlags
	}

	self.Store 			= Store:new ()
	-- call Control constructor
	self.super : init ( fields.Name, fields.Parent, fields.PosX or self.DefaultPosition.X, fields.PosY or self.DefaultPosition.Y, fields.Width or self.DefaultSize.Width, fields.Height or self.DefaultSize.Height, fields.ID )

	self.wxObj = self.Parent:getParent():getwxObj():CreateToolBar(self.Flags, self.ID, self.Name)
	
	---------------------------------------------------------------------------------------------
	-- [deprecated]
	-- NO SE MUESTRA EL TOOLBAR CUANDO LO CREAMOS CON ESTE CONSTRUCTOR DESDE UBUNTU 14.04 WXWIDGETS 2.8 WXLUA 2.8 LUA 5.1
	--
	-- create wxWidgets object and store it on self:getwxObj():
	-- wxToolBar(wxWindow *parent, wxWindowID id, const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxDefaultSize, long style = wxNO_BORDER | wxTB_HORIZONTAL, const wxString &name = "wxToolBar" ); 
	--self:getwxObj() = wx.wxToolBar( self.Parent:getParent():getwxObj(), self.ID, 
	--	wx.wxPoint( self.PosX, self.PosY ), 
	--	wx.wxSize( self.Width, self.Height ), 
	--	self.Flags or self.DefaultFlags, 
	--	self.Name
	--)
	---------------------------------------------------------------------------------------------

	-- registry toolbar specific events
	
	getmetatable(self) .__events['onToolClick'] = {
		data = wx.wxEVT_COMMAND_TOOL_CLICKED,
		args = function ( event )
			local ID 		= event:GetId()
			local IsChecked = event:IsChecked()

			return	ID, IsChecked
		end
	}
	
	---getmetatable(self) .__events['onToolEnter'] = {
	---	data = wx.wxEVT_COMMAND_TOOL_ENTER,
	---	args = lide.core.base.voidf
	---}
	
	---getmetatable(self) .__events['onToolRightClick'] = {
	---	data = wx.wxEVT_COMMAND_TOOL_RCLICKED,
	---	args = lide.core.base.voidf
	---}

	self:initializeEvents {
		'onToolClick',
	}

end

-- add a separator at the end to the toolbar.
function Toolbar:addSeparator()
	self:getwxObj():AddSeparator()
	self:getwxObj():Realize()
end

-- add item to the toolbar, store this on self.Store and returns the index
function Toolbar:addTool( nID, sText, sImage, sTooltip )
	isNumber(nID) isString(sText)

	-- set default tool img if not specified:
	if not sImage or ( sImage == '' ) then
		local default_tool_img = 'imgs/box.png'
		sImage = default_tool_img
	else
		isString(sImage)
	end

	sImage = sImage : gsub ( '\\', '/' )

	if not lide.core.file.doesExists( sImage ) then
		lide.core.error.lperr(('The file "%s" does not exists.'):format( sImage ))
	end

	local enabled_bmp  = wx.wxBitmap(wx.wxBitmap(sImage ):ConvertToImage())
	local disabled_bmp = wx.wxBitmap( enabled_bmp:ConvertToImage():ConvertToGreyscale())

	local objItem = Item:new {
		ID = nID, Text = sText, ImageFilename = sImage, Tooltip = sTooltip,
		wxObj = self:getwxObj():AddTool(nID, sText, enabled_bmp )
	}
	
	-- wxToolBarToolBase* AddTool(int toolId, const wxString& label, const wxBitmap& bitmap1, const wxBitmap& bitmap2 = wxNullBitmap, wxItemKind kind = wxITEM_NORMAL, const wxString& shortHelpString = "", const wxString& longHelpString = "", wxObject* clientData = NULL ); 
	local wxObj = objItem:get 'wxObj'
	
	-- Fue necesario llamarlo despues del constructor para mejorar la compatibilidad entre OS diferentes:
	if lide.platform.getOSName == 'Windows' then
		--- Estas dos sentencias son necesaria para que en Windows XP 32 se ejecute correctamente, 
		--- de lo contrario no se mostrara el bitmap de deshabilitado:
		-- Reconvertirlo a grayscale:
		disabled_bmp = disabled_bmp:ConvertToImage():ConvertToGreyscale()
		wxObj:SetDisabledBitmap( disabled_bmp )

	elseif lide.platform.getOSName == 'Linux' then
		--- Para Linux no es necesario reconvertirlo:
		wxObj:SetDisabledBitmap( disabled_bmp )
		
	end
	
	if objItem:get 'Tooltip' then
	    wxObj:SetShortHelp(objItem:get 'Tooltip')
	end 

	-- Refresh changes on the wxToolbar
	self:getwxObj():Realize() 

	-- Store the wxObject referenced to this item tool
	--objItem:add ('wxObj', wxObj )

	return self.Store:add ( objItem ) --> return the index in the internal Store
end

function Toolbar:addControl( objControl )
	isObject(objControl)
	objControl:getwxObj():Reparent(self:getwxObj())
	self:getwxObj():AddControl ( objControl:getwxObj() )
	self:getwxObj():Realize ()
	self:getwxObj():Update ()
	self:getwxObj():Refresh()
end

-- bool GetToolEnabled(int toolId) const; 
function Toolbar:getToolEnabled( nToolID )
	return self:getwxObj():GetToolEnabled(nToolID)
end

-- void EnableTool(int toolId, const bool enable );
function Toolbar:setToolEnabled( nToolID, bEnable )
	self:getwxObj():EnableTool(nToolID, bEnable)
end

-- void SetToolBitmapSize(const wxSize& size ); 
function Toolbar:setImageSizes(nWidth, nHeight )
	isNumber(nWidth) isNumber(nHeight)
	self:getwxObj():SetToolBitmapSize(wx.wxSize(nWidth, nHeight))
end

-- void SetRows(int nRows ); 
function Toolbar:setRows( nRows )
	self.wxObj:SetRows(nRows)
	--self.wxObj:Realize()
end

-- int GetMaxRows( ); 
function Toolbar:getMaxRows()
	return self.wxObj:GetMaxRows()
end

-- int GetMaxCols( ); 
function Toolbar:getMaxCols()
	return self.wxObj:GetMaxCols()
end


-- wxBitmap GetNormalBitmap( ); 
-- wxBitmap GetBitmap( ); 
-- wxBitmap GetDisabledBitmap( ); 
function Toolbar:getToolImageFilename( nID )
	local objItem = self.Store:get { ID = nID }
	return objItem:get 'ImageFilename'
end

-- void SetNormalBitmap(const wxBitmap& bmp ); 
--function Toolbar:setToolImageFilename( nID, sImageFilename )
	---local objItem = self.Store:get { ID = nID }
--	objItem:get 'wxObj' : SetNormalBitmap(wx.wxBitmap(sImageFilename))
	---objItem:set ('ImageFilename', sImageFilename )
	---print(objItem:get 'wxObj')
	--self.wxObj:SetToolNormalBitmap(nID, wx.wxBitmap(sImageFilename))
--	self.wxObj:Realize()
--end


--[[


-- wxString GetLabel( ); 
function ToolBar:GetToolText( id )
	local objItem = self.Items[id]

	return objItem.wxObj:GetLabel()
end
]]

-- void SetLabel(const wxString& label ); 
function Toolbar:setToolText( nID, text )
	local objItem = self.Store:get { ID = nID }
	
	objItem:get 'wxObj' : SetLabel( text )
	
	--objItem:get 'wxObj' : Realize()
	--objItem:set ( 'Text', text )
	--print('wxObj')
	self:getwxObj():Realize()
end

return Toolbar