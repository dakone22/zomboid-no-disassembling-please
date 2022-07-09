local NoDisassemblingPlease = require("NoDisassemblingPlease/NoDisassemblingPlease_Auth")

local ISWorldMenuElements_ContextDisassemble = ISWorldMenuElements.ContextDisassemble

ISWorldMenuElements.ContextDisassemble = function()

	local instance = ISWorldMenuElements_ContextDisassemble()
	ISWorldMenuElements_disassemble = instance.disassemble

	instance.disassemble = function(data, v)

		if not SandboxVars.NoDisassemblingPlease.NoDisassembling then
			return ISWorldMenuElements_disassemble(data, v)
		end

		local square = data.player:getSquare()

		local safehouse = SafeHouse.getSafeHouse(square)
		local safehouseMember = false

		if safehouse then
			local access = NoDisassemblingPlease.getSafehouseAccessLevel(data.player, safehouse)
			safehouseMember = access ~= "None"
		end

		if safehouseMember then
			return ISWorldMenuElements_disassemble(data, v)
		end

		data.player:setHaloNote(getText("IGUI_NoDisassemblingAllowed"))
	end

	return instance
end
