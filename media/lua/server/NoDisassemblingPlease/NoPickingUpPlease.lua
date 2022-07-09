local NoDisassemblingPlease = require("NoDisassemblingPlease/NoDisassemblingPlease_Auth")

local NoPickingUpPlease = {}

NoPickingUpPlease.exceptions = {
    'barbecue',
    'bin',
    'cashregister',
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

        if SandboxVars.NoDisassemblingPlease.NoDisassembling then
            if ISMoveableCursor.mode[self.player] == "scrap" then
                if safehouseArea and safehouseMember then
                    return NoPickingUpPlease.ISMoveableCursor_isValid(self, square)
                end
                return false
            end
        end

        if SandboxVars.NoDisassemblingPlease.NoPickingUp then

            local objects = self.objectListCache or self:getObjectList()
            local object = objects[self.objectIndex]
            if object and object.object and object.object.getSprite then
                object = object.object
                local props = object:getSprite():getProperties()
                if props:Is(IsoFlagType.container) then
                    local containerType = object:getContainer():getType()
                    if NoPickingUpPlease.whitelist[containerType] or  -- allow whitelist
							props:Is(IsoFlagType.attachedSurface) or  -- allow ???
							(safehouseArea and safehouseMember) then  -- allow in safehouse
                        return NoPickingUpPlease.ISMoveableCursor_isValid(self, square)
                    end
                    return false
                end
            end
        end

        return NoPickingUpPlease.ISMoveableCursor_isValid(self, square)
    end
end
