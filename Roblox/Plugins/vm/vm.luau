--!strict
--!native
-- Pajamas plugin wrapper
-- Module
local plug =				require( game.ReplicatedStorage.Pajamas.Plugins.vm.module )
-- Exports
export type SharedData =	plug.SharedData
export type VM_Thread =		plug.VM_Thread
-- Return
return plug ::				typeof( plug )