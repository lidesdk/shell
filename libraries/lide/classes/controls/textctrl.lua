-- /////////////////////////////////////////////////////////////////////////////
-- // Name:        lide/classes/controls/textctrl.lua
-- // Purpose:     TextCtrl class
-- // Author:      Dario Cano [thdkano@gmail.com]
-- // Modified by:
-- // Created:     07/07/2014
-- // Copyright:   (c) 2014 Dario Cano
-- // License:     lide license
-- /////////////////////////////////////////////////////////////////////////////
--
-- Class constructor:
--
--  object TextCtrl:new { 
--  	string Name  ,		The control name.
--		object Parent,		The control parent.
--		string Text  , 		The button text.
--	}
-- 

-- set TextCtrl constants:
enum {
	TC_MULTILINE = wx.wxTE_MULTILINE,
	TC_READONLY  = wx.wxTE_READONLY,
	TC_BESTWRAP  = wx.wxTE_BESTWRAP,  --> default
	
	TC_NOVSCROLL = wx.wxTE_NO_VSCROLL, --> ONLY MULTILINED
	
	--Only Win32:
	TC_NOHIDESEL = wx.wxTE_NOHIDESEL,
	--TC_RICHTEXT = wx.wxTE_RICH  (DEPRECATED BY TE_RICH2) --> Only Win32?  
	TC_RICHTEXT = wx.wxTE_RICH2,   --> Only Win32?
	
	-- text relative:
	TC_LEFT 	= wx.wxTE_LEFT,  --> default
	TC_RIGHT    = wx.wxTE_RIGHT,
	TC_CENTRE   = wx.wxTE_CENTRE,
	TC_AUTOURL  = wx.wxTE_AUTO_URL, --> only wxgtk2 multiline, win32 and richtext
	TC_DONTWRAP = wx.wxTE_DONTWRAP,
	TC_PASSWORD = wx.wxTE_PASSWORD,
	
	-- events relative:
	TC_PROCESS_ENTER = wx.wxTE_PROCESS_ENTER,
	TC_PROCESS_TAB   = wx.wxTE_PROCESS_TAB,
	
	--wxUniv and wxGTK2 Only:
	TC_CHARWRAP = wx.wxTE_CHARWRAP,
	TC_WORDWRAP = wx.wxTE_WORDWRAP,
	
	-- PocketPC and Smartphone:
	TC_CAPITALIZE = wx.wxTE_CAPITALIZE,
	
	-- enum wxTextCtrlHitTestResult :
	TC_HT_UNKNOWN = wx.wxTE_HT_UNKNOWN,
	TC_HT_BEFORE  = wx.wxTE_HT_BEFORE,
	TC_HT_ON_TEXT = wx.wxTE_HT_ON_TEXT,
	TC_HT_BELOW   = wx.wxTE_HT_BELOW,
	TC_HT_BEYOND  = wx.wxTE_HT_BEYOND,
}

-- import libraries
local check = lide.core.base.check

-- import local functions:
local isString = lide.core.base.isstring
local isNumber = lide.core.base.isnumber
local isObject = lide.core.base.isobject

-- import required classes
local Control = lide.classes.widgets.control

-- define class:
local TextCtrl = class 'TextCtrl' : subclassof 'Control' : global(false)


function TextCtrl:TextCtrl( fields )	
	-- check for fields required by constructor:
	check.fields { 
	 	'string Name', 'object Parent', 'string Text'
	}
	
	-- define class fields
	private {
		DefaultPosition = { X = -1, Y = -1 }, 
		DefaultSize     = { Width = -1, Height = -1 },
		DefaultFlags    = wx.wxTE_LEFT,

		_MaxLength = isNumber(fields.MaxLength or -1 )
	}

	protected {
		Text  = fields.Text,
		Flags = fields.Flags and isNumber(fields.Flags),
	}

	-- call Control constructor
	self.super : init ( fields.Name, fields.Parent, fields.PosX or self.DefaultPosition.X, fields.PosY or self.DefaultPosition.Y, fields.Width or self.DefaultSize.Width, fields.Height or self.DefaultSize.Height, fields.ID )
	
	-- create wxWidgets object and store it on self.wxObj:
	--print(self.Parent:getwxObj())
	self.wxObj = wx.wxTextCtrl(self.Parent:getwxObj(), self.ID, self.Text, wx.wxPoint( self.PosX, self.PosY ), wx.wxSize( self.Width, self.Height ), self.Flags or self.DefaultFlags)
	self:getwxObj():SetName(self.Name)
	
	if fields.Font then
		self:setFont( fields.Font, -1 )
	end
	
	-- registry event onKey
	--self:initializeEvents {
		--'onLeftUp', 'onLeftDown',
		--'onChar', 
        --'onKeyDown', 'onKeyUp',
        --'onKeyEnter',
        --'onTextEnter'
	--}
