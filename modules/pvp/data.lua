-- TODO: check if PVP module is enabled. If not, return immediately
--if true then return end
local MasterCollector = select(2,...)
local moduleDB, mapData = {}, {}
local function Process()
	for k,v in pairs(moduleDB) do
		for id, obj in pairs(v) do
			MasterCollector.DB:MergeObject(k, id, obj, MasterCollector.structs[obj.type or k])
		end
	end
	table.wipe(moduleDB)

	for k,v in pairs(mapData) do
		MasterCollector.DB:MergeMapData(k, v)
	end
	table.wipe(mapData)
end
--@GENERATE_HERE@--
MasterCollector.Modules.Pvp={}
moduleDB={
	["quest"]={
		[62285]={coordinates={{34.24,55.91,1670}},minlevel=60,providers={{"n",174922}}},
		[62288]={coordinates={{34.24,55.91,1670}},minlevel=60,providers={{"n",174922}}},
	},
}
mapData={
	[1670]={{"quest",{62285,62288}}},
}
Process()