-- RobuNexa Studio GitHub Sync Plugin
-- Syncs trusted GitHub Lua source into Roblox Studio.
--
-- This is a Studio-time importer, not a runtime executor.
-- It fetches the source with HttpService and writes Script.Source directly
-- inside StarterPlayerScripts.

local HttpService = game:GetService("HttpService")
local Selection = game:GetService("Selection")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local OWNER = "BursaliAlperen"
local REPO = "RobuNexa"
local REF = "rbxm-moveset-system"

local GUI_URL = string.format(
	"https://raw.githubusercontent.com/%s/%s/%s/Roblox/GitHubGUI/ClientMain.client.lua",
	OWNER,
	REPO,
	REF
)

local MOVES_URL = string.format(
	"https://raw.githubusercontent.com/%s/%s/%s/Roblox/Studio/CosmicMoveset.client.lua",
	OWNER,
	REPO,
	REF
)

local toolbar = plugin:CreateToolbar("RobuNexa GitHub")
local syncGuiButton = toolbar:CreateButton(
	"Sync GUI",
	"Fetch GitHub GUI Lua into StarterPlayerScripts",
	""
)
syncGuiButton.ClickableWhenViewportHidden = true

local syncMovesButton = toolbar:CreateButton(
	"Sync Moveset",
	"Fetch Cosmic client Lua into StarterPlayerScripts",
	""
)
syncMovesButton.ClickableWhenViewportHidden = true

local function getStarterScripts()
	local starterPlayer = game:GetService("StarterPlayer")
	local scripts = starterPlayer:FindFirstChildOfClass("StarterPlayerScripts")

	if not scripts then
		scripts = Instance.new("StarterPlayerScripts")
		scripts.Parent = starterPlayer
	end

	return scripts
end

local function writeLocalScript(name, source)
	local scripts = getStarterScripts()

	local target = scripts:FindFirstChild(name)
	if target and not target:IsA("LocalScript") then
		target:Destroy()
		target = nil
	end

	if not target then
		target = Instance.new("LocalScript")
		target.Name = name
		target.Parent = scripts
	end

	local ok, err = pcall(function()
		target.Source = source
	end)

	if not ok then
		warn("[RobuNexa] Could not write " .. name .. ": " .. tostring(err))
		return false
	end

	Selection:Set({target})
	ChangeHistoryService:SetWaypoint("RobuNexa GitHub Sync: " .. name)
	print("[RobuNexa] Synced " .. name .. " (" .. tostring(#source) .. " bytes)")
	return true
end

local function sync(url, targetName)
	local ok, source = pcall(function()
		return HttpService:GetAsync(url, false)
	end)

	if not ok then
		warn("[RobuNexa] GitHub sync failed: " .. tostring(source))
		return false
	end

	if type(source) ~= "string" or #source < 20 then
		warn("[RobuNexa] GitHub returned invalid/empty source for " .. targetName)
		return false
	end

	return writeLocalScript(targetName, source)
end

syncGuiButton.Click:Connect(function()
	sync(GUI_URL, "RobuNexaGitHubGUI")
end)

syncMovesButton.Click:Connect(function()
	sync(MOVES_URL, "CosmicMoveset")
end)

-- Sync the GUI automatically the first time the plugin is run.
sync(GUI_URL, "RobuNexaGitHubGUI")
