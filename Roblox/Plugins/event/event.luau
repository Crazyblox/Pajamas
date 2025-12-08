--!strict
--!native
-- Pajamas plugin wrapper
-- Module
local plug =				require( game.ReplicatedStorage.Pajamas.Plugins.event.module )
-- Exports
export type Hook =			plug.Hook
-- Return
return plug ::				typeof( plug )