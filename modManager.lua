MasterCollector = select(2,...)	-- Intentionally made non-local

--------------------
-- Event Handling --
--------------------
local eventFrame = CreateFrame("FRAME", "MasterCollectorEventFrame", UIParent)
eventFrame.events = {}
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
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
eventFrame.events.PLAYER_ENTERING_WORLD = function()
	MasterCollector.playerData = {
		class = select(3, UnitClass("player")),
		race = select(3, UnitRace("player")),
	}
	-- set a faction identifier. We translate blizzard's english code value to a number to compare against faction-level race restrictions
	local factionCode = select(1, UnitFactionGroup("player"))
	if factionCode == 'Horde' then
		MasterCollector.playerData.faction = -2
	elseif factionCode == 'Alliance' then
		MasterCollector.playerData.faction = -1
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

local function LoadPanel(mod, tbl)
	local workingItem
	for _,data in pairs(tbl) do
		-- initialize the datatype table if it doesn't exist
		if not mod.DB[data[1]] then mod.DB[data[1]] = {} end
		 -- iterate each item in the panel
		for _, item in pairs(data[2]) do
			-- if the item we're looking at is a table, then we need to go into it to retrieve the appropriate IDs
			if type(item) == 'table' then
				LoadPanel(mod, item)
			else
				workingItem = mod.DB[data[1]][item] or {}
				workingItem.id = item
				-- if the item hasn't been initialized with a metatable for behavior, do so now
				if not getmetatable(workingItem) then
					mod.DB[data[1]][item] = setmetatable(workingItem, MasterCollector.structs[data[1]])
				end
			end
		end
	end
end
function MasterCollector:InitializeDatabases(mod)
	for mapID,data in pairs(mod.mapData) do
		LoadPanel(mod, data)
	end
end
