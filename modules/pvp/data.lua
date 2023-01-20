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
	["npc"]={
		[12796]={coordinates={41.75,72.83,85},grants={{"item",{29466,29469,29470,29472,34129}}},races=-2},
		[73151]={coordinates={41.81,73.17,85},grants={{"item",{70910,102533,116778,124540,140348,140354,143649,142437,142235,152869,163124,165020,163121,173713,184013,186179,187680,187642}}},races=-2},
		[174922]={coordinates={34.24,55.89,1670}},
		[196191]={coordinates={43.35,42.52,2112}},
		[199393]={coordinates={42.07,40.62,2112}},
		[199526]={coordinates={49.52,59.83,2112}},
	},
	["quest"]={
		[62285]={coordinates={34.24,55.91,1670},minlevel=60,providers={"n",174922}},
		[62288]={coordinates={34.24,55.91,1670},minlevel=60,providers={"n",174922}},
		[72166]={minlevel=70,providers={"n",196191}},
		[72648]={flags={weekly=true},minlevel=60,providers={"n",199393}},
		[72720]={flags={weekly=true},minlevel=70,providers={"n",199526}},
	},
}
mapData={
	[85]={{"npc",{12796,73151}}},
	[1670]={{"quest",{62285,62288}}},
	[2112]={{"quest",{72166,72648,72720}}},
}
Process()
