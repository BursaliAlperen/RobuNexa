-- StarterPlayer/StarterPlayerScripts/Client.client.lua
-- For your own experience: the server validates the animation key and
-- starts the track so Roblox can replicate it to other clients.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("R6AnimationRequest")

local gui = Instance.new("ScreenGui")
gui.Name = "R6AnimationControls"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(240, 230)
panel.Position = UDim2.new(0, 18, 0.5, -115)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
panel.BorderSizePixel = 0
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -16, 0, 34)
title.Position = UDim2.fromOffset(8, 5)
title.BackgroundTransparency = 1
title.Text = "R6 ANIMATIONS"
title.TextColor3 = Color3.fromRGB(135, 195, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.Parent = panel

local function addButton(label, animationKey, y)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -20, 0, 32)
	button.Position = UDim2.fromOffset(10, y)
	button.BackgroundColor3 = Color3.fromRGB(43, 43, 56)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.GothamMedium
	button.TextSize = 12
	button.Text = label
	button.AutoButtonColor = true
	button.Parent = panel
	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)
	button.Activated:Connect(function()
		remote:FireServer("Play", animationKey)
	end)
end

addButton("Gojo Awakening", "GojoAwakening", 44)
addButton("Maximum Hollow Purple", "MaximumHollowPurple", 82)
addButton("Sukuna Awakening", "SukunaAwakening", 120)
addButton("Cid Overdrive", "CidOverdrive", 158)

local stop = Instance.new("TextButton")
stop.Size = UDim2.new(1, -20, 0, 28)
stop.Position = UDim2.fromOffset(10, 196)
stop.BackgroundColor3 = Color3.fromRGB(90, 40, 45)
stop.TextColor3 = Color3.new(1, 1, 1)
stop.Font = Enum.Font.GothamMedium
stop.TextSize = 12
stop.Text = "Stop Animation"
stop.Parent = panel
Instance.new("UICorner", stop).CornerRadius = UDim.new(0, 7)
stop.Activated:Connect(function()
	remote:FireServer("Stop")
end)
