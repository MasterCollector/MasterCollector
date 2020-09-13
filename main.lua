local addonName = select(1,...)
MasterCollector = select(2,...)
local data = {
	
}

MasterCollector.harvest = function()
	MCAppearanceHarvestData = {}
	local TMogGetItemInfo = C_TransmogCollection.GetItemInfo
	local items = {}
	local modIDs = {
	   0,	-- no mods
	   1,	-- normal dungeon
	   2,	-- heroic dungeon
	   3,	-- normal raid
	   4,	-- lfr raid
	   5,	-- heroic raid
	   6,	-- mythic raid
	   22,	-- timewalking
	   23	-- 'mythic dungeon'
	}
	for itemID=1,180784,1--175000,175100,1--1,178015,1
	do
	   local id,_,_,loc,_,classID,subclassID = GetItemInfoInstant(itemID)
	   if id and (classID == 4 or (classID == 2 and (subclassID ~= 0 and subclassID ~= 11))) then
		  for idx=1,#modIDs,1 do
			 local appearanceID,sourceID = TMogGetItemInfo(itemID, modIDs[idx])
			 if appearanceID then
				if not items[itemID] then items[itemID] = {} end
				table.insert(items[itemID], { modIDs[idx], appearanceID, sourceID})
			 end
		  end
	   end
	end
	MCAppearanceHarvestData = items
	print('Appearance data has been collected. /reload or close your client and inspect SavedVariables for the collected data.')
end



--------------------
-- Event Handling --
--------------------
-- Events must be registered to a frame. Since we only want these to fire once, we'll create an invisible
-- dummy frame to intercept and handle collection events
local eventFrame = CreateFrame("FRAME", "MasterCollectorEventFrame", UIParent)
eventFrame.events = {}
eventFrame:RegisterEvent("VARIABLES_LOADED")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, ...)
	if eventFrame.events[event] then
		-- each event can have multiple handlers due to modules, so we want to fire each handler
		if type(eventFrame.events[event]) == 'table' then
			for k,v in pairs(eventFrame.events[event]) do v(...) end
		else
			eventFrame.events[event](...)
		end
	end
end)
eventFrame.events.VARIABLES_LOADED = function()
	print('MASTERCOLLECTOR VARIABLES_LOADED')
end
eventFrame.events.ADDON_LOADED = function(loadedAddonName)
	if loadedAddonName:find('^'..addonName..'%-') then
		print('MASTERCOLLECTOR: ' .. loadedAddonName)
	end
end
function MasterCollector:UnregisterEvent(event, func)
	if eventFrame.events[event] then
		if type(eventFrame.events[event]) == 'table' then
			for k,v in pairs(eventFrame.events[event]) do
				if v == func then
					eventFrame.events[event][k]=nil
					return
				end
			end
		else
			eventFrame.events[event]=nil
		end
	end
end
function MasterCollector:RegisterModule(ModuleName, mod)
	if MasterCollector.Modules[ModuleName] then
		print('Module "'..ModuleName..'" cannot be registered twice.')
		return
	end
	MasterCollector.Modules[ModuleName]={
		DB = mod.DB
	}
	if mod.events then
		for k,v in pairs(mod.events) do
			if not eventFrame.events[k] then
				eventFrame.events[k] = {}
				eventFrame:RegisterEvent(k)
			end
			table.insert(eventFrame.events[k], v)
		end
	end
	print(ModuleName .. ' registered successfully')
end
