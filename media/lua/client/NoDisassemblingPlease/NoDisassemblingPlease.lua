local NoDisassemblingPlease = require("NoDisassemblingPlease/NoDisassemblingPlease_Auth")

local ISWorldMenuElements_ContextDisassemble = ISWorldMenuElements.ContextDisassemble

ISWorldMenuElements.ContextDisassemble = function()

	local instance = ISWorldMenuElements_ContextDisassemble()
	ISWorldMenuElements_disassemble = instance.disassemble

	instance.disassemble = function(data, v)
		if (not data.player:getModData()["voc:trust"]) or data.player:getModData()["voc:trust"] == 0 then
			data.player:setHaloNote(getText("IGUI_NoDisassemblingAllowed"))
		else 
			local trust = data.player:getModData()["voc:trust"]			
			local square = data.player:getSquare()

			local safehouse = SafeHouse.getSafeHouse(square)			
			local safehouseMember = false

			if safehouse then
				local access = NoDisassemblingPlease.getSafehouseAccessLevel(data.player, safehouse)						
				safehouseMember = access ~= "None"
			end

			if (safehouse and safehouseMember and trust == 1) or trust >= 2 then
				return ISWorldMenuElements_disassemble(data, v)
			else
				data.player:setHaloNote(getText("IGUI_NoDisassemblingAllowed"))
			end
		end		
	end

	return instance
end
