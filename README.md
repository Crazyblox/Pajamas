### DISCLAIMER:
Pajamas is a WIP project. Feedback regarding the spec and contributions regarding plugin support for multiple luau runtimes are welcome!
It is likely that the project will fundamentally change how it operates from version to version; once it is felt that Pajamas has reached a certain maturity, we will do away with this label. :)

# About:
'Pajamas' crystalizes Luau into its purest form by enforcing a platform-agnostic structure, paving the way for stupidly-easy integration via Pajamas-provided plugin modules handling communication with any given supported runtime.

Pajamas achieves this by adhering to only these principles:
- Filesystem-enforced project structure (./init, ./lib, ./plugin)
- ./init & ./lib modules retain pure Luau status via plugin modules abstracting & exposing runtime functionality
	
# Project structure:
	 ┣━ .pajamasrc.luau
	 ┃
	 ┣━ /init
	 ┃   ┣━ main.luau
	 ┃   ┗━ .luau Files
	 ┃
	 ┣━ /lib
	 ┃   ┣━ Nested Directories
	 ┃   ┗━ .luau Files
	 ┃
	 ┗━ /plugin [Added on init by runtime]
	     ┗━ .luau Files
	 
# Explained:
### .pajamasrc.luau:
The Pajamas runtime starts validating a Pajamas project by looking for this file.
Included are various settings such as the schema, what plugins the project requires for functionality, and runtime sub-configurations etc.

Example:
```luau
return {
	schema = "0.0.1",
	project = {
		name = "Penumbra",
		author = "Crazyblox",
		version = "25.49.0",
		launch_note = "Feedback welcome at https://github.com/Crazyblox/Penumbra!"
	},
	runtime = {
		default = { run = true },
		roblox = { run_server = false, run_client = true }
	},
	plugin = {
		["display"] = { include = true },
		["event"] = { include = true },
		["input"] = { include = true },
		["task"] = { include = true },
		["vm"] = { include = true }
	}
}
```

### ./init:
Init modules are used upon project initialisation via './init/main.luau', or when an init module is passed to the VM plugin for creation of a new process.
Conventionally requiring an init module violates Pajamas' runtime-agnostic principles.
	
### ./lib:
Lib modules can be required from init and other lib modules.
Requiring lib modules from plugin modules violates Pajamas' runtime-agnostic principles.

### ./plugin:
Where plugin modules will be made accessible by the Pajamas runtime.
Plugin modules can be required from init, lib & other plugin modules, ensuring the runtime is able to provide support for the given plugin and is included via the .pajamasrc.
Init and lib modules can not be required by plugin modules; these are intended to be self-contained without any dependencies on the project-specific code itself.
Plugin modules are intended to handle interfacing with the Luau runtime the project is running on, enabling all init and lib modules to remain as pure, unopinionated Luau.

For example, Roblox/Lune's 'task' standard library would be returned under a simple plugin module, ensuring Luau purity for init and library modules and allowing other runtimes to provide their own version of 'task' when a standard library isn't provided.
