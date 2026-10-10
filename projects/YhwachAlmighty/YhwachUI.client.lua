-- Yhwach Almighty UI shell
-- Place in StarterPlayerScripts in an experience you own.
-- This file only builds the interface and emits local UI intent events.
-- It does not equip catalog items, modify character joints, or bypass replication/security.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("YhwachAlmightyUI")
if old then
	old:Destroy()
end

local actionEvent = script:FindFirstChild("ActionRequested")
if not actionEvent then
	actionEvent = Instance.new("BindableEvent")
	actionEvent.Name = "ActionRequested"
	actionEvent.Parent = script
end

local gui = Instance.new("ScreenGui")
gui.Name = "YhwachAlmightyUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 50
gui.Parent = playerGui

local root = Instance.new("Frame")
root.Name = "Panel"
root.AnchorPoint = Vector2.new(0.5, 0.5)
root.Position = UDim2.fromScale(0.5, 0.55)
root.Size = UDim2.fromOffset(320, 365)
root.BackgroundColor3 = Color3.fromRGB(13, 15, 23)
root.BackgroundTransparency = 0.08
root.BorderSizePixel = 0
root.Parent = gui

local rootCorner = Instance.new("UICorner")
rootCorner.CornerRadius = UDim.new(0, 18)
rootCorner.Parent = root

local rootStroke = Instance.new("UIStroke")
rootStroke.Color = Color3.fromRGB(115, 92, 180)
rootStroke.Transparency = 0.25
rootStroke.Thickness = 1.3
rootStroke.Parent = root

local rootGradient = Instance.new("UIGradient")
rootGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 22, 42)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 12, 20)),
})
rootGradient.Rotation = 35
rootGradient.Parent = root

local scale = Instance.new("UIScale")
scale.Scale = 1
scale.Parent = root

local function addText(parent, name, text, size, position, font, color)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color or Color3.fromRGB(238, 237, 248)
	label.Font = font or Enum.Font.Gotham
	label.TextSize = size
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Position = position
	label.Size = UDim2.new(1, 0, 0, 24)
	label.Parent = parent
	return label
end

local header = addText(root, "Header", "Y H W A C H", 19, UDim2.fromOffset(20, 16), Enum.Font.GothamBold)
header.Size = UDim2.new(1, -70, 0, 28)

local subtitle = addText(root, "Subtitle", "THE ALMIGHTY  /  VISUAL CONTROL", 9, UDim2.fromOffset(21, 43), Enum.Font.GothamMedium, Color3.fromRGB(157, 148, 190))
subtitle.Size = UDim2.new(1, -40, 0, 18)

local close = Instance.new("TextButton")
close.Name = "Close"
close.Text = "×"
close.Font = Enum.Font.GothamMedium
close.TextSize = 24
close.TextColor3 = Color3.fromRGB(220, 216, 239)
close.BackgroundColor3 = Color3.fromRGB(38, 35, 54)
close.Size = UDim2.fromOffset(34, 32)
close.Position = UDim2.new(1, -48, 0, 14)
close.BorderSizePixel = 0
close.Parent = root
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 10)

local divider = Instance.new("Frame")
divider.Name = "Divider"
divider.Position = UDim2.fromOffset(20, 73)
divider.Size = UDim2.new(1, -40, 0, 1)
divider.BackgroundColor3 = Color3.fromRGB(82, 74, 113)
divider.BackgroundTransparency = 0.3
divider.BorderSizePixel = 0
divider.Parent = root

local status = addText(root, "Status", "FORM: BASE", 11, UDim2.fromOffset(22, 86), Enum.Font.GothamBold, Color3.fromRGB(185, 177, 220))
status.Size = UDim2.new(1, -44, 0, 20)

local hint = addText(root, "Hint", "Choose a form to preview its state.", 10, UDim2.fromOffset(22, 108), Enum.Font.Gotham, Color3.fromRGB(143, 145, 165))
hint.Size = UDim2.new(1, -44, 0, 18)

