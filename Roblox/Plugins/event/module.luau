--!strict
--!native

-- Loop plugin for Roblox
-- Hooks provided functions up to a host-platform's loop events

export type Hook = {
	Connect: (Hook, boolean?) -> (),
	Disconnect: (Hook) -> ()
}

local Events = {
	Loop = game:GetService("RunService")[ game.Players.LocalPlayer and "PreRender" or "PreSimulation" ]
}

return function( Function, EventName: string )
	assert( Events[EventName], `Event named '{EventName}' does not exist` )
	local Signal = Events[EventName]
	local Connection: RBXScriptConnection
	local Hook = {}
	function Hook:Connect( Parallel: boolean? )
		if Parallel == true then
			Connection = Signal:ConnectParallel(Function)
		else
			Connection = Signal:Connect(Function)
		end
	end
	function Hook:Disconnect()
		if Connection.Connected then
			Connection:Disconnect()
		end
	end
	table.freeze( Hook )
	return Hook
end