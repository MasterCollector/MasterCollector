local MasterCollector = select(2, ...)
local L = MasterCollector.L
-- set local functions for blizz API calls for slightly faster processing
local GetPetInfoBySpeciesID = C_PetJournal.GetPetInfoBySpeciesID
local GetQuestTitle = C_QuestLog.GetTitleForQuestID
local IsQuestComplete = C_QuestLog.IsQuestFlaggedCompleted
local RequestLoadQuestByID = C_QuestLog.RequestLoadQuestByID

MasterCollector.playerData = {}
local playerData = MasterCollector.playerData

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
		local optionIgnoreRaces = false -- TODO: replace with addon setting when the settings panel is written
		if not optionIgnoreRaces and tbl.races then
			if type(tbl.races) == 'table' then
				local matched = false
				for i=1,#tbl.races do
					if tbl.races[i] == MasterCollector.playerData.race then matched = true break end
				end
				if not matched then return false end
			else
				if tbl.races == MasterCollector.playerData.faction or tbl.races == MasterCollector.playerData.race then
					return false
				end
			end
		end
		
		local ignoreLevel = false
		-- the player must be between the min and max level of the object. If either is not defined, compare against a default value
		if not ignoreLevel and not (MasterCollector.playerData.level >= (tbl.minLevel or 1)) and (MasterCollector.playerData.level <= (tbl.maxLevel or MasterCollector.playerData.level)) then
			return false
		end
		
		-- special requirements inspection
		if tbl.requirements then
			local ignoreCovenant = false
			if not ignoreCovenant and tbl.requirements.covenant and tbl.requirements.covenant ~= MasterCollector.playerData.covenant then
				return false
			end
		end
	
		local optionShowCollected = false -- TODO: replace with addon setting when the settings panel is written
		-- if the object has already been collected and the user has chosen not to show collected items, then don't show the object
		if tbl.collected and not optionShowCollected then
			return false
		end
	end
	
	return true
end
local colors = {
	red = "|cFFFF0000",
	green = "|cFF00FF00",
	blue = "|cFF33DAFF",
}
local function GetQuestTextColor(obj)
	if not obj then return end
	-- Go through requirements first. If they aren't met, we want to render the text as red
	if obj.minlevel and playerData.level < obj.minlevel then return colors.red end
	if obj.requirements then
		if obj.requirements.covenant and obj.requirements.covenant ~= playerData.covenant then return colors.red end
		if obj.requirements.quest then
			if type(obj.requirements.quest) == "table" then
				for i=1,#obj.requirements.quest do
					if not IsQuestComplete(obj.requirements.quest[i]) then return colors.red end
				end
			else
				if not IsQuestComplete(obj.requirements.quest) then return colors.red end
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
			if not name then
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
	if event == "QUEST_DATA_LOAD_RESULT" then
		local questID, success = ...
		if success then
			rawset(QuestNames, questID, GetQuestTitle(questID))
		else
			rawset(QuestNames, questID, string.format(L.Text.QUEST_PENDING_NAME, questID))
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
			return select(2, GetAchievementInfo(self.id)) or 'Achievement #' .. self.id
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
MasterCollector.structs.map = {
	__index = function(self, key)
		if key == "visible" then
			return true
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
		elseif key == "sortkey" then
			return QuestNames[self.id]
		elseif key == "text" then
			local color = GetQuestTextColor(self)
			if color then
				return string.format("%s%s|r", color, QuestNames[self.id])
			else
				return QuestNames[self.id]
			end
		elseif key == "icon" then
			if self.repeatable then
				self.icon = "Interface\\gossipframe\\dailyquesticon"
			else
				self.icon = "Interface\\gossipframe\\availablequesticon"
			end
			return self.icon
		elseif key == "repeatable" then
			return self.flags and (self.flags.daily or self.flags.weekly or self.flags.yearly or self.flags.calling)
		elseif key == "collected" then
			if not rawget(self, key) then
				self.collected = IsQuestComplete(self.id)
			end
			return self.collected
		else
			return rawget(self, key)
		end
	end
}
MasterCollector.structs.treasure = {
	__index = function(self, key)
		if not rawget(self, "loaded") then
			self.text = "Treasure " .. self.id
			--self.icon = "Interface\\minimap\\objecticons"
			--self.txcoord = { left = 0.25, right = 0.25, top = 0.625, bottom = 0.75 }
			self.loaded = true
		end
		if key == "visible" then
			return determineVisibility(self)
		elseif key == "collected" then
			return IsQuestComplete(self.questID)
		else
			return rawget(self, key)
		end
	end
}