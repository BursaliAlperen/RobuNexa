-- YhwachCutscenes.lua
-- Client-only cinematic helper for a Roblox experience you own.
-- Place as a ModuleScript beside AlmightyController.client and require it there.
-- No executor APIs, remote injection, or external code loading.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local Cutscenes = {}
Cutscenes.__index = Cutscenes

local player = Players.LocalPlayer
local activeToken = 0
local activeGui
local blur
local colorCorrection

local function makeOverlay()
	local playerGui = player:WaitForChild("PlayerGui")
	local existing = playerGui:FindFirstChild("YhwachCinematicOverlay")
	if existing then existing:Destroy() end

	local gui = Instance.new("ScreenGui")
	gui.Name = "YhwachCinematicOverlay"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 100
	gui.Parent = playerGui

	local function bar(name, position)
		local frame = Instance.new("Frame")
		frame.Name = name
		frame.Position = position
		frame.Size = UDim2.new(1, 0, 0, 0)
		frame.BackgroundColor3 = Color3.new(0, 0, 0)
		frame.BorderSizePixel = 0
		frame.Parent = gui
		return frame
	end

	local top = bar("TopLetterbox", UDim2.fromScale(0, 0))
	local bottom = bar("BottomLetterbox", UDim2.new(0, 0, 1, 0))
	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.AnchorPoint = Vector2.new(0.5, 1)
	subtitle.Position = UDim2.new(0.5, 0, 0.91, 0)
	subtitle.Size = UDim2.new(0.84, 0, 0, 52)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = ""
	subtitle.TextColor3 = Color3.fromRGB(245, 239, 255)
	subtitle.TextStrokeTransparency = 0.4
	subtitle.Font = Enum.Font.GothamBold
	subtitle.TextSize = 20
	subtitle.TextWrapped = true
	subtitle.Parent = gui

	local skip = Instance.new("TextButton")
	skip.Name = "Skip"
	skip.AnchorPoint = Vector2.new(1, 0)
	skip.Position = UDim2.new(1, -18, 0, 18)
	skip.Size = UDim2.fromOffset(90, 34)
	skip.BackgroundColor3 = Color3.fromRGB(24, 18, 38)
	skip.BackgroundTransparency = 0.15
	skip.BorderSizePixel = 0
	skip.Text = "SKIP  »"
	skip.TextColor3 = Color3.fromRGB(235, 225, 255)
	skip.TextSize = 12
	skip.Font = Enum.Font.GothamBold
	skip.Parent = gui
	Instance.new("UICorner", skip).CornerRadius = UDim.new(0, 9)

	return gui, top, bottom, subtitle, skip
end

local function tween(instance, duration, properties)
	local animation = TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), properties)
	animation:Play()
	return animation
end

function Cutscenes.Stop()
	activeToken += 1
	local camera = workspace.CurrentCamera
	if camera then
		camera.CameraType = Enum.CameraType.Custom
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then camera.CameraSubject = humanoid end
	end
	if activeGui then activeGui:Destroy(); activeGui = nil end
	if blur then blur:Destroy(); blur = nil end
	if colorCorrection then colorCorrection:Destroy(); colorCorrection = nil end
end

function Cutscenes.PlayAwakening(character)
	Cutscenes.Stop()
	activeToken += 1
	local token = activeToken
	character = character or player.Character
	if not character then return false, "Character not found" end
	local root = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local camera = workspace.CurrentCamera
	if not root or not humanoid or not camera then return false, "Character camera parts missing" end

	local gui, top, bottom, subtitle, skip = makeOverlay()
	activeGui = gui
	blur = Instance.new("BlurEffect")
	blur.Name = "YhwachCinematicBlur"
	blur.Size = 0
	blur.Parent = Lighting
	colorCorrection = Instance.new("ColorCorrectionEffect")
	colorCorrection.Name = "YhwachCinematicGrade"
	colorCorrection.TintColor = Color3.fromRGB(220, 204, 255)
	colorCorrection.Contrast = 0.08
	colorCorrection.Saturation = -0.15
	colorCorrection.Parent = Lighting

	local previousType = camera.CameraType
	local previousSubject = camera.CameraSubject
	local previousFov = camera.FieldOfView
	camera.CameraType = Enum.CameraType.Scriptable
	camera.FieldOfView = 60

	local function restore()
		if token ~= activeToken then return end
		camera.CameraType = previousType == Enum.CameraType.Scriptable and Enum.CameraType.Custom or previousType
		camera.CameraSubject = humanoid or previousSubject
		camera.FieldOfView = previousFov
		if activeGui then activeGui:Destroy(); activeGui = nil end
		if blur then blur:Destroy(); blur = nil end
		if colorCorrection then colorCorrection:Destroy(); colorCorrection = nil end
	end
	skip.Activated:Connect(restore)

	local shots = {
		{time=0.9, offset=CFrame.new(0, 2.2, 9), focus=Vector3.new(0, 1.6, 0), line="THE FUTURE... IS MINE."},
		{time=1.4, offset=CFrame.new(5, 2.8, 6), focus=Vector3.new(0, 1.8, 0), line="ALL POSSIBILITIES, UNDER MY SIGHT."},
		{time=1.5, offset=CFrame.new(0, 3.2, -8), focus=Vector3.new(0, 1.5, 0), line="THE ALMIGHTY AWAKENS."},
	}
	tween(top, 0.35, {Size=UDim2.new(1, 0, 0, 58)})
	tween(bottom, 0.35, {Size=UDim2.new(1, 0, 0, 58), Position=UDim2.new(0, 0, 1, -58)})
	tween(blur, 0.5, {Size=5})

	task.spawn(function()
		for _, shot in ipairs(shots) do
			if token ~= activeToken or not root.Parent then break end
			subtitle.TextTransparency = 1
			subtitle.Text = shot.line
			tween(subtitle, 0.25, {TextTransparency=0})
			local target = CFrame.lookAt((root.CFrame * shot.offset).Position, root.Position + shot.focus)
			local cameraTween = tween(camera, shot.time, {CFrame=target, FieldOfView=shot.offset.Z < 0 and 48 or 58})
			cameraTween.Completed:Wait()
			if token ~= activeToken then return end
		end
		if token == activeToken then
			tween(blur, 0.45, {Size=0})
			tween(subtitle, 0.25, {TextTransparency=1})
			task.wait(0.3)
			restore()
		end
	end)
	return true
end

return Cutscenes
