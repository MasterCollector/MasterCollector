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
function DB:MergeObject(type, id, object, struct)
	if not self.data[type] then self.data[type] = {} end
	if not self.data[type][id] then
		object.id = id -- TODO: I don't like this. Why should an object be self-aware of its id when the DB key is that id?
		self.data[type][id] = setmetatable(object, struct)
		if type == 'item' then
			local item = Item:CreateFromItemID(id)
			item:ContinueOnItemLoad(function()
				local _,_,_,_,icon, classID = GetItemInfoInstant(id)
				rawset(self.data[type][id], 'text', item:GetItemName() or 'Item #' .. id)
				rawset(self.data[type][id], 'icon', icon)
				if classID == 2 or classID == 4 then
					rawset(self.data[type][id], 'type', 'equipment')
				end
			end)
		end
	end
	return self.data[type][id]
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