local function makeButton(name, text, y, primary)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Text = text
	button.Font = Enum.Font.GothamBold
	button.TextSize = 12
	button.TextColor3 = Color3.fromRGB(244, 242, 255)
	button.AutoButtonColor = false
	button.BorderSizePixel = 0
	button.Size = UDim2.new(1, -40, 0, primary and 50 or 39)
	button.Position = UDim2.fromOffset(20, y)
	button.BackgroundColor3 = primary and Color3.fromRGB(92, 64, 155) or Color3.fromRGB(30, 31, 47)
	button.Parent = root
	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 12)
	local stroke = Instance.new("UIStroke")
	stroke.Color = primary and Color3.fromRGB(172, 139, 255) or Color3.fromRGB(74, 72, 102)
	stroke.Transparency = 0.35
	stroke.Parent = button
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12), {
			BackgroundColor3 = primary and Color3.fromRGB(111, 78, 184) or Color3.fromRGB(43, 42, 65)
		}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12), {
			BackgroundColor3 = primary and Color3.fromRGB(92, 64, 155) or Color3.fromRGB(30, 31, 47)
		}):Play()
	end)
	return button
end

local almighty = makeButton("AlmightyButton", "AWAKEN  /  ALMIGHTY", 137, true)
local base = makeButton("BaseButton", "RETURN TO BASE FORM", 197, false)
local aura = makeButton("AuraButton", "AURA  •  TOGGLE", 244, false)
local reset = makeButton("ResetButton", "STOP EFFECTS  /  RESET VISUALS", 291, false)

local footer = addText(root, "Footer", "READY  •  ASSETS PENDING", 8, UDim2.fromOffset(22, 337), Enum.Font.GothamMedium, Color3.fromRGB(125, 125, 150))
footer.Size = UDim2.new(1, -44, 0, 16)

local mode = "Base"
local auraEnabled = false

local function request(action, payload)
	actionEvent:Fire(action, payload)
end

local function setMode(nextMode)
	mode = nextMode
	if mode == "Almighty" then
		status.Text = "FORM: ALMIGHTY"
		status.TextColor3 = Color3.fromRGB(213, 188, 255)
		hint.Text = "Almighty state selected; awaiting authorized handler."
		almighty.Text = "ALMIGHTY  •  ACTIVE"
		footer.Text = "STATE CHANGED  •  HANDLER NOT CONNECTED"
	else
		status.Text = "FORM: BASE"
		status.TextColor3 = Color3.fromRGB(185, 177, 220)
		hint.Text = "Base state selected."
		almighty.Text = "AWAKEN  /  ALMIGHTY"
		footer.Text = "READY  •  ASSETS PENDING"
	end
	request("SetForm", mode)
end

almighty.Activated:Connect(function()
	setMode(mode == "Base" and "Almighty" or "Base")
end)

base.Activated:Connect(function()
	setMode("Base")
end)

aura.Activated:Connect(function()
	auraEnabled = not auraEnabled
	aura.Text = auraEnabled and "AURA  •  ON" or "AURA  •  TOGGLE"
	request("SetAura", auraEnabled)
end)

reset.Activated:Connect(function()
	auraEnabled = false
	aura.Text = "AURA  •  TOGGLE"
	setMode("Base")
	request("StopEffects")
	request("ResetVisuals")
	footer.Text = "RESET REQUESTED"
end)

close.Activated:Connect(function()
	gui.Enabled = false
end)

-- Reopen with RightControl on keyboard; touch users can rerun the UI from their own menu.
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.RightControl then
		gui.Enabled = not gui.Enabled
	end
end)

local function updateScale()
	local camera = workspace.CurrentCamera
	if not camera then return end
	local viewport = camera.ViewportSize
	local shortest = math.min(viewport.X, viewport.Y)
	if shortest < 500 then
		scale.Scale = math.clamp(shortest / 430, 0.78, 0.95)
	else
		scale.Scale = 1
	end
end

updateScale()
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(updateScale)
if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end
