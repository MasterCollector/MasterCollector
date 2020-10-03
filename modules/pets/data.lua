-- TODO: check if pets module is enabled. If not, return immediately
--if true then return end
local MasterCollector = select(2,...)
MasterCollector.Modules.Pets = {}
MasterCollector.Modules.Pets.DB={
	["pet"] = {
		[635] = {description='super snake'},
		[448] = {description='sample description for hare'},
		[467] = {},
		[466] = {},
		[420] = {},
		[418] = {},
		[474] = {},
		[631] = {},
		[1157] = {},
		[386] = {},
		[419] = {},
		[468] = {description='creepy crawly description'},
		[1330] = {description='death adder. he\'s a scary dude'},
		[2403] = {},
		[2468] = {description='pandaland pet'},
	},
	["quest"] = {
		[31813] = {},
		[31570] = {},
		[31571] = {},
		[31830] = {},
		[31572] = {},
		[31818] = {},
	},
}
MasterCollector.Modules.Pets.mapData={
	[1]={{"pet",{635,468,467,448,466,420,418}},{"quest",{31813,31570,31571,31830,31572,31818}}},
	[10]={{"pet",{635,474,631,1157,386,419}}},
}