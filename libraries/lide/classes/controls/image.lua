-- /////////////////////////////////////////////////////////////////////////////
-- // Name:        controls/image.lua
-- // Purpose:     Image class
-- // Author:      Hernán Cano [jhernancanom@gmail.com]
-- // Modified by: Dario Cano 07/19/2014 (Agregue los flags y el segundo constructor)
-- // Created:     2014-07-08
-- // Copyright:   (c) 2014 Dario Cano
-- // License:     lide license
-- /////////////////////////////////////////////////////////////////////////////

-- set image constants: (defined in control class)
-- BORDER_SIMPLE = wx.wxSIMPLE_BORDER
-- BORDER_DOUBLE = wx.wxDOUBLE_BORDER
-- BORDER_SUNKEN = wx.wxSUNKEN_BORDER
-- BORDER_RAISED = wx.wxRAISED_BORDER 
-- BORDER_STATIC = wx.wxSTATIC_BORDER 
-- BORDER_NO     = wx.wxNO_BORDER 

local check = lide.core.base.check

-- define class:
local Image = class 'Image' : subclassof 'Control'

function Image:Image ( fields )	

	--- Implementa el segundo constructor:
	---  object	Image:new ( object oParent, string sFilename )
	---
	if type(fields) == 'string' then
		fields.Filename = ( fields )
	else
	--- Implementa el constructor por tabla
	--- object Image:new { Filename = string, Parent = object }
	-- check for fields required by constructor:
		check.fields { 
	 		'string Name', 'object Parent', 'string Filename'
		}	
	end

	-- define class fields
	private {
		DefaultPosition = { X = -1, Y = -1 }, 
		DefaultSize     = { Width = -1, Height = -1 },
		DefaultFlags    = -1,
	}

	protected {
		Filename  = fields.Filename,
		wxBitmap  = '.none.',
		Flags           = fields.Flags
	}

	-- call Control constructor
	self.super : init ( fields.Name, fields.Parent, fields.PosX or self.DefaultPosition.X, fields.PosY or self.DefaultPosition.Y, fields.Width or self.DefaultSize.Width, fields.Height or self.DefaultSize.Height, fields.ID )

	-- Define internal properties:
	self.Filename = fields.Filename or wx.wxNullBitmap

	-- Define specific object properties:
	self.wxBitmap = wx.wxBitmap( fields.Filename )
	
	-- Si no se le dio un tamaño, le damos el tamaño del bitmap por defecto:
	if (self.Width + self.Height) == -2 then
		self.Width  = self.wxBitmap:GetWidth()
		self.Height = self.wxBitmap:GetHeight()
	end
	
	-- Create current wxObj: wxImage
	self.wxObj = wx.wxStaticBitmap( self.Parent:getwxObj(), self.ID, self.wxBitmap, wx.wxPoint(self.PosX, self.PosY), wx.wxSize(self.Width, self.Height), self.Flags or self.DefaultFlags, self.Name )
	
	-- initialize all events:
	self:initializeEvents {
		-- inherited events:
		'onEnter', 'onLeave', 'onLeftDown', 'onMotion'
	}
end

function Image:setFile( File )
	local wxbmp  = wx.wxBitmap( File, wx.wxBITMAP_TYPE_ANY )
	local wxwdth = wxbmp:GetWidth()
	local wxhght = wxbmp:GetHeight()

	self.wxObj:SetBitmap( wxbmp )
	self.wxObj:SetSize( wx.wxSize(wxwdth, wxhght) )
	self.Width, self.Height = wxwdth, wxhght
	self.wxObj:GetParent():Refresh()
end

function Image:getFile( )
	return self.Filename
end

function Image:getHeight()
	local Bitmap = self.wxObj:GetBitmap()
	return Bitmap:GetHeight()
end


function Image:getWidth()
	local Bitmap = self.wxObj:GetBitmap()
	return Bitmap:GetWidth()
end

function Image:getDepth()
	local Bitmap = self.wxObj:GetBitmap()
	return Bitmap:GetDepth()
end

return Image