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
		rawset(MasterCollector.DB.data.pet[speciesID], 'collected', (C_PetJournal.GetNumCollectedInfo(speciesID) or 0) > 0)
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
events.NEW_MOUNT_ADDED = function(mountID)
	MasterCollector:RefreshWindows()
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
events.UNIT_AURA = function(unit, auraUpdates)
	local refreshNeeded = false
	if auraUpdates.addedAuras then
	   for _,v in pairs(auraUpdates.addedAuras) do
		  if MasterCollector.Constants.SpellIDsForRefresh[v.spellId] then
			 MasterCollector.playerData.auraInstances[v.auraInstanceID] = true
			 refreshNeeded = true
			 break
		  end
	   end
	end
	if not refreshNeeded and auraUpdates.removedAuraInstanceIDs then
	   for _,instanceID in pairs(auraUpdates.removedAuraInstanceIDs) do
		  if MasterCollector.playerData.auraInstances[instanceID] then
			 MasterCollector.playerData.auraInstances[instanceID] = nil
			 refreshNeeded = true
			 break
		  end
	   end
	end
	if refreshNeeded then
		MasterCollector:RefreshWindows()
	end
end
events.PLAYER_ENTERING_WORLD = function(initialLogin, reload)
	MasterCollector.playerData.professions = {}
	for _,v in pairs({GetProfessions()}) do
		local _,_,level,_,_,_,skill,_,specialization = GetProfessionInfo(v)
		MasterCollector.playerData.professions[skill]={
			level = level,
			profession = C_TradeSkillUI.GetProfessionInfoBySkillLineID(skill).profession
		}
	end
	
	local  completedQuestIDs = C_QuestLog.GetAllCompletedQuestIDs()
	for _,v in pairs(completedQuestIDs) do
		local quest = MasterCollector.DB:GetObjectData("quest", v)
		if quest then quest.collected = true end
	end
	
	MasterCollector.playerData.auraInstances = {}
	AuraUtil.ForEachAura("player", AuraUtil.AuraFilters.Helpful, nil, function(...)
		local spellID = select(10,...)
		if(MasterCollector.Constants.SpellIDsForRefresh[spellID]) then
			local auraInfo = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
			if auraInfo and auraInfo.auraInstanceID then
				MasterCollector.playerData.auraInstances[auraInfo.auraInstanceID] = true
			end
		end
	end)
	
	MasterCollector.playerData.covenant = C_Covenants.GetActiveCovenantID()
	MasterCollector.playerData.renown = C_CovenantSanctumUI.GetRenownLevel()
end
events.ADDON_LOADED = function(loadedAddonName)
	if loadedAddonName == addonName then
		MasterCollector.playerData.class = select(3, UnitClass("player"))
		MasterCollector.playerData.race = select(3, UnitRace("player"))
		MasterCollector.playerData.sex = UnitSex("player")
		MasterCollector.playerData.level = UnitLevel("player")
		
		-- set a faction identifier. We translate blizzard's english code value to a number to compare against faction-level race restrictions
		local factionCode = select(1, UnitFactionGroup("player"))
		if factionCode == 'Horde' then
			MasterCollector.playerData.faction = -2
		elseif factionCode == 'Alliance' then
			MasterCollector.playerData.faction = -1
		end
		
		MasterCollector:InitializeSettings()
		MasterCollector.DB:Initialize()
		MasterCollector:Start()
	end
end

for k,v in pairs(events or {}) do
	eventFrame:RegisterEvent(k)
end