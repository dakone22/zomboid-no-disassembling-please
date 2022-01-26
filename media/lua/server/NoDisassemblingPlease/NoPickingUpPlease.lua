local NoDisassemblingPlease = require("NoDisassemblingPlease/NoDisassemblingPlease_Auth")

local NoPickingUpPlease = {}

NoPickingUpPlease.exceptions = {
	'barbecue',
	'fireplace',
	'freezer',
	'fridge',
	'microwave',
	'stove',
	'woodstove',
}

NoPickingUpPlease.whitelist = {}

for i, v in pairs(NoPickingUpPlease.exceptions) do
	NoPickingUpPlease.whitelist[v] = true
end

NoPickingUpPlease.ISMoveableCursor_isValid = ISMoveableCursor.isValid
function ISMoveableCursor:isValid(square)
	if isClient() then 
		local trust = 0
		local player = getPlayer()
		
		if player:getModData()["voc:trust"] then
			trust = player:getModData()["voc:trust"]
		else
			return false
		end
		
		local safehouse = SafeHouse.getSafeHouse(square)
		local safehouseArea = false
		local safehouseMember = false

		if safehouse then
			local access = NoDisassemblingPlease.getSafehouseAccessLevel(player, safehouse)		

			safehouseArea = true
			safehouseMember = access ~= "None"
		end

		if ISMoveableCursor.mode[self.player] == "scrap" then		
			if trust == 1 then
				return NoPickingUpPlease.ISMoveableCursor_isValid(self, square) and safehouseArea and safehouseMember
			else 
				return NoPickingUpPlease.ISMoveableCursor_isValid(self, square)
			end			
		end
		if trust <= 1 then
			local objects = square:getObjects()	
			for i = 0, objects:size() - 1 do

				local object = objects:get(i);
				local sprite = object:getSprite()
				local props = sprite:getProperties()

				if props:Is(IsoFlagType.container) then
					if trust == 0 then
						return false
					else
						local containerType = object:getContainer():getType()
						if not NoPickingUpPlease.whitelist[containerType] and ((not safehouseArea) and (not safehouseMember)) then
							return false
						end
					end
				end
			end	
		end
		return NoPickingUpPlease.ISMoveableCursor_isValid(self, square)
	else 
		return NoPickingUpPlease.ISMoveableCursor_isValid(self, square) and SafeHouse.getSafeHouse(square)
	end
end
