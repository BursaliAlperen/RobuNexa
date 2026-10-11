-- RealFlingClient.client.lua
-- Place in StarterPlayer > StarterPlayerScripts in YOUR OWN Roblox experience.
-- The server validates owner/admin permission, target, range, power and cooldown.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("RealFlingRequest", 15)
if not remote then
    warn("[RealFling] Server script not found. Add RealFlingServer.server.lua to ServerScriptService.")
    return
end

local gui = Instance.new("ScreenGui")
gui.Name = "RealFlingGui"
gui.ResetOnSpawn = false
gui.DisplayOrder = 30
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(260, 218)
panel.Position = UDim2.new(1, -276, 0.5, -109)
panel.BackgroundColor3 = Color3.fromRGB(24, 27, 35)
panel.BorderSizePixel = 0
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(76, 126, 220)
stroke.Thickness = 1.2
stroke.Parent = panel

local function makeLabel(text, position, size)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = position
    label.Size = size
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.TextColor3 = Color3.fromRGB(235, 239, 248)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text
    label.Parent = panel
    return label
end

local function makeBox(name, placeholder, position, size, value)
    local box = Instance.new("TextBox")
    box.Name = name
    box.Position = position
    box.Size = size
    box.BackgroundColor3 = Color3.fromRGB(39, 44, 56)
    box.BorderSizePixel = 0
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderColor3 = Color3.fromRGB(160, 168, 184)
    box.PlaceholderText = placeholder
    box.Text = value or ""
    box.ClearTextOnFocus = false
    box.Parent = panel
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    return box
end

local title = makeLabel("REAL FLING  /  SERVER", UDim2.fromOffset(12, 8), UDim2.new(1, -24, 0, 24))
title.TextSize = 15

local targetBox = makeBox("TargetName", "Target player username", UDim2.fromOffset(12, 39), UDim2.new(1, -24, 0, 32))
local powerBox = makeBox("Power", "Power 20–120", UDim2.fromOffset(12, 80), UDim2.fromOffset(112, 31), "60")

local mode = "Hybrid"
local modeButton = Instance.new("TextButton")
modeButton.Name = "ModeButton"
modeButton.Position = UDim2.fromOffset(132, 80)
modeButton.Size = UDim2.new(1, -144, 0, 31)
modeButton.BackgroundColor3 = Color3.fromRGB(47, 58, 79)
modeButton.BorderSizePixel = 0
modeButton.Font = Enum.Font.GothamSemibold
modeButton.TextSize = 12
modeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
modeButton.Text = "Mode: Hybrid"
modeButton.Parent = panel
Instance.new("UICorner", modeButton).CornerRadius = UDim.new(0, 6)

local modes = {"Hybrid", "Velocity", "Angular"}
modeButton.Activated:Connect(function()
    local index = table.find(modes, mode) or 1
    mode = modes[index % #modes + 1]
    modeButton.Text = "Mode: " .. mode
end)

local flingButton = Instance.new("TextButton")
flingButton.Name = "FlingButton"
flingButton.Position = UDim2.fromOffset(12, 122)
flingButton.Size = UDim2.new(1, -24, 0, 35)
flingButton.BackgroundColor3 = Color3.fromRGB(54, 111, 213)
flingButton.BorderSizePixel = 0
flingButton.Font = Enum.Font.GothamBold
flingButton.TextSize = 14
flingButton.TextColor3 = Color3.new(1, 1, 1)
flingButton.Text = "FLING TARGET"
flingButton.Parent = panel
Instance.new("UICorner", flingButton).CornerRadius = UDim.new(0, 7)

local status = makeLabel("Only the experience owner/allowlisted admins can use this.", UDim2.fromOffset(12, 164), UDim2.new(1, -24, 0, 42))
status.Font = Enum.Font.Gotham
status.TextSize = 10
status.TextColor3 = Color3.fromRGB(177, 187, 207)
status.TextWrapped = true

flingButton.Activated:Connect(function()
    local targetName = targetBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
    local power = tonumber(powerBox.Text)
    if targetName == "" then
        status.Text = "Enter the target player's username."
        return
    end
    if not power then
        status.Text = "Power must be a number from 20 to 120."
        return
    end
    remote:FireServer("Fling", targetName, math.clamp(power, 20, 120), mode)
    status.Text = "Request sent. Server checks permissions, range and cooldown."
end)
