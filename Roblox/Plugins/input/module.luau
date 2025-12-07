--!strict
--!native

-- Pajamas - input
-- Crude WIP plugin for providing a method of keyboard input to the project
-- No way to disconnect it properly yet, trying to get things off the ground by showing various use-cases.

local Input = {}
local UIS = game:GetService("UserInputService")

function Input:KeyDown( Listen_KeyCode: string, func )
	UIS.InputBegan:Connect(function( input: InputObject )
		if ( string.split( tostring( input.KeyCode ), `.` )[3] or `` ) == Listen_KeyCode then
			func()
		end
	end)
end

function Input:KeyUp( Listen_KeyCode: string, func )
	UIS.InputEnded:Connect(function( input: InputObject )
		if ( string.split( tostring( input.KeyCode ), `.` )[3] or `` ) == Listen_KeyCode then
			func()
		end
	end)
end

return Input