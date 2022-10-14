local MasterCollector = select(2,...)
local Mappins = MasterCollector.MapPins
local mod = MasterCollector.Modules.Quests
if mod then
	-- Set up all the events that this module will use
	local events = {}
	events.QUEST_TURNED_IN = function(questID)
		local quest = MasterCollector.DB:GetObjectData("quest", questID)
		if quest then
			rawset(quest, 'collected', true)
			Mappins:TryRemoveObjectPins(quest)
			MasterCollector:RefreshWindows()
		end
	end
	events.QUEST_ACCEPTED = function()
		-- There is a delay between the event and the API responding with the right values.
		-- this solution sucks. I hate it, but it works for the time being
		C_Timer.After(0.1, function() MasterCollector:RefreshWindows() end)
	end
	events.QUEST_REMOVED = events.QUEST_ACCEPTED
	
	-- Last step is to register the mod-specific events to the core engine
	MasterCollector:RegisterModuleEvents(events)
	MasterCollector:FlagModAsLoaded("Quests")
end