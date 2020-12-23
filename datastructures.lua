local addonTable = select(2, ...)
local L = addonTable.L
-- set local functions for blizz API calls for slightly faster processing
local GetPetInfoBySpeciesID = C_PetJournal.GetPetInfoBySpeciesID
local GetQuestTitle = C_QuestLog.GetTitleForQuestID
local IsQuestComplete = C_QuestLog.IsQuestFlaggedCompleted
local RequestLoadQuestByID = C_QuestLog.RequestLoadQuestByID

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
					if tbl.races[i] == addonTable.playerData.race then matched = true break end
				end
				if not matched then return false end
			else
				return tbl.races == addonTable.playerData.faction or tbl.races == addonTable.playerData.race
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


-- set a background frame that listens to load requests for quest data
local pendingQuestTitles = CreateFrame("FRAME", 'MasterCollectorQuestTitleQueueFrame', UIParent)
pendingQuestTitles.data = {}
pendingQuestTitles.AddPendingQuestTitle = function(questData)
	if not pendingQuestTitles.data[questData.id] then
		questData.text = SEARCH_LOADING_TEXT
		RequestLoadQuestByID(questData.id)
		pendingQuestTitles.data[questData.id] = questData
	end
end
pendingQuestTitles:RegisterEvent("QUEST_DATA_LOAD_RESULT")
pendingQuestTitles:SetScript("OnEvent", function(self, event, ...)
	-- Once blizzard returns the quest data, we can inspect the result to see if it's a valid entry or not
	-- Quests that have a nil or false "success" return tell us that either blizzard has removed the quest completely OR
	--   the quest itself doesn't have a name (e.g. tracking quests). 
	if event == "QUEST_DATA_LOAD_RESULT" then
		local questID, success = ...
		-- Only handle quest load results for the ones we're waiting on a response for
		if pendingQuestTitles.data[questID] then
			local quest = pendingQuestTitles.data[questID]
			pendingQuestTitles.data[questID] = nil
			if success then
				rawset(quest, 'text', GetQuestTitle(questID))
			else
				rawset(quest, 'text', string.format(L.Text.QUEST_PENDING_NAME, questID))
			end
			MasterCollector:RefreshWindows(true)
		end
	end
end)
-- If the client has already cached the quest name, GetQuestTitle returns immediately. If it doesn't set a name, add the quest to the queue so it can be loaded in the background
local function TrySetQuestName(questData)
	rawset(questData, 'text', GetQuestTitle(questData.id))
	if not rawget(questData, 'text') then
		pendingQuestTitles.AddPendingQuestTitle(questData)
	end
end


-- All metatables describing data structures should be added below
addonTable.structs = {}
addonTable.structs.panel = {
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
addonTable.structs.ach = {
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
addonTable.structs.pet = {
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
addonTable.structs.quest = {
	__index = function(self, key)
		if not rawget(self, "loaded") then
			TrySetQuestName(self)
			self.icon = "Interface\\gossipframe\\availablequesticon" -- TODO: temporary
			self.loaded = true
		end
		if key == "visible" then
			return determineVisibility(self)
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
addonTable.structs.treasure = {
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