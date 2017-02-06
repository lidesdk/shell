-- /////////////////////////////////////////////////////////////////////////////
-- // Name:        classes/controls/htmlview.lua
-- // Purpose:     HTMLView class
-- // Author:      Dario Cano [thdkano@gmail.com]
-- // Created:     2014/07/20
-- // Copyright:   (c) 2014 Dario Cano
-- // License:     lide license
-- /////////////////////////////////////////////////////////////////////////////
--
--
--
local HTMLView, Control
local check, isObject

-- set htmlview constants:
enum {
	HV_SCROLLBAR_NEVER  = wx.wxHW_SCROLLBAR_NEVER, -->>> Never display scrollbars, not even when the page is larger than the window. 
	HV_SCROLLBAR_AUTO   = wx.wxHW_SCROLLBAR_AUTO ,-- >>> Display scrollbars only if page's size exceeds window's size. 
	HV_SCROLLBAR_ALL    = ( -1 ),			      -- >>> DISPLAY ALL SCROLLBARS
}

-- import libraries
check = lide.core.base.check

-- import local functions:
isObject = lide.core.base.isobject
isNumber = lide.core.base.isnumber

-- import required classes
Control = lide.classes.widgets.control


-- define class:
HTMLView = class 'HTMLView' : subclassof "Control"
	: global(false)

function HTMLView:HTMLView( fields )
		-- check for fields required by constructor:
	check.fields { 
	 	'string Name', 'object Parent',
	}
	
	-- define class fields
	private {
		DefaultPosition = { X = -1, Y = -1 }, 
		DefaultSize     = { Width = -1, Height = -1 },
		
		DefaultFlags    = HV_SCROLLBAR_ALL,
		Flags 		    = fields.Flags and isNumber(fields.Flags)
	}
	

	protected {
		Text  = fields.Text,
	}
	
	-- call Control constructor
	self.super : init ( fields.Name, fields.Parent, fields.PosX or self.DefaultPosition.X, fields.PosY or self.DefaultPosition.Y, fields.Width or self.DefaultSize.Width, fields.Height or self.DefaultSize.Height, fields.ID )
	
	--print('htmlview1' .. fields.Flags)	

	-- create wxWidgets object and store it on self.wxObj:
	self.wxObj = wx.wxLuaHtmlWindow( self.Parent:getwxObj(), self.ID, wx.wxPoint( self.PosX, self.PosY ), wx.wxSize( self.Width, self.Height ), self.Flags or self.DefaultFlags, self.Name)


	-- Load HTML document:
	if fields.Page then		
		self.wxObj:LoadPage( fields.Page )
	elseif fields.Filename then
		self.File = fields.Filename
		self.wxObj:LoadFile(wx.wxFileName(fields.Filename))
	elseif fields.Code then
		self.Code = fields.Code
		self.wxObj:SetPage(fields.Code)
	end
	
--[[	self:InitWidgetEvents { 
		-- MouseButtons:
		"OnLeftUp"	 , "OnLeftDown"  , "OnLeftDoubleClick",
		"OnRightUp"  , "OnRightDown" , "OnRightDoubleClick",
		"OnMiddleUp" , "OnMiddleDown", "OnMiddleDoubleClick",

		-- MouseActions:
		"OnEnter"	, "OnLeave",
		"OnSize" 	, "OnSizing",
		"OnMotion",
		
		--> MouseWheel:	
		"OnMouseWheel",
	}

	self:InitHtmlViewEvents {
		"OnSetTitle"
	}   
		]]--
