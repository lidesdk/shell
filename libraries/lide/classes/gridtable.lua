-- /////////////////////////////////////////////////////////////////////////////
-- // Name:        controls/gridtable.lua
-- // Purpose:     Grid Table class
-- // Author:      Dario Cano [thdkano@gmail.com]
-- // Modified by:
-- // Created:     27/07/2014
-- // Copyright:   (c) 2014 Dario Cano
-- // License:     lide license
-- /////////////////////////////////////////////////////////////////////////////

local GridTable, Object

---
--- import required classes:
Object = lide.classes.objects

--- define class
GridTable = class 'GridTable' : subclassof 'Object'

	: global (false)

-- define internal functions
function GridTable:GridTable( ... ) --> rows, cols
	local query, rows, cols, database, driver
	
	private {
		wxObj = '.none'
	}

	if type(...) == "string" then
		-- try create a table from sql query
		query, database, driver = ...
		self = GridTable_initFromSQL( self, query, database, driver) -- run another constructor
	else
		rows, cols = ...
	    -- wxGridStringTable( int numRows=0, int numCols=0 );
		self.wxObj = wx.wxGridStringTable( rows, cols)
	end
end

function test_query( query, database, driver )
	local env

	if not luasql then
		error "gridtable: no hay driver sql"
	else
		if driver == "oracle" then
			driver = "oci8" --> in luasql oracle driver has the name luasql.oci8
		end
		env = luasql[driver]()
	end
	
		-- create a connection:
	local conn = env:connect(database)
	
	-- create a cursor
	local cur = assert(conn:execute(query))
end

function GridTable_initFromSQL( self, query, database, driver )
	local env, conn, cur, row, col_names, row_name, num_cols, num_rows, grid_table, row_number
	
	if not luasql then
		error "gridtable: no hay driver sql"
	else
		if driver == "oracle" then
			driver = "oci8" --> in luasql oracle driver has the name luasql.oci8
		end
		env = luasql[driver]()
	end

	-- create a connection:
	conn = env:connect(database)
	
	-- create a cursor
	cur = conn:execute(query)

	col_names  = cur:getcolnames()  --> table of strings, contains columns of query result
	num_cols = #col_names			--> get number of columns
	num_rows = 1				    --> initialize rows

	-- create a GridTable object
	if not self.wxObj then
		self.wxObj = wx.wxGridStringTable(num_rows, num_cols)
	else
		self.wxObj:Destroy() self.wxObj = nil
	end
	
	-- set columns labels:
	for col = 1, #col_names do
		local row_name = col_names[col]
		self:getwxObj():SetColLabelValue(col-1, row_name)  -- > wxLua index columns by zero
	end
	
	-- add rows to GridTable object:
	row = cur:fetch ({}, "a")
	while row do
	  	row_number = (row_number or 0) +1
	  	
	  	if row_number > 1 then
	  		self:addRows(1)
	  	end
				
		for col_number=1, #col_names do
			row_name = col_names[col_number]
			self:getwxObj():SetValue( row_number-1, col_number-1, tostring(row[row_name]))
		end
	  	row = cur:fetch (row, "a")
	end

	--
	if cur then cur:close() end
	assert(conn:close())  --> true in case of success and false in case of failure.
	assert(env:close()) --> true in case of success; false when the object is already closed.
end

function GridTable:initFromSQL( query, database, driver )
   test_query(query, database, driver)
   self = GridTable_initFromSQL( self, query, database, driver ) -- run another constructor
end

function GridTable:getwxObj()
	return self.wxObj
end

function GridTable:setwxObj( wxObj )
	self.wxObj = wxObj
end


-- virtual int GetNumberRows( ); 
function GridTable:getNumberRows()
	return self.wxObj:GetNumberRows()
end

-- virtual int GetNumberCols( ); 
function GridTable:getNumberCols()
	return self.wxObj:GetNumberCols()
end

-- virtual bool IsEmptyCell( int row, int col ); 
function GridTable:isEmptyCell( row, col)
	return self.wxObj:IsEmptyCell(row,col)
end

-- virtual wxString GetValue( int row, int col ); 
function GridTable:getValue( row, col )
	return self.wxObj:GetValue(row, col)
end

-- virtual void SetValue( int row, int col, const wxString& value ); 
function GridTable:setValue( row, col, value )
	if value == nil then
		value = ""
	end
	return self.wxObj:SetValue(row, col, tostring(value))
end

-- virtual wxString GetTypeName( int row, int col ); 
function GridTable:getTypeName( row, col )
	return self.wxObj:GetTypeName(row, col)
end

-- virtual bool CanGetValueAs( int row, int col, const wxString& typeName ); 
function GridTable:canGetValueAs( row, col, typeName )
	return self.wxObj:CanGetValueAs( row, col, typeName )
end

