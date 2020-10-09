local MasterCollector = select(2,...)
local mod = MasterCollector.Modules.Quests
if mod then
	-- scan through mapData and initialize the known objects by key
	MasterCollector:InitializeDatabases(mod)
	-- Set up all the events that this module will use
	local events = {}
	events.QUEST_TURNED_IN = function(questID)
		if mod.DB.quest[questID] then
			mod.DB.quest[questID].collected = true
			MasterCollector:RefreshWindows()
		end
	end
	
	-- Last step is to register the mod-specific events to the core engine
	MasterCollector:RegisterModuleEvents(events)
	MasterCollector:FlagModAsLoaded("Quests")
end