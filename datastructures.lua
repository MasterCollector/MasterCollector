local MasterCollector = select(2, ...)
local L = MasterCollector.L
-- set local functions for blizz API calls for slightly faster processing
local GetPetInfoBySpeciesID = C_PetJournal.GetPetInfoBySpeciesID
local GetQuestTitle = QuestUtils_GetQuestName
local RequestLoadQuestByID = C_QuestLog.RequestLoadQuestByID
local IsOnQuest = C_QuestLog.IsOnQuest

MasterCollector.playerData = {}
local playerData = MasterCollector.playerData

local function IsLevelRangeMet(obj)
	local ignoreLevel = false -- TODO: replace with addon setting when the settings panel is written
	if ignoreLevel then return true end
	return (not obj.minlevel or playerData.level >= obj.minlevel) and (not obj.maxlevel or playerData.level <= obj.maxlevel)
end
local function IsRaceOrFactionMet(obj)
	if not obj.races then return true end
	if type(obj.races) == 'table' then
		for i=1,#obj.races do
			if obj.races[i] == MasterCollector.playerData.race then return true end
		end
		return false
	else
		return obj.races == MasterCollector.playerData.faction or obj.races == MasterCollector.playerData.race
	end
end
local function IsPlayerSexMet(obj)
	if obj.requirements and obj.requirements.sex then
		return obj.requirements.sex == MasterCollector.playerData.sex
	end
	return true
end
local function IsProfessionMet(obj)
	if obj.requirements then
		if not obj.requirements.prof then return true end
		local professionData = MasterCollector.playerData.professions
		return professionData and professionData[obj.requirements.prof]
	end
	return true
end
local function IsClassMet(obj)
	if not obj.classes then return true end
	if type(obj.classes) == 'table' then
		for i=1,#obj.classes do
			if obj.classes[i] == MasterCollector.playerData.class then return true end
		end
		return false
	else
		return obj.classes == MasterCollector.playerData.class or obj.classes == MasterCollector.playerData.class
	end
end
-- supporting functions for the data structure metatables
local function determineVisibility(tbl)
	if tbl.type == "panel" then
		-- if the panel has no children (should never happen but this is a safety check), don't show it
		if not tbl.children then return false end
		-- check all children of the panel. If any of them are visible, then the panel itself must be visible
		for _,v in pairs(tbl.children) do
			if determineVisibility(v) then return true end
		end
		-- if no children are visible, then the panel doesn't need to be shown
		return false
	else
		if tbl.flags and (tbl.flags.hidden or tbl.flags.removed or tbl.flags.nyi) then return false end
	
		if not MCSettings.ActiveSettings.Filters.IgnoreRace and not IsRaceOrFactionMet(tbl) then return false end
		
		if not MCSettings.ActiveSettings.Filters.IgnoreClass and not IsClassMet(tbl) then return false end

		local optionIgnoreProfessions = false
		if not optionIgnoreProfessions and not IsProfessionMet(tbl) then return false end
		
		-- special requirements inspection
		if tbl.requirements then
			local ignoreCovenant = false
			if not ignoreCovenant and tbl.requirements.covenant and tbl.requirements.covenant ~= MasterCollector.playerData.covenant then
				return false
			end
			
			if not MCSettings.ActiveSettings.Filters.IgnoreGender and not IsPlayerSexMet(tbl) then
				return false
			end
		end
	
		-- if the object has already been collected and the user has chosen not to show collected items, then don't show the object
		if tbl.collected and not MCSettings.ActiveSettings.Filters.ShowCollected then
			return false
		end
		
		local optionShowMissed = true
		if tbl.collected == -1 and not optionShowMissed then
			return false
		end
	end
	
	if tbl.children then
		local hasVisibleChildren = false
		-- check all children of the panel. If any of them are visible, then the panel itself must be visible
		for _,v in pairs(tbl.children) do
			if determineVisibility(v) then return true end
		end
		if not hasVisibleChildren then return false end
	end
	
	return true
end
local colors = {
	red = "|cFFFF0000",
	green = "|cFF00FF00",
	blue = "|cFF33DAFF",
}
local function IsPlayerEligibleForQuest(quest)
	return quest and IsRaceOrFactionMet(quest) and IsClassMet(quest) and IsPlayerSexMet(quest)
end
local function IsQuestOptional(quest)
	return quest and quest.flags and quest.flags.breadcrumb
end

local dataFunctions = {
   IsOnQuestOrComplete = function(questID)
      if not questID then return end
	  questID = tonumber(questID)
      return IsOnQuest(questID) or MasterCollector.DB:GetObjectData("quest", questID).collected
   end
}

