-- DOG movement pack for RobuNexa / NAM.
-- Uses NAM's local .anim parser; no Roblox animation asset IDs are required.
local modules = {}
local function AddModule(m)
	table.insert(modules, m)
end

AddModule(function()
	local m = {}
	m.ModuleType = "MOVESET"
	m.Name = "dog"
	m.Description = "Dog movement pack with local Sleep, Sit and Dance animations."
	m.Assets = {
		"DANCEDAWG.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/DANCEDAWG.anim",
		"DOGRUN.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/DOGRUN.anim",
		"JUMPDOG.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/JUMPDOG.anim",
		"SITDAWG.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/SITDAWG.anim",
		"Sleepp.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/Sleepp.anim",
	}
	local animationFiles = { Sleep = "Sleepp.anim", Sit = "SITDAWG.anim", Dance = "DANCEDAWG.anim", Run = "DOGRUN.anim", Jump = "JUMPDOG.anim" }
	local activeFigure
	local activeName
	local activeAnimator
	local startedAt = 0

	local function stopAll()
		activeAnimator = nil
		activeName = nil
		if activeFigure then
			for _, joint in activeFigure:GetDescendants() do
				if joint:IsA("Motor6D") then
					pcall(function() joint.Transform = CFrame.identity end)
				end
			end
		end
	end

	local function play(name)
		if not activeFigure then return end
		stopAll()
		local path = AssetGetPathFromFilename(animationFiles[name])
		local ok, track = pcall(function() return AnimLib.Track.fromfile(path) end)
		if not ok or not track or not track.Keyframes or #track.Keyframes == 0 then
			pcall(function() Util.Notify(name .. " animation file missing/invalid. Reload dog movement after conversion.") end)
			return
		end
		activeAnimator = AnimLib.Animator.new()
		activeAnimator.rig = activeFigure
		activeAnimator.track = track
		activeAnimator.looped = true
		startedAt = os.clock()
		activeName = name
	end

	m.Config = function(parent: GuiBase2d)
		local panel = Instance.new("Frame")
		panel.Name = "DogMovementControls"
		panel.BackgroundTransparency = 1
		panel.Size = UDim2.new(1, 0, 0, 42)
		panel.Parent = parent
		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		layout.VerticalAlignment = Enum.VerticalAlignment.Center
		layout.Padding = UDim.new(0, 6)
		layout.Parent = panel
		for _, name in ipairs({"Sleep", "Sit", "Dance"}) do
			local button = Instance.new("TextButton")
			button.Name = name .. "Button"
			button.Size = UDim2.new(0, 88, 0, 34)
			button.BackgroundColor3 = Color3.fromRGB(38, 42, 52)
			button.BorderSizePixel = 0
			button.Text = name
			button.TextColor3 = Color3.fromRGB(245, 247, 255)
			button.TextSize = 14
			button.Font = Enum.Font.GothamMedium
			button.Parent = panel
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(1, 0)
			corner.Parent = button
			button.Activated:Connect(function()
				if activeName == name then stopAll() else play(name) end
			end)
		end
	end

	m.Init = function(figure: Model)
		activeFigure = figure
		stopAll()
	end
	m.Update = function(dt: number, figure: Model)
		activeFigure = figure
		local humanoid = figure:FindFirstChildOfClass("Humanoid")
		if activeName == "Sleep" or activeName == "Sit" or activeName == "Dance" then
			if activeAnimator then activeAnimator:Step(os.clock() - startedAt) end
			return
		end
		local wanted
		if humanoid and humanoid.Jump then
			wanted = "Jump"
		elseif humanoid and humanoid.MoveDirection.Magnitude > 0.05 then
			wanted = "Run"
		end
		if wanted ~= activeName then
			if wanted then play(wanted) else stopAll() end
		elseif activeAnimator then
			activeAnimator:Step(os.clock() - startedAt)
		end
	end
	m.Destroy = function(figure: Model?)
		stopAll()
		activeFigure = nil
	end
	return m
end)

return modules
