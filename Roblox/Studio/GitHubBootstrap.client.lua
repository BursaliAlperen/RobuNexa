--!strict
-- StarterPlayerScripts client bootstrap.
--
-- This script deliberately does NOT fetch or execute arbitrary GitHub Lua.
-- The server owns the HTTP/loadstring step and creates the GUI for each player.
-- Keeping this file client-side preserves the requested StarterPlayerScripts
-- integration point without relying on executor-only game:HttpGet/loadstring APIs.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local REMOTE_NAME = "RobuNexaGitHubGuiReady"

local remote = ReplicatedStorage:WaitForChild(REMOTE_NAME, 30)
if not remote or not remote:IsA("RemoteEvent") then
	warn("[RobuNexa] GitHub GUI bridge RemoteEvent was not created.")
	return
end

remote.OnClientEvent:Connect(function()
	-- Reserved for future client-only GUI hooks.
	-- The actual GUI factory is executed server-side and its ScreenGui
	-- replicates to this player's PlayerGui.
end)

print("[RobuNexa] StarterPlayerScripts GitHub GUI bridge ready.")
