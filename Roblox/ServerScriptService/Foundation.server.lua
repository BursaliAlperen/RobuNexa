--!strict
-- RobuNexa Foundation Bootstrap
-- Stage 1: validates the runtime tree before gameplay starts.
-- This script is intentionally small and server-side.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")

local function requireFolder(parent: Instance, name: string): Folder
\tlocal object = parent:FindFirstChild(name)
\tif not object or not object:IsA("Folder") then
\t\terror(("[Foundation] Missing Folder %s/%s"):format(parent:GetFullName(), name))
\tend
\treturn object
end

local function requireModule(parent: Instance, name: string): ModuleScript
\tlocal object = parent:FindFirstChild(name)
\tif not object or not object:IsA("ModuleScript") then
\t\terror(("[Foundation] Missing ModuleScript %s/%s"):format(parent:GetFullName(), name))
\tend
\treturn object
end

local modules = requireFolder(ReplicatedStorage, "Modules")
local miniGames = requireFolder(ReplicatedStorage, "MiniGames")
local serverModules = requireFolder(ServerScriptService, "ServerModules")

for _, moduleName in ipairs({"GameConfig","Remotes","UITheme","Anim","FxKit","AudioKit"}) do
\trequireModule(modules, moduleName)
end

for _, gameId in ipairs({"DodgeRun","TargetRush","StackTower","CoinRush","JumpChallenge","ReactionTest","ColorRush","MemoryMatch","FallingPlatforms","FloorIsLava"}) do
\trequireModule(miniGames, gameId)
end

for _, moduleName in ipairs({"DataService","GameService","LeaderboardService","LightingService","WorldBuilder"}) do
\trequireModule(serverModules, moduleName)
end

local playerScripts = StarterPlayer:FindFirstChild("StarterPlayerScripts")
if not playerScripts or not playerScripts:IsA("StarterPlayerScripts") then
\terror("[Foundation] Missing StarterPlayerScripts")
end

local client = playerScripts:FindFirstChild("MainClient")
if not client or not client:IsA("LocalScript") then
\twarn("[Foundation] StarterPlayerScripts/MainClient is not present as a LocalScript yet.")
end

local scoreHud = playerScripts:FindFirstChild("ScoreHUD")
if not scoreHud or not scoreHud:IsA("LocalScript") then
\twarn("[Foundation] StarterPlayerScripts/ScoreHUD is not present as a LocalScript yet.")
end

print("[RobuNexa][Stage 1] Foundation validated: modules, 10 mini-games, server services and client entry points.")