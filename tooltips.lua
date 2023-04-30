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
			if obj.children then
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
				if races ~= 'table' then races = {races} end
				for _,v in pairs(races) do
					tooltip:AddDoubleLine("Race(s):", L.Races[v])
				end
			end
			
			if data.requirements then
				for k,v in pairs(data.requirements) do
					if k == "quest" then
						if type(v) ~= "table" then v = {v} end
						for row,questID in pairs(v) do
							local quest = MasterCollector.DB:GetObjectData("quest", questID)
							if row == 1 then
								tooltip:AddDoubleLine("Quests: ", quest.text)
							else
								tooltip:AddDoubleLine(" ", quest.text)
							end
							
							if quest.icon then tooltip:AddTexture(quest.icon, {margin={right=4},region=Enum.TooltipTextureRelativeRegion.RightLine}) end
							if quest.collected then tooltip:AddTexture("Interface\\AddOns\\MasterCollector\\assets\\Collected", {margin={right=16},region=Enum.TooltipTextureRelativeRegion.RightLine}) end
						end
					elseif k == "script" then
						if type(v) ~= "table" then v = {v} end
						local scriptName, params = v[1], v[2]
						if scriptName == "IsOnQuestOrComplete" then
							local quest = MasterCollector.DB:GetObjectData("quest", tonumber(params))
							tooltip:AddDoubleLine(MasterCollector.L.Scripts[scriptName], quest.text)
						end
					elseif k == "rep" then
						local name = GetFactionInfoByID(v)
						tooltip:AddDoubleLine(REPUTATION, name or string.format("Unknown (%s)",v))
					elseif k == "renown" then
						tooltip:AddDoubleLine(RENOWN_LEVEL_LABEL, v)
					end
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