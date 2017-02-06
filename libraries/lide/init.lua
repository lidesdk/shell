-- /////////////////////////////////////////////////////////////////////////////////////////////////
-- // Name:        init.lua
-- // Purpose:     Initialize framework
-- // Author:      Dario Cano [dario.canohdz@gmail.com]
-- // Created:     2016/01/03
-- // Copyright:   (c) 2014 Dario Cano
-- // License:     MIT License/X11 license
-- /////////////////////////////////////////////////////////////////////////////////////////////////
--
-- GNU/Linux Lua version:   5.1.5
-- Windows x86 Lua version: 5.1.4

lide = require 'lide.core.init'
app  = lide.app

if not wx then
	local _lide_path = os.getenv 'LIDE_PATH'

	if lide.platform.getOSName() == 'Linux' then
		wx = require 'wx'
		
	elseif lide.platform.getOSName() == 'Windows' then
		wx = require 'wx'
	else
		print 'lide: error fatal: plataforma no soportada.'
	end

	if not wx then lide.core.error.lperr 'No se pudo cargar wxLua' os.exit(1) end
end

--> lide.core.file is deprecated by lide.file
lide.file = lide.core.file

----------------------------------------------------------------------
--- Alignment constants:
--	used by BoxSizer,

enum -- wxAlignment 
{
    ALIGN_NOT    = wx.wxALIGN_NOT, 
    ALIGN_LEFT   = wx.wxALIGN_LEFT, 
    ALIGN_TOP    = wx.wxALIGN_TOP, 
    ALIGN_RIGHT  = wx.wxALIGN_RIGHT, 
    ALIGN_BOTTOM = wx.wxALIGN_BOTTOM, 
    ALIGN_CENTER = wx.wxALIGN_CENTER, 
    ALIGN_CENTRE = wx.wxALIGN_CENTRE, 
    ALIGN_MASK   = wx.wxALIGN_MASK,
    
    ALIGN_CENTER_HORIZONTAL = wx.wxALIGN_CENTER_HORIZONTAL, 
    ALIGN_CENTRE_HORIZONTAL = wx.wxALIGN_CENTRE_HORIZONTAL, 
    ALIGN_CENTER_VERTICAL   = wx.wxALIGN_CENTER_VERTICAL, 
    ALIGN_CENTRE_VERTICAL   = wx.wxALIGN_CENTRE_VERTICAL, 
}

enum { -- wxMessageDialog
	 ICON_ASTERISK    = wx.wxICON_ASTERISK ,
	 ICON_ERROR  	  = wx.wxICON_ERROR,
	 ICON_EXCLAMATION = wx.wxICON_EXCLAMATION,
	 ICON_HAND  	  = wx.wxICON_HAND,
	 ICON_INFORMATION = wx.wxICON_INFORMATION,
	 ICON_MASK  	  = wx.wxICON_MASK,
	 ICON_QUESTION    = wx.wxICON_QUESTION,
	 ICON_STOP  	  = wx.wxICON_STOP,
	 ICON_WARNING     = wx.wxICON_WARNING,
}

----------------------------------------------------------------------
lide.core.base.maxid = 1000
------------------------------------------

--- Get the architecture of the runnig operating system.
---		Returns one value: a string like "32 bit" or "64 bit"
---
--- string getOSVersion( nil )
function lide.platform.getArchName( ... )
	return wx.wxPlatformInfo:Get():GetArchName()
end


lide.core.base.enum {
	HELP        = wx.wxHELP, 
	CANCEL      = wx.wxCANCEL, 
	YES_NO      = wx.wxYES_NO, 
	OK_DEFAULT  = wx.wxOK_DEFAULT, 
	YES_DEFAULT = wx.wxYES_DEFAULT,
	NO_DEFAULT  = wx.wxNO_DEFAULT,
	YES         = wx.wxYES,
	NO          = wx.wxNO,
	OK 		    = wx.wxOK, 
}

-- int wxMessageBox(const wxString& message, const wxString& caption = "Message", int style = wxOK | wxCENTRE, wxWindow *parent = NULL, int x = -1, int y = -1 ); 
function lide.core.base.messagebox ( message, caption, style, pos_x, pos_y, parent)
	return wx.wxMessageBox(message or "", caption or "Message", style or wx.wxOK + wx.wxCENTRE, parent or wx.NULL, pos_x or -1, pos_y or -1 )	
end


local function normalizePath ( path )
	if lide.platform.getOSName() == 'Linux' then
		return path:gsub('\\', '/');
	elseif lide.platform.getOSName() == 'Windows' then
		return path:gsub('/', '\\');
	end
end


-- Import classes to the framework:
lide.classes = require 'lide.classes.init'

arch     = lide.platform.getArch ()         --'x86' -- x64, arm7
platform = lide.platform.getOS () : lower() -- linux, macosx

lua_dir = ( lide.app.getWorkDir() .. '\\lua\\%s\\%s\\?.lua;'):format(platform, arch) ..
          ( lide.app.getWorkDir() .. '\\lua\\%s\\?.lua;'):format(platform) ..
          ( lide.app.getWorkDir() .. '\\lua\\?.lua;') .. -- Crossplatform: root\lua\package.lua
          ( os.getenv 'LIDE_PATH' .. '\\libraries\\%s\\%s\\lua\\?.lua;'):format(platform, arch) ..
          ( os.getenv 'LIDE_PATH' .. '\\libraries\\%s\\lua\\?.lua;'):format(platform) ..
          ( os.getenv 'LIDE_PATH' .. '\\libraries\\lua\\?.lua;').. -- Crossplatform: libraries\lua\package.lua

          ( os.getenv 'LIDE_PATH' .. '\\libraries\\%s\\%s\\lua\\?\\init.lua;'):format(platform, arch) ..
          ( os.getenv 'LIDE_PATH' .. '\\libraries\\%s\\lua\\?\\init.lua;'):format(platform) ..
          ( os.getenv 'LIDE_PATH' .. '\\libraries\\lua\\?\\init.lua;') -- Crossplatform: libraries\lua\package.lua

clibs_dir=( lide.app.getWorkDir() .. '\\clibs\\%s\\%s\\?.dll;'):format(platform, arch) ..
          ( lide.app.getWorkDir() .. '\\clibs\\%s\\?.dll;'):format(platform) ..
          ( os.getenv 'LIDE_PATH' .. '\\libraries\\%s\\%s\\clibs\\?.dll;'):format(platform, arch) ..
          ( os.getenv 'LIDE_PATH' .. '\\libraries\\%s\\clibs\\?.dll;'):format(platform)

package.path   = lua_dir
package.cpath  = clibs_dir

return lide