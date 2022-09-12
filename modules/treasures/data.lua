-- TODO: check if treasures module is enabled. If not, return immediately
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
MasterCollector.Modules.Treasures={}
moduleDB={
	["quest"]={
		[48938]={providers={"o",276735}},
		[49257]={providers={"o",277561}},
		[49936]={providers={"o",279609}},
		[50259]={providers={"o",281092}},
		[50582]={providers={"o",281655}},
		[50707]={providers={"o",281898}},
		[50726]={flags={daily=true},providers={"o",281903}},
		[50947]={description="Kill Da White Shark",providers={"o",284454},requirements={quest=46957}},
		[50949]={providers={"o",284455}},
		[51338]={providers={"o",288596}},
		[51624]={providers={"o",290725}},
		[54131]={providers={"o",310709}},
		[56088]={providers={"o",327407},requirements={quest={55981,59978}}},
		[56579]={providers={"o",329918}},
		[56581]={providers={"o",329919}},
		[58380]={providers={"o",339770}},
	},
	["object"]={
		[276735]={coordinates={38.3,7.2,1165}},
		[277561]={coordinates={49.5,65.3,862}},
		[279609]={coordinates={24.5,27,1177}},
		[281092]={coordinates={64.71,21.67,862}},
		[281655]={coordinates={51.43,26.61,862}},
		[281898]={coordinates={38.8,34.4,862}},
		[281903]={coordinates={{40.6,77.34,862},{39.86,76.54,862}}},
		[284454]={coordinates={59.5,88.8,1165}},
		[284455]={coordinates={71.83,16.78,862}},
		[288596]={coordinates={46.3,26.6,862}},
		[290725]={coordinates={52.96,47.2,862}},
		[310709]={coordinates={32.21,63.43,37}},
		[327407]={coordinates={41.84,42.84,1409}},
		[329918]={coordinates={58.47,59.33,1409}},
		[329919]={coordinates={59.36,37.69,1409}},
		[339770]={coordinates={57.08,68.43,1409}},
	},
}
mapData={
	[37]={{"quest",{54131}}},
	[862]={{"quest",{49257,50259,50582,50707,50949,51624}}},
	[1165]={{"quest",{48938,50947,51338}}},
	[1177]={{"quest",{49936}}},
	[1409]={{"quest",{56088,56579,56581,58380}}},
}
Process()
