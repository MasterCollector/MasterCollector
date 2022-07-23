local addonName = select(1, ...)
MasterCollector = select(2, ...)	-- Intentionally made non-local

--------------------
-- Event Handling --
--------------------
local eventFrame = CreateFrame("FRAME", "MasterCollectorEventFrame", UIParent)
eventFrame.events = {}
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
eventFrame.events.ADDON_LOADED = function(loadedAddonName)
	if loadedAddonName == addonName then
		MasterCollector.playerData.class = select(3, UnitClass("player"))
		MasterCollector.playerData.race = select(3, UnitRace("player"))
		MasterCollector.playerData.level = UnitLevel("player")
		MasterCollector.playerData.covenant = C_Covenants.GetActiveCovenantID()
		MasterCollector.playerData.renown = C_CovenantSanctumUI.GetRenownLevel()
		-- set a faction identifier. We translate blizzard's english code value to a number to compare against faction-level race restrictions
		local factionCode = select(1, UnitFactionGroup("player"))
		if factionCode == 'Horde' then
			MasterCollector.playerData.faction = -2
		elseif factionCode == 'Alliance' then
			MasterCollector.playerData.faction = -1
		end
		MasterCollector:Start()
		-- we don't need to listen to this event anymore. Free up the memory of this function and unregister it from the frame listener
		eventFrame.events.ADDON_LOADED = nil
		eventFrame:UnregisterEvent('ADDON_LOADED')
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
function MasterCollector:RegisterModuleEvents(events)
	for k,v in pairs(events or {}) do
		if not eventFrame.events[k] then
			eventFrame.events[k] = {}
			eventFrame:RegisterEvent(k)
		end
		table.insert(eventFrame.events[k],v)
	end
end
function MasterCollector:FlagModAsLoaded(modName)
	if MasterCollector.Modules and MasterCollector.Modules[modName] then
		MasterCollector.Modules[modName].loaded = true
	end
end