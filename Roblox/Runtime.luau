--!strict
--!native

-- Pajamas - RBX_Runtime : Roblox-versioned auto-init system for the self-contained 'Pajamas' project specification 
-- Consult README for more information

type Pajamas = {
	init: Folder,
	lib: Folder,
	plugin: Folder,
	[".pajamasrc"]: ModuleScript
}

type pajamasrc = {
	schema: string,
	project: {
		name: string,
		author: string,
		version: string,
		launch_note: string,
	},
	runtime: {
		default: { run: boolean },
		roblox: { run_server: boolean, run_client: boolean }
	},
	plugin: {
		[string]: { include: boolean }
	}
}

-- Init assertions
local RuntimeDir = game.ReplicatedStorage:FindFirstChild("Pajamas")
assert( RuntimeDir, "Pajamas: Can't initialise - Pajamas must be a direct child of game.ReplicatedStorage." )
assert( script.Parent == RuntimeDir, "Pajamas: Can't initialise - Runtime is not present in runtime directory" )
assert( RuntimeDir:FindFirstChild("LICENSE"), "Pajamas: Can't initialise - Missing 'LICENSE' in runtime directory" )
assert( RuntimeDir:FindFirstChild("Plugins"), "Pajamas: Can't initialise - Missing 'Plugins' in runtime directory" )
assert( RuntimeDir:FindFirstChild("LuauVM_Client"), "Pajamas: Can't initialise - Missing 'LuauVM_Client' in runtime directory" )
assert( RuntimeDir:FindFirstChild("LuauVM_Server"), "Pajamas: Can't initialise - Missing 'LuauVM_Client' in runtime directory" )

print( `PAJAMAS IS IN-DEV & SUBJECT TO CHANGE; USE AT YOUR OWN RISK.` )
local RuntimePlugins = script.Parent.Plugins

local Wrappers = {}
Wrappers.Server = script.Parent.LuauVM_Server:Clone()
Wrappers.Server.Name = "LuauVM"
Wrappers.Client = script.Parent.LuauVM_Client:Clone()
Wrappers.Client.Name = "LuauVM"
table.freeze( Wrappers )

-- Clear server/client copies present in the datamodel; we have cloned our own for use.
script.Parent.LuauVM_Server:Destroy()
script.Parent.LuauVM_Client:Destroy()

-- Used to track what Pajamas have been set up
-- Ensures we don't look inside Pajamas for... more Pajamas
local WornPajamas = {}

