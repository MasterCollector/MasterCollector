local MasterCollector = select(2,...)

MasterCollector.harvest = function()
	local TMogGetItemInfo = C_TransmogCollection.GetItemInfo
	local GetItemInfo = GetItemInfo
	local items = {}
	local minModID = 0   -- default appearance
	local maxModID = 156 -- covenants
	local pendingCounter = 0
	print('[MasterCollector] Harvesting all items with appearances...')
	for itemID=1,185000,1
	do
		local id,_,_,loc,_,classID,subclassID = GetItemInfoInstant(itemID)
		-- if the itemID exists and (is weapon OR (is armor and not a trinket/ring/neck/etc or relic))
		if id and (classID == 2 or (classID == 4 and(subclassID ~= 0 and subclassID ~= 11))) then
			local item = Item:CreateFromItemID(id)
			-- it must be a valid itemID. the item mixin will tell us this easily
			if not item:IsItemEmpty() then
				pendingCounter = pendingCounter + 1
				item:ContinueOnItemLoad(function()
						local name,_,rarity,_,_,_,_,_,_,_,_,_,_,bindType = GetItemInfo(id)
						-- don't care about grey or white quality items. they don't grant appearances so they aren't worth going further
						if (rarity or 0) > 1 then
							for mod=minModID,maxModID,1 do
								local appearanceID,sourceID = TMogGetItemInfo(itemID, mod)
								if appearanceID then
									if not items[itemID] then
										local itemData = {}
										itemData.name = name
										itemData.rarity = rarity
										itemData.bindType = bindType
										itemData.classID = classID
										itemData.subclassID = subclassID
										itemData.appearanceData = {}
										items[itemID] = itemData
									end
									table.insert(items[itemID].appearanceData, { mod, appearanceID, sourceID})
								end
							end
						end
						pendingCounter = pendingCounter - 1
				end)
			end
		end
	end
	MCItemHarvestData = items
	-- Output to chat window as progress is made. Since it can take a few seconds for harvesting to finish, this makes it a bit more clear when it's safe to refresh/logout
	local function pendingItemCheck()
		print('[MasterCollector] Items remaining: ' .. pendingCounter)
		if pendingCounter > 0 then
			C_Timer.After(1, function()
				pendingItemCheck()
			end)
		else
			print('[MasterCollector] Item and appearance data has been collected. /reload or close your client and inspect SavedVariables for the collected data.')
		end
	end
	pendingItemCheck()
end

-- create a panel cache from the localization file
local panelCache = {}
for k,v in pairs(MasterCollector.L.Panels) do
	panelCache[k] = setmetatable({id=k},MasterCollector.structs.panel)
end

local function GetClosestZoneMapFromMapID(mapID)
	local mapInfo = C_Map.GetMapInfo(mapID)
	if mapInfo and mapInfo.mapType == 5 and mapInfo.parentMapID then
		return GetClosestZoneMapFromMapID(mapInfo.parentMapID)
	end
	return mapInfo.mapID
end

local function GetCurrentZoneData()
	local mapID = GetClosestZoneMapFromMapID(C_Map.GetBestMapForUnit("player"))
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

function MasterCollector:Start()
	local currentZoneWindow = MasterCollector.Window:Get("MasterCollectorCurrentZone")
	if not currentZoneWindow then
		currentZoneWindow = MasterCollector.Window:New("MasterCollectorCurrentZone", "currentZone")
	end
	local mapID, data = GetCurrentZoneData()
	if not mapID then return end
	currentZoneWindow:SetTitle(((mapID and C_Map.GetMapInfo(mapID).name) or "UNKNOWN MAP" ) .. ' ('..mapID..')')
	currentZoneWindow:SetData(data, true)
	-- temporary data preload here
	currentZoneWindow.displayFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	currentZoneWindow.displayFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	currentZoneWindow.displayFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
	currentZoneWindow.displayFrame:SetScript("OnEvent", function(self, event, ...)
		-- the current zone list should perform the same initial load as it does with zone map changes
		-- TODO: add listender for ZONE_CHANGED_INDOOR. check micro zone map, then select parent if exists. This will resolve the 1550-1671 map transition (shadowlands to oribos)
		if event == "PLAYER_ENTERING_WORLD" or "ZONE_CHANGED_NEW_AREA" or "ZONE_CHANGED_INDOORS" then
			local mapID, data = GetCurrentZoneData()
			if mapID then
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