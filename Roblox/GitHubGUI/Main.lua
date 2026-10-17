--!strict
-- GitHub-hosted GUI factory.
--
-- Contract:
--   return function(player: Player)
--       -- build/update only this player's GUI
--   end
--
-- This file is fetched by GitHubGuiLoader.server.lua and executed with
-- loadstring on the SERVER. Keep it trusted and keep it under your repo.
--
-- The default implementation is intentionally non-destructive: it creates
-- only a small status widget with a unique name and never deletes/replaces
-- existing GUI objects.

local function getPlayerGui(player: Player): PlayerGui
	return player:WaitForChild("PlayerGui") :: PlayerGui
end

return function(player: Player)
	local playerGui = getPlayerGui(player)

	local old = playerGui:FindFirstChild("RobuNexaGitHubHUD")
	if old then
		old:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RobuNexaGitHubHUD"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = false
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
end