local function Wear_Pajamas( Pajamas: Folder | Camera ) --local function Wear_Pajamas( Pajamas: Folder | Camera )
	local Pajamas = 		Pajamas
	local PajamasParent = 	Pajamas.Parent
	
	-- Are these Pajamas already worn?
	if table.find( WornPajamas, Pajamas ) then
		warn( `Pajamas: { Pajamas.Name } - Already Initialised` )
		return
	end
	
	if Pajamas:IsDescendantOf(RuntimeDir) then
		warn( `Pajamas: { Pajamas.Name } - Can't initialise as a descendant of Pajamas runtime`)
		return
	end
	
	assert( Pajamas:FindFirstChild(".pajamasrc"), `Pajamas: { Pajamas.Name } - Missing '.pajamasrc'` )
	local pajamasrc: pajamasrc = require( ( Pajamas :: any )[".pajamasrc"] ) :: any
	
	print( `Pajamas: Init - { pajamasrc.project.name } by { pajamasrc.project.author } [Version { pajamasrc.project.version }]` )
	
	-- Pre-wearing check of given Pajamas...
	assert( Pajamas:FindFirstChild("init"),							`Pajamas: { Pajamas.Name } - Missing './init'` )
	assert( Pajamas:FindFirstChild("init"):FindFirstChild("main"),	`Pajamas: { Pajamas.Name } - Missing './init/main.luau'` )
	assert( Pajamas:FindFirstChild("lib"),							`Pajamas: { Pajamas.Name } - Missing './lib'` )
	
	local RunServer: boolean = pajamasrc.runtime.roblox.run_server
	local RunClient: boolean = pajamasrc.runtime.roblox.run_client
	local NoReplicate: Camera? = RunServer and Instance.new( "Camera", PajamasParent ) or nil
	local Wrapper: Script
	
	--[[ Pajamas - Structure Requirements:
		./
			init/
				main.luau
			lib/
	]]
	
	-- Add to worn pajamas after validating that this is, infact, a valid pajamas project
	table.insert( WornPajamas, NoReplicate or Pajamas )
	
	-- Pajamas - Server: Transplant/Clone project based on .pajamasrc runserver/runclient config
	if NoReplicate then
		NoReplicate.Name = Pajamas.Name
		for _, i: Instance in Pajamas:GetChildren() do
			( RunClient and i:Clone() or i ).Parent = NoReplicate
		end
		Wrapper = Wrappers.Server:Clone()
	end
	
	-- Pajamas - Client
	if RunClient then
		Wrapper = Wrappers.Client:Clone()
	else
		-- Not needed on client; Destroy to prevent replication
		Pajamas:Destroy()
	end
	
	-- Set NoReplicate to be Pajamas now that setup is done.
	if NoReplicate then Pajamas = NoReplicate end
	
	-- Clear dev plugins and insert own runtime plugins.
	local OldPluginDir = Pajamas:FindFirstChild("plugin")
	if OldPluginDir then OldPluginDir:Destroy() end
	local NewPluginDir = Instance.new( "Folder" )
	NewPluginDir.Name = "plugin"
	local pajamasrc = require( Pajamas:FindFirstChild(".pajamasrc") :: ModuleScript ) :: any
	for n: string, info in pajamasrc.plugin do
		if info.include == true then
			RuntimePlugins[n][n]:Clone().Parent = NewPluginDir
		end
	end
	NewPluginDir.Parent = Pajamas
	
	-- If wrapper is created, we get it ready and place it in its own VM, then run!
	if Wrapper then
		local VM = Instance.new( "Actor" )
		VM.Name = "VM_Main"
		Wrapper.Parent = VM
		VM.Parent = Pajamas
		Wrapper.Enabled = true
	end
	
	print( `Pajamas: { pajamasrc.project.name } - { pajamasrc.project.launch_note }`)
end

-- Checks if instance is Pajamas, otherwise recursively search for any more :) 
local function Do_Laundry( Thing: Instance ): boolean
	-- A Pyjama's root directory can only start out as a 'Folder' instance.
	-- This means that even if a project is clone to be server-only without replication...
	-- ...then it wont execute the rest of this function.
	if not Thing:IsA("Folder") then return false end
	
	-- Ensure we're not wearing Pajamas!
	local SearchUpwards: Instance = Thing
	while SearchUpwards ~= nil and SearchUpwards ~= game do
		if table.find( WornPajamas, SearchUpwards :: Camera | Folder ) then
			-- These Pajamas are already sorted! Cancel search...
			return false 
		end
		SearchUpwards = SearchUpwards.Parent :: Instance
	end
	
	-- Check if this really is Pajamas!
	local IsPajamas: boolean = not not Thing:FindFirstChild(".pajamasrc")
	if IsPajamas then Wear_Pajamas( Thing ) end
	
	return false
end

local function Wash_Laundry()
	local Services = { "Workspace", "Players", "Lighting", "MaterialService", "ReplicatedFirst", "ReplicatedStorage", "ServerScriptService", "ServerStorage", "StarterGui", "StarterPack", "StarterPlayer", "Teams", "SoundService", "TextChatService" }
	-- Iterate through given services
	for _, Name: string in Services do
		local Service = game:GetService( Name )
		if Service then
			-- Post-Init Pajamas [Connects before long-processing of 'Do_Laundry()']  
			Service.DescendantAdded:Connect( Do_Laundry )
			-- Init Pajamas
			for _, i: Instance in Service:GetDescendants() do
				Do_Laundry( i )
			end
		end
	end
end

-- Run at launch
Wash_Laundry()