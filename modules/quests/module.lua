local MasterCollector = select(2,...)
local Mappins = MasterCollector.MapPins
local mod = MasterCollector.Modules.Quests
if mod then
	-- scan through mapData and initialize the known objects by key
	MasterCollector:InitializeDatabases(mod)
	-- Set up all the events that this module will use
	local events = {}
	events.QUEST_TURNED_IN = function(questID)
		local quest = MasterCollector.DB:GetObjectData("quest", questID)
		if quest then
			quest.collected = true
			if quest.coordinates then
				for i=1,#quest.coordinates do
					if quest.coordinates[i].wp then 
						Mappins:RemovePin(quest.coordinates[i].wp)
					end
				end
			end
			MasterCollector:RefreshWindows()
		end
	end
	
	-- Last step is to register the mod-specific events to the core engine
	MasterCollector:RegisterModuleEvents(events)
	MasterCollector:FlagModAsLoaded("Quests")
end