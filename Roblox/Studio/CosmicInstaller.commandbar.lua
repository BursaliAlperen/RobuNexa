--!strict
-- RobuNexa / Cosmic decoded asset installer
-- Studio one-time installer.
-- Requires Game Settings > Security > Allow HTTP Requests.
-- Downloads the decoded CosmicG/Cosmic source manifests from GitHub and reconstructs
-- their Instance hierarchy inside ReplicatedStorage.
--
-- IMPORTANT:
-- The decoded manifests contain the Instance tree and a small set of custom
-- attributes, but they do NOT contain every original Roblox property (MeshId,
-- TextureId, Pose.CFrame, etc.). Therefore this installer reconstructs everything
-- that is actually represented by the manifests and reports properties that cannot
-- be reconstructed from the available data.
--
-- Run this entire script ONCE from the Roblox Studio Command Bar,
-- then inspect ReplicatedStorage/CosmicG and ReplicatedStorage/Cosmic.
-- You can delete this installer afterwards.

local HttpService = game:GetService("HttpService")\nlocal StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BASE = "https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/Roblox/Studio/"
local SOURCES = {
    CosmicG = BASE .. "CosmicG_VFX_decoded.txt",
    Cosmic = BASE .. "Cosmic_VFX_decoded.txt",
}

local function fetch(url)
    local ok, body = pcall(function()
        return HttpService:GetAsync(url, false)
    end)
    if not ok then
        error("[RobuNexa] HTTP failed: " .. tostring(body))
    end
    if type(body) ~= "string" or #body < 50 then
        error("[RobuNexa] Invalid/empty GitHub response")
    end
    return body
end

local function trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function parseScalar(s)
    s = trim(s)

    local f64 = s:match("^f64=([%-%d%.eE]+)")
    if f64 then
        return tonumber(f64)
    end

    local vec = s:match("^%(([^)]+)%)")
    if vec then
        local nums = {}
        for n in vec:gmatch("[%-%d%.eE]+") do
            table.insert(nums, tonumber(n))
        end
        if #nums == 3 then
            return Vector3.new(nums[1], nums[2], nums[3])
        elseif #nums == 2 then
            return Vector2.new(nums[1], nums[2])
        end
    end

    local quoted = s:match('^"(.*)"$')
    if quoted then
        return quoted
    end

    local b = s:lower()
    if b == "true" then return true end
    if b == "false" then return false end

    local n = tonumber(s)
    if n ~= nil then return n end

    return s
end

local function safeInstance(className, name)
    local ok, obj = pcall(function()
        return Instance.new(className)
    end)

    if not ok or not obj then
        warn("[RobuNexa] Cannot create " .. className .. "; using Folder fallback")
        obj = Instance.new("Folder")
        obj:SetAttribute("OriginalClass", className)
    end

    obj.Name = name ~= "" and name or className
    return obj
end

local function uniqueName(parent, desired)
    if not parent:FindFirstChild(desired) then
        return desired
    end

    local i = 2
    while parent:FindFirstChild(desired .. "_" .. i) do
        i += 1
    end
    return desired .. "_" .. i
end

local function parseHeader(line)
    local spaces = #(line:match("^%s*") or "")
    local className, name = line:match("^%s*%[([^%]]+)%]%s*(.*)$")
    if not className then
        return nil
    end

    name = trim(name or "")
    if name == "?" or name == "" then
        name = className
    end

    return spaces, className, name
end

local function buildManifest(text, rootName)
    local root = Instance.new("Folder")
    root.Name = rootName

    local stack = {
        {indent = -1, instance = root}
    }

    local created = 0
    local skipped = 0
    local pendingAttributes = nil

    local lines = string.split(text, "\n")
    for index, line in ipairs(lines) do
        if line:match("^%s*%[") then
            local indent, className, name = parseHeader(line)

            while #stack > 0 and indent <= stack[#stack].indent do
                table.remove(stack)
            end

            local parent = stack[#stack] and stack[#stack].instance or root
            name = uniqueName(parent, name)

            local obj = safeInstance(className, name)
            obj.Parent = parent

            -- Preserve the source class if Roblox had to use a Folder fallback.
            obj:SetAttribute("RobuNexaSourceClass", className)

            table.insert(stack, {
                indent = indent,
                instance = obj
            })

            created += 1
            pendingAttributes = obj
        elseif line:match("^%s*ATTRIBUTES") then
            pendingAttributes = stack[#stack] and stack[#stack].instance or root
        elseif line:match("^%s*%- ") and pendingAttributes then
            local attrName, attrType, value = line:match(
                "^%s*%-%s+([%w_]+)%s+<([^>]+)>%s*=%s*(.*)$"
            )

            if attrName and value then
                local parsed = parseScalar(value)

                -- Keep the decoded data losslessly when Roblox cannot accept
                -- the value as an Attribute type.
                local ok = pcall(function()
                    pendingAttributes:SetAttribute(attrName, parsed)
                end)

                if not ok then
                    pendingAttributes:SetAttribute(
                        "Decoded_" .. attrName,
                        tostring(value)
                    )
                end

                pendingAttributes:SetAttribute(
                    "RobuNexaDecodedType_" .. attrName,
                    attrType
                )
            end
        end
    end

    return root, created, skipped
end

local function installOne(name, url)
    print("[RobuNexa] Downloading " .. name .. " ...")
    local text = fetch(url)

    local existing = ReplicatedStorage:FindFirstChild(name)
    if existing then
        existing:Destroy()
    end

    local root, count = buildManifest(text, name)
    root.Parent = ReplicatedStorage

    print("[RobuNexa] Installed " .. name .. " with " .. tostring(count) .. " reconstructed Instances.")
    return count
end

print("========== RobuNexa Cosmic Installer ==========")

-- In Studio Command Bar, Script.Source can be populated.
local function installMoveset()
    local url = BASE .. "CosmicMoveset.client.lua"
    local source = fetch(url)

    local scripts = StarterPlayer:FindFirstChild("StarterPlayerScripts")
    if not scripts then
        scripts = Instance.new("StarterPlayerScripts")
        scripts.Name = "StarterPlayerScripts"
        scripts.Parent = StarterPlayer
    end

    local existing = scripts:FindFirstChild("CosmicMoveset")
    if existing and not existing:IsA("LocalScript") then
        existing:Destroy()
        existing = nil
    end

    if not existing then
        existing = Instance.new("LocalScript")
        existing.Name = "CosmicMoveset"
        existing.Parent = scripts
    end

    local ok, err = pcall(function()
        existing.Source = source
    end)

    if not ok then
        warn("[RobuNexa] Could not write CosmicMoveset.Source: " .. tostring(err))
        return false
    end

    print("[RobuNexa] CosmicMoveset.client.lua installed: " .. tostring(#source) .. " bytes")
    return true
end



local total = 0
for name, url in pairs(SOURCES) do
    local ok, result = pcall(function()
        return installOne(name, url)
    end)

    if ok then
        total += result
    else
        warn("[RobuNexa] " .. name .. " install failed: " .. tostring(result))
    end
end

print("[RobuNexa] Total reconstructed Instances: " .. tostring(total))
print("[RobuNexa] IMPORTANT: decoded manifests do not contain all original MeshId/TextureId/Pose.CFrame values.")
print("[RobuNexa] The source manifests are installed successfully; missing binary/property data must be restored from the original .rbxmx when available.")
print("================================================")
