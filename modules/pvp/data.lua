-- TODO: check if PVP module is enabled. If not, return immediately
--if true then return end
local MasterCollector = select(2,...)
--@GENERATE_HERE@--
MasterCollector.Modules.Pvp={}
MasterCollector.Modules.Pvp.DB={
	["quest"]={
		[62285]={coordinates={{34.24,55.91,1670}},minlevel=60,providers={{"n",174922}}},
		[62288]={coordinates={{34.24,55.91,1670}},minlevel=60,providers={{"n",174922}}},
	},
}
MasterCollector.Modules.Pvp.mapData={
	[1670]={{"quest",{62285,62288}}},
}
