-- RobuNexa / Yhwach preparation
-- Checks whether the local avatar's HumanoidDescription contains the required catalog accessories.
-- This module does not equip items, play animations, or modify the character.
local AccessoryCheck = {}

AccessoryCheck.Required = {
    [133316266380557] = "Yhwach Sankt Bagen Quincy Sword [Waist]",
    [136927833912492] = "Catalog accessory (verify item name)",
    [77682019335863] = "Star Glitcher: PURITY (GLOWING)",
}

function AccessoryCheck.Check(character)
    local result = {
        ready = false,
        equipped = {},
        missing = {},
        error = nil,
    }

    if not character or not character:IsA("Model") then
        result.error = "Character model is unavailable"
        return result
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        result.error = "Humanoid is unavailable"
        return result
    end

    local ok, description = pcall(function()
        return humanoid:GetAppliedDescription()
    end)
    if not ok or not description then
        result.error = "Could not read the applied HumanoidDescription"
        return result
    end

    local found = {}
    local okAccessories, accessories = pcall(function()
        return description:GetAccessories(true)
    end)
    if okAccessories and type(accessories) == "table" then
        for _, item in ipairs(accessories) do
            local assetId = tonumber(item.AssetId)
            if assetId then
                found[assetId] = true
            end
        end
    end

    for assetId, name in pairs(AccessoryCheck.Required) do
        local entry = { assetId = assetId, name = name, equipped = found[assetId] == true }
        if entry.equipped then
            table.insert(result.equipped, entry)
        else
            table.insert(result.missing, entry)
        end
    end

    result.ready = #result.missing == 0
    return result
end

return AccessoryCheck
