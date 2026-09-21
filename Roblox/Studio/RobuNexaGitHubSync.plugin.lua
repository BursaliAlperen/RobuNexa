-- RobuNexa Studio GitHub Sync Plugin
-- One-time install as a Studio Plugin. After that, use the toolbar button to sync
-- CosmicMoveset.client.lua directly into StarterPlayer/StarterPlayerScripts.
-- Roblox runtime LocalScripts cannot download and execute arbitrary Lua from GitHub.

local HttpService = game:GetService("HttpService")
local Selection = game:GetService("Selection")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local RAW_URL = "https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/Roblox/Studio/CosmicMoveset.client.lua"
local TARGET_NAME = "CosmicMoveset"

local toolbar = plugin:CreateToolbar("RobuNexa")
local button = toolbar:CreateButton("Sync Cosmic", "Sync CosmicMoveset from GitHub", "")
button.ClickableWhenViewportHidden = true

local function sync()
    local ok, source = pcall(function()
        return HttpService:GetAsync(RAW_URL, false)
    end)

    if not ok then
        warn("[RobuNexa] GitHub sync failed: " .. tostring(source))
        return false
    end

    if type(source) ~= "string" or #source < 100 then
        warn("[RobuNexa] GitHub returned invalid/empty source.")
        return false
    end

    local starterPlayer = game:GetService("StarterPlayer")
    local scripts = starterPlayer:FindFirstChild("StarterPlayerScripts")
    if not scripts then
        scripts = Instance.new("StarterPlayerScripts")
        scripts.Name = "StarterPlayerScripts"
        scripts.Parent = starterPlayer
    end

    local target = scripts:FindFirstChild(TARGET_NAME)
    if target and not target:IsA("LocalScript") then
        target:Destroy()
        target = nil
    end

    if not target then
        target = Instance.new("LocalScript")
        target.Name = TARGET_NAME
        target.Parent = scripts
    end

    local sourceOk, sourceErr = pcall(function()
        target.Source = source
    end)

    if not sourceOk then
        warn("[RobuNexa] Could not write Script.Source: " .. tostring(sourceErr))
        return false
    end

    Selection:Set({target})
    ChangeHistoryService:SetWaypoint("RobuNexa GitHub Sync")
    print("[RobuNexa] CosmicMoveset synced: " .. tostring(#source) .. " bytes")
    return true
end

button.Click:Connect(sync)

-- Sync immediately when the plugin is first run.
sync()
