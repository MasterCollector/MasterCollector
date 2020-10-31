local MasterCollector = select(2,...)
local mod = MasterCollector.Modules.Pets
if mod then
	local numPetsOwned
	local GetNumPetsOwned = C_PetJournal.GetNumPets
	MasterCollector:InitializeDatabases(mod)
	
	local function reloadCollectedStates()
		for id in pairs(mod.DB.pet) do
			rawset(mod.DB.pet[id], 'collected', C_PetJournal.GetNumCollectedInfo(id) > 0)
		end
	end

	-- Set up all the events that this module will use
	local events = {}
	events.QUEST_TURNED_IN = function(questID)
		if mod.DB.quest[questID] then
			mod.DB.quest[questID].collected = true
			MasterCollector:RefreshWindows()
		end
	end
	-- During the login/reload process, pets appear to be available after the first SPELLS_CHANGED event fires. We don't need to listen to it after its first run
	events.SPELLS_CHANGED = function()
		MasterCollector:UnregisterEvent('SPELLS_CHANGED', events.SPELLS_CHANGED)
		MasterCollector:FlagModAsLoaded("Pets")
		numPetsOwned = select(2, GetNumPetsOwned())
	end
	events.PET_JOURNAL_PET_DELETED = function() -- fires when caging a pet
		-- we can't use C_PetJournal.GetPetInfoByPetID here because it depends on the pet being in your journal
		-- since it isn't in the journal anymore, we have no choice but to scan the pets you do know to update the collected states
		numPetsOwned = select(2, GetNumPetsOwned())
		reloadCollectedStates()
		MasterCollector:RefreshWindows()
	end
	events.PET_JOURNAL_LIST_UPDATE = function()
		local nowNumPetsOwned = select(2, GetNumPetsOwned())
		-- this event fires with just about any change to the pet journal ingame, so we want to limit our refresh only when the number of pets known changes.
		-- check if the number of owned pets is less than the last known number of pets. If so, that means we lost a pet somehow and need to refresh
		if numPetsOwned and nowNumPetsOwned < numPetsOwned then
			numPetsOwned = nowNumPetsOwned
			reloadCollectedStates()
			MasterCollector:RefreshWindows()
		end
	end
	events.NEW_PET_ADDED = function(petID) -- fires when capturing a wild pet, learning a pet from a cage, or learning from an item
		local speciesID = C_PetJournal.GetPetInfoByPetID(petID);
		if speciesID and mod.DB.pet[speciesID] then
			mod.DB.pet[speciesID].collected = true
		end
		MasterCollector:RefreshWindows()
		-- This isn't ideal, but blizzard API doesn't return the correct number of pets owned until AFTER this event completes.
		-- By setting a very small background timer to update the number of pets owned, we get the correct value for comparisons in other functions
		C_Timer.After(0.1, function() numPetsOwned = select(2, GetNumPetsOwned()) end)
	end

	-- Last step is to register the mod-specific events to the core engine
	MasterCollector:RegisterModuleEvents(events)
end