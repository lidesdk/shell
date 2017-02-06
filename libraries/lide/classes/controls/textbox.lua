-- /////////////////////////////////////////////////////////////////////////////
-- // Name:        lide/classes/controls/textbox.lua
-- // Purpose:     Textbox class
-- // Author:      Dario Cano [thdkano@gmail.com]
-- // Created:     2016/03/20
-- // Copyright:   (c) 2014-2016 Dario Cano
-- // License:     lide license
-- /////////////////////////////////////////////////////////////////////////////
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

-- import local functions:
local isString = lide.core.base.isstring

-- import libraries
local check = lide.core.base.check

-- import required classes
local TextCtrl = lide.classes.controls.textctrl

local Textbox = class 'Textbox' : subclassof 'TextCtrl' : global (false)

function Textbox:Textbox ( fields )
	-- check for fields required by constructor:
	check.fields { 
	 	'string Name', 'object Parent', --> text is not required 'string Text'
	}
	
	-- define class fields
	private {
		DefaultPosition = { X = -1, Y = -1 }, 
		DefaultSize     = { Width = -1, Height = -1 },
		DefaultFlags    = TC_LEFT + TC_PROCESS_ENTER,
	}
   
    fields.Text = fields.Text or '' --> '' >> text is not required
	
    --- call TextCtrl constructor
	self.super : init ( fields )
	
    if fields.Font and isString(fields.Font) then
        self:setFont(fields.Font, -1)
    end
    
	--- 
    --- initialize object events:
    ---

	self:initializeEvents {
        'onKeyDown', 'onKeyUp', 'onMotion', 'onLeftDown', 'onLeftUp', 'onLeftDoubleClick'
	}

end

function Textbox:getText( ... )
    return self:getwxObj():GetRange(0, self:getwxObj():GetLastPosition())
end

function Textbox:setText( sText )
    isString(sText)
    self:getwxObj():SetSelection(0, self:getwxObj():GetLastPosition())
    self:getwxObj():WriteText( sText )
    self:getwxObj():SetSelection(self:getwxObj():GetLastPosition(), self:getwxObj():GetLastPosition())
end

return Textbox

--[[
enum wxKeyCode
{

    WXK_ADD,
    WXK_ALT,
    WXK_BACK,
    WXK_CANCEL,
    WXK_CAPITAL,
    WXK_CLEAR,
    WXK_CONTROL,
    WXK_DECIMAL,
    WXK_DELETE,
    WXK_DIVIDE,
    WXK_DOWN,
    WXK_END,
    WXK_ESCAPE,
    WXK_EXECUTE,
    WXK_F1,
    WXK_F10,
    WXK_F11,
    WXK_F12,
    WXK_F13,
    WXK_F14,
    WXK_F15,
    WXK_F16,
    WXK_F17,
    WXK_F18,
    WXK_F19,
    WXK_F2,
    WXK_F20,
    WXK_F21,
    WXK_F22,
    WXK_F23,
    WXK_F24,
    WXK_F3,
    WXK_F4,
    WXK_F5,
    WXK_F6,
    WXK_F7,
    WXK_F8,
    WXK_F9,
    WXK_HELP,
    WXK_HOME,
    WXK_INSERT,
    WXK_LBUTTON,
    WXK_LEFT,
    WXK_MBUTTON,
    WXK_MENU,
    WXK_MULTIPLY,
    //WXK_NEXT = WXK_PAGEDOWN since 2.6
    WXK_NUMLOCK,
    WXK_NUMPAD_ADD,
    WXK_NUMPAD_BEGIN,
    WXK_NUMPAD_DECIMAL,
    WXK_NUMPAD_DELETE,
    WXK_NUMPAD_DIVIDE,
    WXK_NUMPAD_DOWN,
    WXK_NUMPAD_END,
    WXK_NUMPAD_ENTER,
    WXK_NUMPAD_EQUAL,
    WXK_NUMPAD_F1,
    WXK_NUMPAD_F2,
    WXK_NUMPAD_F3,
    WXK_NUMPAD_F4,
    WXK_NUMPAD_HOME,
    WXK_NUMPAD_INSERT,
    WXK_NUMPAD_LEFT,
    WXK_NUMPAD_MULTIPLY,
    // WXK_NUMPAD_NEXT = WXK_NUMPAD_PAGEDOWN since 2.6
    WXK_NUMPAD_PAGEDOWN,
    WXK_NUMPAD_PAGEUP,
    // WXK_NUMPAD_PRIOR = WXK_NUMPAD_PAGEUP since 2.6
    WXK_NUMPAD_RIGHT,
    WXK_NUMPAD_SEPARATOR,
    WXK_NUMPAD_SPACE,
    WXK_NUMPAD_SUBTRACT,
    WXK_NUMPAD_TAB,
    WXK_NUMPAD_UP,
    WXK_NUMPAD0,
    WXK_NUMPAD1,
    WXK_NUMPAD2,
    WXK_NUMPAD3,
    WXK_NUMPAD4,
    WXK_NUMPAD5,
    WXK_NUMPAD6,
    WXK_NUMPAD7,
    WXK_NUMPAD8,
    WXK_NUMPAD9,
    WXK_PAGEDOWN,
    WXK_PAGEUP,
    WXK_PAUSE,
    WXK_PRINT,
    // WXK_PRIOR = WXK_PAGEUP since 2.6
    WXK_RBUTTON,
    WXK_RETURN,
    WXK_RIGHT,
    WXK_SCROLL,
    WXK_SELECT,
    WXK_SEPARATOR,
    WXK_SHIFT,
    WXK_SNAPSHOT,
    WXK_SPACE,
    WXK_START,
    WXK_SUBTRACT,
    WXK_TAB,
    WXK_UP

}; 
]]