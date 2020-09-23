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
local WINDOW_MIN_WIDTH = 300
local WINDOW_MIN_HEIGHT = 200
local WINDOW_WIDTH=300
local WINDOW_HEIGHT=500
local WINDOW_LEFT_MARGIN = 8
local WINDOW_RIGHT_MARGIN = -8
local ROW_HEIGHT = 16
local ICON_WIDTH = 16
local INDENT_LEVEL_SPACING = 16
local SCROLLBAR_WIDTH = 18
--[[
local function CreateRow(container, rowType, indent)
    local row = CreateFrame("BUTTON", nil, container)
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint("RIGHT", container, "RIGHT")
    row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    local knownRows = #container.rows
    if knownRows == 0 then
        row:SetPoint("TOPLEFT", container)
    else
        row:SetPoint("TOPLEFT", container.rows[knownRows], "BOTTOMLEFT", INDENT_LEVEL_SPACING * ((indent and 1) or 0), 0)
    end
    container.rows[knownRows+1]=row
    
    -- TODO: is a collected icon desirable for a panel? It makes sense on individual items
    local collectedIcon = row:CreateTexture(nil, "ARTWORK")
    collectedIcon:SetSize(ICON_WIDTH, ICON_WIDTH) -- a texture must have at least a 1x1 size, otherwise no other frames can use it as a setpoint anchor
    collectedIcon:SetPoint("LEFT", row, "LEFT", WINDOW_LEFT_MARGIN, 0)
    collectedIcon:SetTexture("Interface\\AddOns\\MasterCollector\\assets\\Collected")
    
    local expandableIcon = row:CreateTexture(nil, "ARTWORK")
    expandableIcon:SetSize(ICON_WIDTH, ICON_WIDTH)
    expandableIcon:SetPoint("TOPRIGHT", row, "TOPRIGHT", WINDOW_RIGHT_MARGIN, 0)
    expandableIcon:SetTexture("Interface\\AddOns\\MasterCollector\\assets\\Collapse") -- Expand.blp if the panel can be opened, Collapse.blp if it can be closed
    
    -- TODO: fix the label text to be the remaining width between the row icon and expandable icon
    local label = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    label:SetHeight(ROW_HEIGHT)
    label:SetPoint("LEFT", collectedIcon, "RIGHT")
    label:SetPoint("RIGHT", expandableIcon, "LEFT")
    label:SetJustifyH("LEFT")
    label:SetText("DUMMY LABEL " .. #container.rows)
    
    return row
end
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
    cascadeFrame:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", -2, 0)
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
    anchorFrame:SetScript("OnLeave", function(s, motion)
            -- If the frame the mouse goes to isn't the new cascade frame, then we want to close it instead
            -- TODO: make this work without depending on a name. It shouldn't be necessary since the anchor frame should know it has a child frame
            local frameUnderMouse = GetMouseFocus()
            if not frameUnderMouse:GetName() or (anchorFrame.cascadeWindow and not frameUnderMouse:GetName():find('^MasterCollector.*CascadeFrame.*$')) then
                CloseCascadeFrame(anchorFrame.cascadeWindow)
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
    local window = CreateFrame("FRAME", windowName, UIParent)
    window:SetMovable(true)
    window:SetToplevel(true)
    window:EnableMouse(true)
    window:SetPoint("RIGHT", -400, 0) -- this line is responsible for the window position reseting on /reloadui
    window:SetWidth(WINDOW_WIDTH)
    window:SetHeight(WINDOW_HEIGHT)
    window:SetResizable(true)
    window:SetMinResize(WINDOW_MIN_WIDTH, WINDOW_MIN_HEIGHT)
    window:SetClampedToScreen(true) -- prevents window from being dragged off-screen
    window:SetUserPlaced(true) -- this will allow window placement to be stored in cache, but is that reliable enough? Should we set up a window placement along with the saved sessions?
    
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
    --local mapName = C_Map.GetMapInfo(C_Map.GetBestMapForUnit("player")).name or "UNKNOWN MAP"
    fnt:SetText('Loading...')
    window.titleLabel:RegisterForClicks("RightButtonUp")
    window.titleLabel:SetScript("OnClick", function(s, button, down)
            if button == 'RightButton' then
                OpenCascadingWindow(window.titleLabel)
            end
    end)
    
    local scrollFrame = CreateFrame('ScrollFrame', windowName .. 'scrollframe', window)
    scrollFrame:SetPoint("TOPLEFT", window.titleLabel, "BOTTOMLEFT")
    scrollFrame:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT")
    
    local grip = CreateFrame('Button', nil, scrollFrame)
    grip:SetSize(16, 16)
    grip:SetPoint("BOTTOMRIGHT", -5, 5)
    grip:SetNormalTexture("Interface\\AddOns\\MasterCollector\\assets\\resize")
    grip:RegisterForDrag("LeftButton")
    grip:SetScript("OnDragStart", function() window:StartSizing() end)
    grip:SetScript("OnDragStop", function() window:StopMovingOrSizing() end)
    scrollFrame.grip = grip
    
    local scrollbar = CreateFrame('Slider', windowName .. 'scrollBar', scrollFrame, "UIPanelScrollBarTemplate")
    scrollbar:SetWidth(SCROLLBAR_WIDTH)
    scrollbar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", -SCROLLBAR_WIDTH, -16)
    scrollbar:SetPoint("BOTTOMRIGHT", grip, "TOPRIGHT", 0, 16)
    scrollbar:SetMinMaxValues(0, 10)
    scrollbar:SetValue(0)
    scrollbar:SetValueStep(1)
    scrollFrame.bar = scrollbar
    
    local dataArea = CreateFrame('FRAME', windowName .. 'dataArea', scrollFrame)
    dataArea:SetPoint("TOPLEFT", window.titleLabel, "BOTTOMLEFT")
    dataArea:SetPoint("BOTTOMRIGHT", grip, "BOTTOMLEFT")
    dataArea.rows = {}
    window.dataArea = dataArea
    
    -- TODO: populate the dataArea with rows equal the maximum number of rows that could exist within the size limit
    local maxRows = math.floor(dataArea:GetHeight() / ROW_HEIGHT)
    for i=1,maxRows do
        CreateRow(dataArea, "data", false)
    end
    
    local resizing = false
    window:SetScript("OnSizeChanged", function(s, width, height)
            local newMaxRows = math.floor(dataArea:GetHeight()/ROW_HEIGHT)
            if newMaxRows ~= maxRows and not resizing then
                resizing = true
                if newMaxRows > maxRows then
                    for i=1, newMaxRows do
                        local row = dataArea.rows[i] or CreateRow(dataArea, "data", false)
                        row:Show()
                    end
                elseif newMaxRows < maxRows then
                    for i=maxRows,#dataArea.rows do
                        dataArea.rows[i]:Hide()
                    end
                end
                maxRows = newMaxRows
                resizing = false
            end
    end)
    
    window.SetData = function(dataTable, title)
        -- do something with the dataTable
        fnt:SetText(title)
    end
    
    return window
end
-- TODO: creating the window before the player finishes loading into the world will cause an error if setting the titleLabel with the current zone text
local currentZoneWindow = CreateWindow("MasterCollectorCurrentZone")
currentZoneWindow:RegisterEvent("ZONE_CHANGED_NEW_AREA")
currentZoneWindow:SetScript("OnEvent", function(self, event, ...)
        currentZoneWindow.SetData(nil, C_Map.GetMapInfo(C_Map.GetBestMapForUnit("player")).name or "UNKNOWN MAP")
end)
]]--

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
