-- DOG movement pack for RobuNexa / NAM
-- Animation IDs are intentionally placeholders until supplied by the user.
AddModule(function()
	local m = {}
	m.ModuleType = "MOVESET"
	m.Name = "dog"
	m.Description = "Dog movement pack with Sleep, Sit and Dance controls. Animation IDs pending."
	m.Assets = {}
	m.AnimationIds = { Sleep = "", Sit = "", Dance = "" }
	local tracks = {}
	local gui
	local activeFigure
	local activeName
	local function stopAll()
		for name, track in pairs(tracks) do
			pcall(function() track:Stop(0.15) track:Destroy() end)
			tracks[name] = nil
		end
		activeName = nil
	end
	local function play(name)
		if not activeFigure then return end
		local id = m.AnimationIds[name]
		if not id or id == "" then
			pcall(function()
				Util.Notify(name .. " animation ID not set yet — send the animation IDs.")
			end)
			return
		end
		local humanoid = activeFigure:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end
		local animator = humanoid:FindFirstChildOfClass("Animator")
		if not animator then
			animator = Instance.new("Animator")
			animator.Parent = humanoid
		end
		stopAll()
		local animation = Instance.new("Animation")
		animation.AnimationId = tostring(id):find("rbxassetid://", 1, true) and tostring(id) or ("rbxassetid://" .. tostring(id))
		local ok, track = pcall(function() return animator:LoadAnimation(animation) end)
		animation:Destroy()
		if not ok or not track then
			pcall(function() Util.Notify("Could not load " .. name .. " animation.") end)
			return
		end
		track.Priority = Enum.AnimationPriority.Action
		track.Looped = true
		tracks[name] = track
		activeName = name
		track:Play(0.15)
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
		for _, item in ipairs({{"Sleep","Sleep"},{"Sit","Sit"},{"Dance","Dance"}}) do
			local button = Instance.new("TextButton")
			button.Name = item[1] .. "Button"
			button.Size = UDim2.new(0, 88, 0, 34)
			button.BackgroundColor3 = Color3.fromRGB(38, 42, 52)
			button.BorderSizePixel = 0
			button.Text = item[2]
			button.TextColor3 = Color3.fromRGB(245, 247, 255)
			button.TextSize = 14
			button.Font = Enum.Font.GothamMedium
			button.Parent = panel
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(1, 0)
			corner.Parent = button
			button.Activated:Connect(function()
				if activeName == item[1] then
					stopAll()
				else
					play(item[1])
				end
			end)
		end
	end
	m.Init = function(figure: Model)
		activeFigure = figure
		stopAll()
	end
	m.Update = function(dt: number, figure: Model)
		activeFigure = figure
	end
	m.Destroy = function(figure: Model?)
		stopAll()
		activeFigure = nil
	end
	return m
end)
