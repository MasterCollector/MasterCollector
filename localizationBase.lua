local MasterCollector = select(2,...)
MasterCollector.L = {}

-- panel info
MasterCollector.L.Text = {
	QUEST_PENDING_NAME = LOOT_JOURNAL_LEGENDARIES_SOURCE_QUEST .. ' #%d' -- Using a known global constant here will auto-translate. Not the best key but it works
}
MasterCollector.L.Panels = {
	["ach"] = {
		text = ACHIEVEMENTS,
		icon = "Interface\\ACHIEVEMENTFRAME\\UI-Achievement-TinyShield",
		txcoord = { left = 0, right = 0.6, top = 0, bottom = 0.6 },
	},
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
