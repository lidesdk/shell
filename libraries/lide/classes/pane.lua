-- /////////////////////////////////////////////////////////////////////////////
-- // Name:        classes/widgets/pane.lua
-- // Purpose:     Pane class
-- // Author:      Dario Cano [thdkano@gmail.com]
-- // Created:     2014-08-19
-- // Copyright:   (c) 2014 Dario Cano
-- // License:     lide license
-- /////////////////////////////////////////////////////////////////////////////

local Pane = class 'Pane' : subclassof 'Widget'

function Pane:Pane( Properties, PaneType )
        -- check for fields required by constructor:
        --check.fields { 
        --    -- 'string Name', 'object Parent'
        --}

        -- define class fields
        private {
            DefaultPosition = { X = -1, Y = -1 }, 
            DefaultSize     = { Width = -1, Height = -1 },
            --DefaultFlags    = wx.wxTAB_TRAVERSAL,

            -- Para guardar el FocusedObject, lo inicializamos con un boolean false
            FocusedObject   = false,
        }
        

        -- call Widget constructor
        fields = Properties
        self.super:init( fields.Name, 'widget', fields.PosX or self.DefaultPosition.X, fields.PosY or self.DefaultPosition.Y, fields.Width or self.DefaultSize.Width, fields.Height or self.DefaultSize.Height, fields.ID, fields.Parent )


        if self.ObjectType == "Pane" then --> equivalent to PaneType
           --self.Panel  = wx.wxPanel (Properties.Parent.wxObj, wx.wxID_ANY, wx.wxDefaultPosition, wx.wxSize( 500,300 ), wx.wxTAB_TRAVERSAL )
           self.Panel  = Panel { Parent = Properties.Parent }
           self.Sizer  = wx.wxBoxSizer( wx.wxVERTICAL )  
           self.Widget = Properties.Widget


        -- Get PaneInfo from a lua table:
        --self.PaneInfo = Properties.PaneInfo

        -- Reparent the widget to this Pane's Panel:
           self.Widget.wxObj:Reparent(self.Panel)        
        
        -- Add BoxSizers:
           self.Sizer:Add( self.Widget:getwxObj(), 1, wx.wxALL + wx.wxEXPAND, Properties.Margin or 5 )        
           self.Panel:SetSizer( self.Sizer )
           self.Panel:Layout()

        elseif self.ObjectType == "ToolbarPane" then
            self.Widget = Properties.Widget
        end

        -- Pane properties:

        self.Name    = Properties.Name
        self.Caption = Properties.Caption
        
        --if Properties.ToolBarPane then
        self.ToolBarPane = Properties.ToolBarPane
        --end

        if type(Properties.Position) == "userdata" then
            Properties.Position = 0
        end

        if Properties.Resizable == nil then
            Properties.Resizable = true
        end

        -- Positioning:
        self.Layer           = Properties.Layer
        --if type(self.Position == "userdata") then -- Widget position
        self.Position        = Properties.Position or 0
        
        self.Sizing          = Properties.Sizing
        self.MinSize         = Properties.MinSize
        self.MaxSize         = Properties.MaxSize
        self.BestSize        = Properties.BestSize 

        self.Floatable       = Properties.Floatable
        self.Dockable        = Properties.Dockable
        self.Resizable       = Properties.Resizable
        self.Fixed           = Properties.Fixed

        --> Pane Buttons:
        self.PinButton       = Properties.PinButton
        self.CloseButton     = Properties.CloseButton
        self.MaximizeButton  = Properties.MaximizeButton
        self.MinimizeButton  = Properties.MinimizeButton

        --> Pane positioning:
        self.Center          = Properties.Center
        self.Left            = Properties.Left
        self.Top             = Properties.Top
        self.Right           = Properties.Right
        self.Bottom          = Properties.Bottom

        self.Row = Properties.Row
end

return Pane