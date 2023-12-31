local MasterCollector = select(2,...)

local missable = {
	["quest"] = {
		[24493] = [[return C_QuestLog.IsQuestFlaggedCompleted(24492)]],
		[25617] = [[return C_QuestLog.IsQuestFlaggedCompleted(25624)]],
		[25624] = [[return C_QuestLog.IsQuestFlaggedCompleted(25617)]],
		[25618] = [[return C_QuestLog.IsQuestFlaggedCompleted(25623)]],
		[25623] = [[return C_QuestLog.IsQuestFlaggedCompleted(25618)]],
		[26009] = [[return C_QuestLog.IsQuestFlaggedCompleted(26115)]],
		[26028] = [[return C_QuestLog.IsQuestFlaggedCompleted(26115)]],
		[26692] = [[return C_QuestLog.IsQuestFlaggedCompleted(26714)]],
		-- Some quests were remade during Cataclysm, but if you did the original versions then the new ones become unavailable
		[29021] = [[return C_QuestLog.IsQuestFlaggedCompleted(902)]],
		[29022] = [[return C_QuestLog.IsQuestFlaggedCompleted(902)]],
		[29023] = [[return C_QuestLog.IsQuestFlaggedCompleted(902)]],
		[29024] = [[return C_QuestLog.IsQuestFlaggedCompleted(902)]],
		[29027] = [[return C_QuestLog.IsQuestFlaggedCompleted(3922)]],
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
		-- complex conditions that invalidate quests. Not confident in handling these as "missed" because they were never collectible in the first place
		-- Zangarmarsh
		[9742] = [[return select(3,GetFactionInfoByID(970))>=5]], -- sporegarr friendly
		[9744] = [[return select(3,GetFactionInfoByID(970))>=5]], -- sporegarr friendly
		[9807] = [[return select(3,GetFactionInfoByID(970))>=5]], -- sporegarr friendly
		[9809] = [[return select(3,GetFactionInfoByID(970))>=5]], -- sporegarr friendly
		-- breadcrumbs below. These should be easy to automate since they lead to another quest, but having them here works for now
		[239] = [[return C_QuestLog.IsQuestFlaggedCompleted(11)]],
		[1097] = [[return C_QuestLog.IsQuestFlaggedCompleted(353)]],
		[9498] = [[return C_QuestLog.IsQuestFlaggedCompleted(9340)]],
		[9499] = [[return C_QuestLog.IsQuestFlaggedCompleted(9340)]],
		[9697] = [[return C_QuestLog.IsQuestFlaggedCompleted(9701)]],
		[9778] = [[return C_QuestLog.IsQuestFlaggedCompleted(9728)]],
		[9913] = [[return C_QuestLog.IsQuestFlaggedCompleted(9882)]],
		[9944] = [[return C_QuestLog.IsQuestFlaggedCompleted(9945)]],
		[9957] = [[return C_QuestLog.IsQuestFlaggedCompleted(9968)]],
		[9982] = [[return C_QuestLog.IsQuestFlaggedCompleted(9991)]],
		[9983] = [[return C_QuestLog.IsQuestFlaggedCompleted(9991)]],
		[10113] = [[return C_QuestLog.IsQuestFlaggedCompleted(9854)]],
		[10114] = [[return C_QuestLog.IsQuestFlaggedCompleted(9854)]],
		[10279] = [[return C_QuestLog.IsQuestFlaggedCompleted(10277)]],
		[10289] = [[return C_QuestLog.IsQuestFlaggedCompleted(10291)]],
		[10403] = [[return C_QuestLog.IsQuestFlaggedCompleted(10367)]],
		[10442] = [[return C_QuestLog.IsQuestFlaggedCompleted(9372)]],
		[10443] = [[return C_QuestLog.IsQuestFlaggedCompleted(9372)]],
		[11048] = [[return C_QuestLog.IsQuestFlaggedCompleted(10595)]],
		[13635] = [[return C_QuestLog.IsQuestFlaggedCompleted(26145)]],
		[13636] = [[return C_QuestLog.IsQuestFlaggedCompleted(26843)]],
		[13866] = [[return C_QuestLog.IsQuestFlaggedCompleted(13612)]],
		[13923] = [[return C_QuestLog.IsQuestFlaggedCompleted(13936)]],
		[13991] = [[return C_QuestLog.IsQuestFlaggedCompleted(14066)]],
		[14073] = [[return C_QuestLog.IsQuestFlaggedCompleted(852)]],
		[14129] = [[return C_QuestLog.IsQuestFlaggedCompleted(28496)]],
		[14162] = [[return C_QuestLog.IsQuestFlaggedCompleted(14161)]],
		[14184] = [[return C_QuestLog.IsQuestFlaggedCompleted(14188)]],
		[14255] = [[return C_QuestLog.IsQuestFlaggedCompleted(14256)]],
		[14337] = [[return C_QuestLog.IsQuestFlaggedCompleted(14334)]],
		[14338] = [[return C_QuestLog.IsQuestFlaggedCompleted(14339)]],
		[14391] = [[return C_QuestLog.IsQuestFlaggedCompleted(24467)]],
		[14424] = [[return C_QuestLog.IsQuestFlaggedCompleted(14308)]],
		[14442] = [[return C_QuestLog.IsQuestFlaggedCompleted(14408)]],
		[24459] = [[return C_QuestLog.IsQuestFlaggedCompleted(749)]],
		[24463] = [[return C_QuestLog.IsQuestFlaggedCompleted(13866)]],
		[24543] = [[return C_QuestLog.IsQuestFlaggedCompleted(24546)]],
		[24604] = [[return C_QuestLog.IsQuestFlaggedCompleted(24603)]],
		[24632] = [[return C_QuestLog.IsQuestFlaggedCompleted(24684)]],
		[24698] = [[return C_QuestLog.IsQuestFlaggedCompleted(24730)]],
		[24854] = [[return C_QuestLog.IsQuestFlaggedCompleted(24719)]],
		[24905] = [[return C_QuestLog.IsQuestFlaggedCompleted(24955)]],
		[24911] = [[return C_QuestLog.IsQuestFlaggedCompleted(24740)]],
		[25356] = [[return C_QuestLog.IsQuestFlaggedCompleted(25487)]],
		[25386] = [[return C_QuestLog.IsQuestFlaggedCompleted(25209)]],
		[25478] = [[return C_QuestLog.IsQuestFlaggedCompleted(25487)]],
		[25702] = [[return C_QuestLog.IsQuestFlaggedCompleted(25703)]],
		[25018] = [[return C_QuestLog.IsQuestFlaggedCompleted(25019)]],
		[25556] = [[return C_QuestLog.IsQuestFlaggedCompleted(27068)]],
		[25770] = [[return C_QuestLog.IsQuestFlaggedCompleted(25721)]],
		[25777] = [[return C_QuestLog.IsQuestFlaggedCompleted(25780)]],
		[25882] = [[return C_QuestLog.IsQuestFlaggedCompleted(25932)]],
		[25986] = [[return C_QuestLog.IsQuestFlaggedCompleted(25978)]],
		[26069] = [[return C_QuestLog.IsQuestFlaggedCompleted(24504)]],
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
		[26496] = [[return C_QuestLog.IsQuestFlaggedCompleted(26497)]],
		[26589] = [[return C_QuestLog.IsQuestFlaggedCompleted(25210)]],
		[26627] = [[return C_QuestLog.IsQuestFlaggedCompleted(26653)]],
		[26785] = [[return C_QuestLog.IsQuestFlaggedCompleted(26717)]],
		[26838] = [[return C_QuestLog.IsQuestFlaggedCompleted(26735)]],
		[26895] = [[return C_QuestLog.IsQuestFlaggedCompleted(25067)]],
		[26896] = [[return C_QuestLog.IsQuestFlaggedCompleted(25067)]],
		[26935] = [[return C_QuestLog.IsQuestFlaggedCompleted(27000)]],
		[26980] = [[return C_QuestLog.IsQuestFlaggedCompleted(25864)]],
		[26981] = [[return C_QuestLog.IsQuestFlaggedCompleted(25849)]],
		[27182] = [[return C_QuestLog.IsQuestFlaggedCompleted(27183)]],
		[27447] = [[return C_QuestLog.IsQuestFlaggedCompleted(24906)]],
		[27532] = [[return C_QuestLog.IsQuestFlaggedCompleted(27531)]],
		[27535] = [[return C_QuestLog.IsQuestFlaggedCompleted(27533)]],
		[27544] = [[return C_QuestLog.IsQuestFlaggedCompleted(27420)]],
		[27683] = [[return C_QuestLog.IsQuestFlaggedCompleted(27367)]],
		[27763] = [[return C_QuestLog.IsQuestFlaggedCompleted(27774)]],
		[27869] = [[return C_QuestLog.IsQuestFlaggedCompleted(27694)]],
		[27915] = [[return C_QuestLog.IsQuestFlaggedCompleted(27605)]],
		[27919] = [[return C_QuestLog.IsQuestFlaggedCompleted(25715)]],
		[27870] = [[return C_QuestLog.IsQuestFlaggedCompleted(27821)]],
		[27871] = [[return C_QuestLog.IsQuestFlaggedCompleted(27852)]],
		[27927] = [[return C_QuestLog.IsQuestFlaggedCompleted(27713)]],
		[28150] = [[return C_QuestLog.IsQuestFlaggedCompleted(28000)]],
		[28152] = [[return C_QuestLog.IsQuestFlaggedCompleted(28116)]],
		[28278] = [[return C_QuestLog.IsQuestFlaggedCompleted(28327)]],
		[28284] = [[return C_QuestLog.IsQuestFlaggedCompleted(27317)]],
		[28305] = [[return C_QuestLog.IsQuestFlaggedCompleted(28207)]],
		[28306] = [[return C_QuestLog.IsQuestFlaggedCompleted(28360)]],
		[28372] = [[return C_QuestLog.IsQuestFlaggedCompleted(28333)]],
		[28373] = [[return C_QuestLog.IsQuestFlaggedCompleted(28338)]],
		[28392] = [[return C_QuestLog.IsQuestFlaggedCompleted(28338)]],
		[28512] = [[return C_QuestLog.IsQuestFlaggedCompleted(27963)]],
		[28514] = [[return C_QuestLog.IsQuestFlaggedCompleted(28172)]],
		[28524] = [[return C_QuestLog.IsQuestFlaggedCompleted(28460)]],
		[28532] = [[return C_QuestLog.IsQuestFlaggedCompleted(25945)]],
		[28542] = [[return C_QuestLog.IsQuestFlaggedCompleted(27997)]],
		[28543] = [[return C_QuestLog.IsQuestFlaggedCompleted(27997)]],
		[28544] = [[return C_QuestLog.IsQuestFlaggedCompleted(28460)]],
		[28545] = [[return C_QuestLog.IsQuestFlaggedCompleted(28460)]],
		[28562] = [[return C_QuestLog.IsQuestFlaggedCompleted(26209)]],
		[28563] = [[return C_QuestLog.IsQuestFlaggedCompleted(26503)]],
		[28569] = [[return C_QuestLog.IsQuestFlaggedCompleted(27587)]],
		[28573] = [[return C_QuestLog.IsQuestFlaggedCompleted(26093)]],
		[28581] = [[return C_QuestLog.IsQuestFlaggedCompleted(27963)]],
		[28582] = [[return C_QuestLog.IsQuestFlaggedCompleted(27963)]],
		[28674] = [[return C_QuestLog.IsQuestFlaggedCompleted(28676)]],
		[28718] = [[return C_QuestLog.IsQuestFlaggedCompleted(28640)]],
		[28768] = [[return C_QuestLog.IsQuestFlaggedCompleted(28460)]],
		[28847] = [[return C_QuestLog.IsQuestFlaggedCompleted(28837)]],
		[28666] = [[return C_QuestLog.IsQuestFlaggedCompleted(28416) or C_QuestLog.IsQuestFlaggedCompleted(28174)]],
		[28749] = [[return C_QuestLog.IsQuestFlaggedCompleted(27159)]],
		[69896] = [[return C_QuestLog.IsQuestFlaggedCompleted(66435)]],
		[76566] = [[return C_QuestLog.IsQuestFlaggedCompleted(76567)]],
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
