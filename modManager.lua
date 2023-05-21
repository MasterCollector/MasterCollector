local addonName = select(1, ...)
MasterCollector = select(2, ...)	-- Intentionally made non-local
-- local references for performance
local C_PetJournal = C_PetJournal

--------------------
-- Event Handling --
--------------------
local eventFrame = CreateFrame("FRAME", "MasterCollectorEventFrame", UIParent)
eventFrame.events = {}
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, ...)
	if eventFrame.events[event] then
		-- each event can have multiple handlers due to modules, so we want to fire each handler
		if type(eventFrame.events[event]) == 'table' then
			for k,v in pairs(eventFrame.events[event]) do v(...) end
		else
			eventFrame.events[event](...)
		end
	end
end)

local events = {}
local numPets
events.PET_JOURNAL_LIST_UPDATE = function ()
	local newPetCount = select(2, C_PetJournal.GetNumPets())
	if numPets == newPetCount then return end
	
	numPets = newPetCount
	for speciesID in pairs(MasterCollector.DB.data.pet) do
		rawset(MasterCollector.DB.data.pet[speciesID], 'collected', C_PetJournal.GetNumCollectedInfo(speciesID) > 0)
	end
	MasterCollector:RefreshWindows()
end


events.ACHIEVEMENT_EARNED = function(achievementID, alreadyEarned)
	-- TODO: where does 'alreadyEarned' come into play? Is it for achievements unlocked
	--		 on your account but not on the character?
	local ach = MasterCollector.DB:GetObjectData("ach", achievementID)
	if ach then
		rawset(ach, 'collected', true)
		MasterCollector:RefreshWindows()
	end
end
events.TRANSMOG_COLLECTION_SOURCE_ADDED = function(itemModifiedAppearanceID)
	if not itemModifiedAppearanceID then return end
	print('TRANSMOG_COLLECTION_SOURCE_ADDED:', itemModifiedAppearanceID)
	MasterCollector:RefreshWindows()
end
events.TRANSMOG_COLLECTION_SOURCE_REMOVED = function(itemModifiedAppearanceID)
	print('TRANSMOG_COLLECTION_SOURCE_REMOVED:', itemModifiedAppearanceID)
	MasterCollector:RefreshWindows()
end
events.TRANSMOG_COLLECTION_UPDATED = function(collectionIndex, modID, itemAppearanceID, reason)
	-- probably fires when a transmog set has an item added to its collection (e.g. raid tier, world quest items, etc)
	print("TRANSMOG_COLLECTION_UPDATED", collectionIndex, modID, itemAppearanceID, reason)
end
events.QUEST_TURNED_IN = function(questID)
	local quest = MasterCollector.DB:GetObjectData("quest", questID)
	if quest then
		rawset(quest, 'collected', true)
		print('quest completed: ' .. questID .. ' (' .. quest.text .. ')')
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

eventFrame.events.ADDON_LOADED = function(loadedAddonName)
	if loadedAddonName == addonName then
		MasterCollector.playerData.class = select(3, UnitClass("player"))
		MasterCollector.playerData.race = select(3, UnitRace("player"))
		MasterCollector.playerData.sex = UnitSex("player")
		MasterCollector.playerData.level = UnitLevel("player")
		MasterCollector.playerData.covenant = C_Covenants.GetActiveCovenantID()
		MasterCollector.playerData.renown = C_CovenantSanctumUI.GetRenownLevel()
		-- set a faction identifier. We translate blizzard's english code value to a number to compare against faction-level race restrictions
		local factionCode = select(1, UnitFactionGroup("player"))
		if factionCode == 'Horde' then
			MasterCollector.playerData.faction = -2
		elseif factionCode == 'Alliance' then
			MasterCollector.playerData.faction = -1
		end
		
		MasterCollector.playerData.professions = {}
		for _,v in pairs({GetProfessions()}) do
		   local _,_,level,_,_,_,skill = GetProfessionInfo(v)
		   MasterCollector.playerData.professions[skill]=level
		end
		
		local  completedQuestIDs = C_QuestLog.GetAllCompletedQuestIDs()
		for _,v in pairs(completedQuestIDs) do
			quest = MasterCollector.DB:GetObjectData("quest", v)
			MasterCollector.DB:SetCollectedState(quest, true)
		end
		
		MasterCollector:Start()
		-- we don't need to listen to this event anymore. Free up the memory of this function and unregister it from the frame listener
		eventFrame.events.ADDON_LOADED = nil
		eventFrame:UnregisterEvent('ADDON_LOADED')
	end
end
function MasterCollector:UnregisterEvent(event, func)
	if eventFrame.events[event] then
		if type(eventFrame.events[event]) == 'table' then
			for k,v in pairs(eventFrame.events[event]) do
				if v == func then
					eventFrame.events[event][k]=nil
					return
				end
			end
		else
			eventFrame.events[event]=nil
		end
	end
end
function MasterCollector:RegisterModuleEvents(events)
	for k,v in pairs(events or {}) do
		if not eventFrame.events[k] then
			eventFrame.events[k] = {}
			eventFrame:RegisterEvent(k)
		end
		table.insert(eventFrame.events[k],v)
	end
end
function MasterCollector:FlagModAsLoaded(modName)
	if MasterCollector.Modules and MasterCollector.Modules[modName] then
		MasterCollector.Modules[modName].loaded = true
	end
end

-- work in progress. Registing events at the addon-level doesn't make sense but there are too many dependencies right now to eliminate it
MasterCollector:RegisterModuleEvents(events)