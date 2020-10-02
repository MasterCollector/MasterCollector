local addonTable = select(2, ...)
local L = addonTable.L
local GetPetInfoBySpeciesID = C_PetJournal.GetPetInfoBySpeciesID

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

-- All metatables describing data structures should be added below
addonTable.structs = {}
addonTable.structs.panel = {
	__index = function(self, key)
		if key == "text" then
			return L.Panels[self.id].text
		elseif key == "icon" then
			return L.Panels[self.id].icon
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
		local name, _, petTypeID, companionID, _, _, _, _, _, _, _, displayID = GetPetInfoBySpeciesID(self.id)
		self["text"] = name
		self["displayID"] = companionID
		if key == "text" then
			return name
		elseif key == "type" then
			return "data"
		elseif key == "visible" then
			return determineVisibility(self)
		else
			return nil
		end
	end
}