local function GetQuestTextColor(obj)
	if not obj then return end
	if not IsLevelRangeMet(obj) then return colors.red end
	if not IsRaceOrFactionMet(obj) then return colors.red end
	if not IsClassMet(obj) then return colors.red end
	if not IsPlayerSexMet(obj) then return colors.red end
	-- Go through requirements first. If they aren't met, we want to render the text as red
	if obj.requirements then
		if obj.requirements.covenant and obj.requirements.covenant ~= playerData.covenant then return colors.red end
		if obj.requirements.quest then
			local quests = obj.requirements.quest
			if type(quests) ~= "table" then quests = {quests} end
			local quest
			for i=1,#quests do
				quest = MasterCollector.DB:GetObjectData("quest", quests[i])
				if quest and not quest.collected and IsPlayerEligibleForQuest(quest) and not IsQuestOptional(quest) then
					return colors.red
				end
			end
		end
		if obj.requirements.spell then
			local spells = obj.requirements.spell
			if type(spells) ~= "table" then spells = {spells} end
			for i=1,#spells do
				local found = false
				AuraUtil.ForEachAura("player", AuraUtil.AuraFilters.Helpful, 1, function(...)
					if(MasterCollector.L.constants.SpellIDsForRefresh[select(10, ...)]) then
						found = true
						return
					end
				end)
				if not found then return colors.red end
			end
		end
		if obj.requirements.script then
			local scripts = obj.requirements.script
			if type(scripts[1]) ~= "table" then scripts = {scripts} end
			for i=1,#scripts do
				if not dataFunctions[scripts[i][1]](strsplit(',',scripts[i][2])) then
					return colors.red
				end
			end
		end
	end
	-- If requirements are met, now we can color based on other conditions
	if obj.repeatable then return colors.blue end
end

-- set a background frame that listens to load requests for quest data
local QuestNames = setmetatable({}, {
	__index = function(self, key)
		if not rawget(self, key) then
			local name = GetQuestTitle(key)
			if not name or name=='' then
				RequestLoadQuestByID(key)
				rawset(self, key, SEARCH_LOADING_TEXT)
				return SEARCH_LOADING_TEXT
			else
				rawset(self, key, name)
				return name
			end
		else
			return string.format(L.Text.QUEST_PENDING_NAME, key)
		end
	end
})
local pendingQuestTitles = CreateFrame("FRAME", 'MasterCollectorQuestTitleQueueFrame', UIParent)
pendingQuestTitles:RegisterEvent("QUEST_DATA_LOAD_RESULT")
pendingQuestTitles:SetScript("OnEvent", function(self, event, ...)
	-- Once blizzard returns the quest data, we can inspect the result to see if it's a valid entry or not
	-- Quests that have a nil or false "success" return tell us that either blizzard has removed the quest completely OR
	--   the quest itself doesn't have a name (e.g. tracking quests). 
	if event == "QUEST_DATA_LOAD_RESULT" and rawget(QuestNames, ...) then -- only bother with results from quest load requests made by this addon
		local questID, success = ...
		-- For some reason, Blizzard sends QUEST_DATA_LOAD_RESULT for every step completion in a world quest for all world/bonus quests on the map.
		-- If the quest already has a name that isn't the loading text, we can skip this event
		if QuestNames[questID] ~= SEARCH_LOADING_TEXT then return end
		
		if success then
			rawset(QuestNames, questID, GetQuestTitle(questID))
		else
			rawset(QuestNames, questID, MasterCollector.L.Quests[questID] or string.format(L.Text.QUEST_PENDING_NAME, questID))
		end
		MasterCollector:RefreshWindows(true)
	end
end)


