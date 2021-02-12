local MasterCollector = select(2,...)
local hbdp = LibStub("HereBeDragons-Pins-2.0")

local MapPins = {}
MapPins.__index = MapPins
MasterCollector.MapPins = MapPins

local pinFramePool = {}
local minimapParent = Minimap

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
				mm:SetHeight(16)
				mm:SetWidth(16)
				mm.icon = mm:CreateTexture(nil, "OVERLAY")
				mm.icon:SetPoint("CENTER", 0, 0)
				mm.icon:SetBlendMode("BLEND")
				point.mm = mm
			end
			
			point.x = coord[1] / 100.00
			point.y = coord[2] / 100.00
			point.mapID = coord[3]
			coord.wp = point
			
			if obj.icon then
				point.mm.icon:SetTexture(obj.icon)
			else 
				point.mm.icon:SetTexture("Interface\\minimap\\objecticons")
				point.mm.icon:SetTexCoord(0.875, 1, 0, 0.125)
			end
			point.mm.icon:SetHeight(16)
			point.mm.icon:SetWidth(16)
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
end
function MapPins:RemovePin(point)
	hbdp:RemoveMinimapIcon(self, point.mm)
	table.insert(pinFramePool, point)
end