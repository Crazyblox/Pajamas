--!strict
--!native

-- Pajamas Plugin - Display:
-- Enables the ability to display framebuffer content within Roblox

local Display = {}
function Display.ViewportSize(): vector
	local v3
	if game.Players.LocalPlayer then
		v3 = game.Players.LocalPlayer.PlayerGui.RenderGui.Present.AbsoluteSize
	else
		v3 = game.StarterGui.RenderGui.Present.AbsoluteSize
	end
	return vector.create( v3.X, v3.Y, 0 )
end

function Display.New( Settings: { [string]: any } )
	-- Enforcing the limit in './lib/Settings' before here AND including these assertions isn't platform-agnostic friendly...
	-- ...Would be nice to report display parameter capabilities before taking the Pajamas project's word for it...
	assert( Settings.Display_Res.x <= 1024, `Settings.Display_Res.x is set too high ({Settings.Display_Res.x}), Roblox EditableImage limit is 1024x1024)` )
	assert( Settings.Display_Res.y <= 1024, `Settings.Display_Res.y is set too high ({Settings.Display_Res.y}), Roblox EditableImage limit is 1024x1024)` )
	local Aspect_X: number = Settings.Display_Res.x / Settings.Display_Res.y
	--Roblox: Create objects
	local LocalPlayer = game:GetService("Players").LocalPlayer
	local ScreenGui = Instance.new("ScreenGui") :: any
	local ImagePresent = Instance.new("ImageLabel") :: any
	local EditableImage: EditableImage = game:GetService("AssetService"):CreateEditableImage( { Size = Vector2.new( Settings.Display_Res.x, Settings.Display_Res.y ) } )
	
	-- ScreenGui
	for Prop: any, Value: any in {
		Name = "RenderGui",
		ClipToDeviceSafeArea = true,
		SafeAreaCompatibility = Enum.SafeAreaCompatibility.FullscreenExtension,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		IgnoreGuiInset = true,
		AutoLocalize = false,
		DisplayOrder = -999,
		ResetOnSpawn = false,
		Archivable = false,
		Parent = if LocalPlayer then LocalPlayer.PlayerGui else game:GetService("StarterGui")
		} do ScreenGui[ Prop ] = Value end
	ScreenGui = ScreenGui :: ScreenGui
	-- EditableImage
	assert( EditableImage, `EditableImage not created` )

	-- ImageLabel
	for Prop: any, Value: any in {
		Name = "Present",
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Size = UDim2.new(Aspect_X, 0, 1, 0),
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = 1,
		ZIndex = -999,
		Interactable = false,
		Active = false,
		Archivable = false,
		ImageContent = Content.fromObject( EditableImage ) :: Content,
		ResampleMode =
			if Settings.Display_Resample == "Bilinear" then Enum.ResamplerMode.Default
			elseif Settings.Display_Resample == "Nearest" then Enum.ResamplerMode.Pixelated
			else Enum.ResamplerMode.Default,
		Parent = ScreenGui
		} do ImagePresent[ Prop ] = Value end
	ImagePresent = ImagePresent :: ImageLabel -- Exit Typecast
	
	-- This is what we will be returning to whoever calls to initialize the display
	local Expose = {}
	Expose.Settings = Settings
	Expose.Framebuffer = buffer.create( Settings.Display_Res.x * Settings.Display_Res.y * 4 )
	for c = 0, buffer.len( Expose.Framebuffer ) - 1, 4 do
		buffer.writeu32( Expose.Framebuffer, c, 0xFF000000 )
	end
	Expose.Present = function( self )
		EditableImage:WritePixelsBuffer(
			Vector2.zero,
			Vector2.new(
				Settings.Display_Res.x,
				Settings.Display_Res.y
			), Expose.Framebuffer
		)
	end
	return table.freeze( Expose )
end

return table.freeze( Display )