-- virtual bool CanSetValueAs( int row, int col, const wxString& typeName ); 
function GridTable:canSetValueAs( row, col, typeName )
	return self.wxObj:CanGetValueAs( row, col, typeName )
end

-- virtual bool GetValueAsBool( int row, int col ); 
function GridTable:getValueAsBool( row, col )
	self.wxObj:GetValueAsBool(row, col)
end

-- virtual long GetValueAsLong( int row, int col ); 
function GridTable:getValueAsLong( row, col )
	self.wxObj:GetValueAsLong(row, col)
end

-- virtual double GetValueAsDouble( int row, int col ); 
function GridTable:getValueAsDouble( row, col )
	self.wxObj:GetValueAsDouble(row, col)
end

-- virtual void SetValueAsBool( int row, int col, bool value ); 
function GridTable:setValueAsBool( row, col, bool )
	self.wxObj:SetValueAsBool(row, col, bool)
end

-- virtual void SetValueAsLong( int row, int col, long value ); 
function GridTable:setValueAsLong( row, col, value)
	self.wxObj:SetValueAsLong(row, col, value)
end

-- virtual void SetValueAsDouble( int row, int col, double value ); 
function GridTable:setValueAsDouble( row, col, value)
	self.wxObj:SetValueAsDouble(row, col, value)
end

-- virtual wxGrid * GetView() const; 
function GridTable:getView()
	self.wxObj:GetView()
end

-- virtual void SetView( wxGrid *grid ); 
function GridTable:setView( grid )
	self.wxObj:SetView()
end

-- virtual void Clear( ); 
function GridTable:clear( )
	self.wxObj:Clear()
end

-- virtual bool InsertRows( size_t pos = 0, size_t numRows = 1 ); 
function GridTable:insertRows( pos, numRows )
	local ret = self.wxObj:InsertRows(pos or 0, numRows or 1)
	--%see self.wxObj:GetView():AutoSize()
	return ret
end

-- virtual bool AppendRows( size_t numRows = 1 ); 
function GridTable:addRows( numRows )
	local ret =  self.wxObj:AppendRows(numRows or 1)
	--%see self.wxObj:GetView():AutoSize()
	return ret
end

-- virtual bool DeleteRows( size_t pos = 0, size_t numRows = 1 ); 
function GridTable:deleteRows( pos, numRows )
	local ret = self.wxObj:DeleteRows(pos or 0, numRows or 1)
	--%see self.wxObj:GetView():AutoSize()
	return ret
end

-- virtual bool InsertCols( size_t pos = 0, size_t numCols = 1 ); 
function GridTable:insertCols( pos, numCols )
	local ret = self.wxObj:InsertCols(pos or 0, numCols or 1)
	--%see self.wxObj:GetView():AutoSize()
	return ret
end

-- virtual bool AppendCols( size_t numCols = 1 ); 
function GridTable:addCols( numCols )
	local ret = self.wxObj:AppendCols(numCols or 1)
	--%see self.wxObj:GetView():AutoSize()
	return ret
end

-- virtual bool DeleteCols( size_t pos = 0, size_t numCols = 1 ); 
function GridTable:deleteCols( pos, numCols )
	local ret = self.wxObj:DeleteCols(pos or 0, numRows or 1)
	--%see self.wxObj:GetView():AutoSize()
	return ret
end

-- virtual wxString GetRowLabelValue( int row ); 
function GridTable:getRowLabelValue( row )
	return self.wxObj:GetRowLabelValue(row)
end

-- virtual wxString GetColLabelValue( int col ); 
function GridTable:getColLabelValue( col )
	return self.wxObj:GetColLabelValue(col)
end

-- virtual void SetRowLabelValue( int row, const wxString& value ); 
function GridTable:setRowLabelValue( row, value )
	self.wxObj:SetRowLabelValue(row, value)
end

-- virtual void SetColLabelValue( int col, const wxString& value ); 
function GridTable:setColLabelValue( col, value )
	self.wxObj:SetColLabelValue(col, value)
end

return GridTable

-- // --------------------------------------------------------------------------- 
-- // wxGridTableBase 

-- class wxGridTableBase : public wxObject //, public wxClientDataContainer 
-- {
-- // no constructor pure virtual base class 

-- void SetAttrProvider(wxGridCellAttrProvider *attrProvider ); 
-- wxGridCellAttrProvider *GetAttrProvider() const; 
-- virtual bool CanHaveAttributes( ); 

-- // wxLua Note: The table calls IncRef() on the returned attribute so wxLua will garbage collect it. 
-- virtual %gc wxGridCellAttr* GetAttr( int row, int col, wxGridCellAttr::wxAttrKind kind ); 

-- // wxLua calls IncRef() on the input attr since the table will call DecRef() on it. 
-- // You should not have to worry about Inc/DecRef() of the attr as you would in C++. 
-- void SetAttr(%IncRef wxGridCellAttr* attr, int row, int col ); 
-- // wxLua calls IncRef() on the input attr since the table will call DecRef() on it. 
-- // You should not have to worry about Inc/DecRef() of the attr as you would in C++. 
-- void SetRowAttr(%IncRef wxGridCellAttr *attr, int row ); 
-- // wxLua calls IncRef() on the input attr since the table will call DecRef() on it. 
-- // You should not have to worry about Inc/DecRef() of the attr as you would in C++. 
-- void SetColAttr(%IncRef wxGridCellAttr *attr, int col ); 
-- }; 

