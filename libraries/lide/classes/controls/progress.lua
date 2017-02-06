-- /////////////////////////////////////////////////////////////////////////////
-- // Name:        classes/controls/progress.lua
-- // Purpose:     Progress class
-- // Author:      Hernán Cano [jhernancanom@gmail.com]
-- // Created:     2014-07-07
-- // Copyright:   (c) 2014 Hernán Cano
-- // License:     lide license
-- /////////////////////////////////////////////////////////////////////////////

-- Define local variables:
local Progress

-- set progress constants:
enum {
	PROGRESS_HORIZONTAL = wx.wxGA_HORIZONTAL,
	PROGRESS_VERTICAL   = wx.wxGA_VERTICAL  ,
	PROGRESS_SMOOTH     = wx.wxGA_SMOOTH    ,
}

-- import local functions:
local isNumber = lide.core.base.isnumber
local isBoolean = lide.core.base.isboolean

-- Importar las librerias:
local check = lide.core.base.check

-- define class:
Progress = class 'Progress' : subclassof 'Control' 
	: global(false)

function Progress:Progress( fields )
	-- check for fields required by constructor:
	check.fields { 
	 	'string Name', 'object Parent',
	}
	
	-- define class fields
	private {
		DefaultPosition = { X = -1, Y = -1 }, 
		DefaultSize     = { Width = -1, Height = -1 },
		DefaultFlags    = wx.wxGA_HORIZONTAL,

		MaxValue  = fields.MaxValue or 100,
		Validator = (fields.Validator or wx.wxDefaultValidator),
	}


	-- call Control constructor
	self.super : init ( fields.Name, fields.Parent, fields.PosX or self.DefaultPosition.X, fields.PosY or self.DefaultPosition.Y, fields.Width or self.DefaultSize.Width, fields.Height or self.DefaultSize.Height, fields.ID )
	
	-- Create current wxObj:
	self.wxObj = wx.wxGauge( self.Parent:getwxObj(), self.ID, self.MaxValue, wx.wxPoint( self.PosX, self.PosY ), wx.wxSize( self.Width, self.Height ), self.Flags or self.DefaultFlags, self.Validator, self.Name )

	self:initializeEvents {
		'onEnter', 'onLeave',
	}

end

function Progress:setCurrentPos( nValue, bSmooth )
	isNumber(nValue) 
	
	if bSmooth then isBoolean(bSmooth)
		for i = self.wxObj:GetValue(), nValue, 0.01 do
			self.wxObj:SetValue( i )
		end
	else
		self.wxObj:SetValue( nValue )
	end
end

function Progress:pulse()
	self.wxObj:Pulse()
end

function Progress:setMaxValue( nMaxValue )
	isNumber (nMaxValue)
	self.wxObj:SetRange( nMaxValue )
end

function Progress:getCurrentPos()
	return self.wxObj:GetValue()
end

function Progress:getMaxValue()
	return self.wxObj:GetRange()
end

function Progress:isVertical()
	return self.wxObj:IsVertical()
end

return Progress
