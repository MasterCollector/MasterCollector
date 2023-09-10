local MasterCollector = select(2,...)

local missable = {
	["quest"] = {
		[24493] = [[return C_QuestLog.IsQuestFlaggedCompleted(24492)]],
		[25617] = [[return C_QuestLog.IsQuestFlaggedCompleted(25624)]],
		[25624] = [[return C_QuestLog.IsQuestFlaggedCompleted(25617)]],
		[25618] = [[return C_QuestLog.IsQuestFlaggedCompleted(25623)]],
		[25623] = [[return C_QuestLog.IsQuestFlaggedCompleted(25618)]],
		[26692] = [[return C_QuestLog.IsQuestFlaggedCompleted(26714)]],
		-- lvl 20 riding quests. While collectible if you hit level 10, they're not possible to get if you abandon them, use a boost, or learn a riding skill without the quest
		[14083] = [[for _,spellID in pairs({33388,33391,34090,34091,90265}) do if IsSpellKnown(spellID) then return true end end return false ]],
		[14084] = [[for _,spellID in pairs({33388,33391,34090,34091,90265}) do if IsSpellKnown(spellID) then return true end end return false ]],
		[32618] = [[for _,spellID in pairs({33388,33391,34090,34091,90265}) do if IsSpellKnown(spellID) then return true end end return false ]],
		[32661] = [[for _,spellID in pairs({33388,33391,34090,34091,90265}) do if IsSpellKnown(spellID) then return true end end return false ]],
		[32662] = [[for _,spellID in pairs({33388,33391,34090,34091,90265}) do if IsSpellKnown(spellID) then return true end end return false ]],
		[32663] = [[for _,spellID in pairs({33388,33391,34090,34091,90265}) do if IsSpellKnown(spellID) then return true end end return false ]],
		[32664] = [[for _,spellID in pairs({33388,33391,34090,34091,90265}) do if IsSpellKnown(spellID) then return true end end return false ]],
		[32665] = [[for _,spellID in pairs({33388,33391,34090,34091,90265}) do if IsSpellKnown(spellID) then return true end end return false ]],
		[32667] = [[for _,spellID in pairs({33388,33391,34090,34091,90265}) do if IsSpellKnown(spellID) then return true end end return false ]],
		[32668] = [[for _,spellID in pairs({33388,33391,34090,34091,90265}) do if IsSpellKnown(spellID) then return true end end return false ]],
		[32669] = [[for _,spellID in pairs({33388,33391,34090,34091,90265}) do if IsSpellKnown(spellID) then return true end end return false ]],
		[32670] = [[for _,spellID in pairs({33388,33391,34090,34091,90265}) do if IsSpellKnown(spellID) then return true end end return false ]],
		[32671] = [[for _,spellID in pairs({33388,33391,34090,34091,90265}) do if IsSpellKnown(spellID) then return true end end return false ]],
		[32672] = [[for _,spellID in pairs({33388,33391,34090,34091,90265}) do if IsSpellKnown(spellID) then return true end end return false ]],
		[32673] = [[for _,spellID in pairs({33388,33391,34090,34091,90265}) do if IsSpellKnown(spellID) then return true end end return false ]],
		-- lvl 30 riding quests
		[32674] = [[for _,spellID in pairs({34090,34091,90265}) do if IsSpellKnown(spellID) then return true end end return false ]],
		[32675] = [[for _,spellID in pairs({34090,34091,90265}) do if IsSpellKnown(spellID) then return true end end return false ]],
		-- breadcrumbs below. These should be easy to automate since they lead to another quest, but having them here works for now
		[239] = [[return C_QuestLog.IsQuestFlaggedCompleted(11)]],
		[1097] = [[return C_QuestLog.IsQuestFlaggedCompleted(353)]],
		[13635] = [[return C_QuestLog.IsQuestFlaggedCompleted(26145)]],
		[13636] = [[return C_QuestLog.IsQuestFlaggedCompleted(26843)]],
		[25702] = [[return C_QuestLog.IsQuestFlaggedCompleted(25703)]],
		[25770] = [[return C_QuestLog.IsQuestFlaggedCompleted(25721)]],
		[25777] = [[return C_QuestLog.IsQuestFlaggedCompleted(25780)]],
		[25882] = [[return C_QuestLog.IsQuestFlaggedCompleted(25932)]],
		[25986] = [[return C_QuestLog.IsQuestFlaggedCompleted(25978)]],
		[26137] = [[return C_QuestLog.IsQuestFlaggedCompleted(25395)]],
		[26139] = [[return C_QuestLog.IsQuestFlaggedCompleted(26093)]],
		[26150] = [[return C_QuestLog.IsQuestFlaggedCompleted(106)]],
		[26175] = [[return C_QuestLog.IsQuestFlaggedCompleted(26184)]],
		[26176] = [[return C_QuestLog.IsQuestFlaggedCompleted(26842)]],
		[26327] = [[return C_QuestLog.IsQuestFlaggedCompleted(26127)]],
		[26341] = [[return C_QuestLog.IsQuestFlaggedCompleted(26039)]],
		[26346] = [[return C_QuestLog.IsQuestFlaggedCompleted(26049)]],
		[26365] = [[return C_QuestLog.IsQuestFlaggedCompleted(26503)]],
		[26371] = [[return C_QuestLog.IsQuestFlaggedCompleted(26348)]],
		[26373] = [[return C_QuestLog.IsQuestFlaggedCompleted(25724)]],
		[26378] = [[return C_QuestLog.IsQuestFlaggedCompleted(26209)]],
		[26627] = [[return C_QuestLog.IsQuestFlaggedCompleted(26653)]],
		[26785] = [[return C_QuestLog.IsQuestFlaggedCompleted(26717)]],
		[26838] = [[return C_QuestLog.IsQuestFlaggedCompleted(26735)]],
		[26980] = [[return C_QuestLog.IsQuestFlaggedCompleted(25864)]],
		[26981] = [[return C_QuestLog.IsQuestFlaggedCompleted(25849)]],
		[27763] = [[return C_QuestLog.IsQuestFlaggedCompleted(27774)]],
		[27869] = [[return C_QuestLog.IsQuestFlaggedCompleted(27694)]],
		[27915] = [[return C_QuestLog.IsQuestFlaggedCompleted(27605)]],
		[27919] = [[return C_QuestLog.IsQuestFlaggedCompleted(25715)]],
		[27870] = [[return C_QuestLog.IsQuestFlaggedCompleted(27821)]],
		[27871] = [[return C_QuestLog.IsQuestFlaggedCompleted(27852)]],
		[27927] = [[return C_QuestLog.IsQuestFlaggedCompleted(27713)]],
		[28278] = [[return C_QuestLog.IsQuestFlaggedCompleted(28327)]],
		[28512] = [[return C_QuestLog.IsQuestFlaggedCompleted(27963)]],
		[28514] = [[return C_QuestLog.IsQuestFlaggedCompleted(28172)]],
		[28562] = [[return C_QuestLog.IsQuestFlaggedCompleted(26209)]],
		[28563] = [[return C_QuestLog.IsQuestFlaggedCompleted(26503)]],
		[28569] = [[return C_QuestLog.IsQuestFlaggedCompleted(27587)]],
		[28573] = [[return C_QuestLog.IsQuestFlaggedCompleted(26093)]],
		[28581] = [[return C_QuestLog.IsQuestFlaggedCompleted(27963)]],
		[28582] = [[return C_QuestLog.IsQuestFlaggedCompleted(27963)]],
		[28666] = [[return C_QuestLog.IsQuestFlaggedCompleted(28416) or C_QuestLog.IsQuestFlaggedCompleted(28174)]],
		[28749] = [[return C_QuestLog.IsQuestFlaggedCompleted(27159)]],
	}
}

MasterCollector.PostProcess = function()
	-- apply missable criteria to objects that have been loaded previously
	for objectType,objectTable in pairs(missable) do
		for id, funcString in pairs(objectTable) do
			local obj = MasterCollector.DB:GetObjectData(objectType, id)
			if obj and funcString then
				obj.IsMissed = loadstring(funcString)
			end
		end
	end
	-- the table is no longer needed once everything has been applied, so set to nil for garbage collection
	missable = nil
	collectgarbage()
end