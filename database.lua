local MasterCollector = select(2,...)

local C_Timer = C_Timer
local C_PetJournal = C_PetJournal
local GetQuestTitle = QuestUtils_GetQuestName
local RequestLoadQuestByID = C_QuestLog.RequestLoadQuestByID

local DB = {
	data = {},
	mapData = {}
}

local ModelViewer = CreateFrame("DressUpModel", nil, UIParent);
local function GetCreatureDisplayID(id)
	if id > 0 then
		ModelViewer:SetDisplayInfo(0);
		ModelViewer:SetUnit("none");
		ModelViewer:SetCreature(id);
		return ModelViewer:GetDisplayInfo();
	end
end
local HarvesterTooltip = CreateFrame("GameTooltip", "MCHarvesterTooltip", UIParent, "GameTooltipTemplate")
local function GetCreatureNameFromID(id)
	if not HarvesterTooltip:GetOwner() then 
		HarvesterTooltip:SetOwner(UIParent,"ANCHOR_NONE")
	end
	HarvesterTooltip:SetHyperlink(format("unit:Creature-0-0-0-0-%d-0000000000",id))
	return HarvesterTooltip.TextLeft1:GetText() or "NPC #"..id
end

local PendingQuestNames = {}
HarvesterTooltip:RegisterEvent("QUEST_DATA_LOAD_RESULT")
HarvesterTooltip:SetScript("OnEvent", function(self, event, ...)
	-- Once blizzard returns the quest data, we can inspect the result to see if it's a valid entry or not
	-- Quests that have a nil or false "success" return tell us that either blizzard has removed the quest completely OR
	--   the quest itself doesn't have a name (e.g. tracking quests). 
	if event == "QUEST_DATA_LOAD_RESULT" and rawget(PendingQuestNames, ...) then -- only bother with results from quest load requests made by this addon
		local questID, success = ...
		if success then
			PendingQuestNames[questID].callback(GetQuestTitle(questID))
			PendingQuestNames[questID] = nil
		else
			if PendingQuestNames[questID].attempts >= 2 then
				PendingQuestNames[questID].callback()
				PendingQuestNames[questID] = nil
				return
			end
			PendingQuestNames[questID].attempts = PendingQuestNames[questID].attempts + 1
			C_Timer.After(3, function() RequestLoadQuestByID(questID) end)
		end
	end
end)
local function GetQuestName(quest)
	if MasterCollector.L.Quests[quest.id] then
		return MasterCollector.L.Quests[quest.id]
	elseif quest.flags then
		if quest.flags.removed then
			return string.format(MasterCollector.L.Text.QUEST_REMOVED, quest.id)
		elseif quest.flags.hidden then
			if quest.flags.daily then
				return MasterCollector.L.Text.QUEST_HIDDEN_DAILY
			elseif quest.flags.weekly then
				return MasterCollector.L.Text.QUEST_HIDDEN_WEEKLY
			else
				return MasterCollector.L.Text.QUEST_HIDDEN
			end
		end
	end
	
	local name = GetQuestTitle(quest.id)
	if not name or name=='' then
		RequestLoadQuestByID(quest.id)
		PendingQuestNames[quest.id] = {
			attempts = 0,
			callback = function(name)
				quest.name = name or string.format(MasterCollector.L.Text.QUEST_UNKNOWN_NAME, quest.id)
			end
		}
		return SEARCH_LOADING_TEXT
	else
		return name
	end
end

local function EnrichAchievement(achievement)
	local _,name,_,_,_,_,_,_,_,icon = GetAchievementInfo(achievement.id)
	achievement.text = format('|cffffff00%s|r', (name or 'Achievement #'..achievement.id))
	achievement.icon = icon
end
local function EnrichItem(item)
	item.baseType = 'item'
	local loadedItem = Item:CreateFromItemID(item.id)
	if not loadedItem:IsItemEmpty() then
		loadedItem:ContinueOnItemLoad(function()
			local _,_,_,_,icon, classID, subclassID = GetItemInfoInstant(item.id)
			item.icon = icon
			if classID == 2 or classID == 4 then
				item.type = "equipment"
			end
			item.quality = loadedItem:GetItemQuality()
			item.text = format('|c%s|Hitem:%d|h%s|h|r', select(4,GetItemQualityColor(loadedItem:GetItemQuality())), item.id, loadedItem:GetItemName())
			
			if item.type then
				if C_ToyBox.GetToyInfo(item.id) then
					item.type = "toy"
				elseif C_MountJournal.GetMountFromItem(item.id) then
					item.type = "mount"
					item.mountID = C_MountJournal.GetMountFromItem(item.id)
				elseif (classID == 15 and subclassID ==2) or classID == 17 then
					item.type = "pet"
					item.speciesID = select(13, C_PetJournal.GetPetInfoByItemID(item.id))
				end
			end
		end)
	else
		item.text = format('Item #%d', item.id)
	end
