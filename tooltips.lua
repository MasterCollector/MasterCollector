local MasterCollector = select(2,...)
local tt = {}
local L = MasterCollector.L
MasterCollector.Tooltip = tt

local tooltip = GameTooltip

-- game tooltip extensions
local function OnTooltipSetUnit(tooltip)
	local unitGuid = UnitGUID("mouseover")
	if unitGuid then
		local unitType,_,_,_,_,id = strsplit('-',unitGuid)
		if unitType == 'Player' then return end
		
		tooltip:AddDoubleLine(unitType .. ' ID:', id)
		if unitType == 'Creature' then
			local obj = MasterCollector.DB:GetObjectData('npc', tonumber(id))
			if obj and obj.children then
				local visible = false
				for _,v in pairs(obj.children) do
					if v.visible then visible = true break end
				end
				if visible then
					tooltip:AddLine('Grants:')
					for _,v in pairs(obj.children or {}) do
						if v.visible then
							tooltip:AddLine(v.text)
							if v.icon then tooltip:AddTexture(v.icon) end
						end
					end
				end
			end
		end
	end
end

local function OnTooltipSetItem(tooltip)
	if not tooltip.GetItem then return end
	local _, link, itemID = tooltip:GetItem()
	if itemID then
		tooltip:AddDoubleLine("Item ID:", tostring(itemID))
		local _,_,_,equipLocation,_,classID,subclassID = GetItemInfoInstant(itemID)
		local appearanceID, sourceID = C_TransmogCollection.GetItemInfo(link)
		tooltip:AddDoubleLine("Item classID:", tostring(classID))
		tooltip:AddDoubleLine("Item subclassID:", tostring(subclassID))
		if equipLocation and equipLocation ~= "" then
			tooltip:AddDoubleLine("Item equipLocation:", tostring(equipLocation))
		end
		if appearanceID then
			tooltip:AddDoubleLine("Appearance ID:", tonumber(appearanceID))
			tooltip:AddDoubleLine("Source ID:", tonumber(sourceID))
		end
	end
end

local function AppendQuestRequirement(quest, first)
	if quest.eligible then
		if first then
			tooltip:AddDoubleLine("Quest(s): ", quest.text)
		else
			tooltip:AddDoubleLine(" ", quest.text)
		end
		
		if quest.icon then tooltip:AddTexture(quest.icon, {margin={right=4},region=Enum.TooltipTextureRelativeRegion.RightLine}) end
		if quest.collected then tooltip:AddTexture("Interface\\AddOns\\MasterCollector\\assets\\Collected", {margin={right=16},region=Enum.TooltipTextureRelativeRegion.RightLine}) end
	end
end
local function AppendLeadsTo(quest, printHeader)
	if printHeader then
		tooltip:AddDoubleLine("Leads To Quest(s): ", quest.text)
	else
		tooltip:AddDoubleLine(" ", quest.text)
	end
	
	if quest.icon then tooltip:AddTexture(quest.icon, {margin={right=4},region=Enum.TooltipTextureRelativeRegion.RightLine}) end
	if quest.collected then tooltip:AddTexture("Interface\\AddOns\\MasterCollector\\assets\\Collected", {margin={right=16},region=Enum.TooltipTextureRelativeRegion.RightLine}) end
end

local function OnTooltipSetQuest(tooltip, rowFrame)
	if rowFrame and rowFrame.data then
		local data = rowFrame.data
		tooltip:SetOwner(rowFrame)
		tooltip:AddLine(string.format('%s %s', data.text, '('..tostring(data.id or "Unknown")..')'))
		
		if data.description then
			tooltip:AddLine(" ")
			tooltip:AddLine(data.description, nil, nil, nil, true)
			tooltip:AddLine(" ")
		end
		
		if data.requirements or data.races then
			tooltip:AddLine("Requirements:")
			
			if data.races then
				local races = data.races
				if type(races) ~= 'table' then races = {races} end
				for row,raceID in pairs(races) do
					if row == 1 then
						tooltip:AddDoubleLine("Race(s):", L.Races[raceID])
					else
						tooltip:AddDoubleLine(" ", L.Races[raceID])
					end
				end
			end
			
			if data.requirements then
				for k,v in pairs(data.requirements) do
					if k == "quest" then
						if getmetatable(v) then
							AppendQuestRequirement(v, true)
						else
							local printFirstLine = true
							for index=1, #v do
								if v[index].eligible then
									AppendQuestRequirement(v[index], printFirstLine)
									if printFirstLine then printFirstLine = false end
								end
							end
						end
					elseif k == "script" then
						if type(v) ~= "table" then v = {v} end
						local scriptName, params = v[1], v[2]
						if scriptName == "IsOnQuestOrComplete" or scriptName == "IsOnQuest" then
							local quest = MasterCollector.DB:GetObjectData("quest", tonumber(params)) or {text=string.format(L.Text.QUEST_PENDING_NAME, params)}
							tooltip:AddDoubleLine(MasterCollector.L.Scripts[scriptName], quest.text)
						end
					elseif k == "rep" then
						local name = GetFactionInfoByID(v)
						tooltip:AddDoubleLine(REPUTATION, name or string.format("Unknown (%s)",v))
					elseif k == "renown" then
						tooltip:AddDoubleLine(RENOWN_LEVEL_LABEL, v)
					elseif k == "spell" then
						tooltip:AddDoubleLine('Spell:', select(1,GetSpellInfo(v)))
					end
				end
			end
		end
		
		if data.leadsTo then
			local printFirstLine = true
			for index=1, #data.leadsTo do
				if data.leadsTo[index].eligible then
					AppendLeadsTo(data.leadsTo[index], printFirstLine)
					if printFirstLine then printFirstLine = false end
				end
			end
		end
	end
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem)
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, OnTooltipSetUnit)

function tt:WindowFrameEnter(frame)
	if frame.data then
		tooltip:SetOwner(frame)
		if frame.data.type == 'achievement' then
			tooltip:SetAchievementByID(frame.data.id)
		elseif frame.data.baseType == 'item' then
			tooltip:SetItemByID(frame.data.id)
		elseif frame.data.type == 'quest' then
			OnTooltipSetQuest(tooltip, frame)
		end
		tooltip:Show()
	end
end
function tt:WindowFrameLeave(frame)
	tooltip:ClearLines()
	tooltip:Hide()
end