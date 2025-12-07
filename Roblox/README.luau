--[[ Pajamas Runtime - Roblox - README

Pajamas is WIP; not even the setup instructions are properly written...
...but hopefully the error messages you find along the way make enough sense.
Issue reports regarding functionality are welcome at https://github.com/Crazyblox/Pajamas 
Thanks :)
Crazyblox

CONFIGURATION:
	'Runtime' script acts as the handler for all Pajamas projects within a given Roblox environment.
This checks for and listens to the DataModel for valid projects & sets up the project based on its given configuration.
Pajamas are self-contained, so you get to choose wherever you wish to place the project itself, keeping Roblox's own behaviour in mind.
Make sure your './plugin' modules consider client/server environment differences if relevant to the project.

'.pajamasrc' runtime-specific configuration:
		run_server: boolean
	Tells 'Runtime' if a given project should setup './init/main.luau' via a script with runcontext set to the server.
	If only 'run_server' is true, 'Runtime' will transplant the project into a non-replicating instance
	before running (Currently a Camera instance) so that the project is not replicated to the client. 
	
		run_client: boolean
	Tells 'Runtime' if a given project should setup './init/main.luau' via a script with runcontext set to client.
]]