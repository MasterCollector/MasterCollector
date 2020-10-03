local MasterCollector = select(2,...)

--------------------
-- Event Handling --
--------------------
local eventFrame = CreateFrame("FRAME", "MasterCollectorEventFrame", UIParent)
eventFrame.events = {}
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
		eventFrame.events[k] = v
	end
end
function MasterCollector:FlagModAsLoaded(modName)
	if MasterCollector.Modules and MasterCollector.Modules[modName] then
		MasterCollector.Modules[modName].loaded = true
	end
	-- do a quick scan of registered modules. If we detect a
	for mod,modTable in pairs(MasterCollector.Modules) do
		if not modTable.loaded then return end
	end
	-- if all registered modules have finished loading, then we can finish the start-up process and open windows
	MasterCollector:Start()
end
