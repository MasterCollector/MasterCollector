-- TODO: check if pets module is enabled. If not, return immediately
--if true then return end
local MasterCollector = select(2,...)
--@GENERATE_HERE@--
MasterCollector.Modules.Pets={
	moduleDB={
		["ach"]={
			[19293]={grants={{"item",{210522}}}},
			[19401]={},
		},
		["npc"]={
			[3636]={grants={{"item",{48114}}}},
			[3637]={grants={{"item",{48114}}}},
			[6367]={coordinates={44.22,53.44,37},grants={{"item",{8485,8486,8487,8488}}},races=-1},
			[8404]={coordinates={33.86,67.94,85},grants={{"item",{10360,10361,10392}}},races=-2},
			[49687]={coordinates={33.53,49.35,25}},
			[63194]={coordinates={46,40.45,50}},
			[63626]={coordinates={52.56,59.27,85}},
			[64330]={coordinates={41.66,83.67,37}},
			[65648]={coordinates={60.85,18.5,52}},
			[65651]={coordinates={33.3,52.57,49}},
			[65655]={coordinates={19.87,44.62,47}},
			[65656]={coordinates={51.47,73.39,210}},
			[66126]={coordinates={43.85,28.87,1}},
			[66135]={coordinates={58.61,53.05,10}},
			[66136]={coordinates={20.2,29.55,63}},
			[66137]={coordinates={59.65,71.59,65}},
			[66352]={coordinates={59.75,49.64,69}},
			[66372]={coordinates={57.11,45.69,66}},
			[66422]={coordinates={39.59,79.14,199}},
			[66436]={coordinates={53.86,74.88,70}},
			[66442]={coordinates={39.95,56.57,77}},
			[66452]={coordinates={31.88,32.94,64}},
			[66466]={coordinates={65.64,64.51,83}},
			[66478]={coordinates={62.98,54.58,26}},
			[66512]={coordinates={66.97,52.43,23}},
			[66515]={coordinates={35.3,27.76,32}},
			[66518]={coordinates={76.82,41.5,51}},
			[66520]={coordinates={25.54,47.5,36}},
			[66522]={coordinates={40.04,76.47,42}},
			[66730]={coordinates={47.96,54.17,371}},
			[66819]={coordinates={61.37,32.71,198}},
			[68464]={coordinates={28.9,36.03,371}},
			[115286]={coordinates={63.58,35.81,10}},
			[116781]={coordinates={23.49,81.29,11}},
			[124617]={coordinates={42.9,74.28,30}},
			[150987]={coordinates={43.13,19.93,23},grants={{"item",{169678,169677,169676,169679}}}},
			[187077]={coordinates={22.8,95.11,2022},description="Bring a Petrified Dragon Egg and Eroded Fossil to get the pet",grants={{"item",{202085}}}},
			[187783]={coordinates={43.48,74.97,2112},grants={{"item",{193571}}}},
			[198604]={coordinates={52.45,83.61,2025},grants={{"item",{201463}}}},
			[199526]={coordinates={49.52,59.83,2112}},
			[201004]={coordinates={52.41,66.04,2133},grants={{"item",{193071,200927,201707,192459,201703,205052,201441}}}},
		},
		["pet"]={
			[43]={},
			[55]={},
			[68]={},
			[69]={description="Only available between 21.December and 20.March."},
			[70]={},
			[72]={},
			[75]={},
			[138]={},
			[142]={},
			[374]={},
			[378]={},
			[379]={},
			[380]={},
			[383]={},
			[385]={},
			[386]={},
			[387]={},
			[388]={},
			[389]={},
			[391]={},
			[392]={},
			[393]={},
			[395]={},
			[396]={},
			[397]={},
			[398]={},
			[399]={},
			[400]={},
			[401]={},
			[402]={},
			[403]={},
			[404]={},
			[405]={},
			[406]={},
			[407]={},
			[408]={},
			[409]={},
			[410]={},
			[411]={description="Only available when it rains on Jaguero Isle."},
			[412]={},
			[414]={},
			[415]={},
			[416]={},
			[417]={},
			[418]={},
			[419]={},
			[420]={},
			[421]={},
			[422]={},
			[423]={},
			[424]={},
			[425]={},
			[427]={},
			[428]={},
			[429]={},
			[430]={},
			[431]={},
			[432]={},
			[433]={},
			[437]={},
			[438]={},
			[439]={description="Spawns in The Master\'s Cellar at midnight PST."},
			[440]={},
			[441]={},
			[442]={},
			[443]={},
			[445]={},
			[446]={},
			[447]={},
			[448]={},
			[449]={},
			[450]={},
			[452]={},
			[453]={},
			[454]={},
			[455]={},
			[456]={},
			[457]={},
			[458]={},
			[459]={},
			[460]={},
			[461]={},
			[463]={},
			[464]={},
			[465]={},
			[466]={},
			[467]={},
			[468]={},
			[469]={},
			[470]={},
			[471]={},
			[472]={},
			[473]={},
			[474]={},
			[475]={},
			[477]={},
			[478]={},
			[479]={},
			[480]={},
			[482]={},
			[483]={},
			[484]={},
			[485]={},
			[487]={},
			[488]={},
			[489]={},
			[491]={},
			[492]={},
			[493]={},
			[494]={description="Spawns between the Gaping Chasm and Noxious Lair during a sandstorm."},
			[495]={},
			[496]={},
			[497]={},
			[498]={},
			[499]={},
			[500]={},
			[502]={},
			[503]={},
			[504]={},
			[505]={},
			[506]={},
			[507]={},
			[508]={},
			[509]={},
			[511]={},
			[512]={},
			[513]={description="Only available between 21.June and 23.September."},
			[514]={},
			[515]={},
			[517]={},
			[518]={},
			[519]={},
			[521]={},
			[523]={},
			[525]={},
			[528]={},
			[529]={},
			[530]={},
			[532]={},
			[534]={},
			[535]={},
			[536]={},
			[537]={},
			[538]={},
			[539]={},
			[540]={},
			[541]={},
			[542]={},
			[543]={},
			[544]={},
			[545]={},
			[546]={},
			[547]={},
			[548]={},
			[549]={},
			[550]={},
			[552]={},
			[553]={},
			[554]={},
			[555]={},
			[556]={},
			[557]={},
			[558]={},
			[559]={},
			[560]={},
			[562]={},
			[564]={},
			[565]={},
			[566]={},
			[567]={},
			[568]={},
			[569]={},
			[570]={},
			[571]={},
			[572]={},
			[573]={},
			[626]={},
			[627]={},
			[628]={},
			[629]={},
			[630]={},
			[631]={},
			[632]={},
			[633]={},
			[634]={},
			[635]={},
			[637]={},
			[638]={},
			[639]={},
			[640]={},
			[641]={},
			[644]={},
			[645]={},
			[646]={},
			[647]={},
			[648]={},
			[649]={},
			[675]={},
			[677]={},
			[678]={},
			[679]={},
			[680]={},
			[699]={},
			[702]={},
			[703]={},
			[706]={},
			[707]={},
			[708]={},
			[709]={},
			[710]={},
			[711]={},
			[712]={},
			[713]={},
			[714]={},
			[716]={},
			[717]={},
			[718]={},
			[722]={},
			[723]={},
			[724]={},
			[725]={},
			[726]={},
			[727]={},
			[728]={},
			[729]={},
			[730]={},
			[731]={},
			[732]={},
			[733]={},
			[737]={},
			[739]={},
			[740]={},
			[741]={},
			[742]={},
			[743]={},
			[744]={},
			[745]={},
			[746]={},
			[747]={},
			[748]={},
			[749]={},
			[750]={},
			[751]={},
			[752]={},
			[753]={},
			[754]={},
			[755]={},
			[756]={},
			[792]={},
			[817]={},
			[818]={},
			[819]={},
			[823]={},
			[837]={},
			[838]={},
			[851]={},
			[1013]={description="Spawns during the Wanderer\'s Festival on Sundays between 9PM and 11PM PST."},
			[1062]={},
			[1068]={},
			[1128]={description="Only spawns when the Rodent Crate, bought from your faction camp vendor, is used."},
			[1157]={},
			[1158]={},
			[1159]={},
			[1160]={},
			[1161]={},
			[1162]={},
			[1163]={},
			[1164]={},
			[1165]={},
			[1166]={},
			[1167]={},
			[1175]={},
			[1179]={},
			[1181]={},
			[1182]={},
			[1238]={},
			[1324]={},
			[1325]={},
			[1326]={},
			[1427]={},
			[1435]={},
			[1441]={},
			[1447]={},
			[1455]={},
			[1456]={},
			[1457]={},
			[1462]={},
			[1463]={},
			[1464]={},
			[1465]={},
			[1468]={},
			[1469]={},
			[1470]={},
			[1572]={},
			[1573]={},
			[1578]={},
			[1579]={},
			[1581]={},
			[1582]={},
			[1583]={},
			[1586]={},
			[1587]={},
			[1589]={description="Only one spawns on the map at any given time."},
			[1590]={},
			[1591]={},
			[1592]={description="Only one spawns on the map at a time"},
			[1593]={},
			[1594]={},
			[1595]={},
			[1599]={},
			[1615]={},
			[1708]={},
			[1709]={},
			[1710]={},
			[1712]={},
			[1713]={},
			[1714]={},
			[1722]={description="Found after defeating Xavius."},
			[1726]={},
			[1728]={},
			[1729]={},
			[1731]={},
			[1734]={},
			[1735]={},
			[1736]={},
			[1737]={},
			[1738]={},
			[1739]={},
			[1743]={},
			[1744]={},
			[1749]={},
			[1750]={},
			[1761]={},
			[1762]={},
			[1763]={},
			[1773]={},
			[1774]={},
			[1775]={},
			[1776]={},
			[1778]={},
			[1807]={},
			[1809]={},
			[1810]={},
			[1913]={},
			[1914]={},
			[1915]={},
			[1917]={},
			[1935]={},
			[2122]={},
			[2123]={},
			[2124]={},
			[2126]={},
			[2127]={},
			[2128]={},
			[2129]={},
			[2130]={},
			[2131]={},
			[2132]={},
			[2133]={},
			[2134]={},
			[2165]={description="Must have 1 million gold on hand. You DO NOT lose any gold by interacting with Francois."},
			[2372]={},
			[2373]={},
			[2374]={},
			[2375]={},
			[2376]={},
			[2377]={},
			[2378]={},
			[2379]={},
			[2380]={},
			[2381]={},
			[2382]={},
			[2383]={},
			[2384]={},
			[2385]={},
			[2386]={},
			[2387]={},
			[2388]={},
			[2389]={},
			[2390]={},
			[2392]={},
			[2393]={},
			[2394]={},
			[2395]={},
			[2397]={},
			[2398]={},
			[2399]={},
			[2400]={},
			[2411]={description="Combine 4 parts found in treasures around the zone."},
			[2537]={},
			[2645]={},
			[2646]={},
			[2647]={},
			[2648]={},
			[2649]={},
			[2650]={},
			[2651]={},
			[2652]={},
			[2653]={},
			[2660]={},
			[2661]={},
			[2662]={description="Rare. Shares spawn with Rustyroot Snooter."},
			[2663]={},
			[2664]={description="Rare. Shares spawn with Junkheap Roach."},
			[2665]={},
			[2666]={description="Rare. Shares spawn with Fleeting Frog."},
			[2667]={},
			[2669]={},
			[2670]={},
			[2671]={},
			[2673]={},
			[2676]={},
			[2677]={},
			[2678]={},
			[2864]={},
			[2895]={},
			[2902]={},
			[2919]={},
			[2924]={},
			[2926]={},
			[2927]={},
			[2929]={},
			[2930]={},
			[2936]={},
			[2937]={},
			[2939]={},
			[2943]={},
			[2950]={},
			[3007]={},
			[3014]={},
			[3015]={},
			[3021]={},
			[3049]={},
			[3050]={},
			[3051]={},
			[3052]={},
			[3080]={},
			[3081]={},
			[3082]={},
			[3083]={},
			[3120]={},
			[3266]={},
			[3272]={},
			[3273]={},
			[3276]={},
			[3280]={},
			[3281]={},
			[3282]={},
			[3283]={},
			[3288]={},
			[3295]={},
			[3296]={},
			[3300]={},
			[3301]={},
			[3313]={},
			[3322]={},
			[3328]={},
			[3336]={},
			[3351]={},
			[3352]={},
			[3353]={},
			[3354]={description="Found during a storm elemental invasion"},
			[3357]={},
			[3366]={},
			[3367]={},
			[3384]={description="Elemental Storm must be active"},
			[3385]={},
			[3403]={},
			[3404]={},
			[3477]={},
			[3478]={},
			[3479]={},
			[3480]={},
			[3481]={},
			[3482]={},
			[3483]={},
			[3484]={},
			[3485]={},
			[3487]={},
			[3488]={},
			[3489]={},
			[4275]={},
			[4276]={},
			[4277]={},
			[4278]={},
			[4279]={},
			[4280]={},
			[4302]={},
			[4303]={},
			[4304]={},
		},
		["quest"]={
			[28617]={providers={"n",49687},requirements={quest=28733}},
			[28733]={providers={"n",49687}},
			[28744]={providers={"n",49687},requirements={quest=28617}},
			[28747]={providers={"n",49687},requirements={quest=28744}},
			[28748]={grants={{"item",{65689,65666,131894,66067}}},providers={"n",49687},requirements={quest=28747}},
			[28751]={flags={daily=true},providers={"n",49687},requirements={quest=28748}},
			[31308]={races=-1},
			[31309]={races=-1},
			[31316]={races=-1},
			[31548]={races=-1},
			[31549]={races=-1},
			[31550]={races=-1},
			[31551]={races=-1},
			[31552]={coordinates={55.2,51.2,57},providers={"n",63070},races=-1},
			[31553]={coordinates={55.2,51.2,57},providers={"n",63070},races=-1,requirements={quest=31552}},
			[31555]={coordinates={55.2,51.2,57},providers={"n",63070},races=-1,requirements={quest=31826}},
			[31556]={coordinates={49.2,52,97},providers={"n",63077},races=-1},
			[31568]={coordinates={49.2,52,97},providers={"n",63077},races=-1,requirements={quest=31556}},
			[31569]={coordinates={49.2,52,97},providers={"n",63077},races=-1,requirements={quest=31825}},
			[31570]={coordinates={52.7,41.3,1},providers={"n",63061},races=-2,requirements={quest=31830}},
			[31571]={coordinates={52.7,41.3,1},providers={"n",63061},races=-2},
			[31572]={coordinates={52.7,41.3,1},providers={"n",63061},races=-2,requirements={quest=31571}},
			[31573]={races=-2},
			[31574]={races=-2},
			[31575]={races=-2},
			[31576]={races=-2},
			[31577]={races=-2},
			[31578]={races=-2},
			[31579]={races=-2},
			[31580]={races=-2},
			[31581]={races=-2},
			[31582]={coordinates={50.1,20.2,62},providers={"n",63083},races=-1},
			[31583]={coordinates={50.1,20.2,62},providers={"n",63083},races=-1,requirements={quest=31582}},
			[31584]={coordinates={50.1,20.2,62},providers={"n",63083},races=-1,requirements={quest=31832}},
			[31585]={races=-2},
			[31586]={races=-2},
			[31587]={races=-2},
			[31588]={races=-2},
			[31589]={races=-2},
			[31590]={races=-2},
			[31591]={races=-1},
			[31592]={races=-1},
			[31593]={races=-1},
			[31693]={flags={daily=true},providers={"n",64330},races=-1},
			[31724]={races=-1},
			[31725]={races=-1},
			[31726]={races=-1},
			[31728]={races=-1},
			[31729]={races=-1},
			[31780]={flags={daily=true},providers={"n",65648},races=-1},
			[31781]={flags={daily=true},providers={"n",65651},races=-1},
			[31785]={races=-1},
			[31812]={races=-2},
			[31813]={coordinates={43.9,28.9,1},providers={"n",66126},races=-2},
			[31814]={coordinates={58.6,53,10},providers={"n",66135},races=-2,requirements={quest=31813}},
			[31815]={coordinates={20.2,29.5,63},providers={"n",66136},races=-2,requirements={quest=31814}},
			[31817]={providers={"n",66317},races=-2},
			[31818]={flags={daily=true},providers={"n",66126},races=-2},
			[31819]={flags={daily=true},providers={"n",66135},races=-2},
			[31821]={races=-1},
			[31822]={races=-1},
			[31823]={races=-2},
			[31824]={races=-2},
			[31825]={coordinates={49.2,52,97},providers={"n",63077},races=-1,requirements={quest=31568}},
			[31826]={coordinates={55.2,51.2,57},providers={"n",63070},races=-1,requirements={quest=31553}},
			[31827]={races=-2},
			[31828]={races=-2},
			[31830]={coordinates={52.7,41.3,1},providers={"n",63061},races=-2,requirements={quest=31572}},
			[31831]={races=-2},
			[31832]={coordinates={50.1,20.2,62},providers={"n",63083},races=-1,requirements={quest=31583}},
			[31850]={flags={daily=true},providers={"n",65655}},
			[31851]={flags={daily=true},providers={"n",65656},races=-1},
			[31852]={flags={daily=true},providers={"n",63194}},
			[31854]={flags={daily=true},providers={"n",66136},races=-2,requirements={quest=31814}},
			[31862]={flags={daily=true},providers={"n",66137},races=-2},
			[31870]={coordinates={57.2,45.8,66},providers={"n",66372},races=-2},
			[31871]={flags={daily=true},providers={"n",66352},races=-2},
			[31872]={flags={daily=true},providers={"n",66372},races=-2},
			[31889]={races=-1},
			[31891]={races=-2},
			[31897]={coordinates={65.6,64.5,83},providers={"n",66466}},
			[31902]={races=-1},
			[31903]={races=-2},
			[31904]={flags={daily=true},providers={"n",66422},races=-2},
			[31905]={flags={daily=true},providers={"n",66436},races=-2},
			[31906]={flags={daily=true},providers={"n",66452},races=-2},
			[31907]={flags={daily=true},providers={"n",66442},races=-2},
			[31908]={races=-2},
			[31909]={flags={daily=true},providers={"n",66466}},
			[31910]={flags={daily=true},providers={"n",66478}},
			[31911]={flags={daily=true},providers={"n",66512}},
			[31912]={flags={daily=true},providers={"n",66515}},
			[31913]={flags={daily=true},providers={"n",66518}},
			[31914]={flags={daily=true},providers={"n",66520}},
			[31915]={},
			[31916]={flags={daily=true},grants={{"item",{89125}}},providers={"n",66522}},
			[31917]={races=-1},
			[31918]={coordinates={39.5,79.1,199},providers={"n",66422},races=-2},
			[31919]={races=-1},
			[31920]={},
			[31921]={races=-2},
			[31922]={},
			[31923]={},
			[31924]={},
			[31925]={},
			[31926]={},
			[31927]={races=-1},
			[31928]={},
			[31929]={races=-2},
			[31930]={races=-1},
			[31931]={},
			[31932]={},
			[31933]={},
			[31934]={},
			[31935]={},
			[31952]={races=-2},
			[31953]={flags={daily=true},providers={"n",66730}},
			[31954]={},
			[31955]={},
			[31956]={},
			[31957]={},
			[31958]={},
			[31966]={races=-1},
			[31967]={races=-2},
			[31970]={coordinates={56.6,41.8,249},providers={"n",66824}},
			[31971]={coordinates={56.6,41.8,249},flags={daily=true},providers={"n",66824}},
			[31972]={flags={daily=true},providers={"n",66819}},
			[31973]={},
			[31974]={},
			[31975]={coordinates={65.6,64.4,83},flags={breadcrumb=true},providers={"n",66466},races=-1},
			[31976]={races=-1},
			[31977]={coordinates={65.6,64.4,83},flags={breadcrumb=true},providers={"n",66466},races=-2},
			[31980]={races=-2},
			[31981]={races=-1},
			[31982]={races=-2},
			[31983]={races=-2},
			[31984]={races=-1},
			[31985]={coordinates={56.6,41.8,249},flags={breadcrumb=true},providers={"n",66824},races=-1},
			[31986]={coordinates={56.6,41.8,249},flags={breadcrumb=true},providers={"n",66824},races=-2},
			[31991]={},
			[32008]={races=-1},
			[32009]={races=-2},
			[32428]={},
			[32434]={},
			[32439]={},
			[32440]={flags={daily=true},providers={"n",68464}},
			[32441]={},
			[32603]={},
			[32604]={},
			[32863]={flags={weekly=true},providers={"n",63626}},
			[32868]={},
			[32869]={},
			[36423]={races=-1},
			[36469]={races=-2},
			[36483]={races=-1},
			[36662]={races=-2},
			[37201]={},
			[37203]={},
			[37205]={},
			[37206]={},
			[37207]={},
			[37208]={},
			[37644]={races=-1},
			[37645]={races=-2},
			[38241]={races=-1},
			[38242]={races=-2},
			[38299]={races=-1},
			[38300]={races=-2},
			[40329]={},
			[45083]={flags={daily=true},providers={"n",115286}},
			[45539]={flags={weekly=true},minlevel=45,providers={"n",116781}},
			[47895]={flags={daily=true},grants={{"item",{151638}}},providers={"n",124617}},
			[52061]={description="Kill Idej the Wise to spawn Taptaf."},
			[56444]={races=-1},
			[56445]={races=-2},
			[56446]={races=-1},
			[56447]={races=-1},
			[56448]={races=-1},
			[56449]={races=-1},
			[56450]={races=-1},
			[56451]={races=-1},
			[56452]={races=-1},
			[56453]={races=-1},
			[56454]={races=-1},
			[56455]={races=-1},
			[56456]={races=-1},
			[56457]={races=-2},
			[56458]={races=-2},
			[56459]={races=-2},
			[56460]={races=-2},
			[56461]={races=-2},
			[56462]={races=-2},
			[56463]={races=-2},
			[56464]={races=-2},
			[56465]={races=-2},
			[56466]={races=-2},
			[56467]={races=-2},
			[66588]={flags={wq=true}},
			[71140]={flags={wq=true},minlevel=60},
			[71145]={flags={wq=true}},
			[71166]={flags={wq=true}},
			[71180]={flags={wq=true}},
			[71206]={flags={wq=true},minlevel=60},
			[72721]={flags={weekly=true},minlevel=70,providers={"n",199526}},
			[73146]={description="Lower the objective to an epic quality before defeating it to obtain the pet",flags={wq=true},grants={{"item",{202413}}}},
			[73147]={description="Lower the objective to an epic quality before defeating it to obtain the pet",flags={wq=true},grants={{"item",{202411}}}},
			[73148]={description="Lower the objective to an epic quality before defeating it to obtain the pet",flags={wq=true},grants={{"item",{202412}}}},
			[73149]={description="Lower the objective to an epic quality before defeating it to obtain the pet",flags={wq=true},grants={{"item",{202407}}}},
			[74792]={flags={wq=true}},
			[74794]={flags={wq=true}},
			[74835]={flags={wq=true}},
			[74836]={flags={wq=true}},
			[74837]={flags={wq=true}},
			[74838]={flags={wq=true}},
			[74840]={flags={wq=true}},
			[74841]={flags={wq=true}},
			[75680]={flags={wq=true}},
			[75750]={flags={wq=true},requirements={quest=75658}},
			[75835]={flags={wq=true},requirements={quest=75658}},
		},
	},
	mapData={
		[1]={{"pet",{418,420,448,466,467,468,635}},{"quest",{31570,31571,31572,31813,31818,31830}}},
		[7]={{"pet",{378,385,386,477}},{"quest",{31573,31574,31575,31831}}},
		[10]={{"pet",{386,419,474,631,635,1157}},{"quest",{31814,31819,45083}}},
		[11]={{"quest",{45539}}},
		[14]={{"pet",{386,417,419,443,445,459}}},
		[15]={{"pet",{398,406,430,431,432,433,438}}},
		[17]={{"pet",{412,414,415,416,635}}},
		[18]={{"pet",{412,417,458,626,646}},{"quest",{31576,31577,31578,31823}}},
		[21]={{"pet",{378,379,387,417,420,455,627,628}}},
		[22]={{"pet",{378,379,398,420,456,648}}},
		[23]={{"npc",{150987}},{"pet",{398,457,626,627,628}},{"quest",{31911}}},
		[25]={{"pet",{378,379,412,417,420,450,452,453,640,646,648,1159}},{"quest",{28617,28733,28744,28747,28748,28751}}},
		[26]={{"pet",{393,417,446,448,449,450}},{"quest",{31910}}},
		[27]={{"pet",{440,441}},{"quest",{31548,31549,31551,31822}}},
		[30]={{"pet",{442,1162}},{"quest",{47895}}},
		[32]={{"pet",{415,423,427,428}},{"quest",{31912}}},
		[36]={{"pet",{393,414,415,423,425,429}},{"quest",{31914}}},
		[37]={{"npc",{6367}},{"pet",{374,378,379,419,447,459,646,675}},{"quest",{31308,31309,31550,31693,31724,31785}}},
		[42]={{"pet",{439,1160}},{"quest",{31915,31916,31976,31980}}},
		[47]={{"pet",{378,379,385,396,397,398,399,400,419,424,646}},{"quest",{31729,31850}}},
		[48]={{"pet",{379,387,417,419,437,440,441}}},
		[49]={{"pet",{378,391,392,395,424,646}},{"quest",{31726,31781}}},
		[50]={{"pet",{401,404,405,406,407,408,409,421,424}},{"quest",{31728,31852}}},
		[51]={{"pet",{401,402,403,418,420,422,648}},{"quest",{31913}}},
		[52]={{"pet",{379,385,386,387,388,389,419,646}},{"quest",{31725,31780}}},
		[56]={{"pet",{379,385,393,398,418,420,509,633}}},
		[57]={{"pet",{419,447,452,478,479,507}},{"quest",{31552,31553,31555,31826}}},
		[62]={{"pet",{378,379,417,493,508}},{"quest",{31582,31583,31584,31832}}},
		[63]={{"pet",{379,417,420,424,450,478,495,496}},{"quest",{31815,31854}}},
		[64]={{"pet",{398,414,424,505}},{"quest",{31906}}},
		[65]={{"pet",{378,412,417,424,472,487,488,506,633}},{"quest",{31817,31862}}},
		[66]={{"pet",{417,419,424,452,478,479,480,482,483,484,485,838}},{"quest",{31870,31872}}},
		[69]={{"pet",{378,379,387,557,1158}},{"quest",{31871}}},
		[70]={{"pet",{385,387,398,412,420,489}},{"quest",{31905}}},
		[71]={{"pet",{430,431,432,484,491,492,494,511,560,1161}}},
		[76]={{"pet",{378,379,388,397,412,417,424,469,470,471,472,473}}},
		[77]={{"pet",{406,420,497,498,499,500}},{"quest",{31907}}},
		[78]={{"pet",{393,403,404,405,406,415,502,503,504,631,632}}},
		[80]={{"pet",{378,379,478,503}},{"quest",{31908}}},
		[81]={{"pet",{406,414,433,482,484,511,512,513}}},
		[83]={{"pet",{69,441,471,472,487,633,634,1163}},{"quest",{31897,31909,31975,31977}}},
		[84]={{"pet",{378,379,675}},{"quest",{31316,31591,31592,31593,31821,31889,31902,31919,31927,31930,31966,32008,32863}}},
		[85]={{"npc",{8404}},{"pet",{418,420,466,467,471}},{"quest",{31585,31586,31587,31588,31589,31590,31812,31827,31828,31891,31903,31921,31929,31952,31967,32009,32863}}},
		[87]={{"pet",{404}}},
		[88]={{"pet",{378,385,386,477}}},
		[89]={{"pet",{419,452,478,479}}},
		[90]={{"pet",{424,450,454}}},
		[94]={{"pet",{387,419,420,459,460}},{"quest",{31579,31580,31581,31824}}},
		[95]={{"pet",{387,417,419,420,450,461,463}}},
		[97]={{"pet",{378,379,397,464}},{"quest",{31556,31568,31569,31825}}},
		[100]={{"pet",{414,635}},{"quest",{31922}}},
		[102]={{"pet",{387,419,515}},{"quest",{31923}}},
		[103]={{"pet",{385,464}}},
		[104]={{"pet",{414,425,497,519}},{"quest",{31920,31926,31981,31982}}},
		[105]={{"pet",{378,379,414,482,528,637,1164}}},
		[106]={{"pet",{397,417,465,627,628}}},
		[107]={{"pet",{379,386,417,420,518,635}},{"quest",{31924}}},
		[108]={{"pet",{379,387,397,417,432,514,517}}},
		[109]={{"pet",{521,638}}},
		[110]={{"pet",{378,385,459}}},
		[111]={{"quest",{31925}}},
		[114]={{"pet",{388,530,536,639,641,1165,1238}}},
		[115]={{"pet",{536,537,641,1238}},{"quest",{31933}}},
		[116]={{"pet",{534,633,647,1238}}},
		[117]={{"pet",{378,379,387,388,397,412,417,424,450,523,525,529,644,646,647,1238}},{"quest",{31931}}},
		[118]={{"pet",{393,538,633,641,1238}},{"quest",{31928,31935,31983,31984}}},
		[119]={{"pet",{379,387,532,649,1167,1238}}},
		[120]={{"pet",{393,412,558,633,641,1238}}},
		[121]={{"pet",{387,412,535,641,1238}},{"quest",{31934}}},
		[127]={{"pet",{378,379,385,1238}},{"quest",{31932}}},
		[198]={{"pet",{415,469,479,482,487,503,539,540,541,547,632,755}},{"quest",{31972}}},
		[199]={{"pet",{386,419,474,475,631,635}},{"quest",{31904,31918}}},
		[207]={{"pet",{469,470,480,553,554,555,556,559,756,837,838}},{"quest",{31973}}},
		[210]={{"pet",{401,404,405,406,407,408,410,411,421,424}},{"quest",{31851,31917}}},
		[241]={{"pet",{388,393,398,414,418,431,470,548,549,550,552,645,647,648,823,2677}},{"quest",{31974}}},
		[245]={{"pet",{410}}},
		[249]={{"pet",{467,484,511,542,543,544,545,546,631,851}},{"quest",{31970,31971,31985,31986}}},
		[279]={{"npc",{3636,3637}}},
		[327]={{"pet",{511,512,513}}},
		[371]={{"pet",{380,562,564,565,566,567,568,569,570,571,572,573,699,702,703,711,712,723,753,754,817,818,819}},{"quest",{31953,32440}}},
		[376]={{"pet",{564,677,706,707,708,709,710,711,713}},{"quest",{31955}}},
		[379]={{"pet",{679,724,725,726,727,728,729,730,731,747,1166}},{"quest",{31956,32441}}},
		[388]={{"pet",{680,724,725,729,732,733,737,739,740,741,742,745}},{"quest",{31991,32434}}},
		[390]={{"pet",{383,747,748,749,750,751,752}},{"quest",{31958,32428,32603,32604,32863,32868,32869}}},
		[407]={{"pet",{1062,1068}}},
		[418]={{"pet",{678,708,711,712,714,716,717,718,722,723,1013,1128}},{"quest",{31954}}},
		[422]={{"pet",{732,741,742,743,744,745,746}},{"quest",{31957,32439}}},
		[427]={{"pet",{378,440,441}}},
		[433]={{"pet",{706,708,709}}},
		[460]={{"pet",{447,507}}},
		[461]={{"pet",{448,466,467,468,635}}},
		[462]={{"pet",{378,385,386}}},
		[463]={{"pet",{466,467}}},
		[465]={{"pet",{417,458}}},
		[467]={{"pet",{459}}},
		[468]={{"pet",{464}}},
		[469]={{"pet",{440,441,1162}}},
		[504]={{"pet",{1175,1179,1181,1182}}},
		[525]={{"pet",{417,560,1427,1457,1464,1578,1579}},{"quest",{37205}}},
		[534]={{"pet",{405,417,483,519,1468,1581,1586,1591,1593}}},
		[535]={{"pet",{427,452,560,568,1441,1572,1583,1587,1589,1593,1595,1599}},{"quest",{37208}}},
		[539]={{"pet",{407,412,560,1447,1455,1582,1587,1593}},{"quest",{37203}}},
		[542]={{"pet",{379,401,407,417,568,635,1441,1456,1462,1573,1582,1587,1590,1592,1593}},{"quest",{37207}}},
		[543]={{"pet",{393,410,430,449,568,702,1463,1464,1465,1469,1470,1594,1615}},{"quest",{37201}}},
		[550]={{"pet",{378,379,386,388,397,417,635,1435,1441}},{"quest",{37206}}},
		[554]={{"pet",{417,1324,1325,1326}}},
		[582]={{"pet",{560}},{"quest",{36423,36483,37644,38241,38299,40329}}},
		[590]={{"pet",{560}},{"quest",{36469,36662,37645,38242,38300,40329}}},
		[627]={{"pet",{1778,1915}}},
		[630]={{"pet",{396,464,478,647,699,706,743,1583,1587,1708,1709,1710,1728,1729,1731,1736,1773,1774,1914,1935}}},
		[634]={{"pet",{380,550,633,645,647,743,1441,1579,1583,1708,1712,1713,1736,1743,1744,1749,1750,1917}}},
		[641]={{"pet",{379,380,393,396,397,398,479,1734,1735,1736,1737,1738,1739,1913}}},
		[650]={{"pet",{378,379,391,407,417,487,496,569,1441,1590,1713,1714,1726,1731,1743,1744,1761,1762,1763,1775,1776}}},
		[680]={{"pet",{425,706,751,1325,1591,1807,1809,1810,1914}}},
		[747]={{"pet",{479}}},
		[777]={{"pet",{1722}}},
		[790]={{"pet",{1728,1914}}},
		[830]={{"pet",{2123,2124,2127}}},
		[862]={{"pet",{2384,2385,2387,2390,2537}}},
		[863]={{"pet",{2388,2389,2392,2393,2394,2395,2397,2398,2400}}},
		[864]={{"pet",{2388,2390,2399}}},
		[882]={{"pet",{2128,2129,2130,2131,2132,2133,2134}}},
		[885]={{"pet",{2122,2126}}},
		[895]={{"pet",{478,487,2165,2377,2379,2380,2381,2382,2383,2399,2400}}},
		[896]={{"pet",{379,2377,2378,2381,2383,2386,2411}},{"quest",{52061}}},
		[942]={{"pet",{2372,2373,2374,2375,2376,2377,2378,2379,2381,2399}}},
		[1355]={{"pet",{2645,2646,2647,2648,2649,2650,2651,2652,2653,2660,2678}},{"quest",{56444,56445,56446,56447,56448,56449,56450,56451,56452,56453,56454,56455,56456,56457,56458,56459,56460,56461,56462,56463,56464,56465,56466,56467}}},
		[1462]={{"pet",{2661,2662,2663,2664,2665,2666,2667,2669,2670,2671,2673,2676}}},
		[1525]={{"pet",{2895,2902,3007,3014,3015}}},
		[1533]={{"pet",{2926,2927,2929,2930,2936,2937,2939,2943}}},
		[1536]={{"pet",{2950,3049,3050,3051,3052,3083}}},
		[1543]={{"pet",{3120}}},
		[1565]={{"pet",{2919,2924,3021,3080,3081,3082}}},
		[2022]={{"npc",{187077}},{"pet",{388,406,417,635,3272,3273,3280,3281,3282,3283,3296,3300,3301,3336,3366,3367,3385}},{"quest",{66588,74840,74841}}},
		[2023]={{"pet",{3266,3272,3276,3282,3288,3296,3300,3313,3322,3353}},{"quest",{71140,71206,74837,74838}}},
		[2024]={{"pet",{388,487,550,635,641,3272,3276,3281,3282,3288,3296,3300,3322,3328,3351,3353,3354,3357}},{"quest",{71145,74835,74836}}},
		[2025]={{"npc",{198604}},{"pet",{406,3272,3276,3282,3295,3296,3301,3322,3336,3352,3366,3384,3403,3404}},{"quest",{71166,71180,74792,74794}}},
		[2112]={{"npc",{187783}},{"pet",{3301}},{"quest",{72721}}},
		[2133]={{"npc",{201004}},{"pet",{3477,3478,3479,3480,3481,3482,3483,3484,3485,3487,3488,3489}},{"quest",{75680,75750,75835}}},
		[2151]={{"quest",{73146,73147,73148,73149}}},
		[2166]={{"pet",{387,540,2864}}},
		[2200]={{"ach",{19293,19401}},{"pet",{4275,4276,4277,4278,4279,4280,4302,4303,4304}}},
	}
}
