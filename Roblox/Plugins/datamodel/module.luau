--!strict
--!native

-- Pajamas: DataModel
-- Provided as part of the Pyjama project specification.
-- This lets developers provide drag-and-drop replacements for whatever environment they intend to run their Luau code in.

return function( Name: string? )
	if not Name then return game :: typeof( game ) end -- Return 'game' if no argument is provided
	local Service = game:GetService( Name )
	assert( Service, `Service '{ Name }' does not exist`)
	return Service :: typeof( Service )
end