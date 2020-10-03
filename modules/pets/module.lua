local MasterCollector = select(2,...)
local mod = MasterCollector.Modules.Pets
if mod then
	MasterCollector:InitializeDatabases(mod)
	
	local function loadCollectedStates()
		for id in pairs(mod.DB.pet) do
			rawset(mod.DB.pet[id], 'collected', C_PetJournal.GetNumCollectedInfo(id) > 0)
		end
	end

	-- Set up all the events that this module will use
	local events = {}
	-- During the login/reload process, pets appear to be available after the first SPELLS_CHANGED event fires. We don't need to listen to it after its first run
	events.SPELLS_CHANGED = function()
		MasterCollector:UnregisterEvent('SPELLS_CHANGED', events.SPELLS_CHANGED)
		loadCollectedStates()
		MasterCollector:FlagModAsLoaded("Pets")
	end
	events.PET_JOURNAL_PET_DELETED = function(petID) -- fired when caging a pet
		-- we can't use C_PetJournal.GetPetInfoByPetID here because it depends on the pet being in your journal
		-- since it isn't in the journal anymore, we have no choice but to scan the pets you do know to update the collected states
		loadCollectedStates()
	end
	events.NEW_PET_ADDED = function(petID) -- fires when capturing a wild pet, learning a pet from a cage, or learning from an item
		local speciesID = C_PetJournal.GetPetInfoByPetID(petID);
		if speciesID and mod.DB[speciesID] then
			mod.DB[speciesID].collected = true
		end
	end

	-- Last step is to register the mod-specific events to the core engine
	MasterCollector:RegisterModuleEvents(events)
end