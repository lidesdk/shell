-- /////////////////////////////////////////////////////////////////////////////////////////////////
-- // Name:        classes/widgets/window.lua
-- // Purpose:     class Window definition
-- // Author:      Dario Cano [thdkano@gmail.com]
-- // Created:     2014/07/07
-- // Copyright:   (c) 2014 Dario Cano
-- // License:     lide license
-- /////////////////////////////////////////////////////////////////////////////////////////////////

-- import functions:
local isString  = lide.core.base.isstring
local isNumber  = lide.core.base.isnumber
local isObject  = lide.core.base.isobject
local isBoolean = lide.core.base.isboolean


-- import libraries
local check 	= lide.core.base.check

-- import required classes:
local Event  = lide.classes.event
local Widget = lide.classes.widget

local Panel  = lide.classes.widgets.panel


-- define the class:
local Window = class 'Window' : subclassof 'Widget' 
	: global(false)

-- define class constants:
enum { -- wxFrame
	WIN_DEFAULT_STYLE  	= wx.wxDEFAULT_FRAME_STYLE,
	WIN_ICONIZE  		= wx.wxICONIZE, 		-- %win-only
	WIN_CAPTION  		= wx.wxCAPTION, 
	WIN_MINIMIZE  		= wx.wxMINIMIZE,		-- %win-only
	WIN_MINIMIZE_BOX  	= wx.wxMINIMIZE_BOX,
	WIN_MAXIMIZE 		= wx.wxMAXIMIZE,		-- %win-gtk
	WIN_MAXIMIZE_BOX  	= wx.wxMAXIMIZE_BOX,
	WIN_CLOSE_BOX  	    = wx.wxCLOSE_BOX,
	WIN_STAY_ON_TOP  	= wx.wxSTAY_ON_TOP,
	WIN_SYSTEM_MENU  	= wx.wxSYSTEM_MENU,
	WIN_RESIZE_BORDER   = wx.wxRESIZE_BORDER,

	WIN_TOOL_WINDOW     = wx.wxFRAME_TOOL_WINDOW,
	WIN_NO_TASKBAR 	    = wx.wxFRAME_NO_TASKBAR,
	WIN_FLOAT_ON_PARENT = wx.wxFRAME_FLOAT_ON_PARENT,
	WIN_EX_CONTEXTHELP  = wx.wxFRAME_EX_CONTEXTHELP,
	WIN_SHAPED 		    = wx.wxFRAME_SHAPED,
	WIN_EX_METAL		= wx.wxFRAME_EX_METAL,

	-- //#define wxSIMPLE_BORDER see wxWindow defines 
	-- //#define wxTHICK_FRAME %wxcompat_2_6 use %wxchkver_2_6 
}

function Window:Window ( fields )
	
	-- check for fields required by constructor:
	check.fields { 
	 	'string Name', 'string Title'
	}

	-- define class fields
	private {
		DefaultPosition = { X = -1, Y = -1 }, 
		DefaultSize     = { Width = -1, Height = -1 },
	}

	protected {
		Title = fields.Title, 
		Flags = fields.Flags or wx.wxDEFAULT_FRAME_STYLE
	}

	-- call Widget constructor
	self.super:init( fields.Name, 'window', fields.PosX or self.DefaultPosition.X, fields.PosY or self.DefaultPosition.Y, fields.Width or self.DefaultSize.Width, fields.Height or self.DefaultSize.Height, fields.ID, fields.Parent or self )

	-- create wxWidgets object and save it on self.wxObj:
	self.wxObj = wx.wxFrame(wx.NULL, self.ID, self.Title, wx.wxPoint( self.PosX, self.PosY ), wx.wxSize( self.Width, self.Height ), self.Flags)
	
	-- declare self events into "__events" metatable:

	getmetatable(self) .__events['onClose'] = {
		data = wx.wxEVT_CLOSE_WINDOW,
		args = function ( event )			
			--- Si el metodo está sobreescrito:
			if ( self.onClose:getHandler() ~= lide.core.base.voidf ) then
				-- do anything
			--elseif lide.platform.getOSName() == 'Linux' and wx.wxGetApp() : GetTopWindow () : GetHandle() == self:getwxObj() : GetHandle() then
			--	--- Si es una ventana de primer nivel cerrar elmainloop
			--	wx.wxGetApp():ExitMainLoop()
			else
				--- en cualquier otro caso cerrar la ventana y destruirla
				event:Skip()
			end
		end
	}

	getmetatable(self) .__events['onShow'] = {
		data = wx.wxEVT_SHOW,
		args = function ( event )
		
	    -- HCM<1/3> - V-23-Mar-2016: el sgte código se comentariza, pues no puede ejecutarse el MainLoop
		--                      en Windows antes de "mostrar" la ventana
		
		--[[if not wx.wxGetApp() : IsMainLoopRunning () then
				-- No se pueden crear dos ventanas al mismo tiempo a menos que MainLoop lo pongamos en el
				-- interprete, pero si hacemos esto la app no podra se der consola puesto que siempre va a tener
				-- que esperar a que se cierre el mainloop para poder print()
				wx.wxGetApp() : SetTopWindow( self:getwxObj() )
				local x, e = pcall( wx.wxGetApp() . MainLoop, wx.wxGetApp())
				if not x then
					lide.core.error.lperr(e)
				end
			end]]
			
			return event:GetShow()
		end
	}
	

	getmetatable(self) .__events['onHide'] = {
		data = wx.wxEVT_SHOW,
		args = function ( event )
			return event:GetShow()
		end
	}

	-- connect to widnwo menubar
	getmetatable(self) .__events['onMenuSelected'] = {
		data = wx.wxEVT_COMMAND_MENU_SELECTED,
		args = function ( event )
			local MenuID, IsChecked, ItemText
			
			MenuID    = event:GetId()
			IsChecked = event:IsChecked()

			return MenuID, IsChecked
		end
	}

	getmetatable(self) .__events['onIconize'] = {
		data = wx.wxEVT_ICONIZE,
		args = function ( event )
			return event:Iconized()
		end
	}

	-- initialize all events:
	self:initializeEvents {
		-- inherited events:
		'onEnter', 'onLeave', 'onLeftDown', 'onLeftUp',

		-- self events:
		'onShow',  'onClose', 'onHide',
		'onMenuSelected',

		'onIconize'
	}
end

-- virtual bool Show(bool show = true ); 

Window : virtual 'show' 

