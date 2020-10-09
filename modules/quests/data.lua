-- TODO: check if quests module is enabled. If not, return immediately
--if true then return end
local MasterCollector = select(2,...)
MasterCollector.Modules.Quests = {}
MasterCollector.Modules.Quests.DB={
	["quest"] = {
		[25152]={coords={{45.2,68.4,461}},race=2,providers={{"n",10176}}},
		[25126]={coords={{44.9,66.4,461}},race=2,providers={{"n",3143}}},
		[25172]={coords={{44.9,66.4,461}},race=2,providers={{"n",3143}}},
		[25136]={coords={{43.0,62.4,461}},race=2,providers={{"n",9796}}},
		[25127]={coords={{44.9,66.4,461}},race=2,providers={{"n",3143}}},
		[37446]={coords={{46.2,63.3,461}},race=2,providers={{"n",11378}}},
	},
}
MasterCollector.Modules.Quests.mapData={
	[1]={{"quest",{2161,818,41002,25263,32872,32862,25648,815,25167,1843,832,25924,791,25170,840,806,25444,25480,40607,40983,40760,837,25176,40522,25260,25446,25173,825,5648,25259,25257,25258,25206,29690,31012,1884,40605,25470,32671,14088,25179,816,25193,25187,39698,828,25261,6365,25267,808,812,829,25165,817,25495,25168,25192,25190,823,26806,26807,25171,6384,1842,40982,835,25256,25178,827,25262,1883,25177,2937,25195,830,831,40518,25232,924,25196,42484,2936,39801,25169,25205,25227,25236,786,44281,25461,47867,25194,784,25188,53777,834,826,25445,}}},
	[461]={{"quest",{25130,25132,25126,25136,25128,25172,37446,25133,25129,25127,25135,25131,25152}}},
}