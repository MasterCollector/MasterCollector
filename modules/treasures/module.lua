local MasterCollector = select(2,...)
local mod = MasterCollector.Modules.Treasures
if mod then
	-- scan through mapData and initialize the known objects by key
	for mod,items in pairs(mod.DB) do
		for id,tbl in pairs(items) do
			tbl.id = id
			tbl = setmetatable(tbl,MasterCollector.structs[mod])
		end
	end

	-- Set up all the events that this module will use
	local events = {}
	-- Last step is to register the mod-specific events to the core engine
	MasterCollector:RegisterModuleEvents(events)
	MasterCollector:FlagModAsLoaded("Treasures")
end