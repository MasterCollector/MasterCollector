local MasterCollector = select(2,...)

local DB = {
	data = {},
	mapData = {}
}
function DB:MergeObject(type, id, object, struct)
	if not self.data[type] then self.data[type] = {} end
	if not self.data[type][id] then
		object.id = id -- TODO: I don't like this. Why should an object be self-aware of its id when the DB key is that id?
		self.data[type][id] = setmetatable(object, struct)
	end
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
	return self.data[type][id]
end
function DB:GetMapMetadata(mapID)
	return self.mapData[mapID]
end
MasterCollector.DB = DB
