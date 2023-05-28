local addonName = select(1, ...)
local MasterCollector = select(2, ...)	-- Intentionally made non-local

-- local references for performance
local MapPins = MasterCollector.MapPins
local C_PetJournal = C_PetJournal

--------------------
-- Event Handling --
--------------------
local events = {}
local eventFrame = CreateFrame("FRAME", "MasterCollectorEventFrame", UIParent)
eventFrame:SetScript("OnEvent", function(self, event, ...)
	if events[event] then
		events[event](...)
	end
end)
local function UnregisterEvent(event)
	if events[event] then
		eventFrame:UnregisterEvent(event)
	end
end

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
		MapPins:TryRemoveObjectPins(quest)
		MasterCollector:RefreshWindows()
	end
end
events.QUEST_ACCEPTED = function()
	-- There is a delay between the event and the API responding with the right values.
	-- this solution sucks. I hate it, but it works for the time being
	C_Timer.After(0.1, function() MasterCollector:RefreshWindows() end)
end
events.QUEST_REMOVED = events.QUEST_ACCEPTED
events.ADDON_LOADED = function(loadedAddonName)
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
	end
end

for k,v in pairs(events or {}) do
	eventFrame:RegisterEvent(k)
end