--!strict
-- GitHub-hosted client GUI.
-- This file is synced into StarterPlayerScripts by the RobuNexa Studio plugin.
-- It is intentionally self-contained so the game does not need runtime HTTP.

local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("RobuNexaGitHubHUD")
if old then
	old:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RobuNexaGitHubHUD"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 100
screenGui.Parent = playerGui

local label = Instance.new("TextLabel")
label.Name = "Status"
label.AnchorPoint = Vector2.new(1, 0)
label.Position = UDim2.new(1, -18, 0, 18)
label.Size = UDim2.fromOffset(250, 36)
label.BackgroundTransparency = 0.2
label.Text = "RobuNexa • GitHub GUI online"
label.TextSize = 14
label.Font = Enum.Font.GothamMedium
label.TextColor3 = Color3.new(1, 1, 1)
label.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = label
