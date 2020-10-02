local addonTable = select(2, ...)
local L = addonTable.L
local GetPetInfoBySpeciesID = C_PetJournal.GetPetInfoBySpeciesID
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
			return true -- temporarily hard-coding visibility
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
			return true -- temporarily hard-coding visibility
		else
			return nil
		end
	end
}