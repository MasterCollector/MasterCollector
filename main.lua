local MasterCollector = select(2,...)

-- create a panel cache from the localization file
local panelCache = {}
for k,v in pairs(MasterCollector.L.Panels) do
	panelCache[k] = setmetatable({id=k},MasterCollector.structs.panel)
end

local mapDisplayOverrides = {
	[338] = 338, -- molten front
	[1648] = 1648, -- the maw (intro to shadowlands version)
	[577] = 577, -- draenor (intro - dark portal scenario)
	[427] = 427, -- Coldridge Valley
	[428] = 427, -- Frostmane Hovel -> Coldridge Valley
	[578] = 578,
	[2085] = 2025, -- primalist's future -> thaldraszus
	[2088] = 2025, -- pandaren revolution -> thaldraszus
	[2089] = 2025, -- the black empire -> thaldraszus
	[2090] = 2025, -- the gnoll war -> thaldraszus
	[2091] = 2025, -- war of the shifting sands -> thaldraszus
	[2092] = 2025, -- azmerloth (scenario map) -> thaldraszus
	[464] = 463, -- spitescale cavern -> echo isles
	[2171] = 2171, -- abberus quest area 1
	[2172] = 2171, -- abberus quest area 2
	[2173] = 2171, -- aberrus quest area 3
	[2174] = 2171 -- aberrus quest area 4
}
local function GetClosestZoneMapFromMapID(mapID)
	if not mapID then return end
	if mapDisplayOverrides[mapID] then return mapDisplayOverrides[mapID] end
	local mapInfo = C_Map.GetMapInfo(mapID)
	-- molten front is maptype 6, while most other maps with type 6 are junk. May want to replace this hard-coded value with a map index override
	if mapInfo and (mapInfo.mapType == 5 or (mapInfo.mapType == 6 and mapID ~= 338)) and mapInfo.parentMapID then
		return GetClosestZoneMapFromMapID(mapInfo.parentMapID)
	end
	return mapInfo.mapID
end

local function GetCurrentZoneData(mapID)
	if not mapID then
		mapID = GetClosestZoneMapFromMapID(C_Map.GetBestMapForUnit("player"))
	end
	local data, workingItem = {}
	local mapData = MasterCollector.DB:GetMapMetadata(mapID)
	for panel, panelData in pairs(mapData or {}) do
		if not data[panel] then
			data[panel] = setmetatable({id=panel,children={},expanded=true},MasterCollector.structs.panel)
		end
		for id,value in pairs(panelData) do
			data[panel].children[id] = MasterCollector.DB:GetObjectData(panel, id)
			if data[panel].children[id].expanded == nil and data[panel].children[id].children then
				data[panel].children[id].expanded = true
			end
		end
	end
	
	return mapID, data
end
function MasterCollector:MapData(mapID)
	return GetCurrentZoneData(mapID)
end

function MasterCollector:Start()
	-- initialize the database(s)
	MasterCollector.DB:Process()

	local currentZoneWindow = MasterCollector.Window:Get("MasterCollectorCurrentZone")
	if not currentZoneWindow then
		currentZoneWindow = MasterCollector.Window:New("MasterCollectorCurrentZone", "currentZone")
	end
	currentZoneWindow.displayFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	currentZoneWindow.displayFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	currentZoneWindow.displayFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
	currentZoneWindow.displayFrame:RegisterEvent("ZONE_CHANGED")
	currentZoneWindow.displayFrame:RegisterEvent("NEW_WMO_CHUNK")
	currentZoneWindow.displayFrame:SetScript("OnEvent", function(self, event, ...)
		-- the current zone list should perform the same initial load as it does with zone map changes
		if event == "PLAYER_ENTERING_WORLD" or "ZONE_CHANGED" or "ZONE_CHANGED_NEW_AREA" or "ZONE_CHANGED_INDOORS" or "NEW_WMO_CHUNK" then
			local mapID, data = GetCurrentZoneData()
			if mapID and mapID ~= currentZoneWindow.mapID then
				currentZoneWindow.mapID = mapID
				currentZoneWindow:SetTitle(((mapID and C_Map.GetMapInfo(mapID).name) or "UNKNOWN MAP" ) .. ' ('..mapID..')')
				currentZoneWindow:SetData(data, true)
			end
		end
	end)
end

-- temporary function. This should find its way into a frame manager script
function MasterCollector:RefreshWindows(resort)
	local currentZoneWindow = MasterCollector.Window:Get("MasterCollectorCurrentZone")
	if currentZoneWindow then
		if resort then currentZoneWindow:Sort() end
		currentZoneWindow:Refresh()
	end
end