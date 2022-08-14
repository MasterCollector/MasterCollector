local MasterCollector = MasterCollector
local debugWindow = MasterCollector.Window:New("MasterCollectorHarvester", "debug", "Data Collector")
local IsWorldQuest = C_QuestLog.IsWorldQuest
local IsBonusQuest = C_QuestLog.IsQuestTask
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
   local mapKey = 'map_'..mapID
   if debugWindow.data[mapKey] and debugWindow.data[mapKey].type == 'map' then
      return debugWindow.data[mapKey]
   end
   local parent
   local mapInfo = C_Map.GetMapInfo(mapID)
   if (mapInfo.mapType == 3 or mapInfo.mapType == 5) and mapInfo.parentMapID then
      parent = FindMapOrParent(mapInfo.parentMapID)
   end
   if parent then
      if parent.children[mapKey] and parent.children[mapKey].type == 'map' then
         return parent.children[mapKey]
      end
      parent.children[mapKey] = CreateMap(mapID, mapInfo.name)
      return parent.children[mapKey]
   end
   debugWindow.data[mapKey] = CreateMap(mapID, mapInfo.name)
   return debugWindow.data[mapKey]
end
local function ObjectExistsInContainer(container, type, key)
	for _,v in pairs(container.children or {}) do
		if v.type == type and v.id == key then
			return true
		end
	end
	return false
end

local function IsQuestIDKnown(questID)
	return questID and MasterCollector.DB:GetObjectData("quest", questID)
end

local questFound = 'Quest Completed: %d (%s)'
local questNotFound = 'Quest Completed: %d (%s) (Not found in DB)'
local completedQuestIDs = {}
local function CheckForNewlyTriggeredQuests()
	completedQuestIDs = C_QuestLog.GetAllCompletedQuestIDs()
	local refresh, quest = false
	for _,v in pairs(completedQuestIDs) do
		quest = MasterCollector.DB:GetObjectData("quest", v)
		if not quest then
			MasterCollector.DB.data.quest[v] = setmetatable({id=v,collected=true}, MasterCollector.structs.quest)
			print(string.format(questNotFound, v, MasterCollector.DB.data.quest[v].text))
		else
			if not quest.collected then
				print(string.format(questFound, v, quest.text))
				rawset(MasterCollector.DB.data.quest[v], "collected", true)
				refresh = true
			end
		end
	end
	if refresh then MasterCollector:RefreshWindows() end
	table.wipe(completedQuestIDs)
end
for _,v in pairs(C_QuestLog.GetAllCompletedQuestIDs()) do
	local quest = MasterCollector.DB:GetObjectData("quest", v)
	if quest then rawset(quest, "collected", true) end
end
local function SetCheckQuestIDsTimer()
	CheckForNewlyTriggeredQuests()
	C_Timer.After(1, SetCheckQuestIDsTimer)
end
SetCheckQuestIDsTimer()

local events = {}
-- LOOT_OPENED works for treasures since they contain loot, but it doesn't work for non-loot treasures
events.LOOT_OPENED = function()
	CheckForNewlyTriggeredQuests()
	local guid = GetLootSourceInfo(1)
	if guid then
		local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid);
		if(type == "GameObject") then
			local text = GameTooltipTextLeft1:GetText()
			print('ObjectID: '..(npc_id or 'UNKNOWN').. ' || ' .. 'Name: ' .. (text or 'UNKNOWN'))
			local mapID = C_Map.GetBestMapForUnit("player")
			local mapPosition = C_Map.GetPlayerMapPosition(mapID, "player")
			if mapPosition then
				local posX, posY = mapPosition:GetXY()
				if posX and posY then
					print('Coordinates: (' .. string.format('%.2f', posX * 100) .. ', ' .. string.format('%.2f', posY * 100) .. ', ' .. tostring(mapID) .. ')')
				end
			end
	   end
	end
end
events.QUEST_DETAIL = function(questStartItemID)
	CheckForNewlyTriggeredQuests()
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
		quest.provider = UnitName(npc) .. ' (' .. type .. ': ' .. tonumber(npc_id) .. ')'
		print('Granted by ' .. UnitName(npc) .. ' (' .. type .. ': ' .. tonumber(npc_id) .. ')')
	end
	
	local mapID = C_Map.GetBestMapForUnit("player")
	local mapPosition = C_Map.GetPlayerMapPosition(mapID, "player")
	if mapPosition then
		local posX, posY = mapPosition:GetXY()
		if posX and posY then
			quest.coords = '(' .. string.format('%.2f', posX * 100) .. ', ' .. string.format('%.2f', posY * 100) .. ', ' .. tostring(mapID) .. ')'
			print('Coordinates: (' .. string.format('%.2f', posX * 100) .. ', ' .. string.format('%.2f', posY * 100) .. ', ' .. tostring(mapID) .. ')')
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
events.QUEST_COMPLETE = function()
	local questID = GetQuestID()
	if questID == 0 then return end
	
	local mapID = C_Map.GetBestMapForUnit("player")
	if mapID then
		local map = FindMapOrParent(mapID)
		if map and not ObjectExistsInContainer(map, "quest", questID) then
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
				quest.provider = UnitName(npc) .. ' ('.. tonumber(npc_id) .. ')'
				print('Granted by ' .. UnitName(npc) .. ' ('.. tonumber(npc_id) .. ')')
			end
			local mapPosition = C_Map.GetPlayerMapPosition(mapID, "player")
			if mapPosition then
				local posX, posY = mapPosition:GetXY()
				if posX and posY then
					quest.coords = '(' .. string.format('%.2f', posX * 100) .. ', ' .. string.format('%.2f', posY * 100) .. ', ' .. tostring(mapID) .. ')'
					print('Coordinates: (' .. string.format('%.2f', posX * 100) .. ', ' .. string.format('%.2f', posY * 100) .. ', ' .. tostring(mapID) .. ')')
				end
			end
			table.insert(map.children, quest)
			SaveDebugData()
			debugWindow:Refresh()
		end
	end
	CheckForNewlyTriggeredQuests()
end
events.QUEST_ACCEPTED = function(questID)
	CheckForNewlyTriggeredQuests()
	if not questID then return end
	-- if it's a world quest, just print the ID and name so it's easier to tag
	local mapID = C_Map.GetBestMapForUnit("player")
	local name = C_TaskQuest.GetQuestInfoByQuestID(questID)
	if IsWorldQuest(questID) then
		print('MapID ' .. mapID .. ' World Quest #' .. questID .. ': ' .. name)
	end
	if IsBonusQuest(questID) then
		print('MapID ' .. mapID .. ' Bonus/Task Quest #' .. questID .. ': ' .. name)
	end
	
end
events.VARIABLES_LOADED = function()
	CheckForNewlyTriggeredQuests()
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
	CheckForNewlyTriggeredQuests()
	local mapID = C_Map.GetBestMapForUnit("player")
	if not mapID then return end
	_ = FindMapOrParent(mapID)
	SaveDebugData()
	debugWindow:Refresh()
end
events.NEW_WMO_CHUNK = events.ZONE_CHANGED_NEW_AREA
MasterCollector:RegisterModuleEvents(events)
debugWindow:Show()