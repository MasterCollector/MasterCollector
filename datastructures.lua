local addonTable = select(2, ...)
local L = addonTable.L
-- set local functions for blizz API calls for slightly faster processing
local GetPetInfoBySpeciesID = C_PetJournal.GetPetInfoBySpeciesID
local RequestLoadQuestByID = C_QuestLog.RequestLoadQuestByID
local GetQuestInfo = C_QuestLog.GetQuestInfo

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
		local optionShowCollected = false -- TODO: replace with addon setting when the settings panel is written
		-- if the object has already been collected and the user has chosen not to show collected items, then don't show the object
		if tbl.collected and not optionShowCollected then
			return false
		end
	end
	
	return true
end
local function GetQuestName(questID)
	RequestLoadQuestByID(questID)
	return GetQuestInfo(questID) or ('Quest #' .. questID)
end

-- All metatables describing data structures should be added below
addonTable.structs = {}
addonTable.structs.panel = {
	__index = function(self, key)
		if key == "text" then
			return L.Panels[self.id].text
		elseif key == "icon" then
			return L.Panels[self.id].icon
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
addonTable.structs.pet = {
	__index = function(self, key)
		if not rawget(self, "loaded") then
			local name, icon, _, npcID = GetPetInfoBySpeciesID(self.id)
			self.text = name
			self.npcID = npcID
			self.icon = icon
			self.loaded = true
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
			self.text = GetQuestName(self.id)
			self.icon = "Interface\\gossipframe\\availablequesticon" -- TODO: temporary
			self.loaded = true
		end
		if key == "visible" then
			return determineVisibility(self)
		else
			return rawget(self, key)
		end
	end
}
local IsQuestComplete = C_QuestLog.IsQuestFlaggedCompleted
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