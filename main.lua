local addonName = select(1,...)
MasterCollector = select(2,...)

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
	
	local collectedIcon = row:CreateTexture(nil, "ARTWORK")
	collectedIcon:SetSize(ICON_WIDTH, ICON_WIDTH) -- a texture must have at least a 1x1 size, otherwise no other frames can use it as a setpoint anchor
	collectedIcon:SetPoint("LEFT", row, "LEFT", WINDOW_LEFT_MARGIN, 0)
	row.collectedIcon = collectedIcon
	
	local expandableIcon = row:CreateTexture(nil, "ARTWORK")
	expandableIcon:SetSize(ICON_WIDTH, ICON_WIDTH)
	expandableIcon:SetPoint("TOPRIGHT", row, "TOPRIGHT", WINDOW_RIGHT_MARGIN, 0)
	row.expandableIcon = expandableIcon
	
	local label = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	label:SetHeight(ROW_HEIGHT)
	label:SetPoint("LEFT", collectedIcon, "RIGHT")
	label:SetPoint("RIGHT", expandableIcon, "LEFT")
	label:SetJustifyH("LEFT")
	row.label = label
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
local CreateWindow = function(windowName, windowType)
	--	local window = _G[windowName] or CreateFrame("FRAME", windowName, UIParent)
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
	scrollbar:SetValue(0)
	scrollbar:SetValueStep(1)
	scrollbar:SetMinMaxValues(0,0)
	scrollbar:SetObeyStepOnDrag(true)
	scrollbar.scrollStep = 1
	scrollbar:SetScript("OnValueChanged", function() window.Refresh() end)
	scrollFrame.bar = scrollbar
	
	local dataArea = CreateFrame('FRAME', windowName .. 'dataArea', scrollFrame)
	dataArea:SetPoint("TOPLEFT", window.titleLabel, "BOTTOMLEFT")
	dataArea:SetPoint("BOTTOMRIGHT", grip, "BOTTOMLEFT")
	dataArea.rows = {}
	window.dataArea = dataArea
	
	-- populate the dataArea with the maximum number of visible rows
	local maxRowsVisible = math.floor(dataArea:GetHeight() / ROW_HEIGHT)
	for i=1,maxRowsVisible do
		CreateRow(dataArea, "data", false)
	end
	
	local resizing = false
	window:SetScript("OnSizeChanged", function(s, width, height)
			local newMaxRows = math.floor(dataArea:GetHeight()/ROW_HEIGHT)
			if newMaxRows ~= maxRows and not resizing then
				resizing = true
				if newMaxRows > maxRowsVisible then
					for i=1, newMaxRows do
						local row = dataArea.rows[i] or CreateRow(dataArea, "data", false)
						row:Show()
					end
				elseif newMaxRows < maxRowsVisible then
					for i=maxRowsVisible,#dataArea.rows do
						dataArea.rows[i]:Hide()
					end
				end
				maxRowsVisible = newMaxRows
				scrollbar:SetMinMaxValues(0, #dataArea.rows) -- TODO: this won't work if sections are collapsed
				window.Refresh()
				resizing = false
			end
	end)
	
	local SetExpandedTexture = function(row, data)
		-- Expand.blp if the panel can be opened, Collapse.blp if it can be closed
		if data.expanded then
			row.expandableIcon:SetTexture("Interface\\AddOns\\MasterCollector\\assets\\Collapse") -- up arrow
		else
			row.expandableIcon:SetTexture("Interface\\AddOns\\MasterCollector\\assets\\Expand") -- down arrow
		end
	end
	
	local DrawRow = function(row, data)
		row.label:SetText(data.text)
		if data.type == "panel" then
			row.expanded = data.expanded
			row.collectedIcon:SetSize(1,1) -- we can't just hide the icon because it'll still take space in the row and a 0-point size breaks anchors
			row.collectedIcon:Hide()
			
			SetExpandedTexture(row, data)
			row.expandableIcon:Show()
			
			row:RegisterForClicks("LeftButtonUp")
			row:SetScript("OnClick", function(self, button)
					data.expanded = not data.expanded
					SetExpandedTexture(row, data)
			end)
		else
			row.collectedIcon:SetSize(ICON_WIDTH, ICON_WIDTH)
			if data.collected then
				row.collectedIcon:SetTexture("Interface\\AddOns\\MasterCollector\\assets\\Collected")
			end
		end
		row:Enable()
	end
	
	window.Refresh = function()
		local offset = scrollbar:GetValue()
		local targetRowCounter = 1
		local skipCounter = 0
		-- Update the scrollbar's max and min values
		local visibleDataEntries = window.dataArea.countVisibleDataEntries(dataTable)
		if visibleDataEntries >= maxRowsVisible then
			scrollbar:SetMinMaxValues(0, visibleDataEntries - maxRowsVisible)
		else
			scrollbar:SetMinMaxValues(0, 0)
		end
		
		-- clear and disable all rows
		for _,row in pairs(dataArea.rows) do
			row.label:SetText('')
			row.collectedIcon:SetSize(1,1)
			row.collectedIcon:Hide()
			row.expandableIcon:Hide() -- we can't actually remove textures, so hiding is our best option
			row:Disable()
		end
		
		local minValue,maxValue = scrollbar:GetMinMaxValues()
		if minValue == maxValue then -- if the window fits all content, the scrollbar is effectively useless
			scrollbar.ScrollUpButton:Disable()
			scrollbar.ScrollDownButton:Disable()
		elseif offset <= minValue then -- if the scrollbar is at min position but there are more rows than the window will allow, allow only downward motion
			scrollbar.ScrollUpButton:Disable()
			scrollbar.ScrollDownButton:Enable()
		elseif offset >= maxValue then -- if the scrollbar is at max position, allow only upward motion
			scrollbar.ScrollUpButton:Enable()
			scrollbar.ScrollDownButton:Disable()
		else -- the scrollbar is somewhere between min and max so both directions should be enabled
			scrollbar.ScrollUpButton:Enable()
			scrollbar.ScrollDownButton:Enable()
		end
		
		if dataArea.data then
			for k,v in pairs(dataArea.data) do
				if targetRowCounter > maxRowsVisible then return end
				-- todo: need to set this up as a recursive function because of multiple nested rows
				if v.visible then
					if skipCounter < offset then
						skipCounter = skipCounter + 1
					else
						DrawRow(dataArea.rows[targetRowCounter], v)
						targetRowCounter = targetRowCounter + 1
					end
				end
			end
		else
			print('TODO: empty the list and present some kind of message indicating no data')
		end
	end
	
	window.dataArea.countVisibleDataEntries = function(tbl)
		if not window.dataArea.rows then return 0 end
		local visibleEntries = 0
		for _,v in pairs(tbl or window.dataArea.data) do
			if v.visible then visibleEntries = visibleEntries + 1 end
			if v.children then visibleEntries = visibleEntries + window.dataArea.countVisibleDataEntries(v.children) end
		end
		return visibleEntries
	end
	
	window.SetData = function(dataTable, title)
		dataArea.data = dataTable
		fnt:SetText(title)
		scrollbar:SetValue(0)
	end
	
	return window
end
-- TODO: creating the window before the player finishes loading into the world will cause an error if setting the titleLabel with the current zone text
local data = {
	{
		text="Battle Pets",
		visible=true,
		type="panel",
		expanded=true,
		children = {
			[635] = {collected=false},
			[448] = {collected=false},
			[1330] = {collected=false},
			[2468] = {collected=false}
		},
	},
	{
		text="Panel test #1",
		visible=true,
		type="panel",
		expanded=true,
	},
	{
		text="Panel test #2",
		visible=true,
		type="panel",
		expanded=true,
	},
	{
		text="Panel test #3",
		visible=true,
		type="panel",
		expanded=true,
	},
	{
		text="Panel test #4",
		visible=true,
		type="panel",
		expanded=true,
	},
	{
		text="Panel test #5",
		visible=true,
		type="panel",
		expanded=true,
	},
	{
		text="Panel test #6",
		visible=true,
		type="panel",
		expanded=true,
	},
	{
		text="Panel test #7",
		visible=true,
		type="panel",
		expanded=true,
	},
	{
		text="Panel test #8",
		visible=true,
		type="panel",
		expanded=false,
	},
	{
		text="Panel test #9",
		visible=true,
		type="panel",
		expanded=false,
	},
	{
		text="Panel test #10",
		visible=true,
		type="panel",
		expanded=false,
	},
	{
		text="Panel test #11",
		visible=true,
		type="panel",
		expanded=false,
	},
	{
		text="Panel test #12",
		visible=true,
		type="panel",
		expanded=false,
	},
	{
		text="Panel test #13",
		visible=true,
		type="panel",
		expanded=false,
	},
	{
		text="Panel test #14",
		visible=true,
		type="panel",
		expanded=false,
	}
}
local currentZoneWindow = CreateWindow("MasterCollectorCurrentZone", "currentZone")
-- temporary data preload here
currentZoneWindow.SetData(data, "TODO: set this on player load in")
currentZoneWindow:RegisterEvent("ZONE_CHANGED_NEW_AREA")
currentZoneWindow:SetScript("OnEvent", function(self, event, ...)
		currentZoneWindow.SetData(data, C_Map.GetMapInfo(C_Map.GetBestMapForUnit("player")).name or "UNKNOWN MAP")
end)
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
