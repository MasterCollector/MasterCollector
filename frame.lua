local MasterCollector = select(2, ...)
MasterCollector.Modules = {}

-- NOTE: NOT THE FINAL PRODUCT BUT SUFFICIENT FOR EARLY DRAFT TESTING OF CORE FUNCTIONALITY
local WINDOW_MIN_WIDTH = 300
local WINDOW_MIN_HEIGHT = 200
local WINDOW_WIDTH=300
local WINDOW_HEIGHT=500
local WINDOW_LEFT_MARGIN = 8
local WINDOW_RIGHT_MARGIN = -8
local ROW_HEIGHT = 16
local ICON_WIDTH = 16
local INDENT_LEVEL_SPACING = 10
local SCROLLBAR_WIDTH = 20
local cascadeFrame
local MapPins = MasterCollector.MapPins

local Window, Windows = {}, {}
Window.__index = Window
MasterCollector.Window = Window

local function CreateRow(container)
	local row = CreateFrame("BUTTON", nil, container)
	row:SetHeight(ROW_HEIGHT)
	row:SetPoint("RIGHT", container, "RIGHT")
	row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
	local knownRows = #container.rows
	if knownRows == 0 then
		row:SetPoint("TOPLEFT", container)
	else
		row:SetPoint("TOPLEFT", container.rows[knownRows], "BOTTOMLEFT", 0, 0)
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
local function SetExpandedTexture(row, data)
	-- Expand.blp if the panel can be opened, Collapse.blp if it can be closed
	if data.expanded then
		row.expandableIcon:SetTexture("Interface\\AddOns\\MasterCollector\\assets\\Collapse") -- up arrow
	else
		row.expandableIcon:SetTexture("Interface\\AddOns\\MasterCollector\\assets\\Expand") -- down arrow
	end
end
local function DrawRow(row, data, indentSize)
	row.label:SetText(data.text)
	row.objectIcon:SetPoint("LEFT", row, "LEFT", WINDOW_LEFT_MARGIN+((indentSize or 0)*INDENT_LEVEL_SPACING), 0)
	if data.icon then
		row.objectIcon:SetTexture(data.icon)
		-- if the object icon is using a single file with multiple icons, then we can define a relative position in the image to display
		-- however, this isn't always done so we want to default to a full-size image if texture coords are not provided
		if data.txcoord then
			row.objectIcon:SetTexCoord(data.txcoord.left, data.txcoord.right, data.txcoord.top, data.txcoord.bottom)
		else
			row.objectIcon:SetTexCoord(0,1,0,1)
		end
		row.objectIcon:Show()
	end
	if data.type == "panel" or data.type == "map" then
		row.expanded = data.expanded
		row.collectedIcon:Hide()
		row.label:SetPoint("LEFT", row.objectIcon, "RIGHT", 4, 0)
		
		SetExpandedTexture(row, data)
		row.expandableIcon:Show()
		
		row:RegisterForClicks("LeftButtonUp")
		row:SetScript("OnClick", function(self, button)
				data.expanded = not data.expanded
				SetExpandedTexture(row, data)
				-- TODO: this abomination needs to addressed. If window frame layers change AT ALL, this will break
				Windows[row:GetParent():GetParent():GetParent():GetName()]:Refresh()
		end)
	elseif data.type == "command" then
		row.collectedIcon:Hide()
		row.objectIcon:Hide()
		row.expandableIcon:Hide()
		row.label:SetPoint("LEFT", row, "LEFT", WINDOW_LEFT_MARGIN, 0)
	elseif data.type == "textonly" then
		row.collectedIcon:Hide()
		row.objectIcon:Hide()
		row.expandableIcon:Hide()
		row.label:SetPoint("LEFT", row, "LEFT", WINDOW_LEFT_MARGIN, 0)
	else
		row.collectedIcon:SetSize(ICON_WIDTH, ICON_WIDTH)
		row.collectedIcon:SetPoint("LEFT", row, "LEFT", WINDOW_LEFT_MARGIN+((indentSize-1 or 0)*INDENT_LEVEL_SPACING), 0)
		row.objectIcon:SetPoint("LEFT", row.collectedIcon, "RIGHT")
		if data.collected then
			row.collectedIcon:SetTexture("Interface\\AddOns\\MasterCollector\\assets\\Collected")
		else
			row.collectedIcon:SetTexture(nil)
		end
		row.collectedIcon:Show()
	end
	row:Enable()
