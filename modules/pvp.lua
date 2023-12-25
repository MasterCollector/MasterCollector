-- TODO: check if PVP module is enabled. If not, return immediately
--if true then return end
local MasterCollector = select(2,...)
--@GENERATE_HERE@--
MasterCollector.Modules.Pvp={
	moduleDB={
		["ach"]={
			[19294]={},
		},
		["npc"]={
			[12793]={coordinates={37.87,72.09,85},grants={{"item",{15197,15199}}},races=-2},
			[12794]={coordinates={38.48,73.04,85},grants={{"item",{18877,18831,18868,23465,18871,18828,16345,23467,18866,23464,18844,18848,18840,18826,18835,18837,18860,18874,23466,23468,23469}}},races=-2},
			[12795]={coordinates={38.15,72.74,85},grants={{"item",{29600,29601,29603,29602,29605,29604,29613,29612,29614,29617,29616,29615,18430,18429,18427,16341,18461,28377,28378}}},races=-2},
			[12796]={coordinates={41.75,72.83,85},grants={{"item",{29466,29469,29470,29472,34129,18247,18246,18245,18248}}},races=-2},
			[13217]={coordinates={44.65,46.45,25},grants={{"item",{19032,19084,19086,19091,19092,19093,19094,19097,19098,19100,19102,19104,19308,19309,19310,19311,19312,19315,19321,19323,19324,19325,21563,19030}}},races=-1},
			[13841]={coordinates={44.66,46.2,25}},
			[14754]={coordinates={40.14,19.94,10},grants={{"item",{19505,21566,21565,20426,19521,19520,19519,19518,20427,19529,19528,19527,19526,20429,19513,19512,19511,19510,20442,19537,19536,19535,19534,20425,19569,19568,19567,19566,20430,19553,19552,19551,19550,20437,19561,19560,19559,19558,20441,19545,19544,19543,19542,19581,19580,19578,19597,19596,19595,19590,19589,19587,19584,19583,19582,22747,22741,22740,22676,22673,22651,30498}}},races=-2},
			[15127]={coordinates={40.1,46.44,14},grants={{"item",{20132,20073,20043,20088,20089,20090,20050,20091,20092,20093,20055,20054,20094,20095,20096,20047,20097,20098,20099,20061,20042,20106,20107,20108,20049,20109,20110,20111,20058,20052,20112,20113,20114,20045,20115,20116,20117,20059,20053,20100,20101,20102,20046,20103,20104,20105,20060,20044,20118,20119,20120,20051,20121,20122,20123,20056,20041,20124,20125,20126,20048,20127,20128,20129,20057,20069,20070,20071,21117,21118,21119}}},races=-1,requirements={spell=276950}},
			[52033]={coordinates={37.91,70.71,85},grants={{"item",{146435,64802,64803,64804,64805,64806,64843,64844,64845,64846,64847,64754,64753,64716,64715,64869,64870,64757,64756,64683,64684,64704,64705,64719,64718,64733,64732,64734}}},races=-2},
			[52036]={coordinates={37.79,71.6,85},grants={{"item",{122378,122376,122377,122374,122375,122372,122373,122368,122365,122366,122364,122367,122369,122530,122370}}},races=-2},
			[54657]={coordinates={38.19,70.48,85},grants={{"item",{146535,146641,60413,60414,60415,60416,60417,60601,60602,60603,60604,60605,60505,60508,60521,60539,60509,60513,60516,60540,60512,60520,60523,60541,60776,60778,60786,60787,60788,61324,61327,61328,61330,61331,61335,61345,61353,61355,61354,61340,61343,61329,61338,61341,61342,61351,61350,61325,61333,61332,61336,61344,61326,61339,61346,61357,61358,61361,61360,61359}}},races=-2},
			[69977]={coordinates={38.55,70.03,85},grants={{"item",{146515,146640,70249,70250,70251,70252,70253,70353,70354,70355,70356,70357,70319,70320,70326,70332,70321,70323,70324,70333,70322,70325,70327,70334,70383,70384,70387,70388,70389,70211,70214,70215,70217,70218,70221,70230,70236,70238,70237,70225,70228,70216,70223,70235,70234,70226,70227,70212,70220,70219,70222,70229,70213,70224,70231,70239,70240,70243,70242,70241}}},races=-2},
			[69978]={coordinates={38.89,69.93,85},grants={{"item",{146455,146639,73571,88170,73560,73570,73559,73569,73558,73568,73557,73567,73556,73555,73554,73565,73566,73553,73552,73563,73564,73550,73551,73561,73562,73495,73494,73628,73629,73630,73474,73455,73461,73454,73453,73473,73472,73470,73463,73460,73456,73462,73467,73459,73450,73464,73466,73457,73449,73452,73451,73448,73447,73477,73476,73475,73469,73465,73458,73468,73446}}},races=-2},
			[73151]={coordinates={41.81,73.17,85},grants={{"item",{70910,102533,116778,124540,140348,140354,143649,142437,142235,152869,163124,165020,163121,173713,184013,186179,187680,187642}}},races=-2},
			[146626]={coordinates={39.59,71.64,85},grants={{"item",{142380,139776,163974}}},races=-2},
			[174922]={coordinates={34.24,55.89,1670}},
			[175050]={coordinates={38.12,71.21,85},grants={{"item",{184058,184060,184059,172847,172849,172846,172848,172844,172845,174012,172887,172860,172879,172877,172873,172881,172861,172875,174010,172869,172871,174018,172883,174014,172885,172865,172867,172863,174016,172791,172804,172783,172799,172793,172785,172801,172809,172796,172780,172788,172805,172787,172802,172794,172810,172784,172792,172808,172800,172781,172789,172806,172797,172786,172795,172803,172811,172807,172782,172790,172798}}},races=-2},
			[196191]={coordinates={43.35,42.52,2112}},
			[199393]={coordinates={42.07,40.62,2112}},
			[199526]={coordinates={49.52,59.83,2112}},
		},
		["quest"]={
			[7162]={grants={{"item",{17691}}},providers={"n",13841},races=-1},
			[62285]={coordinates={34.24,55.91,1670},minlevel=60,providers={"n",174922}},
			[62288]={coordinates={34.24,55.91,1670},minlevel=60,providers={"n",174922}},
			[72166]={minlevel=70,providers={"n",196191}},
			[72171]={minlevel=70,providers={"n",196191}},
			[72648]={flags={weekly=true},minlevel=60,providers={"n",199393}},
			[72720]={flags={weekly=true},minlevel=70,providers={"n",199526}},
			[78215]={flags={wq=true},requirements={quest=77887}},
		},
	},
	mapData={
		[10]={{"npc",{14754}}},
		[14]={{"npc",{15127}}},
		[25]={{"npc",{13217}},{"quest",{7162}}},
		[85]={{"npc",{12793,12794,12795,12796,52033,52036,54657,69977,69978,73151,146626,175050}}},
		[1670]={{"quest",{62285,62288}}},
		[2112]={{"quest",{72166,72171,72648,72720}}},
		[2200]={{"ach",{19294}},{"quest",{78215}}},
	}
}