end

-- load the whole file to a textctrl
--I bool LoadFile(const wxString& filename)
function TextCtrl:loadFile( sFilename )
	local File = lide.core.File
	if isString(sFilename) and File.doesExists( sFilename ) then
		return self:getwxObj():LoadFile( sFilename )
	else
		return false, 'The File doesn\'t exists.'
	end
end

--- Saves the contents of the control in a text file.
--I  bool SaveFile(const wxString& filename)
function TextCtrl:saveFile( sFilename )
	local File = lide.core.File
	if isString(sFilename) and not File.doesExists( sFilename ) then
		return self:getwxObj():SaveFile(sFilename)
	else
		return false, 'The File can\'t exists.'
	end
	
end

--- Replace a region of text with another string.
--I  virtual void Replace(long from, long to, const wxString& value)
function TextCtrl:replace( nFrom, nTo, sText )
	isNumber(nFrom); isNumber(nTo); isString(sText)
	self:getwxObj():Replace(nFrom, nTo, sText)
end

--- Removes the text starting at the first given position up to (but not including) the character at 
---	the last position.  
--I  virtual void Remove(long from, long to)
function TextCtrl:remove( nFrom, nTo )
	isNumber(nFrom); isNumber(nTo)
	self:getwxObj():Remove(From, To)
end

--- Converts given position to a zero-based column, line number pair. true on success, false on 
--- failure (return bool, number x, number y)
--I  bool PositionToXY(long pos) const
function TextCtrl:positionToXY( nPos )
	isNumber(nPos)
	return self:getwxObj():PositionToXY( nPos )
end

--- Converts the given zero based column and line number to a position.
--I long XYToPosition(long x, long y)
function TextCtrl:xyToPosition( nX, nY )
	isNumber(nX); isNumber(nY)
	return self:getwxObj():XYToPosition(nX, nY)
end

-- Getters:

--- Gets the current selection span.
--I  virtual void GetSelection() const
function TextCtrl:getSelection()
	local nFrom, nTo = self:getwxObj():GetSelection() 
	return nFrom, nTo
end

---  Gets the text currently selected in the control. If there is no selection, the returned string 
---	 is empty.
--I  virtual wxString GetStringSelection()
function TextCtrl:getStringSelection() --> Gets the current selection span. 
	return self:getwxObj():GetStringSelection() 
end

---  Gets the length of the specified line, not including any trailing newline character(s).
--I  int GetLineLength(long lineNo) const
function TextCtrl:getLineLength( nLineNumber )
	isNumber(nLineNumber)
	return self:getwxObj():GetLineLength( nLineNumber )
end
 
--- Returns the contents of a given line in the text control, not including any trailing newline 
---	character(s).
--I wxString GetLineText(long lineNo) const
function TextCtrl:getLineText( nLineNumber )
	isNumber(nLineNumber)
	return self.wxObj:GetLineText(nLineNumber)
end

--- Returns the number of lines in the text control buffer. 
--I  int GetNumberOfLines() const
function TextCtrl:getNumberOfLines( nLineNumber )
	isNumber(nLineNumber)
	return self:getwxObj():GetNumberOfLines(nLineNumber)
end

--- Returns true if the controls contents may be edited by user (note that it always can be changed 
---	by the program), i.e. if the control hasn't been put in read-only mode by a previous call to 
---	setEditable.
--I bool IsEditable() const
function TextCtrl:isEditable()
	return self:getwxObj():IsEditable()
end

--- Returns true if the text has been modified by user. Note that calling SetValue doesn't make the 
--- control modified.
--I bool IsModified() const
function TextCtrl:isModified()
	return self:getwxObj():IsModified() 
end

---	Returns true if this is a multi line edit control and false otherwise.	
--I bool IsMultiLine() const
function TextCtrl:isMultiline()
	return self:getwxObj():IsMultiLine() 
end

