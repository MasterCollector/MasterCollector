-- TODO: check if treasures module is enabled. If not, return immediately
--if true then return end
local MasterCollector = select(2,...)
--@GENERATE_HERE@--
MasterCollector.Modules.Treasures={}
MasterCollector.Modules.Treasures.DB={
	["quest"]={
		[56088]={coordinates={{41.84,42.84,1409}},providers={{"o",327407}},requirements={quest={55981,59978}}},
		[56579]={coordinates={{58.47,59.33,1409}},providers={{"o",329918}}},
		[56581]={coordinates={{59.36,37.69,1409}},providers={{"o",329919}}},
		[58380]={coordinates={{57.08,68.43,1409}},providers={{"o",339770}}},
	},
}
MasterCollector.Modules.Treasures.mapData={
	[1409]={{"quest",{56088,56579,56581,58380}}},
}
