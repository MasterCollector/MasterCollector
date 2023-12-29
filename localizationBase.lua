MasterCollector = select(2, ...)	-- Intentionally made non-local
local L = {}
MasterCollector.L = L

L.Text = {
	QUEST_PENDING_NAME = LOOT_JOURNAL_LEGENDARIES_SOURCE_QUEST .. ' #%d', -- Using a known global constant here will auto-translate. Not the best key but it works
	QUEST_REMOVED = "Removed Quest #%s",
	QUEST_HIDDEN = "Tracking Quest #%s",
	QUEST_HIDDEN_DAILY = "Daily tracker",
	QUEST_HIDDEN_WEEKLY = "Weekly tracker",
	QUEST_UNKNOWN_NAME = "Quest #%s",
}
L.Settings = {
	Filters = {
		IGNORE_RACE = " Ignore race/faction requirements",
		IGNORE_GENDER = " Ignore gender requirements",
		IGNORE_CLASS = " Ignore class requirements",
		IGNORE_LEVEL = " Ignore level requirements",
		SHOW_COLLECTED = " Show collected",
	},
}
L.Panels = {
	["ach"] = {
		text = ACHIEVEMENTS,
		icon = "Interface\\ACHIEVEMENTFRAME\\UI-Achievement-TinyShield",
		txcoord = { left = 0, right = 0.6, top = 0, bottom = 0.6 },
	},
	["npc"] = {
		text = "NPCs"
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

L.Races = {
   [-2] = FACTION_HORDE,
   [-1] = FACTION_ALLIANCE,
   [0] = FACTION_NEUTRAL
}
setmetatable(L.Races, {
      __index = function(self, key)
         local raceID, ci = tonumber(key)
         if raceID then
            ci = C_CreatureInfo.GetRaceInfo(raceID)
         end
         rawset(self, key, (ci and ci.raceName) or "Unknown")
         return self[key]
      end
})

-- not sure if this is a good idea or not [Pr3vention]
-- Explicit titles should only be provided for quests that otherwise don't have names (e.g. account triggers)
L.Quests = {
	[27563] = "Recruit Beezil Linkspanner",
	[75658] = "Zaralek Cavern world quests unlocked",
	[77887] = "Emerald Dream world quests unlocked",
	[78904] = "Emerald Dream Chapter 3 completed on account",
}

L.Scripts = {
	["IsOnQuestOrComplete"] = "Must be on or have completed quest ",
	["IsOnQuest"] = "Must be on quest ",
}