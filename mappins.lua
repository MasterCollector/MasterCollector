local MasterCollector = select(2,...)
local hbdp = LibStub("HereBeDragons-Pins-2.0")

local MapPins = {}
MapPins.__index = MapPins
MasterCollector.MapPins = MapPins

local pinFramePool = {}
local minimapParent = Minimap
local worldMapOverlay

do
	worldMapOverlay = CreateFrame("FRAME", "MCOverlay", WorldMapFrame.BorderFrame)
	worldMapOverlay:SetFrameStrata("HIGH")
	worldMapOverlay:SetFrameLevel(100)
	worldMapOverlay:SetAllPoints(true)
end
local function GetCoordsOnObject(obj)
	if not obj then return end
	if obj.coordinates then return obj.coordinates end
	if obj.providers then
		local coords = {}
		for i=1, #obj.providers do
			local providerType, id = unpack(obj.providers[i])
			local provider
			if providerType == "n" then
				provider = MasterCollector.DB:GetObjectData("npc", id)
			elseif providerType == "i" then
				provider = MasterCollector.DB:GetObjectData("item", id)
			elseif providerType == "o" then
				provider = MasterCollector.DB:GetObjectData("object", id)
			end
		  
			if provider then
				if(type(provider.coordinates[1]) == 'table') then
					for i=1, #provider.coordinates do
						table.insert(coords, provider.coordinates[i])
					end
				else
					table.insert(coords, provider.coordinates)
				end
			end
			i = i+1
		end
		return coords
	end
end
function MapPins:TryMapObject(obj)
	local coords = GetCoordsOnObject(obj)
	if not coords then return end
	if type(coords[1]) ~= 'table' then
		coords = {coords}
	end
	for i=1, #coords do
		coord = coords[1]
		if not coord.wp then
		-- try to get a frame from the pool first before creating new ones
			local point = table.remove(pinFramePool)
			
			if not point then
				point = {}
				local mm = CreateFrame("BUTTON", nil, minimapParent)
				mm:SetSize(16,16)
				mm.icon = mm:CreateTexture(nil, "OVERLAY")
				mm.icon:SetPoint("CENTER", 0, 0)
				mm.icon:SetBlendMode("BLEND")
				point.mm = mm
				
				local wm = CreateFrame("BUTTON", nil, worldMapOverlay)
				wm:SetSize(16, 16)
				wm.icon = wm:CreateTexture(nil, "OVERLAY")
				wm.icon:SetAllPoints()
				wm.icon:SetBlendMode("BLEND")
				point.wm = wm
			end
			
			point.x = coord[1] / 100.00
			point.y = coord[2] / 100.00
			point.mapID = coord[3]
			coord.wp = point
			
			if obj.icon then
				point.mm.icon:SetTexture(obj.icon)
				point.wm.icon:SetTexture(obj.icon)
			else 
				point.mm.icon:SetTexture("Interface\\minimap\\objecticons")
				point.mm.icon:SetTexCoord(0.875, 1, 0, 0.125)
				point.wm.icon:SetTexture("Interface\\minimap\\objecticons")
				point.wm.icon:SetTexCoord(0.875, 1, 0, 0.125)
			end
			self:SetPin(point)
		end
	end
end
function MapPins:TryRemoveObjectPins(obj)
	local coords = GetCoordsOnObject(obj)
	if not coords then return end
	if type(coords[1]) ~= 'table' then
		coords = {coords}
	end
	for i=1, #coords do
		if coords[i].wp then
			MapPins:RemovePin(coords[i].wp)
			coords[i].wp = nil
		end
	end
end

function MapPins:SetPin(point)
	if not type(point) == "table" then return end
	hbdp:AddMinimapIconMap(self, point.mm, point.mapID, point.x, point.y, true, true)
	hbdp:AddWorldMapIconMap(self, point.wm, point.mapID, point.x, point.y)
end
function MapPins:RemovePin(point)
	hbdp:RemoveMinimapIcon(self, point.mm)
	hbdp:RemoveWorldMapIcon(self, point.wm)
	table.insert(pinFramePool, point)
end