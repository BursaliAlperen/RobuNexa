-- RobuNexa / NAM - Sukuna accessory detector only.
-- No animations, VFX, Shrine, slash effects, or ability UI are created here.
-- The listed accessories must be equipped on the current character. Their visual
-- geometry may be placed far away from the character; this module only checks IDs.
local modules = {}

local function AddModule(fn)
    table.insert(modules, fn())
end

AddModule(function()
    local m = {}
    m.ModuleType = "MOVESET"
    m.Name = "Sukuna"
    m.Description = "Checks whether at least one configured Sukuna accessory is equipped."
    m.Assets = {}

    local REQUIRED_IDS = {
        [97087028126781] = "Sukuna accessory 1",
        [100475161263482] = "Sukuna accessory 2",
        [124144353587446] = "Sukuna accessory 3",
        [18726352770] = "Sukuna accessory 4",
    }

    local figure
    local lastSignature = nil

    local function notify(message)
        pcall(function()
            if Util and Util.Notify then
                Util.Notify("Sukuna: " .. message)
            end
        end)
    end

    local function collectEquippedIds(character)
        local found = {}
        if not character or not character:IsA("Model") then
            return found, "Character model unavailable"
        end

        -- Prefer the applied HumanoidDescription for catalog asset IDs.
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local okDescription, description = pcall(function()
                return humanoid:GetAppliedDescription()
            end)
            if okDescription and description then
                local okAccessories, accessories = pcall(function()
                    return description:GetAccessories(true)
                end)
                if okAccessories and type(accessories) == "table" then
                    for _, accessoryInfo in ipairs(accessories) do
                        local id = tonumber(accessoryInfo.AssetId)
                        if id then found[id] = true end
                    end
                end
                -- Also check classic accessory description fields, for compatibility.
                for _, propertyName in ipairs({
                    "HatAccessory", "HairAccessory", "FaceAccessory",
                    "NeckAccessory", "ShouldersAccessory", "FrontAccessory",
                    "BackAccessory", "WaistAccessory",
                }) do
                    local okValue, value = pcall(function()
                        return description[propertyName]
                    end)
                    if okValue and type(value) == "string" then
                        for token in string.gmatch(value, "%d+") do
                            local id = tonumber(token)
                            if id then found[id] = true end
                        end
                    end
                end
            end
        end

        -- Fallback: inspect actual accessory instances and their mesh/handle asset metadata.
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Accessory") then
                local idValue = child:GetAttribute("AssetId")
                local id = tonumber(idValue)
                if id then found[id] = true end
                local handle = child:FindFirstChild("Handle")
                if handle then
                    for _, descendant in ipairs(handle:GetDescendants()) do
                        local meshId = descendant:IsA("SpecialMesh") and descendant.MeshId
                            or (descendant:IsA("MeshPart") and descendant.MeshId)
                        if type(meshId) == "string" then
                            local digits = string.match(meshId, "(%d+)")
                            local meshAssetId = tonumber(digits)
                            if meshAssetId then found[meshAssetId] = true end
                        end
                    end
                end
            end
        end

        return found
    end

    local function checkAccessories(character)
        local found, err = collectEquippedIds(character)
        local matched = {}
        for id, label in pairs(REQUIRED_IDS) do
            if found[id] then
                table.insert(matched, tostring(id))
            end
        end
        table.sort(matched)
        return #matched, 4, matched, err
    end

    m.Config = function(parent) end

    m.Init = function(model)
        figure = model
        local count, total, matched, err = checkAccessories(figure)
        if err then
            lastSignature = "error:" .. err
            notify("Could not inspect accessories: " .. err)
            return
        end

        lastSignature = table.concat(matched, ",")
        if count > 0 then
            notify(string.format("Accessory check: %d/%d matched (%s).", count, total, table.concat(matched, ", ")))
        else
            notify("Accessory check: 0/4 matched. Equip at least one listed accessory.")
        end
    end

    m.Update = function(dt, model)
        figure = model or figure
        -- Poll slowly without creating any visual effects. Notify only when the result changes.
        if not figure then return end
        local count, total, matched, err = checkAccessories(figure)
        local signature = err and ("error:" .. err) or table.concat(matched, ",")
        if signature ~= lastSignature then
            lastSignature = signature
            if err then
                notify("Could not inspect accessories: " .. err)
            elseif count > 0 then
                notify(string.format("Accessory check: %d/%d matched (%s).", count, total, table.concat(matched, ", ")))
            else
                notify("Accessory check: 0/4 matched. Equip at least one listed accessory.")
            end
        end
    end

    m.Destroy = function()
        figure = nil
        lastSignature = nil
    end

    return m
end)

return modules
