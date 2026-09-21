--!strict
-- RobuNexa GitHub GUI runtime bridge.
--
-- Roblox does NOT allow a StarterPlayerScripts LocalScript to call loadstring.
-- loadstring is server-only, so this Script is the trusted bridge:
--   GitHub raw Lua -> HttpService -> loadstring -> GUI factory(player)
--
-- Keep this URL pinned to a branch only while developing. For production,
-- replace GitHubRef with an immutable commit SHA.
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GITHUB_OWNER = "BursaliAlperen"
local GITHUB_REPO = "RobuNexa"
local GITHUB_REF = "rbxm-moveset-system"
local GUI_PATH = "Roblox/GitHubGUI/Main.lua"

local REMOTE_NAME = "RobuNexaGitHubGuiReady"

local function rawUrl(): string
	return string.format(
		"https://raw.githubusercontent.com/%s/%s/%s/%s",
		GITHUB_OWNER,
		GITHUB_REPO,
		GITHUB_REF,
		GUI_PATH
	)
end

local function getRemote(): RemoteEvent
	local existing = ReplicatedStorage:FindFirstChild(REMOTE_NAME)
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end

	local remote = Instance.new("RemoteEvent")
	remote.Name = REMOTE_NAME
	remote.Parent = ReplicatedStorage
	return remote
end

local function loadGuiFactory(): ((Player) -> ())?
	local okFetch, sourceOrError = pcall(function()
		return HttpService:GetAsync(rawUrl(), false)
	end)

	if not okFetch then
		warn("[RobuNexa] GitHub GUI fetch failed: " .. tostring(sourceOrError))
		return nil
	end

	local source = sourceOrError :: string
	if #source == 0 then
		warn("[RobuNexa] GitHub GUI source is empty.")
		return nil
	end

	local loadString = loadstring
	if loadString == nil then
		warn("[RobuNexa] loadstring is disabled. Enable ServerScriptService.LoadStringEnabled.")
		return nil
	end

	local chunk, compileError = loadString(source, "@RobuNexaGitHubGUI")
	if not chunk then
		warn("[RobuNexa] GitHub GUI compile failed: " .. tostring(compileError))
		return nil
	end

	local okFactory, factoryOrError = pcall(chunk)
	if not okFactory then
		warn("[RobuNexa] GitHub GUI module execution failed: " .. tostring(factoryOrError))
		return nil
	end

	if type(factoryOrError) ~= "function" then
		warn("[RobuNexa] GitHub GUI must return function(player).")
		return nil
	end

	return factoryOrError :: (Player) -> ()
end

local function installForPlayer(player: Player, factory: (Player) -> ())
	local ok, err = pcall(factory, player)
	if not ok then
		warn(string.format("[RobuNexa] GitHub GUI install failed for %s: %s", player.Name, tostring(err)))
		return
	end

	print("[RobuNexa] GitHub GUI installed for " .. player.Name)
end

local function bootstrap()
	getRemote()

	local factory = loadGuiFactory()
	if not factory then
		return
	end

	Players.PlayerAdded:Connect(function(player)
		task.defer(installForPlayer, player, factory)
	end)

	for _, player in Players:GetPlayers() do
		task.defer(installForPlayer, player, factory)
	end
end

bootstrap()
