-- TODO: check if treasures module is enabled. If not, return immediately
--if true then return end
local MasterCollector = select(2,...)
--@GENERATE_HERE@--
MasterCollector.Modules.Treasures={
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
			[73548]={flags={daily=true},providers={"o",386088}},
			[73551]={flags={daily=true},providers={"o",386089}},
			[73552]={flags={daily=true},providers={"o",386090}},
			[73553]={flags={daily=true},providers={"o",386091}},
			[75302]={flags={daily=true},providers={"o",396019}},
			[75303]={flags={daily=true},providers={"o",396020}},
			[75320]={description="Knock the moth into the air 5 times.",providers={"o",396339}},
			[75646]={providers={"o",401236},requirements={prof=171}},
			[75649]={providers={"o",401238},requirements={prof=171}},
			[75651]={providers={"o",401240},requirements={prof=171}},
			[75745]={providers={"o",401828}},
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
			[386088]={coordinates={{41.71,44.57,2133},{40.03,51.26,2133},{40.82,50.32,2133}}},
			[386089]={coordinates={{33.02,39.88,2133},{31.88,39.62,2133},{30.49,43.66,2133}}},
			[386090]={coordinates={{36.42,52.25,2133},{35.14,52.24,2133}}},
			[386091]={coordinates={{28.58,48.69,2133},{27.34,42.17,2133},{28.86,44.17,2133}}},
			[396019]={coordinates={60.66,46.25,2133}},
			[396020]={coordinates={63.69,82.56,2184}},
			[396339]={coordinates={56.67,49.35,2133}},
			[401236]={coordinates={52.63,18.3,2133}},
			[401238]={coordinates={62.12,41.13,2133}},
			[401240]={coordinates={40.44,59.21,2133}},
			[401828]={coordinates={64.16,74.96,2133}},
		},
	},
	mapData={
		[37]={{"quest",{54131}}},
		[862]={{"quest",{49257,50259,50582,50707,50949,51624}}},
		[1165]={{"quest",{48938,50947,51338}}},
		[1177]={{"quest",{49936}}},
		[1409]={{"quest",{56088,56579,56581,58380}}},
		[2133]={{"quest",{73548,73551,73552,73553,75302,75320,75646,75649,75651,75745}}},
		[2184]={{"quest",{75303}}},
	}
}
