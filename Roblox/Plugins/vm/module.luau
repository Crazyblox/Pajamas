--!strict
--!native

-- Abstraction module for spinning up a LuauVM in Roblox

export type VM_Thread = {
	Name:			string,
	Instance:		Actor,									-- Roblox-specific, do not access outside of ./Plugins
	Run:			( VM_Thread ) -> (),					-- Runs the specified VM
	Send:			( VM_Thread, ...any ) -> (),
	Bind:			( VM_Thread, string, ...any ) -> (),
	BindParallel:	( VM_Thread, string, ...any ) -> ()
}

-- Global buffer data accessible by all VMs
export type SharedData = {
	Shared_Table: SharedTable,				-- SharedTable used to share buffer data across VMs
	Buffer: buffer,							-- Shareable buffer data via :SyncTo() & :SyncFrom()
	SyncFrom: (SharedData) -> SharedData,	-- Reads Shared_Table[1], converting to Buffer
	SyncTo: (SharedData) -> SharedData		-- Writes Buffer to Shared_Table[1]
}

local VM = {}
VM.ProjectDir = script.Parent --Placeholder until VM.init is run
local VM_Self
local VM_List: { VM_Thread } = {}

-- Wraps a given Actor inside of a 'VM_Thread' object
local function IndexVM( Actor: Actor ): VM_Thread
	-- If it exists, return the VM from the plugin's internal list of VMs
	for i = 1, #VM_List do
		if VM_List[ i ].Instance == Actor then
			return VM_List[ i ]
		end 
	end
	local Wrapper: Script? = Actor:FindFirstChildWhichIsA("Script")
	assert( Wrapper, `Wrapper does not exist for { Actor.Name }`)
	local MakeVM = {}
	function MakeVM:Send( ... ) Actor:SendMessage( ... ) end
	function MakeVM:Run() Wrapper.Disabled = false end
	function MakeVM:Bind( Topic: string, Function ) Actor:BindToMessage( Topic, Function ) end
	function MakeVM:BindParallel( Topic: string, Function ) Actor:BindToMessageParallel( Topic, Function ) end
	MakeVM.Instance = Actor
	MakeVM.Name = Actor.Name
	table.freeze( MakeVM )
	VM_List[ #VM_List + 1 ] = MakeVM
	return MakeVM
end

-- Spin up a brand new VM instance
function VM.New( NameOfVM: string, Wrapper_Attributes, Actor_Attributes ): VM_Thread
	-- Actor
	local Actor = Instance.new("Actor")
	Actor.Name = NameOfVM
	for aName, aVal in Actor_Attributes or {} do
		Actor:SetAttribute( aName :: string, aVal :: any )
	end
	-- Wrapper
	local Wrapper = VM.ProjectDir["VM_Main"].LuauVM:Clone()
	Wrapper.Disabled = true
	for aName, aVal in Wrapper_Attributes or {} do
		Wrapper:SetAttribute( aName :: string, aVal :: any )
	end
	-- Set up methods
	Wrapper.Parent = Actor
	local NewVM = IndexVM( Actor )
	Actor.Parent = VM.ProjectDir
	-- Return
	return NewVM
end

-- Gives us the ability to return a 'VM_Thread' object
-- VM_Main is provided as fallback
function VM.GetVMFromName( Name: string ): VM_Thread
	for _, VM: VM_Thread in VM_List do
		if VM.Name == Name then
			return VM
		end
	end
	warn( `Couldn't find VM with name '{ Name }'. Providing VM_Main` )
	for _, VM: VM_Thread in VM_List do
		if VM.Name == "VM_Main" then
			return VM
		end
	end
	error("VM_Main not found; this project cannot run without VM_Main!")
end

local RBX_SharedTables = game:GetService( "SharedTableRegistry" )
local SharedData_List = {} :: { [string]: SharedData }
function VM.RequireShared( Name: string, Size: number? ): SharedData
	-- Is SharedData already required in this VM?
	if SharedData_List[ Name ] then return SharedData_List[ Name ] end
	-- Returns existing or new/empty SharedTable
	local Requiring_SharedTable: SharedTable = RBX_SharedTables:GetSharedTable( Name )
	local Buffer: buffer
	-- Checks if SharedTable already existed or not
	local HasEntry = Requiring_SharedTable[1]
	if HasEntry then
		Buffer = buffer.fromstring( HasEntry )
	else
		assert( type( Size ) == "number", "Argument `Size` must be a number" )
		Buffer = buffer.create( Size )
	end
	-- Create SharedData
	local SharedData: SharedData = {
		Shared_Table = Requiring_SharedTable,
		Buffer = Buffer,
		-- Read from RBX SharedTable[1]
		SyncFrom = function( self: SharedData ): SharedData
			SharedTable.update(
				self.Shared_Table, 1,
				function( value: string ): string
					buffer.copy( self.Buffer, 0, buffer.fromstring(value) )
					return value
				end
			)
			return self
		end,
		-- Write to RBX SharedTable[1]
		SyncTo = function( self: SharedData ): SharedData
			SharedTable.update(
				self.Shared_Table, 1,
				function( value: string ): string
					return buffer.tostring(self.Buffer)
				end
			)
			return self
		end
	}
	-- Register RBX SharedTable
	if not HasEntry then
		RBX_SharedTables:SetSharedTable( Name, Requiring_SharedTable )
		SharedData:SyncTo()
	end
	-- Index in SharedData_List for future VM.RequireShared calls of the same name.
	SharedData_List[ Name ] = SharedData
	return table.freeze( SharedData )
end

-- This should be run by the runtime-specific pyjamas handler before running './init/main.luau'
-- Returns VM_Thread indicating own process.
local VM_IsInit: boolean = false
VM.Init = function( self: Script )
	if VM_IsInit then return end
	assert( self and self.Parent and self.Parent.Parent ) -- For the typechecker.
	VM.ProjectDir = self.Parent.Parent
	-- RBX: Listens to new VM's added in the Roblox datamodel as a child of the project directory 
	VM.ProjectDir.ChildAdded:ConnectParallel(function( New: Instance )
		if New:IsA("Actor") then IndexVM( New ) end
	end)
	-- RBX: Adds all already-existing VM's in the project directory to the list of VM's.
	for _, c: Instance in VM.ProjectDir:GetChildren() do
		if c:IsA("Actor") then IndexVM( c ) end
	end
	VM.MainProcess = VM.GetVMFromName( "VM_Main" )
	VM.Process = IndexVM( self:GetActor() )
	VM.Env = self.Parent:GetAttributes()
	table.freeze( VM )
	VM_IsInit = true
end

return VM