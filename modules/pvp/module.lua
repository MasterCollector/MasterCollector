local MasterCollector = select(2,...)
local mod = MasterCollector.Modules.PVP
if mod then
	-- Set up all the events that this module will use
	local events = {}
	-- Last step is to register the mod-specific events to the core engine
	MasterCollector:RegisterModuleEvents(events)
	MasterCollector:FlagModAsLoaded("PVP")
end