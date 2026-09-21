-- RobuNexa / Cosmic GitHub bootstrap
-- IMPORTANT: Roblox LocalScripts cannot execute arbitrary Lua downloaded from GitHub.
-- This bootstrap intentionally does NOT use loadstring/executor APIs.
-- It only verifies that the GitHub source is reachable.
-- For true automatic syncing, use a Studio plugin or publish the code as a Roblox asset/package.

local HttpService = game:GetService("HttpService")

local RAW_URL = "https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/Roblox/Studio/CosmicMoveset.client.lua"

local ok, result = pcall(function()
    return HttpService:GetAsync(RAW_URL, false)
end)

if ok then
    print("[RobuNexa] GitHub source reachable. " .. tostring(#result) .. " bytes.")
    print("[RobuNexa] Automatic execution of downloaded Lua is blocked by Roblox security.")
else
    warn("[RobuNexa] GitHub fetch failed: " .. tostring(result))
end