end
local function EnrichNPC(npc)
	npc.text = GetCreatureNameFromID(npc.id)
	npc.displayID = GetCreatureDisplayID(npc.id)
end
local function EnrichPet(pet)
	local name, icon, _, npcID = C_PetJournal.GetPetInfoBySpeciesID(pet.id)
	pet.text = (name or 'Pet Species #'.. pet.id)
	pet.npcID = npcID
	pet.icon = icon
	pet.collected = (C_PetJournal.GetNumCollectedInfo(pet.id) or 0) > 0
end
local function EnrichQuest(quest)
	quest.name = GetQuestName(quest)
	
	if quest.requirements and quest.requirements.quest then
		local backRef
		if type(quest.requirements.quest) == "table" then
			for index=1,#quest.requirements.quest do
				backRef = DB:MergeObject("quest", quest.requirements.quest[index], {}, MasterCollector.structs["quest"])
				quest.requirements.quest[index] = backRef
				if not backRef.leadsTo then backRef.leadsTo = {} end
				table.insert(backRef.leadsTo, quest)
			end
		else
			backRef = DB:MergeObject("quest", quest.requirements.quest, {}, MasterCollector.structs["quest"])
			quest.requirements.quest = backRef
			if not backRef.leadsTo then backRef.leadsTo = {} end
			table.insert(backRef.leadsTo, quest)
		end
	end
end
function DB:EnrichData()
	local map = {
		ach = EnrichAchievement,
		pet = EnrichPet,
		item = EnrichItem,
		npc = EnrichNPC,
		quest = EnrichQuest
	}
	local counter, maxLoadToYield = 0, 100
	local co = coroutine.create(function()
		for dataType,tbl in pairs(DB.data or {}) do
			if map[dataType] then
				for id,obj in pairs(tbl) do
					map[dataType](obj)
					counter = counter + 1
					if counter >= maxLoadToYield then
						coroutine.yield()
						counter = 0
					end
				end
			end
		end
	end)
	local ticker
	ticker = C_Timer.NewTicker(0, function()
		if coroutine.status(co) == "dead" then
			ticker:Cancel()
			ticker = nil
			collectgarbage()
			MasterCollector.Ready = true
			MasterCollector.Window:Get("MasterCollectorCurrentZone"):Reload()
			MasterCollector:RefreshWindows(true)
		else
			coroutine.resume(co)
		end
	end)
	DB.EnrichData = nil
end

local function MergeProperties(fromTable, toTable)
	for k,v in pairs(fromTable) do
		if not rawget(toTable, k) then
			rawset(toTable, k, v)
		else
			if type(v) == 'table' then
				MergeProperties(v, toTable[k])
			end
		end
	end
	return toTable
end
function DB:MergeObject(type, id, object, struct)
	if not self.data[type] then self.data[type] = {} end
	if not self.data[type][id] then
		object.id = id -- TODO: I don't like this. Why should an object be self-aware of its id when the DB key is that id?
		self.data[type][id] = setmetatable(object, struct)
		return self.data[type][id]
	end
	return MergeProperties(object, self.data[type][id])
end
function DB:MergeMapData(mapID, mapData)
	if not self.mapData[mapID] then self.mapData[mapID] = {} end
	local panel, panelData
	for i=1, #mapData do
		panel = mapData[i][1]
		panelData = mapData[i][2]
		if not self.mapData[mapID][panel] then self.mapData[mapID][panel] = {} end
		for k,v in pairs(panelData) do
			if type(v) == 'table' then
				-- TODO: a table at this key would indicate a panel
			else
				self.mapData[mapID][panel][v] = true
			end
		end
		i = i+1
	end
end
function DB:GetObjectData(type, id)
	if self.data[type] then return self.data[type][id] end
end
function DB:GetMapMetadata(mapID)
	return self.mapData[mapID]
end
function DB:SetCollectedState(obj, state)
	if getmetatable(obj) == MasterCollector.structs.quest then
		rawset(obj, 'collected', true)
	end
end
function DB:Initialize()
	for modName,mod in pairs(MasterCollector.Modules or {}) do
		for objType,objTable in pairs(mod.moduleDB) do
			for id, obj in pairs(objTable) do
				if obj.grants then
					if not obj.children then obj.children = {} end
					for group=1,#obj.grants do
						for _,id in pairs(obj.grants[group][2] or {}) do
							local item = DB:GetObjectData(obj.grants[group][1], id) or DB:MergeObject(obj.grants[group][1], id, {}, MasterCollector.structs[obj.grants[group][1]])
							if not item then print('item is null') end
							table.insert(obj.children, item)
						end
					end
					obj.grants = nil
				end
				self:MergeObject(objType, id, obj, MasterCollector.structs[obj.type or objType])
			end
		end
		for mapID,tbl in pairs(mod.mapData or {}) do
			MasterCollector.DB:MergeMapData(mapID, tbl)
		end
	end
	MasterCollector.Modules = nil
	MasterCollector:PostProcess()
	DB.Initialize=nil
end
MasterCollector.DB = DB
