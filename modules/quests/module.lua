local MasterCollector = select(2,...)
local Mappins = MasterCollector.MapPins
local mod = MasterCollector.Modules.Quests
if mod then
	-- Set up all the events that this module will use
	local events = {}
	events.QUEST_TURNED_IN = function(questID)
		local quest = MasterCollector.DB:GetObjectData("quest", questID)
		if quest then
			quest.collected = true
			Mappins:TryRemoveObjectPins(quest)
			MasterCollector:RefreshWindows()
		end
	end
	
	-- Last step is to register the mod-specific events to the core engine
	MasterCollector:RegisterModuleEvents(events)
	MasterCollector:FlagModAsLoaded("Quests")
end