-- // --------------------------------------------------------------------------- 
-- // wxLuaGridTableBase 

-- #include "wxbind/include/wxadv_wxladv.h" 

-- class %delete wxLuaGridTableBase : public wxGridTableBase 
-- {
-- // %override - the C++ function takes the wxLuaState as the first param 
-- wxLuaGridTableBase( ); 

-- // The functions below are all virtual functions that you override in Lua. 

-- // You must override these functions in a derived table class 
-- // 
-- //virtual int GetNumberRows(); 
-- //virtual int GetNumberCols(); 
-- //virtual bool IsEmptyCell( int row, int col ); 
-- //virtual wxString GetValue( int row, int col ); 
-- //virtual void SetValue( int row, int col, const wxString& value ); 
-- // 
-- // Data type determination and value access 
-- //virtual wxString GetTypeName( int row, int col ); 
-- //virtual bool CanGetValueAs( int row, int col, const wxString& typeName ); 
-- //virtual bool CanSetValueAs( int row, int col, const wxString& typeName ); 
-- // 
-- //virtual long GetValueAsLong( int row, int col ); 
-- //virtual double GetValueAsDouble( int row, int col ); 
-- //virtual bool GetValueAsBool( int row, int col ); 
-- // 
-- //virtual void SetValueAsLong( int row, int col, long value ); 
-- //virtual void SetValueAsDouble( int row, int col, double value ); 
-- //virtual void SetValueAsBool( int row, int col, bool value ); 
-- // 
-- // For user defined types - Custom values probably don't make too much sense for wxLua 
-- // wxLua NOT overridable - virtual void* GetValueAsCustom( int row, int col, const wxString& typeName ); 
-- // wxLua NOT overridable - virtual void SetValueAsCustom( int row, int col, const wxString& typeName, void* value ); 
-- // 
-- // Overriding these is optional 
-- // 
-- // wxLua NOT overridable - virtual void SetView( wxGrid *grid ) { m_view = grid; } 
-- // wxLua NOT overridable - virtual wxGrid * GetView() const { return m_view; } 
-- // 
-- //virtual void Clear() {} 
-- //virtual bool InsertRows( size_t pos = 0, size_t numRows = 1 ); 
-- //virtual bool AppendRows( size_t numRows = 1 ); 
-- //virtual bool DeleteRows( size_t pos = 0, size_t numRows = 1 ); 
-- //virtual bool InsertCols( size_t pos = 0, size_t numCols = 1 ); 
-- //virtual bool AppendCols( size_t numCols = 1 ); 
-- //virtual bool DeleteCols( size_t pos = 0, size_t numCols = 1 ); 
-- // 
-- //virtual wxString GetRowLabelValue( int row ); 
-- //virtual wxString GetColLabelValue( int col ); 
-- //virtual void SetRowLabelValue( int WXUNUSED(row), const wxString& ) {} 
-- //virtual void SetColLabelValue( int WXUNUSED(col), const wxString& ) {} 
-- // 
-- // Attribute handling 
-- // 
-- // give us the attr provider to use - we take ownership of the pointer 
-- // wxLua NOT overridable - void SetAttrProvider(wxGridCellAttrProvider *attrProvider); 
-- // 
-- // get the currently used attr provider (may be NULL ); 
-- // wxLua NOT overridable - wxGridCellAttrProvider *GetAttrProvider() const { return m_attrProvider; } 
-- // 
-- // Does this table allow attributes? Default implementation creates 
-- // a wxGridCellAttrProvider if necessary. 
-- //virtual bool CanHaveAttributes(); 
-- // 
-- // by default forwarded to wxGridCellAttrProvider if any. May be 
-- // overridden to handle attributes directly in the table. 
-- //virtual wxGridCellAttr *GetAttr( int row, int col, 
-- // wxGridCellAttr::wxAttrKind kind ); 
-- // 
-- // In wxLua it would be much easier to simply store the attributes in your own Lua table and return them in GetAttr( ); 
-- // wxLua NOT overridable - virtual void SetAttr(wxGridCellAttr* attr, int row, int col); 
-- // wxLua NOT overridable - virtual void SetRowAttr(wxGridCellAttr *attr, int row); 
-- // wxLua NOT overridable - virtual void SetColAttr(wxGridCellAttr *attr, int col); 
-- }; 