local MasterCollector = select(2,...)

local DB = {
	data = {},
	mapData = {}
}
local QuestInvalidationRules = {
	-- format= [completed QuestID] = integer or table of integers of missed/invalidated questIDs
	[25617] = 25624, -- Hyjal, Into the Maw! (Lo'Gosh)
	[25618] = 25623, -- Hyjal, Into the Maw! (Goldrinn)
	[25623] = 25618, -- Hyjal, Into the Maw! (Ian)
	[25624] = 25617 -- Hyjal, Into the Maw! (Takrik)
}

local HarvesterTooltip = CreateFrame("GameTooltip", "MCHarvesterTooltip", UIParent, "GameTooltipTemplate")
local function LoadCreatureNameFromID(id)
	if not HarvesterTooltip:GetOwner() then 
		HarvesterTooltip:SetOwner(UIParent,"ANCHOR_NONE")
	end
	HarvesterTooltip:SetHyperlink(format("unit:Creature-0-0-0-0-%d-0000000000",id))
	local text = MCHarvesterTooltipTextLeft1:GetText()
	if text then
		rawset(DB:GetObjectData('npc', id), 'text', text)
		return text
	end
	return 'Retrieving data...'
end
local ModelViewer = CreateFrame("DressUpModel", nil, UIParent);
local function LoadCreatureDisplayDataFromID(id)
	if id > 0 then
		ModelViewer:SetDisplayInfo(0);
		ModelViewer:SetUnit("none");
		ModelViewer:SetCreature(id);
		local displayID = ModelViewer:GetDisplayInfo();
		if displayID and displayID ~= 0 then
			rawset(DB:GetObjectData('npc', id), 'displayID', displayID)
		end
	end
end
MasterCollector.test = LoadCreatureDisplayDataFromID
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
		if type == 'item' then
			object.baseType = 'item'
			local item = Item:CreateFromItemID(id)
			if not item:IsItemEmpty() then
				item:ContinueOnItemLoad(function()
					local _,_,_,_,icon, classID, subclassID = GetItemInfoInstant(id)
					rawset(self.data[type][id], 'icon', icon)
					if classID == 2 or classID == 4 then
						rawset(self.data[type][id], 'type', 'equipment')
					end
					rawset(self.data[type][id], 'quality', item:GetItemQuality())
					rawset(self.data[type][id], 'text', format('|c%s|Hitem:%d|h%s|h|r', select(4,GetItemQualityColor(item:GetItemQuality())), id, item:GetItemName()))
					
					if not rawget(self.data[type][id], 'type') then
						if (classID == 15 and subclassID ==2) or classID == 17 then
							rawset(self.data[type][id], 'type', 'pet')
							rawset(self.data[type][id], 'speciesID', select(13, C_PetJournal.GetPetInfoByItemID(id)))
						elseif C_MountJournal.GetMountFromItem(id) then
							rawset(self.data[type][id], 'type', 'mount')
							rawset(self.data[type][id], 'mountID', C_MountJournal.GetMountFromItem(id))
						elseif C_ToyBox.GetToyInfo(id) then
							rawset(self.data[type][id], 'type', 'toy')
						end
					end
				end)
			else
				rawset(self.data[type][id], 'text', format('Item #%d', id))
			end
		elseif type == 'npc' then
			LoadCreatureNameFromID(tonumber(id))
			LoadCreatureDisplayDataFromID(tonumber(id))
		end
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
	if not self.data[type] then self.data[type] = {} end
	return self.data[type][id] or DB:MergeObject(type, id, {}, MasterCollector.structs[type])
end
function DB:GetMapMetadata(mapID)
	return self.mapData[mapID]
end
function DB:SetCollectedState(obj, state)
	if getmetatable(obj) == MasterCollector.structs.quest then
		rawset(obj, 'collected', true)
		local invalidates = QuestInvalidationRules[obj.id]
		if invalidates then
			if type(invalidates) == 'table' then
				for _,v in pairs(invalidates) do
					rawset(MasterCollector.DB:GetObjectData("quest", v), "collected", -1)
				end
			else
				rawset(MasterCollector.DB:GetObjectData("quest", invalidates), "collected", -1)
			end
		end
	end
end
MasterCollector.DB = DB
