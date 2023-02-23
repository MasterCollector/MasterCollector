local MasterCollector = select(2,...)
local tt = {}
MasterCollector.Tooltip = tt

local tooltip = GameTooltip
function tt:WindowFrameEnter(frame)
	if frame.data then
		tooltip:SetOwner(frame)
		if frame.data.type == 'achievement' then
			tooltip:SetAchievementByID(frame.data.id)
		elseif frame.data.type == 'item' then
			tooltip:SetItemByID(frame.data.id)
		end
		tooltip:Show()
	end
end
function tt:WindowFrameLeave(frame)
	tooltip:ClearLines()
	tooltip:Hide()
end

-- game tooltip extensions
local function OnTooltipSetUnit(tooltip)
	local unitGuid = UnitGUID("mouseover")
	if unitGuid then
		local unitType,_,_,_,_,id = strsplit('-',unitGuid)
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
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem)
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, OnTooltipSetUnit)
