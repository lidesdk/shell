-- /////////////////////////////////////////////////////////////////////////////
-- // Name:        classes/control/grid.lua
-- // Purpose:     Grid class
-- // Author:      Dario Cano [thdkano@gmail.com]
-- // Created:     2014/07/22
-- // Copyright:   (c) 2014 Dario Cano
-- // License:     lide license
-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--- Grid selection modes:
--- deprecated by line:73 Grid:enum
enum {
	GRID_SELMODE_CELLS   = wx.wxGrid.wxGridSelectCells,
	GRID_SELMODE_ROWS    = wx.wxGrid.wxGridSelectRows,
	GRID_SELMODE_COLUMNS = wx.wxGrid.wxGridSelectColumns,
}


-- import libraries
local check = lide.core.base.check

-- import local functions:
local isObject  = lide.core.base.isobject
local isBoolean = lide.core.base.isboolean
local isString  = lide.core.base.isstring
local isNumber  = lide.core.base.isnumber

-- import required classes
local Font   = lide.classes.font
local Control = lide.classes.control


local Grid = class 'Grid' : subclassof 'Control' : global ( false )

Grid : enum {

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

--- Grid selection modes:
Grid : enum {
	
	GRID_SELMODE_CELLS   = wx.wxGrid.wxGridSelectCells,
	GRID_SELMODE_ROWS    = wx.wxGrid.wxGridSelectRows,
	GRID_SELMODE_COLUMNS = wx.wxGrid.wxGridSelectColumns,
}

function Grid:Grid ( fields )
	 
	fields.Flags      = fields.Flags or 0
	fields.Editing    = fields.Editing or false
	fields.ResizeCols = fields.ResizeCols or false
	fields.ResizeRows = fields.ResizeRows or false
	fields.GridLines  = (fields.GridLines == nil) or fields.GridLines

	-- check for fields required by constructor:
	check.fields { 
	 	'string Name', 'object Parent'
	}

	--self:Nofields "Control.Text Control.Font"
		-- define class fields
	private {
		DefaultPosition = { X = -1, Y = -1 }, 
		DefaultSize     = { Width = -1, Height = -1 },

		Flags = isNumber(fields.Flags) or -1,
		SelectMode = fields.SelectMode or GRID_SELMODE_CELLS,
	}

	self.super : init ( fields.Name, fields.Parent, fields.PosX or self.DefaultPosition.X, fields.PosY or self.DefaultPosition.Y, fields.Width or self.DefaultSize.Width, fields.Height or self.DefaultSize.Height, fields.ID )
	
	self.wxObj = wx.wxGrid(self.Parent:getwxObj(), self.ID, wx.wxPoint( self.PosX, self.PosY ), wx.wxSize( self.Width, self.Height ), self.Flags, self.Name)
	
	local nRows, nCols = fields.Rows or 7, fields.Columns or 7
	
	-- Grid
	if not fields.NotGrid then
		self.wxObj:CreateGrid( nRows, nCols, self.SelectMode )
	end

	self.wxObj:EnableEditing( fields.Editing )
	self.wxObj:EnableGridLines( fields.GridLines )
	
	-- Columns
	self.wxObj:EnableDragColSize( fields.ResizeCols )
	
	-- Rows
	self.wxObj:EnableDragRowSize( fields.ResizeRows )
	
	-- Cell Defaults
	self.wxObj:SetDefaultCellAlignment( wx.wxALIGN_LEFT, wx.wxALIGN_TOP )

	-- Set Flags:
	self.SelectionMode = fields.SelectMode

	-- Grid Events:
	--> self.Events.OnCellChanged = wx.wxEVT_GRID_CELL_CHANGE
	--> self.Events.OnSelectCell = wx.wxEVT_GRID_SELECT_CELL
	--self.Events.OnCellClick = wx.wxEVT_GRID_CELL_LEFT_CLICK
	
--[[

	self:InitGridEvents {
		"OnCellClick",
		"OnCellDoubleClick"
	}]]
end

----------------------------------------------------------------
--> Constructors and Initialization

-- bool ProcessTableMessage( wxGridTableMessage& msg ); 

-- // %override so that takeOwnership releases the table from garbage collection by Lua 
-- bool SetTable( wxGridTableBase * table, bool takeOwnership = false, wxGrid::wxGridSelectionModes selmode = wxGrid::wxGridSelectCells ); 
-- bool SetTable( wxGridTableBase * table, bool takeOwnership = false, wxGrid::wxGridSelectionModes selmode = wxGrid::wxGridSelectCells ); 

function Grid:getTable( table, auto_size, takeOwnership, selmode )
	return self.wxObj:GetTable()
end


function Grid:setTable( table, auto_size, takeOwnership, selmode )
	if (takeOwnership == nil) then
		takeOwnership = false
	end
	
	--io.stdout:write (('%s\n'):format( tostring ( self.wxObj ) )) 

	local ret --=  assert(self.wxObj:SetTable(table:getwxObj(), takeOwnership, selmode or self.SelectionMode))
	local x, e = pcall(self.wxObj.SetTable, self.wxObj, table:getwxObj() )
	
	if not x then
		printf('error en grid: %s', e)
	else
		ret = e
	end

	if auto_size then
		self:getwxObj():AutoSizeColumns()
		self:getwxObj():AutoSizeRows()
	end

	self.GridTable = table

	return ret
end

--< Constructors and Initialization
----------------------------------------------------------------


----------------------------------------------------------------
--> Cell Formatting

-- void SetDefaultCellFont( const wxFont& cellFont ); 
function Grid:setDefaultCellFont( sFontFamily, nFontSize, sFontFlags )
	isString(sFontFamily) isNumber(nFontSize)

	-- Make a new font object:
	local oFont = Font:new (sFontFamily, nFontSize, sFontFlags)

	self:getwxObj():SetDefaultCellFont(oFont:getwxObj())
end

-- void SetCellFont( int row, int col, const wxFont& cellFont ); 
function Grid:setCellFont( nRow, nCol, sFontFamily, nFontSize, sFontFlags )
	isNumber(nRow) isNumber(nCol) isString(sFontFamily) isNumber(nFontSize)
	
	-- Make a new font object:
	local oFont = Font:new (sFontFamily, nFontSize, sFontFlags or '')

	self:getwxObj():SetCellFont(nRow, nCol, oFont:getwxObj())
end

-- void SetDefaultCellAlignment( int horiz, int vert ); 
function Grid:setDefaultCellAlignment( nHoriz, nVert )
	isNumber(nHoriz) isNumber(nVert)
	self:getwxObj():SetDefaultCellAlignment( nHoriz, nVert )
end

-- void SetCellAlignment( int row, int col, int horiz, int vert ); 
function Grid:setCellAlignment( nRow, nCol, nHoriz, nVert )
	isNumber(nHoriz) isNumber(nVert) isNumber(nRow) isNumber(nCol)

	self:getwxObj():SetDefaultCellAlignment(nRow, nCol, nHoriz, nVert)
end


---------------------------------------------------------------
--> Label Values and Formatting

-- int GetRowLabelSize( ); 
function Grid:getRowLabelSize()
	return self:getwxObj():GetRowLabelSize()
end

-- int GetColLabelSize( ); 
function Grid:getColLabelSize()
	return self:getwxObj():GetColLabelSize()
end

-- wxString GetRowLabelValue( int row ); 
function Grid:getRowLabel( nRow )
	return self:getwxObj():GetRowLabelValue(	isNumber(nRow) )
end

-- wxString GetColLabelValue( int col ); 
function Grid:getColLabel( nCol )
	isNumber(nCol)
	return self:getwxObj():GetColLabelValue(nCol)
end

-- void SetRowLabelValue( int row, const wxString& value ); 
function Grid:setRowLabel( nRow, sText )
	isNumber(nRow) isString(sText)
	self:getwxObj():SetRowLabelValue(nRow, sText)
end

-- void SetColLabelValue( int col, const wxString& value ); 
function Grid:setColLabel( nCol, sText )
	isNumber(nCol) isString(sText)
	self:getwxObj():SetColLabelValue(nCol, sText)
end

-- void SetRowLabelSize( int width ); 
function Grid:setRowLabelSize( nWidth )
	isNumber(nWidth)
	self:getwxObj():SetRowLabelSize(nWidth)
end

-- void SetColLabelSize( int height ); 
function Grid:setColLabelSize( nHeight )
	isNumber(nHeight)
	self:getwxObj():SetColLabelSize(nHeight)
end

-- int GetDefaultRowLabelSize( ); 

-- int GetDefaultColLabelSize( ); 


-- void SetLabelBackgroundColour( const wxColour& backColour ); 
-- void SetLabelTextColour( const wxColour& textColour ); 
-- void SetLabelFont( const wxFont& labelFont ); 
-- void SetRowLabelAlignment( int horiz, int vert ); 
-- void SetColLabelAlignment( int horiz, int vert ); 

-- wxColour GetLabelBackgroundColour( ); 
-- wxColour GetLabelTextColour( ); 
-- wxFont GetLabelFont( ); 
-- // %override [int horiz, int vert] wxGrid::GetRowLabelAlignment( ); 
-- // C++ Func: void GetRowLabelAlignment( int *horiz, int *vert ); 
-- void GetRowLabelAlignment( int *horz, int *vert ); 
-- // %override [int horiz, int vert] wxGrid::GetColLabelAlignment( ); 
-- // C++ Func: void GetColLabelAlignment( int *horiz, int *vert ); 
-- void GetColLabelAlignment( int *horz, int *vert ); 

-- int GetColLabelTextOrientation( ); 


--< Label Values and Formatting
----------------------------------------------------------------

----------------------------------------------------------------
--> Column and Row Sizes

-- void AutoSize( );
function Grid:autoSize()
	return self.wxObj:AutoSize()
end

-- void AutoSizeColumn( int col, bool setAsMin = true ); 
function Grid:autoSizeColumn( Col, SetAsMin)
	return self.wxObj:AutoSizeColumn(Col, SetAsMin)
end

-- void AutoSizeColumns( bool setAsMin = true ); 
function Grid:autoSizeColumns( setAsMin)
	return self.wxObj:AutoSizeColumns(setAsMin)
end

-- void AutoSizeRow( int row, bool setAsMin = true ); 
function Grid:autoSizeRow( Row, SetAsMin)
	return self.wxObj:AutoSizeRow(Row, SetAsMin)
end

-- void AutoSizeRows( bool setAsMin = true ); 
function Grid:autoSizeRows( setAsMin )
	return self.wxObj:AutoSizeRows(setAsMin)
end

-- void AutoSizeRowLabelSize( int row ); 
function Grid:autoSizeRowLabelSize( Row )
	return self.wxObj:AutoSizeRow(Row)
end

-- void AutoSizeColLabelSize( int col ); 
function Grid:autoSizeColLabelSize( Col )
	return self.wxObj:AutoSizeColLabelSize(Col)
end

-- int GetColSize( int col );
function Grid:getColSize( Col )
	return self.wxObj:GetColSize(Col)
end

-- int GetRowSize( int row ); 
function Grid:getRowSize( Row )
	self.wxObj:GetRowSize(Row)
end

-- void SetColSize( int col, int width ); 
function Grid:setColSize( Col, Width)
	self.wxObj:SetColSize(Col, Width)
end

-- void SetRowSize( int row, int height ); 
function Grid:setRowSize( Row, Height)
	self.wxObj:SetRowSize(Row, Height)
end

-- // %override [int num_rows, int num_cols] wxGrid::GetCellSize( int row, int col ); 
-- // C++ Func: void GetCellSize( int row, int col, int *num_rows, int *num_cols ); 
-- void GetCellSize( int row, int col ); 
function Grid:getCellSize( row, col )
	self.wxObj:GetCellSize(row,col)
end

-- void SetCellSize( int row, int col, int num_rows, int num_cols ); 	
function Grid:setCellSize( row, col, num_rows, num_cols )
	self.wxObj:SetCellSize(row, col, num_rows, num_cols)
end


-- bool GetDefaultCellOverflow( ); 
-- bool GetCellOverflow( int row, int col ); 
-- void SetDefaultRowSize( int height, bool resizeExistingRows = false ); 
-- void SetDefaultColSize( int width, bool resizeExistingCols = false ); 
-- void SetDefaultCellOverflow( bool allow ); 
-- void SetCellOverflow( int row, int col, bool allow ); 

-- void SetColMinimalWidth( int col, int width ); 
-- void SetRowMinimalHeight( int row, int width ); 
-- void SetColMinimalAcceptableWidth( int width ); 
-- void SetRowMinimalAcceptableHeight( int width ); 
-- int GetColMinimalAcceptableWidth() const; 
-- int GetRowMinimalAcceptableHeight() const; 

-- int GetDefaultRowSize( ); 
-- int GetDefaultColSize( ); 
--< Column and Row Sizes
----------------------------------------------------------------


function Grid:forceRefresh( )
	self.wxObj:ForceRefresh()
end

return Grid