--- Returns true if this is a single line edit control and false otherwise.	
--I bool IsSingleLine() const
function TextCtrl:isSingleLine()
	return self:getwxObj():IsSingleLine() 
end

--Setters:

--- Sets the maximum number of characters the user can enter into the control. 
--I virtual void SetMaxLength(unsigned long value)
function TextCtrl:setMaxLength( nMaxLength )
	isNumber(nMaxLength)
	self:getwxObj():SetMaxLength(nMaxLength)
end

--- Selects the text starting at the first position up to (but not including) the character at the 
--- last position. 
--I  virtual void SetSelection(long from, long to)
function TextCtrl:setSelection( nFrom, nTo )
	isNumber(nFrom); isNumber(nTo)
	self:getwxObj():SetFocus() 
	self:getwxObj():SetSelection(nFrom, nTo) 
end


--- Makes the text item editable or read-only, overriding the wxTE_READONLY flag.
--I  virtual void SetEditable(bool editable)
function TextCtrl:setEditable( bEditable )
	if(bEditable == nil)then bEditable = true end
	isBoolean(bEditable)
	self:getwxObj():SetEditable(bEditable) 
end

--- Returns true if the selection can be cut to the clipboard.
-- virtual bool CanCut()
function TextCtrl:canCut()
	return self:getwxObj():CanCut()
end

--- Returns true if the selection can be copied to the clipboard.
-- virtual bool CanCopy()
function TextCtrl:canCopy( )
	return self:getwxObj():CanCopy()
end

---  Returns true if the contents of the clipboard can be pasted into the text control. On some 
---  platforms (Motif, GTK) this is an approximation and returns true if the control is editable, 
---  false otherwise.
-- virtual bool CanPaste()
function TextCtrl:canPaste(  )
	return self:getwxObj():CanPaste()
end

--- Returns true if there is an undo facility available and the last operation can be undone.
-- virtual bool CanUndo()
function TextCtrl:canUndo()
	return self:getwxObj():CanUndo()
end

--- Returns true if there is a redo facility available and the last operation can be redone.
-- virtual bool CanRedo()
function TextCtrl:canRedo()
	return self:getwxObj():CanRedo()
end

--- Copies to the clipboard the text from 'nFrom' to 'nTo' and removes the selection.
-- virtual void Cut()
function TextCtrl:cutToClipboard( nFrom, nTo )
	isNumber(nFrom); isNumber(nTo)

	self:setSelection(nFrom, nTo)
	self:getwxObj():Cut()
end
 
--- Copies to the clipboard the text between 'nFrom' to 'nTo'.
-- virtual void Copy()
function TextCtrl:copyToClipboard( nFrom, nTo )
	isNumber(nFrom); isNumber(nTo)

	self:setSelection(nFrom, nTo)
	self:getwxObj():Copy()
end

--- Returns true if the contents of the clipboard can be pasted into the text control.
--I  virtual void Paste()
function TextCtrl:pasteFromClipboard( nFrom, nTo )
	isNumber(nFrom); isNumber(nTo)

	self:setSelection(nFrom, nTo)
	self:getwxObj():Paste()
end

--- If there is an undo facility and the last operation can be undone, undoes the last operation.
--- Does nothing if there is no undo facility. 
--I  virtual void Undo()
function TextCtrl:undo()
	self:getwxObj():Undo()
end

--- If there is a redo facility and the last operation can be redone, redoes the last operation.
--- Does nothing if there is no redo facility. 
--I  virtual void Redo()
function TextCtrl:redo()
	self:getwxObj():Redo()
end


---	Appends the text to the end of the text control. 
---
--- After the text is appended, the insertion point will be at the end of the text control. 
--- If this behaviour is not desired, the programmer should use getInsertionPoint() and setInsertionPoint().
--void AppendText(const wxString& text)
function TextCtrl:appendText( sText )
	isString(sText)
	self:getwxObj():AppendText(sText)
end

---	Clears the text in the control.
--- Note that this function will generate a wxEVT_TEXT event, i.e. its effect is identical to 
--- calling SetValue(""). 
-- virtual void Clear()
function TextCtrl:clear()
	self.wxObj:Clear()
end

--- Resets the internal modified flag as if the current changes had been saved.
-- void DiscardEdits()
function TextCtrl:discardEdits()
	return self:getwxObj():DiscardEdits()
end

