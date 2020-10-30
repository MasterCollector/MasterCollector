local MasterCollector = select(2,...)
MasterCollector.L = {}

-- panel info
MasterCollector.L.Panels = {
	["pet"] = {
		text = AUCTION_CATEGORY_BATTLE_PETS,
		icon = "Interface\\Icons\\Tracking_WildPet",
	},
	["quest"] = {
		text = QUESTS_LABEL,
		icon = "Interface\\gossipframe\\availablequesticon",
	},
	["treasure"] = {
		text = "Treasure Chests",
		icon = "Interface\\minimap\\objecticons",
		txcoord = { left = 0.26953125, right = 0.35546875, top = 0.64453125, bottom = 0.734375 }
	}
}
