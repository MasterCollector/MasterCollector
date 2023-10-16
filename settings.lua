local addonName, addonTable = ...
MCSettings = MCSettings or {}
local L = addonTable.L

local defaultSettings = {
	Version = 1,
	Modules = {
		BattlePet = {
			enabled = true,
		},
		PVP = {
			enabled = true,
		},
		Quests = {
			enabled = true,
		},
	},
	Filters = {
		IgnoreLevelRequirement = false,
		IgnoreGender = false,
		IgnoreRace = false,
		IgnoreClass = false,
		ShowCollected = false,
	}
}
local function clone(tbl) 
	local copy = {}
	for k,v in pairs(tbl) do
		if type(v) == 'table' then
			copy[k] = clone(v)
		else
			copy[k] = v
		end
	end
	return tbl
end
local function newCheckbox(parentFrame, label, onclick)
   local check = CreateFrame("CheckButton", nil, parentFrame, "InterfaceOptionsCheckButtonTemplate")
   check.Text:SetText(label)
   if onclick then 
      check:SetScript("OnClick", onclick)
   end
   return check
end

local settingsFrame = CreateFrame("Frame", "MCSettingsMain", nil)
local category, layout = Settings.RegisterCanvasLayoutCategory(settingsFrame, addonName);
Settings.RegisterAddOnCategory(category)

local chk = newCheckbox(settingsFrame, L.Settings.Filters.IGNORE_LEVEL, function(self) MCSettings.ActiveSettings.Filters.IgnoreLevelRequirement = self:GetChecked() end)
chk:SetPoint("TOPLEFT")
local chk2 = newCheckbox(settingsFrame, L.Settings.Filters.IGNORE_RACE, function(self) MCSettings.ActiveSettings.Filters.IgnoreRace = self:GetChecked() end)
chk2:SetPoint("TOPLEFT", chk, "TOPLEFT", 0, -20)
local chk3 = newCheckbox(settingsFrame, L.Settings.Filters.IGNORE_CLASS, function(self) MCSettings.ActiveSettings.Filters.IgnoreClass = self:GetChecked() end)
chk3:SetPoint("TOPLEFT", chk2, "TOPLEFT", 0, -20)
local chk4 = newCheckbox(settingsFrame, L.Settings.Filters.IGNORE_GENDER, function(self) MCSettings.ActiveSettings.Filters.IgnoreGender = self:GetChecked() end)
chk4:SetPoint("TOPLEFT", chk3, "TOPLEFT", 0, -20)
local chk5 = newCheckbox(settingsFrame, L.Settings.Filters.SHOW_COLLECTED, function(self) MCSettings.ActiveSettings.Filters.ShowCollected = self:GetChecked() MasterCollector:RefreshWindows() end)
chk5:SetPoint("TOPLEFT", chk4, "TOPLEFT", 0, -20)

--[[ This is how to create a subcategory of settings when ready
local moduleFrame = CreateFrame("Frame", "MCSettingsModules", nil)
Settings.RegisterCanvasLayoutSubcategory(category, moduleFrame, "Modules");
]]--

local MCSettingsCategoryID
function MasterCollector_OnAddonCompartmentClick(addonName, buttonName, menuButtonFrame)
	if not MCSettingsCategoryID then
		for _,v in pairs(SettingsPanel:GetAllCategories()) do
		   if v:GetName() == addonName then
			  MCSettingsCategoryID = v:GetID()
			  break
		   end
		end
	end
	if MCSettingsCategoryID then
	   SettingsPanel:OpenToCategory(MCSettingsCategoryID)
	else
		error("Unable to locate settings panel ID for " .. addonName)
	end
end

function addonTable:InitializeSettings()
	if not MCSettings.ActiveSettings then MCSettings.ActiveSettings = clone(defaultSettings) end
	setmetatable(MCSettings.ActiveSettings, {__index = defaultSettings})
	
	chk:SetChecked(MCSettings.ActiveSettings.Filters.IgnoreLevelRequirement)
	chk2:SetChecked(MCSettings.ActiveSettings.Filters.IgnoreRace)
	chk3:SetChecked(MCSettings.ActiveSettings.Filters.IgnoreClass)
	chk4:SetChecked(MCSettings.ActiveSettings.Filters.IgnoreGender)
	chk5:SetChecked(MCSettings.ActiveSettings.Filters.ShowCollected)
end
