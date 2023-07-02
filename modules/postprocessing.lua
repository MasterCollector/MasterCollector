local MasterCollector = select(2,...)

local missable = {
	["quest"] = {
		[24493] = [[return C_QuestLog.IsQuestFlaggedCompleted(24492)]],
		-- breadcrumbs below. These should be easy to automate since they lead to another quest, but having them here works for now
		[26373] = [[return C_QuestLog.IsQuestFlaggedCompleted(25724)]],
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