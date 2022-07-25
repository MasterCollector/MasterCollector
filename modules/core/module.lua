local MasterCollector = select(2,...)
local mod = MasterCollector.Modules.Core
if mod then
	-- Set up all the events that this module will use
	local events = {}
	events.ACHIEVEMENT_EARNED = function(achievementID, alreadyEarned)
		-- TODO: where does 'alreadyEarned' come into play? Is it for achievements unlocked
		--		 on your account but not on the character?
		local ach = MasterCollector.DB:GetObjectData("ach", achievementID)
		if ach then
			rawset(ach, 'collected', true)
			MasterCollector:RefreshWindows()
		end
	end
	-- Last step is to register the mod-specific events to the core engine
	MasterCollector:RegisterModuleEvents(events)
	MasterCollector:FlagModAsLoaded("Core")
end