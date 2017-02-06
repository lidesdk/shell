-- /////////////////////////////////////////////////////////////////////////////////////////////////
-- // Name:        classes/timer.lua
-- // Purpose:     Timer class
-- // Author:      Dario Cano [thdkano@gmail.com]
-- // Created:     2014/07/07
-- // Copyright:   (c) 2014 Dario Cano
-- // License:     lide license
-- /////////////////////////////////////////////////////////////////////////////////////////////////

-- Class constructor:
--
--  object Timer:new ( number nID, fTimerHandler )
--
--  	nID      	 	Timer ID
--		fTimerHandler   Timer Handler
--
--
-- Class methods:
--

local Timer = class 'Timer' 

	: global( false )


-- define class:
function Timer:Timer ( nID, fTimerHandler )
	self.wxEvtHandler = wx.wxEvtHandler()
	self.ID = nID
	self.wxObj = wx.wxTimer(self.wxEvtHandler, self.ID)

	self.wxEvtHandler:Connect(wx.wxEVT_TIMER, function ( event )
		local Interval, nID = event:GetInterval(), event:GetId()		
		fTimerHandler( nID, Interval ) -- call user's event handler with arguments
	end)
end

function Timer:getwxObj( )
	return self.wxObj
end

-- define class methods:
function Timer:start( Milliseconds , Oneshot ) 
	if (Oneshot == nil) then
		Oneshot = false
	end
	self.wxObj:Start(Milliseconds, Oneshot)	
end

function Timer:stop()
	self.wxObj:Stop()
end

function Timer:getInterval()
	return self.wxObj:GetInterval()
end

function Timer:isOneShot()
	return self.wxObj:IsOneShot()
end

function Timer:isRunning()
	return self.wxObj:IsRunning()
end

return Timer