end
local function CountVisibleDataEntries(tbl)
	local visibleEntries = 0
	for _,v in pairs(tbl or {}) do
		if v.visible then visibleEntries = visibleEntries + 1 end
		if v.children and v.expanded then visibleEntries = visibleEntries + CountVisibleDataEntries(v.children) end
	end
	return visibleEntries
end

local function ProcessWaypointsForData(data, remove)
	if not data then return end
	for _,v in pairs(data) do
		if v.visible then
			if v.children then ProcessWaypointsForData(v.children, remove) end
			if remove then
				MapPins:TryRemoveObjectPins(v)
			else
				MapPins:TryMapObject(v)
			end
		end
	end
end

local function CloseCascadeFrame(targetFrame)
	if targetFrame then
		if targetFrame.cascadeWindow then
			CloseCascadeFrame(targetFrame.cascadeWindow)
		end
		targetFrame:Hide()
	end
end
local function OpenCascadingWindow(anchorFrame, options)
	if not cascadeFrame then
		cascadeFrame = CreateFrame("FRAME", anchorFrame:GetName() .. 'CascadeFrame', anchorFrame, BackdropTemplateMixin and "BackdropTemplate")
		cascadeFrame:EnableMouse(true)
		cascadeFrame:SetFrameLevel(10) -- not a fan of setting an arbitrary level here, but it works
		local bd = {
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
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
		cascadeFrame.rows = {}
		cascadeFrame:SetScript("OnLeave", function(self, motion)
			CloseCascadeFrame(self)
		end)
		
		local optionsFrame = CreateFrame("FRAME", nil, cascadeFrame)
		optionsFrame:SetPoint("TOPLEFT", cascadeFrame, "TOPLEFT", 3, -3)
		optionsFrame:SetPoint("BOTTOMRIGHT", cascadeFrame, "BOTTOMRIGHT", -3, 3)
		optionsFrame.rows = {}
		cascadeFrame.optionsFrame = optionsFrame
	end
	
	cascadeFrame.anchor = anchorFrame
	cascadeFrame:SetWidth(200)
	cascadeFrame:SetPoint("TOPLEFT", 0, 0)

	-- If the frame the mouse goes to isn't the new cascade frame or any of its children, then we want to close it instead
	anchorFrame:SetScript("OnLeave", function(s, motion)
		local frameUnderMouse = GetMouseFocus()
		if frameUnderMouse ~= cascadeFrame and frameUnderMouse ~= cascadeFrame.optionsFrame and frameUnderMouse:GetParent() ~= cascadeFrame.optionsFrame then
			CloseCascadeFrame(cascadeFrame)
			anchorFrame.cascadeWindow = nil
			anchorFrame:SetScript("OnLeave", nil)
		end
	end)
	
	for k,v in pairs(options or {}) do
		local row = cascadeFrame.optionsFrame.rows[k]
		if not row then
			row = CreateRow(cascadeFrame.optionsFrame)
			row:RegisterForClicks("LeftButtonUp")
			row:EnableMouse(true)
		end
		DrawRow(row, v, 0)
		row:SetScript("OnClick", function()
			v.command()
			CloseCascadeFrame(cascadeFrame)
		end)
	end
	
	-- need to set height after visible rows were evaluated
	cascadeFrame:SetHeight(#cascadeFrame.optionsFrame.rows*ROW_HEIGHT + 6)
	cascadeFrame:Show()
end

function Window:Get(name)
	return Windows[name]
end
function Window:New(name, type, title)
	if Windows[name] then
		error('[MC]: A window with the name ' .. name .. ' already exists!')
	end
	local wnd = {
		name = name,
		type = type,
		refreshing = false,
		data = {},
		maxVisibleRows = 0
	}
	setmetatable(wnd, Window)
	local window = CreateFrame("FRAME", name, UIParent, BackdropTemplateMixin and "BackdropTemplate")
	window:SetMovable(true)
	window:SetToplevel(true)
	window:EnableMouse(true)
	window:EnableMouseWheel(true)
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
	window.titleBar = CreateFrame('Button', name..'TitleBar', window)
	window.titleBar:SetHeight(20)
	window.titleBar:SetPoint("TOPLEFT", window, "TOPLEFT")
	window.titleBar:SetPoint("RIGHT", window, "RIGHT")
	window.titleBar:RegisterForDrag("LeftButton")
	window.titleBar:SetScript("OnDragStart", function() window:StartMoving() end)
	window.titleBar:SetScript("OnDragStop", function() window:StopMovingOrSizing() end)
	
	local titleLabel = window.titleBar:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	titleLabel:SetHeight(16)
	titleLabel:SetPoint("LEFT", window.titleBar, "LEFT", 8, -2)
	titleLabel:SetPoint("RIGHT", window.titleBar, "RIGHT")
	titleLabel:SetJustifyH("LEFT")
	titleLabel:SetText(title or 'Loading...')
	window.titleBar:RegisterForClicks("RightButtonUp")
	window.titleBar:SetScript("OnClick", function(s, button, down)
			if button == 'RightButton' then
				OpenCascadingWindow(window.titleBar, window.contextMenuOptions)
			end
	end)
	window.titleBar.label = titleLabel
	
	window.closeButton = CreateFrame("Button", nil, window.titleBar, "UIPanelCloseButton");
	window.closeButton:SetPoint("TOPRIGHT", window.titleBar, "TOPRIGHT", 4, 3);
	window.closeButton:SetScript("OnClick", function()
		wnd:Hide()
	end);
	
	local scrollFrame = CreateFrame('ScrollFrame', name .. 'scrollframe', window)
	window.scrollFrame = scrollFrame
	scrollFrame:SetPoint("TOPLEFT", window.titleBar, "BOTTOMLEFT")
	scrollFrame:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT")
	
	local grip = CreateFrame('Button', nil, scrollFrame)
	grip:SetSize(16, 16)
	grip:SetPoint("BOTTOMRIGHT", -5, 5)
	grip:SetNormalTexture("Interface\\AddOns\\MasterCollector\\assets\\resize")
	grip:RegisterForDrag("LeftButton")
	grip:SetScript("OnDragStart", function() window:StartSizing() end)
	grip:SetScript("OnDragStop", function() window:StopMovingOrSizing() end)
	scrollFrame.grip = grip
	
	local scrollbar = CreateFrame('Slider', name .. 'scrollBar', scrollFrame, "UIPanelScrollBarTemplate")
	scrollbar:SetWidth(SCROLLBAR_WIDTH)
	scrollbar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", -SCROLLBAR_WIDTH, -19)
	scrollbar:SetPoint("BOTTOMRIGHT", grip, "TOPRIGHT", 0, 16)
	scrollbar:SetValue(0)
	scrollbar:SetValueStep(1)
	scrollbar:SetMinMaxValues(0,0)
	scrollbar:SetObeyStepOnDrag(true)
	scrollbar.scrollStep = 1
	scrollbar:SetScript("OnValueChanged", function() wnd:Refresh() end)
	scrollFrame.bar = scrollbar
	
	-- need to set the script after scrollbar is defined, otherwise you get nil without exposing a non-local variable
	window:SetScript("OnMouseWheel", function(self, delta)
		scrollbar:SetValue(scrollbar:GetValue()-delta)
	end)
	
	local dataArea = CreateFrame('FRAME', name .. 'dataArea', scrollFrame)
	dataArea:SetPoint("TOPLEFT", window.titleBar, "BOTTOMLEFT")
	dataArea:SetPoint("BOTTOMRIGHT", grip, "BOTTOMLEFT")
	dataArea.rows = {}
	window.dataArea = dataArea
	local resizing = false
	window:SetScript("OnSizeChanged", function(s, width, height)
			local newMaxRows = wnd:CalculateMaxVisibleRows()
			if newMaxRows ~= wnd.maxVisibleRows and not resizing then
				resizing = true
				if newMaxRows > wnd.maxVisibleRows then
					for i=1, newMaxRows do
						local row = dataArea.rows[i] or CreateRow(dataArea)
						row:Show()
					end
				elseif newMaxRows < wnd.maxVisibleRows then
					for i=wnd.maxVisibleRows,#dataArea.rows do
						dataArea.rows[i]:Hide()
					end
				end
				wnd.maxVisibleRows = newMaxRows
				scrollbar:SetMinMaxValues(0, #dataArea.rows) -- TODO: this won't work if sections are collapsed
				wnd:Refresh()
				resizing = false
			end
	end)
	
	wnd.displayFrame = window
	-- populate the dataArea with the maximum number of visible rows
	wnd.maxVisibleRows = wnd:CalculateMaxVisibleRows()
	for i=1,wnd.maxVisibleRows do
		CreateRow(dataArea)
	end
	
	window.contextMenuOptions = {
		{
			text = "Show Waypoints",
			type = "command",
			command = function()
				ProcessWaypointsForData(wnd.data)
			end,
		},
		{
			text = "Hide Waypoints",
			type = "command",
			command = function()
				ProcessWaypointsForData(wnd.data, true)
			end,
		},
	}
	
	Windows[name]=wnd
	return wnd
end
function Window:CalculateMaxVisibleRows()
	return math.floor(self.displayFrame.dataArea:GetHeight() / ROW_HEIGHT)
end
function Window:Refresh()
	if not self.refreshing then
		self.refreshing = true
		local scrollbar = self.displayFrame.scrollFrame.bar
		local offset = scrollbar:GetValue()
		local targetRowCounter = 1
		local skipCounter = 0
		
		-- Update the scrollbar's max and min values
		local visibleDataEntries = CountVisibleDataEntries(self.data)
		-- if the number of rows that could be rendered exceeds the number of rows allowed by the window, set the scrollbar with a max offset
		if visibleDataEntries >= self.maxVisibleRows then
			scrollbar:SetMinMaxValues(0, visibleDataEntries - self.maxVisibleRows)
		else
			-- if there are more available rows than visible entries, we want to force the scrollbar back to a 0 position before rendering
			offset = 0
			scrollbar:SetValue(0)
			scrollbar:SetMinMaxValues(0, 0)
		end
		
		-- clear and disable all rows
		for _,row in pairs(self.displayFrame.dataArea.rows) do
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
		
		local function renderRowData(data, indentLevel)
			for k,v in pairs(data or {}) do
				if targetRowCounter > self.maxVisibleRows then return end
				if v.visible then
					if skipCounter < offset then
						skipCounter = skipCounter + 1
					else
						DrawRow(self.displayFrame.dataArea.rows[targetRowCounter], v, (indentLevel or 0))
						targetRowCounter = targetRowCounter + 1
					end
					
					-- if the skipped section was an expanded panel, we need to still inspect the children to render their data
					if v.expanded and v.children then
						renderRowData(v.children, (indentLevel or 0) + 1)
					end
				end
			end
		end
		
		-- if there is information to show
		if self.data and visibleDataEntries > 0 then
			renderRowData(self.data)
		else
			if self.type ~= "debug" then
				DrawRow(self.displayFrame.dataArea.rows[1], {type="textonly",text='No collectible things found for this area.'})
			end
		end
		self.refreshing = false
	end
end
function Window:SetData(dataTable, autoSort)
	self.data = dataTable or {}
	self.displayFrame.scrollFrame.bar:SetValue(0)
	if autoSort then
		self:Sort()
	end
end
function Window:SetTitle(title)
	self.displayFrame.titleBar.label:SetText(title)
end
function Window:Show()
	self.displayFrame:Show()
end
function Window:Sort()
	local function sortData(dataSet)
		local sortedSet = {}
		-- sort the current dataSet keys
		local keys={}
		for k in pairs(dataSet or {}) do keys[#keys+1]=k end
		table.sort(keys, function(a,b) return (dataSet[a].sortkey or dataSet[a].text) < (dataSet[b].sortkey or dataSet[b].text) end)
		-- rebuild the data as a sorted set
		for idx,key in pairs(keys) do
			sortedSet[idx] = dataSet[key]
			-- if the dataset for the given key has children, then we want to run the sort on the child set too
			if dataSet[key].children then
				sortedSet[idx].children = sortData(dataSet[key].children)
			end
		end
		return sortedSet
	end
	
	self.data = sortData(self.data)
	self:Refresh()
end
function Window:Hide()
	self.displayFrame:Hide()
end