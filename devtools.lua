local MasterCollector = MasterCollector
local debugWindow = MasterCollector.Window:New("MasterCollectorHarvester", "debug", "Data Collector")
local function SaveDebugData()
	MCGathererDataPC = debugWindow.data
end
local function CreateMap(id, name)
	local mapPanel = {
		id = id,
		text = (name or "Unknown Map") .. " (" .. id .. ")",
		type = "map",
		children = {},
		expanded = true
	}
	setmetatable(mapPanel, MasterCollector.structs.map)
	return mapPanel
end
local function FindMapOrParent(mapID)
	if debugWindow.data[mapID] then
		return debugWindow.data[mapID]
	end
	local parent
	local mapInfo = C_Map.GetMapInfo(mapID)
	if (mapInfo.mapType == 3 or mapInfo.mapType == 5) and mapInfo.parentMapID then
		parent = FindMapOrParent(mapInfo.parentMapID)
	end
	if parent then
		if parent.children[mapID] then
			return parent.children[mapID]
		end
		parent.children[mapID] = CreateMap(mapID, mapInfo.name)
		return parent.children[mapID]
	end
	debugWindow.data[mapID] = CreateMap(mapID, mapInfo.name)
	return debugWindow.data[mapID]
end
local function ObjectExistsInContainer(container, type, key)
	for _,v in pairs(container.children or {}) do
		if v.type == type and v.id == key then
			return true
		end
	end
	return false
end

local events = {}
-- LOOT_OPENED works for treasures since they contain loot, but it doesn't work for non-loot treasures
events.LOOT_OPENED = function()
	local guid = GetLootSourceInfo(1)
	if guid then
		local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid);
		if(type == "GameObject") then
		  local text = GameTooltipTextLeft1:GetText()
		  print('ObjectID: '..(npc_id or 'UNKNOWN').. ' || ' .. 'Name: ' .. (text or 'UNKNOWN'))
	   end
	end
end
events.QUEST_DETAIL = function(questStartItemID)
	local questID = GetQuestID()
	if questID == 0 then return end
	local quest = {
		id = questID,
		visible = true,
		type = "quest"
	}
	setmetatable(quest, MasterCollector.structs.quest)
	local npc = "questnpc"
	local guid = UnitGUID(npc)
	if not guid then
		npc = "npc"
		guid = UnitGUID(npc)
	end
	local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid
	if guid then type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid) end
	print("QUEST_DETAIL: #" .. questID)
	
	-- this condition apparently never happens because questStartItemID is always 0. Not sure if this just a blizzard bug or the event isn't properly documented
	if questStartItemID and questStartItemID > 0 then
		print('Started by ItemID: ' .. questStartItemID)
	end
	
	if type and npc_id then
		print('Granted by ' .. UnitName(npc) .. ' ('.. tonumber(npc_id) .. ')')
		quest.provider = UnitName(npc) .. ' ('.. tonumber(npc_id) .. ')'
	end
	
	local mapID = C_Map.GetBestMapForUnit("player")
	local mapPosition = C_Map.GetPlayerMapPosition(mapID, "player")
	if mapPosition then
		local posX, posY = mapPosition:GetXY()
		if posX and posY then
			quest.coords = '(' .. string.format('%.2f', posX * 100) .. ', ' .. string.format('%.2f', posY * 100) .. ')'
			print('Coordinates: (' .. string.format('%.2f', posX * 100) .. ', ' .. string.format('%.2f', posY * 100) .. ')')
		end
	end
	if mapID then
		local map = FindMapOrParent(mapID)
		if map and not ObjectExistsInContainer(map, quest.type, quest.id) then
			table.insert(map.children, quest)
			SaveDebugData()
			debugWindow:Refresh()
		end
	end
end
-- quests that immediately show the completion window (e.g. companion/follower quests) skip QUEST_DETAIL and only fire QUEST_COMPLETE
events.QUEST_COMPLETE = events.QUEST_DETAIL
events.VARIABLES_LOADED = function()
	debugWindow.data = MCGathererDataPC or {}
	local function initMetaTables(tbl)
		for _,v in pairs(tbl) do
			if not getmetatable(v) then
				setmetatable(v, MasterCollector.structs[v.type])
			end
			if v.children then initMetaTables(v.children) end
		end
	end
	initMetaTables(debugWindow.data)
	debugWindow:Refresh()
end
events.ZONE_CHANGED_NEW_AREA = function()
	local mapID = C_Map.GetBestMapForUnit("player")
	if not mapID then return end
	local mapInfo = C_Map.GetMapInfo(mapID)
	local parent = FindMapOrParent(mapID)
	if not parent then
		debugWindow.data[mapID] = CreateMap(mapID, mapInfo.name)
	elseif parent.id ~= mapID then
		parent.children[mapID] = CreateMap(mapID, mapInfo.name)
	end
	SaveDebugData()
	debugWindow:Refresh()
end
events.NEW_WMO_CHUNK = events.ZONE_CHANGED_NEW_AREA
MasterCollector:RegisterModuleEvents(events)
debugWindow:Show()