function Window:show( bShow )
	if bShow == nil then bShow = true end
	
	if not self.wxObj then

		--- Agrego el 2 al nivel de muestreo de la función para que al ejecutarse lo haga a partir de aquí.
	    lide.core.error.lperr('The C++ object was deleted, lide crashes :(' , 2)
	    os.exit()
	end
	
	------------------------------------------------------------------------------------------------
	---
	--- Corregido por Hernán Cano Martinez: jhernancano [at] gmail [dot] com 			  23/03/2016
	--  1. Se recoge el valor que devuelve el objeto C++
	--  2. Luego ejecutamos el MainLoop de la aplicación.
	-- ( Esto evita errores de visualizacion de la clase wxFrame en Windows 7 x86, ya que en dicha 
	-- plataforma no es posible ejecutar el MainLoop antes de que se ejecute el formulario.
	-- 
	
	local result = self.wxObj:Show( isBoolean(bShow) )
	if wx then wx.wxGetApp():MainLoop() end

	return result
end

----------------------------------------------------------------------------------------------------
--- Sizing and positioning functions:
--

Window : virtual 'getMaxSize'
Window : virtual 'getMinSize'
Window : virtual 'setMaxSize'
Window : virtual 'setMinSize'

-- wxSize GetMinSize() const; 
function Window:getMinSize( ... )
	local wxsize = self.wxObj:GetMinSize()
	return 	wxsize.Width, wxsize.Height
end

-- wxSize GetMaxSize() const; 
function Window:getMaxSize( ... )
	local wxsize = self.wxObj:GetMaxSize()
	return 	wxsize.Width, wxsize.Height
end

-- void SetMaxSize(const wxSize& size ); 
function Window:setMaxSize( width, height )
	isNumber(width); isNumber(height)

	self.wxObj:SetMaxSize(wx.wxSize(width, height))
end

-- void SetMinSize(const wxSize& size ); 
function Window:setMinSize( width, height )
	isNumber(width); isNumber(height)

	self.wxObj:SetMinSize(wx.wxSize(width, height))
end


Window : virtual 'centre'

-- void Centre(int direction = wxBOTH ); 
-- void CentreOnParent(int direction = wxBOTH ); 
-- // void Centre(int direction = wxBOTH) - see wxWindow 
function Window:centre()
	self.wxObj:Centre()
end

Window : virtual 'iconize'
Window : virtual 'isIconized'
Window : virtual 'maximize'
Window : virtual 'isMaximized'

-- void Iconize(bool iconize ); 
function Window:iconize( bIconize )
	if (bIconize == nil) then bIconize = true end isBoolean(bIconize)
	self.wxObj:iconize( bIconize )
end

-- void Maximize(bool maximize ); 
function Window:maximize( bMaximize )
	if (bMaximize == nil) then bMaximize = true end isBoolean(bMaximize)
	self.wxObj:Maximize( bMaximize )
end

-- bool IsIconized() const; 
function Window:isIconized( ... )
	return self.wxObj:IsIconized()
end

-- bool IsMaximized() const; 
function Window:isMaximized( ... )
	return self.wxObj:IsMaximized()
end


----------------------------------------------------------------------------------------------------
--- Style and appearance functions:
--

Window : virtual 'getTitle'
Window : virtual 'setTitle'

-- wxString GetTitle() const; 
function Window:getTitle()
	return self.wxObj:GetTitle()
end

-- virtual void SetTitle(const wxString& title ); 
function Window:setTitle( sTitle )
	self.wxObj:SetTitle( sTitle )
end

--- Establece la barra de menus, el unico argumento que recibe es una tabla que debe contener los menus que se
--- van a agregar a la barra === ex: window:setMenubar { menuFile, menuEdit, menuView }
--- Tells the window to show the given menu objects at menu bar.
--- 
--- If the frame is destroyed, the menu bar and its menus will be destroyed also, so do not delete the 
--- menu bar explicitly (except by resetting the frame's menu bar to another frame or NULL).
--- 
--- Under Windows, a size event is generated, so be sure to initialize data members properly before 
--- calling SetMenuBar.
--- 
--- Note that on some platforms, it is not possible to call this function twice for the same frame 
--- object.
-- void SetMenuBar(wxMenuBar* menuBar ); 
function Window:setMenuBar( tMenus )
	local BarraMenu = wx.wxMenuBar() 
	
	for _, Menu in pairs(tMenus) do
		BarraMenu:Append(Menu:getwxObj(), Menu:getText())
	end
	
	self.wxObj:SetMenuBar( BarraMenu )
end

function Window:setFocusedObject( oFocusObject )
	self.FocusedObject = isObject(oFocusObject)
	oFocusObject:getwxObj():SetFocus()
end

-- -- /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- -- // StatusBar related methods:
-- -- //
-- -- // We aren't create a statusbar class, all methods to interact to wxStatusBar will be defined here:

-- -- int GetStatusBarPane( ); 
-- function Window:GetStatusBarPane()
-- 	return self.wxObj:GetStatusBarPane()
-- end

-- -- virtual wxString GetStatusText(int ir = 0) const; 
-- function Window:GetStatusText(field)
-- 	return Ventana.wxObj:GetStatusBar():GetStatusText(field or 0)
-- end

-- -- int GetFieldsCount() const; 
-- function Window:GetStatusBarFields()
-- 	return self.wxObj:GetFieldsCount()
-- end

-- -- // %override void wxStatusBar::SetFieldsCount(either a single number or a Lua table with number indexes and values ); 
-- -- // C++ Func: virtual void SetFieldsCount(int number = 1, int* widths = NULL ); 
-- -- virtual void SetFieldsCount(LuaTable intTable ); 
-- function Window:SetStatusBarFields( intTable)
-- 	self.wxObj:SetFieldsCount(intTable )
-- end

-- -- void PushStatusText(const wxString& string, int field = 0 ); 
-- function Window:PushStatusText( string, field )
-- 	self.wxObj:PushStatusText( string, field or 0 ); 
-- end

-- -- void PopStatusText(int field = 0 ); 
-- function Window:PopStatusText( field )
-- 	self.wxObj:PopStatusText( field or 0 ); 
-- end

-- -- void SetMinHeight(int height ); 
-- function Window:SetStatusBarMinHeight( height )
-- 	self.wxObj:SetMinHeight( height ); 
-- end

-- -- // void wxStatusBar::SetStatusStyles(Lua table with number indexes and values ); 
-- -- // C++ Func: virtual void SetStatusStyles(int n, int *styles ); 
-- -- virtual void SetStatusStyles(IntArray_FromLuaTable intTable ); 
-- function Window:SetStatusStyles( styles )
-- 	self.wxObj:SetStatusStyles( styles ); 
-- end

--Window:virtual "CreateStatusBar"
-- virtual wxStatusBar* CreateStatusBar(int number = 1, long style = 0, wxWindowID id = wxID_ANY, const wxString& name = "wxStatusBar" ); 
--#define wxST_SIZEGRIP 
--#define wxSB_NORMAL 
--#define wxSB_FLAT 
--#define wxSB_RAISED 
function Window:createStatusBar( nFields )
	isNumber(nFields);
	self.StatusBar = self.wxObj:CreateStatusBar(nFields, wx.wxSB_NORMAL)
end

--Window:virtual "SetStatusWidths"
-- // void wxFrame::SetStatusWidths(Lua table with number indexes and values ); 
-- // C++ Func: virtual void SetStatusWidths(int n, int *widths ); 
-- virtual void SetStatusWidths(IntArray_FromLuaTable intTable ); 
function Window:setStatusWidths ( ... )
	self.wxObj:SetStatusWidths { ... }
end


--Window:virtual "SetStatusText"
-- virtual void SetStatusText(const wxString& text, int i = 0 ); 
function Window:setStatusText ( text, index )
	self.wxObj:SetStatusText( tostring(text), index or 0)
end

--Window:virtual "SetStatusBarPane"
-- void SetStatusBarPane(int n ); 
function Window:setStatusBarPane( index )
	self.wxObj:SetStatusBarPane( index or 0)
end

-- void Raise( ); 
function Window:raise()
	self.wxObj:Raise()
end

return Window
-- -- %transpass: Este enumerador podría estar definido en la clase Widget.
-- enum { -- wxWindow
-- 	SIMPLE_BORDER = wx.wxSIMPLE_BORDER,
-- 	DOUBLE_BORDER = wx.wxDOUBLE_BORDER,
-- 	SUNKEN_BORDER = wx.wxSUNKEN_BORDER,
-- 	RAISED_BORDER = wx.wxRAISED_BORDER,
-- 	STATIC_BORDER = wx.wxSTATIC_BORDER,

-- 	TRANSPARENT_WINDOW  =  wx.wxTRANSPARENT_WINDOW,
-- 	TAB_TRAVERSAL 		=  wx.wxTAB_TRAVERSAL,
-- 	WANTS_CHARS 		=  wx.wxWANTS_CHARS,
-- 	VSCROLL 			=  wx.wxVSCROLL,
-- 	HSCROLL 			=  wx.wxHSCROLL,
-- 	ALWAYS_SHOW_SB 	    =  wx.wxALWAYS_SHOW_SB,
-- 	CLIP_CHILDREN 		=  wx.wxCLIP_CHILDREN,
	
-- 	NO_FULL_REPAINT_ON_RESIZE =  wx.wxNO_FULL_REPAINT_ON_RESIZE,
-- 	FULL_REPAINT_ON_RESIZE    =  wx.wxFULL_REPAINT_ON_RESIZE,

-- 	-- //#define wxNO_3D %wxcompat_2_6 
-- 	-- //#define wxNO_BORDER in defsutils.i 	
-- }

-- enum { -- wxWindow (Extra Styles)
-- 	WS_EX_VALIDATE_RECURSIVELY = wx.wxWS_EX_VALIDATE_RECURSIVELY,
-- 	WS_EX_BLOCK_EVENTS 		   = wx.wxWS_EX_BLOCK_EVENTS,
-- 	WS_EX_TRANSIENT 		   = wx.wxWS_EX_TRANSIENT,
-- 	WS_EX_PROCESS_IDLE 		   = wx.wxWS_EX_PROCESS_IDLE,
-- 	WS_EX_PROCESS_UI_UPDATES   = wx.wxWS_EX_PROCESS_UI_UPDATES ,
-- }

-- enum { -- wxFrame
-- 	WIN_DEFAULT_STYLE  	= wx.wxDEFAULT_FRAME_STYLE,
-- 	WIN_ICONIZE  		= wx.wxICONIZE, 		-- %win-only
-- 	WIN_CAPTION  		= wx.wxCAPTION, 
-- 	WIN_MINIMIZE  		= wx.wxMINIMIZE,		-- %win-only
-- 	WIN_MINIMIZE_BOX  	= wx.wxMINIMIZE_BOX,
-- 	WIN_MAXIMIZE 		= wx.wxMAXIMIZE,		-- %win-gtk
-- 	WIN_MAXIMIZE_BOX  	= wx.wxMAXIMIZE_BOX,
-- 	WIN_CLOSE_BOX  	    = wx.wxCLOSE_BOX,
-- 	WIN_STAY_ON_TOP  	= wx.wxSTAY_ON_TOP,
-- 	WIN_SYSTEM_MENU  	= wx.wxSYSTEM_MENU,
-- 	WIN_RESIZE_BORDER   = wx.wxRESIZE_BORDER,

-- 	WIN_TOOL_WINDOW     = wx.wxFRAME_TOOL_WINDOW,
-- 	WIN_NO_TASKBAR 	    = wx.wxFRAME_NO_TASKBAR,
-- 	WIN_FLOAT_ON_PARENT = wx.wxFRAME_FLOAT_ON_PARENT,
-- 	WIN_EX_CONTEXTHELP  = wx.wxFRAME_EX_CONTEXTHELP,
-- 	WIN_SHAPED 		    = wx.wxFRAME_SHAPED,
-- 	WIN_EX_METAL		= wx.wxFRAME_EX_METAL,

-- 	-- //#define wxSIMPLE_BORDER see wxWindow defines 
-- 	-- //#define wxTHICK_FRAME %wxcompat_2_6 use %wxchkver_2_6 
-- }

-- enum {
-- 	-- Styles used with wxTopLevelWindow::RequestUserAttention(). More...

-- 	USER_ATTENTION_INFO  = wx.wxUSER_ATTENTION_INFO,  -- 1
-- 	USER_ATTENTION_ERROR = wx.wxUSER_ATTENTION_ERROR, -- 2
-- }

-- enum { 
-- 	-- Styles used with wxTopLevelWindow::showFullScreen()

-- 	FULLSCREEN_NOMENUBAR	= wx.wxFULLSCREEN_NOMENUBAR,
-- 	FULLSCREEN_NOTOOLBAR 	= wx.wxFULLSCREEN_NOTOOLBAR,
-- 	FULLSCREEN_NOSTATUSBAR	= wx.wxFULLSCREEN_NOSTATUSBAR,
-- 	FULLSCREEN_NOBORDER	    = wx.wxFULLSCREEN_NOBORDER,
-- 	FULLSCREEN_NOCAPTION	= wx.wxFULLSCREEN_NOCAPTION,
-- 	FULLSCREEN_ALL	        = wx.wxFULLSCREEN_ALL,
-- }

-- enum { -- wxStatusBar
-- 	ST_SIZEGRIP = wx.wxST_SIZEGRIP,
-- 	SB_NORMAL   = wx.wxSB_NORMAL,
-- 	SB_FLAT     = wx.wxSB_FLAT,
-- 	SB_RAISED   = wx.wxSB_RAISED,
-- }

-- 	-- store the window in global table _wl
-- 	if (Properties.NOT_STORE ~= true ) then  --> for lide console and other core windows:
-- 		_wl.Windows = _wl.Windows or {}
-- 		local nWindows = #_wl.Windows  --> number of actual windows
-- 		_wl.Windows[nWindows+1] = self --> index this window
-- 	end
	
-- 	-- Establecer la primera ventana que se cree como ventana de primer nivel:
-- 	if (self.TopLevelWindow == nil) and (#_wl.Windows == 1) then
-- 		self.TopLevelWindow = true
-- 	end

-- 	self:InitWidgetEvents { 
-- 			-- MouseButtons:
-- 			"OnLeftUp"	 , "OnLeftDown"  , "OnLeftDoubleClick",
-- 			"OnRightUp"  , "OnRightDown" , "OnRightDoubleClick",
-- 			"OnMiddleUp" , "OnMiddleDown", "OnMiddleDoubleClick",

-- 			-- MouseActions:
-- 			"OnEnter"	, "OnLeave",
-- 			"OnSize" 	, "OnSizing",
-- 			"OnMotion",
			
-- 			--> MouseWheel:	
-- 			"OnMouseWheel",
-- 	}
		
-- 	self:InitWindowEvents {
-- 		"OnIdle",
-- 		"OnMove",
-- 		"OnMoving",
-- 		--"OnActive",
-- 		"OnMaximize",
-- 		"OnShow",
-- 		"OnIconize",
-- 		"OnActivate",
-- 		"OnDropFiles",
-- 		--"OnClose",
-- 	} 	--> Initialize Window Events
	
-- 	self.OnShow = xEvent:new ( self.Name .. '.OnShow', self )
-- 	self.wxObj:Connect(wx.wxEVT_SHOW, function ( event )
-- 		if event:GetShow() then -- if true = = eventSHow false == eventHIde
-- 			self.OnShow:call( )
-- 		end
-- 	end)
	
-- 	local function def_onclose ( )
-- 		-- Calling OnClose destroy the window
-- 		print 'this:getSender():Destroy()'
-- 	end

-- 	self.OnClose = xEvent:new ( self.Name .. '.OnClose', self, def_onclose )

-- 	self.wxObj:Connect(wx.wxEVT_CLOSE_WINDOW, function ( event )
-- 	    self.OnClose:call(  )
-- 	end)
-- end

-- -- Define default event handlers :
-- --Window.OnClose = voidf

-- -- /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- --
-- --> Define EventFilter:
-- --



-- Window:virtual "InitWindowEvents"

-- function Window:InitWindowEvents( tEventNames )
-- 	--* See Widget:InitWidgetEvents() for more info... 
	
-- 	-- función local para obtener los valores XY de los eventos del mouse:
-- 	local function getXY ( event )
-- 		local pos = event:GetPosition()
-- 		return pos.X, pos.Y
-- 	end

-- 	local tEvents = {


-- 		OnIconize = {
-- 			data = wx.wxEVT_ICONIZE,
-- 			args = function ( event )
-- 				return event:Iconized()
-- 			end
-- 		},

-- 		OnDropFiles = {
-- 			data = wx.wxEVT_DROP_FILES,
-- 			args = function ( event )
-- 				local FilesList    = event:GetFiles() 		--> table of all files dropped.
-- 				local TotalFiles   = event:GetNumberOfFiles() --> number of all files dropped.
-- 				local DropPosition = event:GetPosition()      --> (wxPoint) the position at which the files were dropped.

-- 				return FilesList, TotalFiles, DropPosition.X, DropPosition.Y
-- 			end
-- 		},
		
-- 		-- OnClose = {
-- 		-- 	data = wx.wxEVT_CLOSE_WINDOW,
-- 		-- 	args = function ( event )
				
-- 		-- 		--if self.TopLevelWindow then
-- 		-- 		if self.TopLevelWindow == 'LOOOOOOOOL' then
-- 		-- 			for i, object in pairs(_wl["Windows"]) do
-- 		-- 				if self == object then
-- 		-- 					_wl["Windows"][i] = nil
-- 		-- 				end
-- 		-- 			end

-- 		-- 			if #_wl["Windows"]  == 0 then
-- 		-- 				os.exit()
-- 		-- 			end
-- 		-- 		end
-- 		-- 		--self.wxObj:show(false) -- self.wxObj:Hide()
-- 		-- 		self.wxObj:Destroy()
-- 		-- 		return 
-- 		-- 	end
-- 		-- }
-- 	}
	
-- 	-- El evento 'OnClose' siempre es heredado sin importar si se pasa como parametro en el inicializador (Window:InitWindowEvents) o no.


-- 	-- comentamos para ver que sucede...
-- 	--[[self.wxObj:Connect(wx.wxEVT_CLOSE_WINDOW, function ( event )
-- 		for i, window in pairs(_wl.Windows) do
-- 			if window == self then
-- 				_wl.Windows[i] = nil
-- 				break
-- 			end
-- 		end
		
-- 		if not self.OnClose then
-- 			-- event:Skip()
-- 			self.wxObj:Destroy()
-- 		else
-- 			this = Event:new(event, "OnClose")
-- 			local exec, err_msg = pcall( self.OnClose )
-- 			if (not exec) then lide.eventhandler_error(self, this, err_msg) end
-- 			this = nil
-- 		end
		
-- 	end)]]
	
-- 	local exec, err_msg = pcall( lide.hand_event, self, tEvents, tEventNames)
-- 	if (not exec) then lide.print_error(err_msg) end	
-- end

-- --[[
-- function Window:initWindowEvents( ... )
	
-- 	self.wxObj:Connect(wx.wxEVT_MOVE, function ( event )
-- 		if not self.OnMove then
-- 			event:Skip()
-- 		else
-- 			this = Event:new(event, "OnMove")
-- 			local exec, msg = pcall( self.OnMove, self, event:GetPosition().X, event:GetPosition().Y )
-- 			if (not exec) then
-- 				print (msg)
-- 			end
-- 			this = nil
-- 		end
-- 	end)

-- 	self.wxObj:Connect(wx.wxEVT_MOVING, function ( event )
-- 		if not self.OnMoving then
-- 			event:Skip()
-- 		else
-- 			this = Event:new(event, "OnMoving")
-- 			self:OnMoving( event:GetPosition().X, event:GetPosition().Y )
-- 			this = nil
-- 		end
-- 	end)

-- 	self.wxObj:Connect(wx.wxEVT_ACTIVATE, function ( event )
-- 		if not self.OnActive then
-- 			event:Skip()
-- 		else
-- 			this = Event:new(event, "OnActive")
-- 			self:OnActive( event:GetActive() )
-- 			this = nil
-- 		end
-- 	end)

-- 	self.wxObj:Connect(wx.wxEVT_MAXIMIZE, function ( event )
-- 		if not self.OnMaximize then
-- 			event:Skip()
-- 		else
-- 			this = Event:new(event, "OnMaximize")
-- 			self:OnMaximize( event:GetActive() )
-- 			this = nil
-- 		end
-- 	end)

-- 	self.wxObj:Connect(wx.wxEVT_SHOW, function ( event )
-- 		if not self.OnShow then
-- 			event:Skip()
-- 		else
-- 			this = Event:new(event, "OnShow")
-- 			self:OnShow( event:GetShow() )
-- 			this = nil
-- 		end
-- 	end)

-- 	self.wxObj:Connect(wx.wxEVT_ICONIZE, function ( event )
-- 		if not self.OnIconize then
-- 			event:Skip()
-- 		else
-- 			this = Event:new(event, "OnIconize")
-- 			self:OnIconize( event:Iconized() )
-- 			this = nil
-- 		end
-- 	end)

-- 	self.wxObj:Connect(wx.wxEVT_IDLE, function ( event )
-- 		if not self.OnIdle then
-- 			event:Skip()
-- 		else
-- 			this = Event:new(event, "OnIdle")
-- 			self:OnIdle( event:Iconized() )
-- 			this = nil
-- 		end
-- 	end)

-- 	self.wxObj:Connect(wx.wxEVT_DROP_FILES, function ( event )
-- 		if not self.OnDropFiles then
-- 			event:Skip()
-- 		else
-- 			FilesList    = event:GetFiles() 		--> table of all files dropped.
-- 			TotalFiles   = event:GetNumberOfFiles() --> number of all files dropped.
-- 			DropPosition = event:GetPosition()      --> (wxPoint) the position at which the files were dropped.

-- 			this = Event:new(event, "OnDropFiles")
-- 			self:OnDropFiles( FilesList, TotalFiles, DropPosition.X, DropPosition.Y)
-- 			this = nil
-- 		end
-- 	end)

-- 	self.wxObj:Connect(wx.wxEVT_CLOSE_WINDOW, function ( ... )
-- 		for i, window in pairs(_wl.Windows) do
-- 			if window == self then
-- 				_wl.Windows[i] = nil
-- 				break
-- 			end
-- 		end
		
-- 		if not self.OnClose then
-- 			-- event:Skip()
-- 			self.wxObj:Destroy()
-- 		else
-- 			this = Event:new(event, "OnClose")
-- 			self:OnClose()
-- 			this = nil
-- 		end
		
-- 	end)
	
-- 	self.wxObj:Connect(wx.wxEVT_ACTIVATE , function ( event )		
-- 		if not self.OnActivate then
-- 			event:Skip()
-- 		else
-- 			local args = {}
-- 			lide.hand_event(self, event, "OnActivate", args)
-- 		end
		
-- 	end)
-- end
-- ]]

-- --[[
-- function Window:EventFilter ( event ) --%deprecated
-- 	local exec, args

-- 	if event:GetEventType() == wx.wxEVT_ACTIVATE then
-- 		-- wxActivateEvent:
-- 		-- bool GetActive() const; 
-- 		args  = { event:GetActive() }
-- 		exec  = true
-- 	elseif event:GetEventType() == wx.wxEVT_MAXIMIZE then
-- 		args = {}
-- 		exec = true
-- 	elseif event:GetEventType() == wx.wxEVT_MENU_OPEN  or
-- 	   event:GetEventType() == wx.wxEVT_MENU_CLOSE or
-- 	   event:GetEventType() == wx.wxEVT_MENU_HIGHLIGHT then
-- 		-- wxMenuEvent:
-- 		-- wxMenu* GetMenu() const; 
-- 		-- int GetMenuId() const; 
-- 		-- bool IsPopup() const; 

-- 		args = { event:GetMenuId(), event:IsPopup() }
-- 		exec = true			

-- 	elseif event:GetEventType() == wx.wxEVT_SHOW then
-- 		-- wxShowEvent: 
-- 		-- void SetShow(bool show ); 
-- 		-- bool GetShow() const; 

-- 		args = { event:GetShow() }
-- 		exec = true
	
-- 	elseif event:GetEventType() == wx.wxEVT_MOVING or 
-- 		   event:GetEventType() == wx.wxEVT_MOVE then
-- 		-- wxMoveEvent:
-- 		-- wxPoint GetPosition() const; 

-- 		args = { event:GetPosition().X, event:GetPosition().Y }
-- 		exec = true
-- 	elseif event:GetEventType() == wx.wxEVT_CLOSE_WINDOW then
-- 		-- wxCloseEvent:
-- 		-- bool CanVeto( ); 
-- 		-- bool GetLoggingOff() const; 
-- 		-- void SetCanVeto(bool canVeto ); 
-- 		-- void SetLoggingOff(bool loggingOff) const; 
-- 		-- void Veto(bool veto = true ); 

-- 		args  = {}
-- 		exec  = true
-- 	elseif event:GetEventType() == wx.wxEVT_ICONIZE then
-- 		-- wxIconizeEvent:
-- 		-- bool Iconized() const; 

-- 		args  = { event:Iconized() }
-- 		exec  = true
-- 	elseif event:GetEventType() == wx.wxEVT_IDLE then

-- 		-- !%wxchkver_2_9_2 static bool CanSend(wxWindow* window ); 
-- 		-- static wxIdleMode GetMode( ); 
-- 		-- void RequestMore(bool needMore = true ); 
-- 		-- bool MoreRequested() const; 
-- 		-- static void SetMode(wxIdleMode mode ); 

-- 		args  = {}
-- 		exec  = true
-- 	elseif event:GetEventType() == wx.wxEVT_DROP_FILES then
-- 		-- wxDropFilesEvent:
-- 		-- wxString* GetFiles() const; 
-- 		-- int GetNumberOfFiles() const; 
-- 		-- wxPoint GetPosition() const; 
		
-- 		FilesList    = event:GetFiles() 		--> table of all files dropped.
-- 		TotalFiles   = event:GetNumberOfFiles() --> number of all files dropped.
-- 		DropPosition = event:GetPosition()      --> (wxPoint) the position at which the files were dropped.

-- 		args = { FilesList, TotalFiles, DropPosition.X, DropPosition.Y } --> args to be passed to eventhandler
-- 		exec = true
-- 	end


-- 	return exec, args
-- end
-- ]]


-- -- /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- --
-- --> Define virtual methods:
-- --

-- Window:virtual "ShowFullScreen"

-- -- bool ShowFullScreen(bool show, long style = wxFULLSCREEN_ALL ); 
-- function Window:showFullScreen( show, style )
-- 	return self.wxObj:showFullScreen( show, style )
-- end

-- Window:virtual "SetFont"

-- --> Reimplement :SetFont method, this effect runs, only if the font is setted in the window Panel:
-- function Window:SetFont( FontFamily, FontSize, FontFlags )
-- 	-- Make a new font object:
-- 	local oFont = Font(FontFamily, FontSize, FontFlags)

-- 	self.Panel.wxObj:SetFont(oFont.wxObj)
-- end


-- Window:virtual "Hide"
-- -- bool Hide( ); 
-- function Window:Hide()
-- 	return self.wxObj:Hide()
-- end

-- Window:virtual "Close"
-- -- virtual bool Close(bool force = false ); 
-- function Window:Close( force )
-- 	-- if (force == nil) then
-- 	-- 	force = false
-- 	-- end
-- 	-- if self.OnClose then
-- 	-- 	self:OnClose()
-- 	-- end
--     if self.OnClose then
--     	self:OnClose(force)
--     end
-- 	--return self.wxObj:Destroy()
-- 	os.exit()
-- end

-- Window:virtual "SetIcon"

-- -- void SetIcon(const wxIcon& icon ); 
-- -- void SetIcons(const wxIconBundle& icons ); 
-- function Window:SetIcon( filename )
-- 	local icon = wx.wxIcon(filename, wx.wxBITMAP_TYPE_ICO)
-- 	self.wxObj:SetIcon(icon)
-- 	icon:delete()
-- end

-- Window:virtual "DragAcceptFiles"

-- -- %win virtual void DragAcceptFiles(bool accept ); 
-- function Window:DragAcceptFiles( accept )
-- 	self.wxObj:DragAcceptFiles(accept)
-- end

-- Window:virtual "SetTransparent"

-- -- virtual bool SetTransparent(int alpha ); 
-- function Window:SetTransparent( alpha)
-- 	if (alpha > 255) then
-- 		alpha = 255
-- 	elseif (alpha < 0) then
-- 		alpha = 0
-- 	end
-- 	return self.wxObj:SetTransparent(alpha)
-- end


-- --
-- --< Virtual methods
-- --
-- -- /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- -- void SetMenuBar(wxMenuBar* menuBar ); 
-- function Window:SetMenuBar( Menus )
-- 	BarraMenu = wx.wxMenuBar() 
	
-- 	for _,Menu in pairs(Menus) do
-- 		BarraMenu:Append(Menu.wxObj, Menu.Name)
-- 	end
	
-- 	self.wxObj:SetMenuBar( BarraMenu )
-- end

-- -- bool CanSetTransparent( ); 
-- function Window:CanSetTransparent()
-- 	return self.wxObj:CanSetTransparent()
-- end

-- -- bool EnableCloseButton(bool enable = true ); 
-- function Window:EnableCloseButton(enable)
-- 	return self.wxObj:EnableCloseButton(enable)
-- end


-- -- bool IsActive() const; 
-- function Window:IsActive()
-- 	return self.wxObj:IsActive()
-- end

-- -- bool IsAlwaysMaximized() const; 
-- function Window:IsAlwaysMaximized()
-- 	return self.wxObj:IsAlwaysMaximized()
-- end

-- -- bool IsFullScreen() const; 
-- function Window:IsFullScreen()
-- 	return self.wxObj:IsFullScreen()
-- end

-- -- void RequestUserAttention(int flags = wxUSER_ATTENTION_INFO ); 
-- function Window:RequestUserAttention( flags)
-- 	return self.wxObj:IsMaximized(flags)
-- end



-- -- long GetWindowStyleFlag() const; 
-- function Window:GetWindowStyleFlag()
-- 	return self.wxObj:GetWindowStyleFlag()
-- end

-- -- %to-fix: ELIMINAR! el interprete utiliza la funcion GetWindowStyle que fue despreciada por GetWindowStyleFlag:
-- function Window:GetWindowStyle( )
-- 	return self.wxObj:GetWindowStyleFlag()
-- end

-- -- %to-fix: ELIMINAR! el interprete utiliza la funcion SetWindowStyle que fue despreciada por SetWindowStyleFlag:
-- function Window:SetWindowStyle( style )
-- 	self.wxObj:SetWindowStyleFlag(style)
-- end


-- -- void SetWindowStyle(long style ); 
-- -- virtual void SetWindowStyleFlag(long style ); 
-- function Window:SetWindowStyleFlag( style )
-- 	self.wxObj:SetWindowStyleFlag(style)
-- end

-- -- virtual void Refresh(bool eraseBackground = true, const wxRect* rect = NULL ); 
-- -- // don't need to worry about rect, void RefreshRect(const wxRect& rect, bool eraseBackground = true ); 
-- function Window:Refresh( ... )
-- 	self.wxObj:Refresh( ... )
-- end

-- -- void Move(int x, int y ); 
-- -- void Move(const wxPoint& pt ); 
-- function Window:Move( ... )
-- 	self.wxObj:Move( ... )
-- end

-- function Window:Destroy( ... )
-- 	-- self.super.super:Destroy()
-- 	self.wxObj:Destroy()
-- end

-- -- class wxFrame : public wxTopLevelWindow 
-- -- {
-- -- wxPoint GetClientAreaOrigin() const; 
-- -- %wxchkver_2_4 void ProcessCommand(int id ); 
-- -- //!%wxchkver_2_4 void Command(int id ); 
-- -- void SendSizeEvent( ); 
-- -- }; 

-- -- class wxTopLevelWindow : public wxWindow 
-- -- {
-- -- %wxchkver_2_8 wxWindow* GetDefaultItem() const; 
-- -- wxIcon GetIcon() const; 
-- -- //const wxIconBundle& GetIcons() const; 
-- -- %wxchkver_2_8 wxWindow* GetTmpDefaultItem() const; 
-- -- %wxchkver_2_8 wxWindow* SetDefaultItem(wxWindow *win ); 

-- -- bool SetShape(const wxRegion& region ); 
-- -- //virtual bool ShouldPreventAppExit() const; // must be overridden 
-- -- %wxchkver_2_8 wxWindow* SetTmpDefaultItem(wxWindow *win ); 
-- -- }; 



-- return Window


-- -----------------------------------------------------------------------------------------------------------------------
-- -- > DEPRECATED:

-- -- void SetSizeHints(int minW, int minH, int maxW=-1, int maxH=-1, int incW=-1, int incH=-1 ); 
-- -- void SetSizeHints(const wxSize& minSize, const wxSize& maxSize=wxDefaultSize, const wxSize& incSize=wxDefaultSize ); 

-- -- < DEPRECATED
-- -----------------------------------------------------------------------------------------------------------------------


-- -- class wxWindow : public wxEvtHandler 
-- -- {
-- -- wxWindow( ); 
-- -- wxWindow(wxWindow* parent, wxWindowID id, const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxDefaultSize, long style = 0, const wxString& name = "wxWindow" ); 
-- -- bool Create(wxWindow *parent, wxWindowID id, const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxDefaultSize, long style = 0, const wxString& name = "wxWindow" ); 

-- -- virtual void AddChild(wxWindow* child ); 
-- -- void CacheBestSize(const wxSize& size) const; 
-- -- virtual void CaptureMouse( ); 
-- -- void Center(int direction = wxBOTH ); 
-- -- void CenterOnParent(int direction = wxBOTH ); 
-- -- !%wxchkver_2_8 void CenterOnScreen(int direction = wxBOTH ); 
-- -- !%wxchkver_2_8 void CentreOnScreen(int direction = wxBOTH ); 
-- -- !%wxchkver_2_6 void Clear( ); 
-- -- %wxchkver_2_6 void ClearBackground( ); 

-- -- // %override [int x, int y] ClientToScreen(int x, int y) const; 
-- -- // C++ Func: virtual void ClientToScreen(int* x, int* y) const; 
-- -- %override_name wxLua_wxWindow_ClientToScreenXY virtual void ClientToScreen(int x, int y) const; 

-- -- virtual wxPoint ClientToScreen(const wxPoint& pt) const; 
-- -- wxPoint ConvertDialogToPixels(const wxPoint& pt ); 
-- -- wxSize ConvertDialogToPixels(const wxSize& sz ); 
-- -- wxPoint ConvertPixelsToDialog(const wxPoint& pt ); 
-- -- wxSize ConvertPixelsToDialog(const wxSize& sz ); 
-- -- virtual bool Destroy( ); 
-- -- virtual void DestroyChildren( ); 
-- -- bool Disable( ); 
-- -- // virtual wxSize DoGetBestSize() const; // protected 
-- -- //virtual void DoUpdateWindowUI(wxUpdateUIEvent& event ); 

-- -- virtual void Enable(bool enable ); 
-- -- static wxWindow* FindFocus( ); 
-- -- wxWindow* FindWindow(long id ); 
-- -- wxWindow* FindWindow(const wxString& name ); 
-- -- static wxWindow* FindWindowById(long id, wxWindow* parent = NULL ); 
-- -- static wxWindow* FindWindowByName(const wxString& name, wxWindow* parent = NULL ); 
-- -- static wxWindow* FindWindowByLabel(const wxString& label, wxWindow* parent = NULL ); 
-- -- virtual void Fit( ); 
-- -- virtual void FitInside( ); 
-- -- virtual void Freeze( ); 
-- -- wxAcceleratorTable* GetAcceleratorTable() const; 
-- -- //wxAccessible* GetAccessible( ); 
-- -- !%wxchkver_2_8 wxSize GetAdjustedBestSize() const; 
-- -- virtual wxColour GetBackgroundColour() const; 
-- -- virtual wxBackgroundStyle GetBackgroundStyle() const; 
-- -- wxSize GetBestFittingSize() const; // deprecated in 2.8 use GetEffectiveMinSize 
-- -- virtual wxSize GetBestSize() const; 
-- -- wxCaret* GetCaret() const; 
-- -- static wxWindow* GetCapture( ); 
-- -- virtual int GetCharHeight() const; 
-- -- virtual int GetCharWidth() const; 
-- -- wxWindowList& GetChildren( ); 
-- -- //static wxVisualAttributes GetClassDefaultAttributes(wxWindowVariant variant = wxWINDOW_VARIANT_NORMAL ); 

-- -- // %override [int width, int height] wxWindow::GetClientSizeWH() const; 
-- -- // C++ Func: virtual void GetClientSize(int* width, int* height) const; 
-- -- %rename GetClientSizeWH virtual void GetClientSize() const; 

-- -- wxSize GetClientSize() const; 
-- -- !%wxchkver_2_6 wxLayoutConstraints* GetConstraints() const; // deprecated use sizers 
-- -- const wxSizer* GetContainingSizer() const; 
-- -- wxCursor GetCursor() const; 
-- -- virtual wxVisualAttributes GetDefaultAttributes() const; 
-- -- !%wxchkver_2_8 wxWindow* GetDefaultItem() const; 
-- -- wxDropTarget* GetDropTarget() const; 
-- -- wxEvtHandler* GetEventHandler() const; 
-- -- long GetExtraStyle() const; 
-- -- wxFont GetFont() const; 
-- -- virtual wxColour GetForegroundColour( ); 
-- -- wxWindow* GetGrandParent() const; 
-- -- void* GetHandle() const; 
-- -- virtual wxString GetHelpText() const; 
-- -- int GetId() const; 
-- -- virtual wxString GetLabel() const; 
-- -- virtual wxString GetName() const; 
-- -- virtual wxWindow* GetParent() const; 

-- -- // %override [int x, int y] wxWindow::GetPosition() const; 
-- -- // C++ Func: virtual void GetPosition(int* x, int* y) const; 
-- -- %override_name wxLua_wxWindow_GetPositionXY %rename GetPositionXY virtual void GetPosition() const; 

-- -- wxPoint GetPosition() const; 
-- -- virtual wxRect GetRect() const; 

-- -- // %override [int x, int y] wxWindow::GetScreenPosition() const; 
-- -- // C++ Func: virtual void GetScreenPosition(int* x, int* y) const; 
-- -- %override_name wxLua_wxWindow_GetScreenPositionXY %rename GetScreenPositionXY virtual void GetScreenPosition() const; 

-- -- virtual wxPoint GetScreenPosition( ); 
-- -- virtual wxRect GetScreenRect() const; 
-- -- virtual int GetScrollPos(int orientation ); 
-- -- virtual int GetScrollRange(int orientation ); 
-- -- virtual int GetScrollThumb(int orientation ); 
-- -- virtual wxSize GetSize() const; 

-- -- // %override [int width, int height] wxWindow::GetSizeWH() const; 
-- -- // C++ Func: virtual void GetSize(int* width, int* height) const; 
-- -- %rename GetSizeWH virtual void GetSize() const; 

-- -- wxSizer* GetSizer() const; 

-- -- // %override [int x, int y, int descent, int externalLeading] int wxWindow::GetTextExtent(const wxString& string, const wxFont* font = NULL ) const; 
-- -- // Note: Cannot use use16 from Lua, virtual void GetTextExtent(const wxString& string, int* x, int* y, int* descent = NULL, int* externalLeading = NULL, const wxFont* font = NULL, bool use16 = false) const; 
-- -- // C++ Func: virtual void GetTextExtent(const wxString& string, int* x, int* y, int* descent = NULL, int* externalLeading = NULL, const wxFont* font = NULL ) const; 
-- -- virtual void GetTextExtent(const wxString& string, const wxFont* font = NULL ) const; 

-- -- !%wxchkver_2_8 virtual wxString GetTitle( ); 
-- -- wxToolTip* GetToolTip() const; 
-- -- virtual wxRegion GetUpdateRegion() const; 
-- -- wxValidator* GetValidator() const; 

-- -- // %override [int width, int height] wxWindow::GetVirtualSizeWH() const; 
-- -- // C++ Func: void GetVirtualSize(int* width, int* height) const; 
-- -- %override_name wxLua_wxWindow_GetVirtualSizeWH %rename GetVirtualSizeWH void GetVirtualSize() const; 

-- -- wxSize GetVirtualSize() const; 
-- -- %wxchkver_2_9_4 virtual wxSize GetBestVirtualSize() const; 
-- -- %wxchkver_2_9_4 virtual double GetContentScaleFactor() const; 

-- -- wxWindowVariant GetWindowVariant() const; 
-- -- %wxchkver_2_4 bool HasCapture() const; 
-- -- virtual bool HasScrollbar(int orient) const; 
-- -- virtual bool HasTransparentBackground() const; 

-- -- void InheritAttributes( ); 
-- -- void InitDialog( ); 
-- -- void InvalidateBestSize( ); 
-- -- virtual bool IsEnabled() const; 
-- -- bool IsExposed(int x, int y) const; 
-- -- bool IsExposed(const wxPoint &pt) const; 
-- -- bool IsExposed(int x, int y, int w, int h) const; 
-- -- bool IsExposed(const wxRect &rect) const; 
-- -- virtual bool IsRetained() const; 
-- -- virtual bool IsShown() const; 
-- -- bool IsTopLevel() const; 
-- -- void Layout( ); 
-- -- void Lower( ); 
-- -- virtual void MakeModal(bool flag ); 
-- -- void MoveAfterInTabOrder(wxWindow *win ); 
-- -- void MoveBeforeInTabOrder(wxWindow *win ); 
-- -- bool Navigate(int flags = wxNavigationKeyEvent::IsForward ); 
-- -- wxEvtHandler* PopEventHandler(bool deleteHandler = false) const; 
-- -- bool PopupMenu(wxMenu* menu, const wxPoint& pos = wxDefaultPosition ); 
-- -- bool PopupMenu(wxMenu* menu, int x, int y ); 
-- -- void PushEventHandler(wxEvtHandler* handler ); 

-- -- // %win bool RegisterHotKey(int hotkeyId, int modifiers, int virtualKeyCode) - only under WinCE 
-- -- virtual void ReleaseMouse( ); 
-- -- virtual void RemoveChild(wxWindow* child ); 
-- -- bool RemoveEventHandler(wxEvtHandler *handler ); 
-- -- virtual bool Reparent(wxWindow* newParent ); 
-- -- virtual wxPoint ScreenToClient(const wxPoint& pt) const; 

-- -- // %override [int x, int y] wxWindow::ScreenToClient(int x, int y) const; 
-- -- // C++ Func: virtual void ScreenToClient(int* x, int* y) const; 
-- -- %override_name wxLua_wxWindow_ScreenToClientXY virtual void ScreenToClient(int x, int y) const; 

-- -- virtual bool ScrollLines(int lines ); 
-- -- virtual bool ScrollPages(int pages ); 
-- -- virtual void ScrollWindow(int dx, int dy, const wxRect* rect = NULL ); 
-- -- virtual void SetAcceleratorTable(const wxAcceleratorTable& accel ); 
-- -- //void SetAccessible(wxAccessible* accessible ); 
-- -- void SetAutoLayout(bool autoLayout ); 
-- -- virtual void SetBackgroundColour(const wxColour& colour ); 
-- -- virtual void SetBackgroundStyle(wxBackgroundStyle style ); 
-- -- !%wxchkver_2_8 void SetBestFittingSize(const wxSize& size = wxDefaultSize); // deprecated in 2.8 use SetInitialSize 
-- -- void SetCaret(wxCaret *caret) const; 
-- -- virtual void SetClientSize(const wxSize& size ); 
-- -- virtual void SetClientSize(int width, int height ); 
-- -- void SetContainingSizer(wxSizer* sizer ); 
-- -- virtual void SetCursor(const wxCursor& cursor ); 
-- -- !%wxchkver_2_6 void SetConstraints(wxLayoutConstraints* constraints ); 
-- -- !%wxchkver_2_8 wxWindow* SetDefaultItem(wxWindow *win ); 
-- -- // virtual void SetInitialBestSize(const wxSize& size) protected 
-- -- %wxchkver_2_8 void SetInitialSize(const wxSize& size = wxDefaultSize ); 
-- -- void SetMaxSize(const wxSize& size ); 
-- -- void SetMinSize(const wxSize& size ); 
-- -- void SetOwnBackgroundColour(const wxColour& colour ); 
-- -- void SetOwnFont(const wxFont& font ); 
-- -- void SetOwnForegroundColour(const wxColour& colour ); 
-- -- void SetDropTarget(%ungc wxDropTarget* target ); 
-- -- void SetEventHandler(wxEvtHandler* handler ); 
-- -- void SetExtraStyle(long exStyle ); 
-- -- virtual void SetFocus( ); 
-- -- //virtual void SetFocusFromKbd( ); 
-- -- void SetFont(const wxFont& font ); 
-- -- virtual void SetForegroundColour(const wxColour& colour ); 
-- -- virtual void SetHelpText(const wxString& helpText ); 
-- -- void SetId(int id ); 
-- -- virtual void SetLabel(const wxString& label ); 
-- -- virtual void SetName(const wxString& name ); 
-- -- // virtual void SetPalette(wxPalette* palette) - obsolete 
-- -- virtual void SetScrollbar(int orientation, int position, int thumbSize, int range, bool refresh = true ); 
-- -- virtual void SetScrollPos(int orientation, int pos, bool refresh = true ); 
-- -- virtual void SetSize(int x, int y, int width, int height, int sizeFlags = wxSIZE_AUTO ); 
-- -- virtual void SetSize(int width, int height ); 
-- -- void SetSize(const wxSize& size ); 
-- -- virtual void SetSize(const wxRect& rect ); 
-- -- virtual void SetSizeHints(int minW, int minH, int maxW=-1, int maxH=-1, int incW=-1, int incH=-1 ); 
-- -- void SetSizeHints(const wxSize& minSize, const wxSize& maxSize=wxDefaultSize, const wxSize& incSize=wxDefaultSize ); 
-- -- void SetSizer(wxSizer* sizer, bool deleteOld=true ); 
-- -- void SetSizerAndFit(wxSizer* sizer, bool deleteOld=true ); 
-- -- !%wxchkver_2_8 virtual void SetTitle(const wxString& title ); 
-- -- virtual void SetThemeEnabled(bool enable ); 
-- -- void SetToolTip(const wxString& tip ); 
-- -- void SetToolTip(%ungc wxToolTip* tip ); 
-- -- virtual void SetValidator(const wxValidator& validator ); 
-- -- void SetVirtualSize(int width, int height ); 
-- -- void SetVirtualSize(const wxSize& size ); 
-- -- virtual void SetVirtualSizeHints(int minW,int minH, int maxW=-1, int maxH=-1 ); 
-- -- void SetVirtualSizeHints(const wxSize& minSize=wxDefaultSize, const wxSize& maxSize=wxDefaultSize ); 
-- -- void SetWindowVariant(wxWindowVariant variant ); 
-- -- virtual bool ShouldInheritColours( ); 
-- -- virtual void Thaw( ); 
-- -- virtual bool TransferDataFromWindow( ); 
-- -- virtual bool TransferDataToWindow( ); 
-- -- //%win bool UnregisterHotKey(int hotkeyId) - only under WinCE 
-- -- virtual void Update( ); 
-- -- virtual void UpdateWindowUI(long flags = wxUPDATE_UI_NONE ); 
-- -- virtual bool Validate( ); 
-- -- void WarpPointer(int x, int y ); 
-- -- }; 
