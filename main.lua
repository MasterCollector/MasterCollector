local addonName = select(1,...)
MasterCollector = select(2,...)
local data = {
	
}

MasterCollector.harvest = function()
	MCAppearanceHarvestData = {}
	local TMogGetItemInfo = C_TransmogCollection.GetItemInfo
	local items = {}
	local modIDs = {
	   0,	-- no mods
	   1,	-- normal dungeon
	   2,	-- heroic dungeon
	   3,	-- normal raid
	   4,	-- lfr raid
	   5,	-- heroic raid
	   6,	-- mythic raid
	   22,	-- timewalking
	   23	-- 'mythic dungeon'
	}
	for itemID=1,180784,1--175000,175100,1--1,178015,1
	do
	   local id,_,_,loc,_,classID,subclassID = GetItemInfoInstant(itemID)
	   if id and (classID == 4 or (classID == 2 and (subclassID ~= 0 and subclassID ~= 11))) then
		  for idx=1,#modIDs,1 do
			 local appearanceID,sourceID = TMogGetItemInfo(itemID, modIDs[idx])
			 if appearanceID then
				if not items[itemID] then items[itemID] = {} end
				table.insert(items[itemID], { modIDs[idx], appearanceID, sourceID})
			 end
		  end
	   end
	end
	MCAppearanceHarvestData = items
	print('Appearance data has been collected. /reload or close your client and inspect SavedVariables for the collected data.')
end


---------------------
-- Window controls --
---------------------
-- TODO: this entire section should be moved to its own file with each window made available with a Windows variable in the addon table
-- TODO: an actual window design rather than a simple box

-- NOTE: NOT THE FINAL PRODUCT BUT SUFFICIENT FOR EARLY DRAFT TESTING OF CORE FUNCTIONALITY
local FRAME_WIDTH = 300
local FRAME_HEIGHT = 500
local function CloseCascadeFrame(targetFrame)
   if targetFrame then
      if targetFrame.cascadeWindow then
         CloseCascadeFrame(targetFrame.cascadeWindow)
      end
      targetFrame:Hide()
   end
end
local function OpenCascadingWindow(anchorFrame)
   local cascadeFrame = anchorFrame.cascadeWindow or CreateFrame("FRAME", anchorFrame:GetName() .. 'CascadeFrame', anchorFrame)
   if not anchorFrame.cascadeWindow then anchorFrame.cascadeWindow = cascadeFrame end
   cascadeFrame:SetHeight(100)
   cascadeFrame:SetWidth(100)
   cascadeFrame:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT")
   cascadeFrame:EnableMouse(true)
   
   local bd = {
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      tile = true,
      edgeSize = 16,
      tileSize = 32,
      insets = {
         left = 2.5,
         right = 2.5,
         top = 2.5,
         bottom = 2.5
      }
   }
   cascadeFrame:SetBackdrop(bd)
   cascadeFrame:SetScript("OnLeave", function(self, motion)
         local frameUnderMouse = GetMouseFocus()
         if frameUnderMouse ~= anchorFrame then
            CloseCascadeFrame(self)
         end
   end)
   cascadeFrame:Show()
end
-- TODO: this function needs to be made more flexible so we can create windows on demand with unique names
local CreateWindow = function(windowName)
   if _G[windowName] then
      _G[windowName]:Hide()
      _G[windowName] = nil
   end
   window = CreateFrame("FRAME", windowName, UIParent)
   window:SetMovable(true)
   window:SetToplevel(true)
   window:EnableMouse(true)
   window:SetPoint("CENTER") -- this line is responsible for the window position reseting on /reloadui
   window:SetWidth(FRAME_WIDTH)
   window:SetHeight(FRAME_HEIGHT)
   
   local bd = {
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      tile = true,
      edgeSize = 16,
      tileSize = 32,
      insets = {
         left = 2.5,
         right = 2.5,
         top = 2.5,
         bottom = 2.5
      }
   }
   window:SetBackdrop(bd)
   
   -- Top row is the map header.
   window.titleLabel = CreateFrame('Button', windowName..'TitleLabel', window)
   window.titleLabel:SetWidth(window:GetWidth())
   window.titleLabel:SetHeight(20)
   window.titleLabel:SetPoint("TOPLEFT", window, "TOPLEFT")
   window.titleLabel:RegisterForDrag("LeftButton")
   window.titleLabel:SetScript("OnDragStart", function() window:StartMoving() end)
   window.titleLabel:SetScript("OnDragStop", function() window:StopMovingOrSizing() end)
   
   local fnt = window.titleLabel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
   fnt:SetHeight(16)
   fnt:SetWidth(200)
   fnt:SetPoint("LEFT", window.titleLabel, "LEFT", 8, -2)
   fnt:SetJustifyH("LEFT")
   local mapName = C_Map.GetMapInfo(C_Map.GetBestMapForUnit("player")).name or "UNKNOWN MAP"
   fnt:SetText(mapName)
   window.titleLabel:RegisterForClicks("RightButtonUp")
   window.titleLabel:SetScript("OnClick", function(s, button, down)
         if button == 'RightButton' then
            OpenCascadingWindow(window.titleLabel)
         end
   end)
   window.titleLabel:SetScript("OnLeave", function(s, motion)
         -- If the frame the mouse goes to isn't the cascade frame, then we want to close the cascade frame instead
         local frameUnderMouse = GetMouseFocus()
         if window.titleLabel.cascadeWindow and not frameUnderMouse:GetName():find('^MasterCollector.*CascadeFrame.*$') then
            CloseCascadeFrame(window.titleLabel.cascadeWindow)
         end
   end)
end
CreateWindow("MasterCollectorCurrentZone")


--------------------
-- Event Handling --
--------------------
-- Events must be registered to a frame. Since we only want these to fire once, we'll create an invisible
-- dummy frame to intercept and handle collection events
local eventFrame = CreateFrame("FRAME", "MasterCollectorEventFrame", UIParent)
eventFrame.events = {}
eventFrame:RegisterEvent("VARIABLES_LOADED")
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
eventFrame.events.VARIABLES_LOADED = function()
	print('MASTERCOLLECTOR VARIABLES_LOADED')
end
eventFrame.events.ADDON_LOADED = function(loadedAddonName)
	if loadedAddonName:find('^'..addonName..'%-') then
		print('MASTERCOLLECTOR: ' .. loadedAddonName)
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
function MasterCollector:RegisterModule(ModuleName, mod)
	if MasterCollector.Modules[ModuleName] then
		print('Module "'..ModuleName..'" cannot be registered twice.')
		return
	end
	MasterCollector.Modules[ModuleName]={
		DB = mod.DB
	}
	if mod.events then
		for k,v in pairs(mod.events) do
			if not eventFrame.events[k] then
				eventFrame.events[k] = {}
				eventFrame:RegisterEvent(k)
			end
			table.insert(eventFrame.events[k], v)
		end
	end
	print(ModuleName .. ' registered successfully')
end