end
--[[
function HtmlView:InitHtmlViewEvents( tEventNames )
		
	-- El método de conectarse a los eventos de la clase wxLuaHtmlWindow es diferente...	

	self.wxObj.lideself = self --> Primera vez que se utiliza este método.
	
	self.wxObj.OnSetTitle = function ( self, title )
		this = Event:new (nil, "OnSetTitle")
		local exec, err_msg = pcall( self.lideself["OnSetTitle"], self.lideself, title)
		if (not exec) then lide.eventhandler_error(self.lideself, this, err_msg) end
		this = nil
	end
	
	self.wxObj.OnLinkClicked = function ( self, wxHtmlLinkInfo )
		local HREF   = wxHtmlLinkInfo:GetHref()
		local TARGET = wxHtmlLinkInfo:GetTarget()
		
		this = Event:new(nil, "OnLinkClicked")
		local exec, err_msg = pcall( self.lideself["OnLinkClicked"], self.lideself, HREF, TARGET)
		if (not exec) then lide.eventhandler_error(self.lideself, this, err_msg) end
		this = nil
	end
end

function HtmlView:AddEvent( EventName, EventHandler)
	
	if EventName ==	"OnSetTitle" then
		 function self.wxObj:OnSetTitle ( Title )
		 	EventHandler(Title)
		 end
	elseif EventName ==	"OnLinkClicked" then
		 function self.wxObj:OnLinkClicked ( wxHtmlLinkInfo )
		 	local HREF   = wxHtmlLinkInfo:GetHref()
		 	local TARGET = wxHtmlLinkInfo:GetTarget()
		 	EventHandler( HREF, TARGET )
		 end
	else
		-- normal events...
	end
end]]


-- wxString ToText( ); 
function HTMLView:toText()
	return self.wxObj:ToText()
end

-- void SelectAll( ); 
function HTMLView:selectAll()
	self.wxObj:SelectAll()
end

-- wxString SelectionToText( ); 
function HTMLView:selectionToText()
	return self.wxObj:SelectionToText()
end

-- bool LoadPage(const wxString& location ); 
function HTMLView:loadPage( Website )
	return self.wxObj:LoadPage(Website)
end

-- virtual bool LoadFile(const wxFileName& filename ); 
function HTMLView:loadFile( File )
	self.File = File -- save for internal purposes
	return self.wxObj:LoadPage(File)
end

-- bool SetPage(const wxString& source ); 
function HTMLView:loadCode( HTMLCode )
	self.Code = HTMLCode -- save for internal purposes
	return self.wxObj:SetPage(HTMLCode)
end

-- wxString GetOpenedPageTitle( ); 
function HTMLView:getTitle()
	return self.wxObj:GetOpenedPageTitle()
end

-- wxString GetOpenedPage( ); 
function HTMLView:getPage()
	return self.wxObj:GetOpenedPage()
end

function HTMLView:getFile()
	return self.File
end

function HTMLView:getCode()
	return self.Code
end

return HTMLView

--> Eventos:

-- //bool OnCellClicked(wxHtmlCell *cell, wxCoord x, wxCoord y, const wxMouseEvent& event ); 
-- //void OnCellMouseHover(wxHtmlCell *cell, wxCoord x, wxCoord y ); 

--< Eventos

-- class wxHtmlWindow : public wxScrolledWindow 
-- {
-- wxHtmlWindow(wxWindow *parent, wxWindowID id = -1, const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxDefaultSize, long style = wxHW_SCROLLBAR_AUTO, const wxString& name = "wxHtmlWindow" ); 

-- //static void AddFilter(wxHtmlFilter *filter ); 
-- bool AppendToPage(const wxString& source ); 
-- wxHtmlContainerCell* GetInternalRepresentation() const; 
-- wxString GetOpenedAnchor( ); 
-- wxFrame* GetRelatedFrame() const; 
-- bool HistoryBack( ); 
-- bool HistoryCanBack( ); 
-- bool HistoryCanForward( ); 
-- void HistoryClear( ); 
-- bool HistoryForward( ); 
-- void ReadCustomization(wxConfigBase *cfg, wxString path = wxEmptyString ); 

-- void SelectLine(const wxPoint& pos ); 
-- void SelectWord(const wxPoint& pos ); 
-- void SetBorders(int b ); 

-- // %override void wxHtmlWindow::SetFonts(wxString normal_face, wxString fixed_face, Lua int table ); 
-- // C++ Func: void SetFonts(wxString normal_face, wxString fixed_face, const int *sizes ); 
-- void SetFonts(wxString normal_face, wxString fixed_face, LuaTable intTable ); 

-- void SetRelatedFrame(wxFrame* frame, const wxString& format ); 
-- void SetRelatedStatusBar(int bar ); 
-- void WriteCustomization(wxConfigBase *cfg, wxString path = wxEmptyString ); 
-- }; 