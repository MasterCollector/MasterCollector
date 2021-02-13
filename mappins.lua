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

function MapPins:TryMapObject(obj)
	if not obj or not obj.coordinates then return end
	local coord
	for i=1, #obj.coordinates do
		coord = obj.coordinates[1]
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
	if not obj or not obj.coordinates then return end
	local coord
	for i=1, #obj.coordinates do
		coord = obj.coordinates[1]
		if coord.wp then
			MapPins:RemovePin(coord.wp)
			coord.wp = nil
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
	table.insert(pinFramePool, point)
end