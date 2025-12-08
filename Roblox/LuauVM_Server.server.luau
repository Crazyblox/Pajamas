--!native
-- Not yet aware of being able to import disabled scripts via file sync, so a basic directory check is required.
if script.Parent == game.ReplicatedStorage.Pajamas then return end
require( `../plugin/vm` ).Init( script )
local ClonedModule = script.Parent.Parent.init[ script:GetAttribute("Init") or "main" ]:Clone()
ClonedModule.Parent = script.Parent
require(ClonedModule)()
