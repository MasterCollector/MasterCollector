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
	
	local objectIcon = row:CreateTexture(nil, "ARTWORK")
	objectIcon:SetSize(ICON_WIDTH, ICON_WIDTH)
	objectIcon:SetPoint("LEFT", collectedIcon, "RIGHT")
	row.objectIcon = objectIcon
	
	local expandableIcon = row:CreateTexture(nil, "ARTWORK")
	expandableIcon:SetSize(ICON_WIDTH, ICON_WIDTH)
	expandableIcon:SetPoint("TOPRIGHT", row, "TOPRIGHT", WINDOW_RIGHT_MARGIN, 0)
	row.expandableIcon = expandableIcon
	
	local label = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	label:SetHeight(ROW_HEIGHT)
	label:SetPoint("LEFT", objectIcon, "RIGHT", 4, 0)
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
			if newMaxRows ~= maxRowsVisible and not resizing then
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
		if data.icon then
			row.objectIcon:SetTexture(data.icon)
			-- if the object icon is using a single file with multiple icons, then we can define a relative position in the image to display
			-- however, this isn't always done so we want to default to a full-size image if texture coords are not provided
			if data.txcoord then
				print(data.txcoord.left, data.txcoord.right, data.txcoord.top, data.txcoord.bottom)
				row.objectIcon:SetTexCoord(data.txcoord.left, data.txcoord.right, data.txcoord.top, data.txcoord.bottom)
			else
				row.objectIcon:SetTexCoord(0,1,0,1)
			end
			row.objectIcon:Show()
		end
		if data.type == "panel" then
			row.expanded = data.expanded
			row.collectedIcon:Hide()
			row.objectIcon:SetPoint("LEFT", row, "LEFT", WINDOW_LEFT_MARGIN, 0)
			row.label:SetPoint("LEFT", row.objectIcon, "RIGHT", 4, 0)
			
			SetExpandedTexture(row, data)
			row.expandableIcon:Show()
			
			row:RegisterForClicks("LeftButtonUp")
			row:SetScript("OnClick", function(self, button)
					data.expanded = not data.expanded
					SetExpandedTexture(row, data)
					window.Refresh()
			end)
		elseif data.type == "textonly" then
			row.collectedIcon:Hide()
			row.objectIcon:Hide()
			row.expandableIcon:Hide()
			row.label:SetPoint("LEFT", row, "LEFT", WINDOW_LEFT_MARGIN, 0)
		else
			row.collectedIcon:SetSize(ICON_WIDTH, ICON_WIDTH)
			if data.collected then
				row.collectedIcon:SetTexture("Interface\\AddOns\\MasterCollector\\assets\\Collected")
			else
				row.collectedIcon:SetTexture(nil)
			end
			row.collectedIcon:Show()
			row.objectIcon:SetPoint("LEFT", row.collectedIcon, "RIGHT")
		end
		row:Enable()
	end
	
	local refreshing = false
	window.Refresh = function()
		if not refreshing then
			refreshing = true
			local offset = scrollbar:GetValue()
			local targetRowCounter = 1
			local skipCounter = 0
			-- Update the scrollbar's max and min values
			local visibleDataEntries = window.dataArea.countVisibleDataEntries()
			if visibleDataEntries >= maxRowsVisible then
				scrollbar:SetMinMaxValues(0, visibleDataEntries - maxRowsVisible)
			else
				scrollbar:SetMinMaxValues(0, 0)
			end
			
			-- clear and disable all rows
			for _,row in pairs(dataArea.rows) do
				row.label:SetText('')
				row.collectedIcon:Hide()
				row.objectIcon:Hide()
				row.expandableIcon:Hide() -- we can't actually remove textures, so hiding is our best option
				row:SetScript("OnClick", nil)
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
			
			local function renderRowData(data, ischild)
				for k,v in pairs(data or {}) do
					if targetRowCounter > maxRowsVisible then return end
					if v.visible then
						if skipCounter < offset then
							skipCounter = skipCounter + 1
						else
							DrawRow(dataArea.rows[targetRowCounter], v)
							targetRowCounter = targetRowCounter + 1
							if v.expanded and v.children then
								renderRowData(v.children, true)
							end
						end
					end
				end
			end
			
			-- if there is information to show
			if dataArea.data and visibleDataEntries > 0 then
				renderRowData(dataArea.data)
			else
				DrawRow(dataArea.rows[1], {type="textonly",text='No collectible things found for this area.'})
			end
			refreshing = false
		end
	end
	
	window.dataArea.countVisibleDataEntries = function(tbl)
		if not window.dataArea.rows then return 0 end
		local visibleEntries = 0
		for _,v in pairs(tbl or window.dataArea.data or {}) do
			if v.visible then visibleEntries = visibleEntries + 1 end
			if v.children then visibleEntries = visibleEntries + window.dataArea.countVisibleDataEntries(v.children) end
		end
		return visibleEntries
	end
	
	window.SetData = function(dataTable, title)
		dataArea.data = dataTable
		fnt:SetText(title)
		scrollbar:SetValue(0)
		window.Refresh()
	end
	
	return window
end

-- create a panel cache from the localization file
local panelCache = {}
for k,v in pairs(MasterCollector.L.Panels) do
	panelCache[k] = setmetatable({id=k},MasterCollector.structs.panel)
end

local function GetCurrentZoneData()
	local mapID = C_Map.GetBestMapForUnit("player") -- TODO: this won't work if you're logging in from a sub-map. Need to determine the parent zone map instead. May be able to do this exclusively with API calls
	local data, workingItem = {}
	for mod,modTable in pairs(MasterCollector.Modules) do
		if modTable.mapData and modTable.mapData[mapID] then
			for _,entry in pairs(modTable.mapData[mapID]) do
				local panelID = entry[1]
				local items = entry[2]
				for i=1,#items do
					-- TODO: if the map data has something that isn't in the DB, how should we handle it? ignoring it for now, but this really shouldn't happen so an error message may be more appropriate
					workingItem = modTable.DB[panelID][items[i]] or nil
					if workingItem then
						if not data[panelID] then
							data[panelID] = setmetatable({id=panelID,children={},expanded=true},MasterCollector.structs.panel)
						end
						data[panelID].children[items[i]] = workingItem
					end
				end
			end
		end
	end
	return mapID, data
end

function MasterCollector:FlagModAsLoaded(modName)
	if MasterCollector.Modules and MasterCollector.Modules[modName] then
		MasterCollector.Modules[modName].loaded = true
	end
	-- do a quick scan of registered modules. If we detect a
	for mod,modTable in pairs(MasterCollector.Modules) do
		if not modTable.loaded then return end
	end
	-- if all registered modules have finished loading, then we can finish the start-up process and open windows
	MasterCollector:Start()
end

function MasterCollector:Start()
	local currentZoneWindow = CreateWindow("MasterCollectorCurrentZone", "currentZone")
	local mapID, data = GetCurrentZoneData()
	currentZoneWindow.SetData(data, C_Map.GetMapInfo(mapID).name or "UNKNOWN MAP")
	-- temporary data preload here
	currentZoneWindow:RegisterEvent("PLAYER_ENTERING_WORLD")
	currentZoneWindow:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	currentZoneWindow:SetScript("OnEvent", function(self, event, ...)
		-- the current zone list should perform the same initial load as it does with zone map changes
		if event == "PLAYER_ENTERING_WORLD" or "ZONE_CHANGED_NEW_AREA" then
			local mapID, data = GetCurrentZoneData()
			currentZoneWindow.SetData(data, C_Map.GetMapInfo(mapID).name or "UNKNOWN MAP")
		end
	end)
end