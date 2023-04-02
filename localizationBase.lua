local MasterCollector = select(2,...)
local L = {}
MasterCollector.L = L

L.Text = {
	QUEST_PENDING_NAME = LOOT_JOURNAL_LEGENDARIES_SOURCE_QUEST .. ' #%d' -- Using a known global constant here will auto-translate. Not the best key but it works
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
	[75658] = "Zaralek Cavern world quests unlocked on one character",
}