-- All metatables describing data structures should be added below
MasterCollector.structs = {}
MasterCollector.structs.panel = {
	__index = function(self, key)
		if key == "text" then
			return L.Panels[self.id].text
		elseif key == "icon" then
			return (L.Panels[self.id] and L.Panels[self.id].icon) or nil
		elseif key == "txcoord" then
			return L.Panels[self.id].txcoord
		elseif key == "type" then
			return "panel"
		elseif key == "visible" then
			return determineVisibility(self)
		else
			return rawget(self, key)
		end
	end
}
MasterCollector.structs.ach = {
	__index = function(self, key)
		if key == "text" then
			local name = select(2, GetAchievementInfo(self.id))
			if name then
				rawset(self, 'name', format('|cffffff00%s|r', name))
				return self.name
			end
			return format('|cffffff00%s|r', 'Achievement #' .. self.id)
		elseif key == "type" then
			return "achievement"
		elseif key == "visible" then
			return determineVisibility(self)
		elseif key == "collected" then
			return select(4, GetAchievementInfo(self.id)) -- TODO: setting for track by character, not just account?
		elseif key == "icon" then
			return select(10, GetAchievementInfo(self.id)) -- TODO: setting for track by character, not just account?
		else
			return rawget(self, key)
		end
	end
}
MasterCollector.structs.item = {
	__index = function(self, key)
		if key == "visible" then
			return determineVisibility(self)
		elseif key == "type" then
			return "item"
		elseif key == "collected" then
			if self.type == 'equipment' then
				return C_TransmogCollection.PlayerHasTransmog(self.id)
			elseif self.type == 'mount' then
				return select(11, C_MountJournal.GetMountInfoByID(self.mountID or 0))
			elseif self.type == 'pet' then
				return C_PetJournal.GetNumCollectedInfo(self.speciesID) > 0
			elseif self.type == 'toy' then
				return PlayerHasToy(self.id)
			end
			return false
		elseif key == "text" then
			return 'Item #' .. self.id
		else
			return rawget(self, key)
		end
	end
}
MasterCollector.structs.map = {
	__index = function(self, key)
		if key == "visible" then
			return true
		else
			return rawget(self, key)
		end
	end
}
MasterCollector.structs.npc = {
	__index = function(self, key)
		if key == "visible" then
			return determineVisibility(self)
		elseif key == "collected" then
			if self.children and #self.children > 0 then
				local collected = true
				for i=1,#self.children do
					collected = self.children[i].collected
					if not collected then break end
				end
				return collected
			end
			return false
		elseif key == "text" then
			return 'NPC #' .. self.id
		else
			return rawget(self, key)
		end
	end
}
MasterCollector.structs.pet = {
	__index = function(self, key)
		if not rawget(self, "loaded") then
			local name, icon, _, npcID = GetPetInfoBySpeciesID(self.id)
			self.text = name
			self.npcID = npcID
			self.icon = icon
			self.loaded = true
			self.collected = C_PetJournal.GetNumCollectedInfo(self.id) > 0
		end
		if key == "visible" then
			return determineVisibility(self)
		else
			return rawget(self, key)
		end
	end
}
MasterCollector.structs.quest = {
	__index = function(self, key)
		if key == "visible" then
			return determineVisibility(self)
		elseif key == "type" then return "quest"
		elseif key == "sortkey" then
			return QuestNames[self.id]
		elseif key == "text" then
			local color = GetQuestTextColor(self)
			local name = QuestNames[self.id]
			if color then
				return string.format("%s%s|r", color, name)
			else
				return name
			end
		elseif key == "collected" then
			if self.IsMissed and self.IsMissed() then
				rawset(self, key, -1)
				MasterCollector.MapPins:TryRemoveObjectPins(self)
				return -1
			end
			return false
		elseif key == "icon" then
			if self.flags and self.flags.breadcrumb then
				self.icon = "Interface\\icons\\inv_misc_food_12"
			elseif self.repeatable then
				self.icon = "Interface\\gossipframe\\dailyquesticon"
			else
				self.icon = "Interface\\gossipframe\\availablequesticon"
			end
			return self.icon
		elseif key == "repeatable" then
			return self.flags and (self.flags.daily or self.flags.weekly or self.flags.yearly or self.flags.calling or self.flags.wq)
		else
			return rawget(self, key)
		end
	end
}
MasterCollector.structs.toy = {
	__index = function(self, key)
		if key == "visible" then
			return determineVisibility(self)
		elseif key == "collected" then
			return PlayerHasToy(self.id)
		elseif key == "text" then
			local item = Item:CreateFromItemID(self.id)
			item:ContinueOnItemLoad(function()
				rawset(self, 'icon', item:GetItemIcon())
				rawset(self, 'text', item:GetItemName())
			end)
			return 'Item #' .. self.id
		else
			return rawget(self, key)
		end
	end
}
MasterCollector.structs.treasure = {
	__index = function(self, key)
		if not rawget(self, "loaded") then
			self.text = "Treasure " .. self.id
			self.icon = "Interface\\minimap\\objecticons"
			self.txcoord = { left = 0.26953125, right = 0.35546875, top = 0.64453125, bottom = 0.734375 }
			self.loaded = true
		end
		if key == "visible" then
			return determineVisibility(self)
		elseif key == "collected" then
			local quest = MasterCollector.DB:GetObjectData("quest", self.id)
			return rawget(quest, 'collected')
		else
			return rawget(self, key)
		end
	end
}