--- Mark text as modified (dirty). 
-- void MarkDirty()
function TextCtrl:markDirty()
	self:getwxObj():MarkDirty()
end

--- Returns the insertion point. This is defined as the zero based index of the character position 
--- to the right of the insertion point. For example, if the insertion point is at the end of the 
--- text control, it is equal to both GetValue().Length() and GetLastPosition().
--  virtual long GetInsertionPoint() const
function TextCtrl:getInsertionPoint()
	return self:getwxObj():GetInsertionPoint()
end

---  Returns the zero based index of the last position in the text control, which is equal to the number of characters in the control.
--  virtual long GetLastPosition() const
function TextCtrl:getLastPosition()
	return self:getwxObj():GetLastPosition()
end

---	Returns the string containing the text starting in the positions from and up to to in the control. 
---	The positions must have been returned by another wxTextCtrl method.
---
---	Please note that the positions in a multiline wxTextCtrl do not correspond to the indices in the 
---	string returned by GetValue because of the different new line representations (CR or CR LF) and 
---	so this method should be used to obtain the correct results instead of extracting parts of the 
---	entire value. It may also be more efficient, especially if the control contains a lot of data.
--  virtual wxString GetRange(long from, long to)

TextCtrl:virtual 'getRange'

function TextCtrl:getRange( nFrom, nTo )
	isNumber(nFrom) isNumber(nTo)
	return self:getwxObj():GetRange(nFrom, nTo)
end

--- Sets the insertion point at the given position.
--  virtual void SetInsertionPoint(long pos)
function TextCtrl:setInsertionPoint( nPos )
	isNumber(nPos)
	self.wxObj:SetInsertionPoint(nPos)
end

--- Sets the insertion point at the end of the text control. This is equivalent to SetInsertionPoint(GetLastPosition()).
--  virtual void SetInsertionPointEnd()
function TextCtrl:setInsertionPointEnd()
	self.wxObj:SetInsertionPointEnd()
end

--- Writes the text into the text control at the current insertion position.
--- Remarks
--- Newlines in the text string are the only control characters allowed, and they will cause appropriate 
--- line breaks. See wxTextCtrl::<< and wxTextCtrl::AppendText for more convenient ways of writing 
---	to the window.
--- After the write operation, the insertion point will be at the end of the inserted text, so 
--- subsequent write operations will be appended. To append text after the user may have interacted 
---	with the control, call wxTextCtrl::SetInsertionPointEnd before writing.
--  void WriteText(const wxString& text)
TextCtrl : virtual 'writeText'
function TextCtrl:writeText( sText )
	isString(sText)
	self.wxObj:WriteText(sText)
end

--- Makes the line containing the given position visible.
--  void ShowPosition(long pos)
function TextCtrl:showPosition( nPos )
	self.wxObj:showPosition( nPos )
end

--[[
function TextCtrl:GetText( ... )
	return self.wxObj:GetRange(0, self.wxObj:GetLastPosition())
end

-- ==SetText  virtual void SetValue(const wxString& value)
if Platform.OperatingSystemIdName == 'Linux' then

function TextCtrl:SetText( value )
	self.wxObj:SetValue( value or '' )
end

end
]]

return TextCtrl

-- In base clasess:
-- ==GetText wxString GetValue() const
-- ==SetText  virtual void ChangeValue(const wxString& value)
-- ==SetText  virtual void SetValue(const wxString& value)

--  bool EmulateKeyPress(const wxKeyEvent& event)
--  const wxTextAttr& GetDefaultStyle() const
--  bool GetStyle(long position, wxTextAttr& style)
-- wxTextCtrlHitTestResult HitTest(const wxPoint& pt) const
-- // %override [wxTextCtrlHitTestResult, int pos] wxTextCtrl::HitTestPos(const wxPoint& pt)
-- // C++ Func: wxTextCtrlHitTestResult HitTest(const wxPoint& pt, long *pos) const
-- %rename HitTestPos wxTextCtrlHitTestResult HitTest(const wxPoint& pt) const
-- //void OnDropFiles(wxDropFilesEvent& event)
-- // %override [bool, int x, int y] wxTextCtrl::PositionToXY(pos)
-- // C++ Func: bool PositionToXY(long pos, long *x, long *y) const
--  bool SetDefaultStyle(const wxTextAttr& style)
--  bool SetStyle(long start, long end, const wxTextAttr& style)