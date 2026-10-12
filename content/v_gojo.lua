-- Gojo moveset scaffold for RobuNexa / NAM.
-- Animation assets can be added to content/ after the user uploads the .rbxm pack.
-- All animation tracks use the existing local AnimLib .anim format.
local modules = {}
local function AddModule(m)
	table.insert(modules, m)
end

AddModule(function()
	local m = {}
	m.ModuleType = "MOVESET"
	m.Name = "Gojo"
	m.Description = "Gojo moveset: Lapse Blue, Red Reversal, Hollow Purple, Infinity and Flight."
	-- Map Gojo movement slots to real .anim files already present in this repository.
	-- The Gojo .rbxm files are model assets, not files AnimLib.Track.fromfile can parse directly.
	m.Assets = {
		"GojoIdle.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/GojoIdle.anim",
		"GojoWalk.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/GojoWalk.anim",
		"GojoJump.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/GojoJump.anim",
		"GojoLapseBlue.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/GojoLapseBlue.anim",
		"CursedTechniqueRed.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/CursedTechniqueRed.anim",
		"RedReversal.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/RedReversal.anim",
		"HollowPurple.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/HollowPurple.anim",
	}
	local animationFiles = {
		Idle = "GojoIdle.anim",
		Walk = "GojoWalk.anim",
		Run = "GojoWalk.anim",
		Jump = "GojoJump.anim",
		Blue = "GojoLapseBlue.anim",
		Red = "CursedTechniqueRed.anim",
		Purple = "HollowPurple.anim",
	}
	local abilityNames = { "Blue", "Red", "Purple", "Infinity", "Flight" }
	local activeFigure, humanoid, root
	local activeAnimator, activeName, startedAt
	local flightEnabled = false
	local infinityEnabled = false
	local originalAutoRotate, originalWalkSpeed
	local flightVelocity, flightGyro
	local guiConnections = {}
	local buttons = {}
	local cooldownUntil = {}
	local COOLDOWNS = { Blue = 5, Red = 8, Purple = 18, Infinity = 12, Flight = 2 }
	local updateFlightConnection
	local FLIGHT_SPEED = 55
	local SOUND_IDS = {
		Infinity = "rbxassetid://74292212867322",
		RedExplosion = "rbxassetid://126359419769568",
		RedAfterTeleport = "rbxassetid://131267451700580",
		Maximum = "rbxassetid://75091144779701",
		HollowPurple = "rbxassetid://120658131553736",
		Footsteps = "rbxassetid://127420585104486",
	}
	local footstepSound
	local function playSound(id, looped, volume)
		if not root or not root.Parent then return nil end
		local sound = Instance.new("Sound")
		sound.Name = "GojoAbilitySound"
		sound.SoundId = id
		sound.Looped = looped == true
		sound.Volume = volume or 1
		sound.RollOffMaxDistance = 90
		sound.Parent = root
		sound:Play()
		if not sound.Looped then
			game:GetService("Debris"):AddItem(sound, 15)
		end
		return sound
	end
	local function stopFootsteps()
		if footstepSound then
			footstepSound:Stop()
			footstepSound:Destroy()
			footstepSound = nil
		end
	end

	local function notify(message)
		pcall(function() Util.Notify("Gojo: " .. message) end)
	end

	local function stopAnimation()
		activeAnimator = nil
		activeName = nil
		if activeFigure then
			for _, joint in ipairs(activeFigure:GetDescendants()) do
				if joint:IsA("Motor6D") then
					pcall(function() joint.Transform = CFrame.identity end)
				end
			end
		end
	end

	local function playAnimation(name, looped)
		if not activeFigure then return false end
		local filename = animationFiles[name]
		if not filename then return false end
		local path = AssetGetPathFromFilename(filename)
		local ok, track = pcall(function() return AnimLib.Track.fromfile(path) end)
		if not ok or not track or not track.Keyframes or #track.Keyframes == 0 then
			notify(filename .. " bulunamadı; .rbxm animasyonları eklendikten sonra bağlanacak.")
			return false
		end
		stopAnimation()
		activeAnimator = AnimLib.Animator.new()
		activeAnimator.rig = activeFigure
		activeAnimator.track = track
		activeAnimator.looped = looped ~= false
		activeName = name
		startedAt = os.clock()
		return true
	end

	local function nearestOtherPlayer()
		local players = game:GetService("Players")
		local localPlayer = players.LocalPlayer
		local best, bestDistance
		if not root then return nil end
		for _, player in ipairs(players:GetPlayers()) do
			if player ~= localPlayer and player.Character then
				local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
				local targetHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
				if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
					local distance = (targetRoot.Position - root.Position).Magnitude
					if not bestDistance or distance < bestDistance then
						best, bestDistance = player, distance
					end
				end
			end
		end
		return best
	end

	local function toggleInfinity()
		if not activeFigure or not activeFigure.Parent or not root or not root.Parent then
			notify("Infinity açılamadı: reanimate karakteri hazır değil.")
			return
		end
		local old = activeFigure:FindFirstChild("GojoInfinityVisual")
		if old then old:Destroy() end
		infinityEnabled = not infinityEnabled
		if infinityEnabled then
			playSound(SOUND_IDS.Infinity, false, 0.8)
			local visual = Instance.new("Part")
			visual.Name = "GojoInfinityVisual"
			visual.Shape = Enum.PartType.Ball
			visual.Size = Vector3.new(7, 7, 7)
			visual.Material = Enum.Material.ForceField
			visual.Color = Color3.fromRGB(90, 190, 255)
			visual.Transparency = 0.72
			visual.Anchored = false
			visual.CanCollide = false
			visual.CanTouch = false
			visual.CanQuery = false
			visual.Massless = true
			visual.CFrame = root.CFrame
			visual.Parent = activeFigure
			local weld = Instance.new("WeldConstraint")
			weld.Name = "GojoInfinityWeld"
			weld.Part0 = root
			weld.Part1 = visual
			weld.Parent = visual
		end
		if buttons.Infinity then
			buttons.Infinity.Text = "∞"
			buttons.Infinity.BackgroundColor3 = infinityEnabled and Color3.fromRGB(28, 105, 150) or Color3.fromRGB(22, 30, 48)
		end
		notify(infinityEnabled and "Infinity etkinleştirildi." or "Infinity kapatıldı.")
	end

	local function stopFlight()
		flightEnabled = false
		if updateFlightConnection then updateFlightConnection:Disconnect(); updateFlightConnection = nil end
		if flightVelocity then flightVelocity:Destroy(); flightVelocity = nil end
		if flightGyro then flightGyro:Destroy(); flightGyro = nil end
		if humanoid and humanoid.Parent then
			humanoid.PlatformStand = false
			if originalAutoRotate ~= nil then humanoid.AutoRotate = originalAutoRotate end
		end
		if buttons.Flight then buttons.Flight.Text = "Flight" end
	end

	local function toggleFlight()
		if flightEnabled then
			stopFlight()
			notify("Uçuş kapatıldı.")
			return
		end
		if not root or not humanoid then notify("Karakter hazır değil."); return end
		flightEnabled = true
		originalAutoRotate = humanoid.AutoRotate
		humanoid.AutoRotate = false
		humanoid.PlatformStand = true
		flightVelocity = Instance.new("BodyVelocity")
		flightVelocity.Name = "GojoFlightVelocity"
		flightVelocity.MaxForce = Vector3.new(1e7, 1e7, 1e7)
		flightVelocity.P = 1e4
		flightVelocity.Velocity = Vector3.zero
		flightVelocity.Parent = root
		flightGyro = Instance.new("BodyGyro")
		flightGyro.Name = "GojoFlightGyro"
		flightGyro.MaxTorque = Vector3.new(1e7, 1e7, 1e7)
		flightGyro.P = 1e4
		flightGyro.CFrame = root.CFrame
		flightGyro.Parent = root
		updateFlightConnection = game:GetService("RunService").RenderStepped:Connect(function()
			if not flightEnabled or not root or not root.Parent then stopFlight(); return end
			local camera = workspace.CurrentCamera
			if not camera then return end
			local input = game:GetService("UserInputService")
			local direction = Vector3.zero
			if input:IsKeyDown(Enum.KeyCode.W) then direction += camera.CFrame.LookVector end
			if input:IsKeyDown(Enum.KeyCode.S) then direction -= camera.CFrame.LookVector end
			if input:IsKeyDown(Enum.KeyCode.D) then direction += camera.CFrame.RightVector end
			if input:IsKeyDown(Enum.KeyCode.A) then direction -= camera.CFrame.RightVector end
			if input:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.yAxis end
			if input:IsKeyDown(Enum.KeyCode.LeftControl) then direction -= Vector3.yAxis end
			flightVelocity.Velocity = direction.Magnitude > 0 and direction.Unit * FLIGHT_SPEED or Vector3.zero
			flightGyro.CFrame = camera.CFrame
		end)
		if buttons.Flight then buttons.Flight.Text = "Flight: ON" end
		notify("Uçuş açıldı. WASD + Space/Ctrl.")
	end

	local function refreshAbilityButton(name)
		local button = buttons[name]
		if not button then return end
		local remaining = math.max(0, (cooldownUntil[name] or 0) - os.clock())
		if remaining > 0 then
			button.Active = false
			button.AutoButtonColor = false
			button.BackgroundColor3 = Color3.fromRGB(55, 60, 75)
			button.Text = (name == "Purple" and "PURP" or (name == "Infinity" and "∞" or name)) .. "\n" .. string.format("%.1f s", remaining)
		else
			button.Active = true
			button.AutoButtonColor = true
			button.BackgroundColor3 = (name == "Infinity" and infinityEnabled) and Color3.fromRGB(28, 105, 150) or (name == "Flight" and flightEnabled) and Color3.fromRGB(28, 105, 150) or Color3.fromRGB(22, 30, 48)
			button.Text = name == "Purple" and "PURP" or (name == "Infinity" and "∞" or name == "Flight" and (flightEnabled and "FLY ON" or "FLIGHT") or name)
		end
	end

	local function beginCooldown(name)
		cooldownUntil[name] = os.clock() + (COOLDOWNS[name] or 5)
		task.spawn(function()
			while buttons[name] and os.clock() < (cooldownUntil[name] or 0) do
				refreshAbilityButton(name)
				task.wait(0.1)
			end
			refreshAbilityButton(name)
		end)
	end

	local function useAbility(name)
		local remaining = (cooldownUntil[name] or 0) - os.clock()
		if remaining > 0 and not (name == "Infinity" and infinityEnabled) and not (name == "Flight" and flightEnabled) then
			notify(name .. " bekleme süresi: " .. string.format("%.1f", remaining) .. " sn")
			return
		end
		if name == "Infinity" then
			if infinityEnabled then toggleInfinity(); refreshAbilityButton(name); return end
			toggleInfinity()
			if infinityEnabled then beginCooldown(name) end
			return
		end
		if name == "Flight" then
			if flightEnabled then toggleFlight(); refreshAbilityButton(name); return end
			toggleFlight()
			if flightEnabled then beginCooldown(name) end
			return
		end
		if name == "Red" then
			playSound(SOUND_IDS.RedExplosion, false, 1)
			local target = nearestOtherPlayer()
			local targetRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
			if targetRoot and root then
				local desired = targetRoot.CFrame * CFrame.new(0, 0, 4)
				local rayParams = RaycastParams.new()
				rayParams.FilterType = Enum.RaycastFilterType.Exclude
				rayParams.FilterDescendantsInstances = { activeFigure, target.Character }
				local ray = workspace:Raycast(targetRoot.Position, desired.Position - targetRoot.Position, rayParams)
				if not ray then
					root.CFrame = CFrame.lookAt(desired.Position, targetRoot.Position)
					playSound(SOUND_IDS.RedAfterTeleport, false, 1)
				else
					notify("Hedefin arkasında güvenli nokta yok.")
				end
			else
				notify("Yakında hedef oyuncu bulunamadı.")
			end
		end
		if name == "Purple" then
			playSound(SOUND_IDS.Maximum, false, 1)
			task.delay(0.35, function() if root and root.Parent then playSound(SOUND_IDS.HollowPurple, false, 1) end end)
		end
		playAnimation(name, false)
		beginCooldown(name)
		notify(name .. " kullanıldı.")
	end

	m.Config = function(parent: GuiBase2d)
		-- Ability buttons are gameplay HUD controls, not settings-page controls.
		-- The runtime HUD is created only by Init when Gojo is equipped.
	end

	local function createRuntimeControls()
		local player = game:GetService("Players").LocalPlayer
		local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
		if not playerGui then
			task.spawn(function()
				for _ = 1, 30 do
					task.wait(0.25)
					playerGui = player and player:FindFirstChildOfClass("PlayerGui")
					if playerGui then break end
				end
				if playerGui and activeFigure then createRuntimeControls() end
			end)
			return
		end
		local oldGui = playerGui:FindFirstChild("GojoAbilityHUD")
		if oldGui then oldGui:Destroy() end
		table.clear(buttons)
		local screen = Instance.new("ScreenGui")
		screen.Name = "GojoAbilityHUD"
		screen.ResetOnSpawn = false
		screen.IgnoreGuiInset = true
		screen.DisplayOrder = 50
		screen.Parent = playerGui
		local panel = Instance.new("Frame")
		panel.Name = "AbilityButtons"
		panel.AnchorPoint = Vector2.new(1, 1)
		panel.Position = UDim2.new(1, -18, 1, -142)
		panel.Size = UDim2.fromOffset(168, 108)
		panel.BackgroundTransparency = 1
		panel.Parent = screen
		local grid = Instance.new("UIGridLayout")
		grid.CellSize = UDim2.fromOffset(48, 48)
		grid.CellPadding = UDim2.fromOffset(7, 5)
		grid.FillDirectionMaxCells = 3
		grid.HorizontalAlignment = Enum.HorizontalAlignment.Right
		grid.VerticalAlignment = Enum.VerticalAlignment.Bottom
		grid.SortOrder = Enum.SortOrder.LayoutOrder
		grid.Parent = panel
		for index, name in ipairs(abilityNames) do
			local button = Instance.new("TextButton")
			button.Name = name .. "Button"
			button.LayoutOrder = index
			button.Size = UDim2.fromOffset(48, 48)
			button.BackgroundColor3 = Color3.fromRGB(22, 30, 48)
			button.BackgroundTransparency = 0.08
			button.BorderSizePixel = 0
			button.Text = name == "Purple" and "PURP" or (name == "Infinity" and "∞" or name)
			button.TextColor3 = Color3.fromRGB(235, 245, 255)
			button.TextSize = 10
			button.TextWrapped = true
			button.Font = Enum.Font.GothamBold
			button.AutoButtonColor = true
			button.Parent = panel
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(1, 0)
			corner.Parent = button
			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(80, 175, 255)
			stroke.Thickness = 1.2
			stroke.Transparency = 0.2
			stroke.Parent = button
			buttons[name] = button
			table.insert(guiConnections, button.Activated:Connect(function()
				useAbility(name)
			end))
		end
	end

	m.Init = function(figure: Model)
		stopFlight()
		stopAnimation()
		if activeFigure then
			local oldVisual = activeFigure:FindFirstChild("GojoInfinityVisual")
			if oldVisual then oldVisual:Destroy() end
		end
		activeFigure = figure
		humanoid = figure:FindFirstChildOfClass("Humanoid")
		root = figure:FindFirstChild("HumanoidRootPart")
		originalWalkSpeed = humanoid and humanoid.WalkSpeed or 16
		infinityEnabled = false
		createRuntimeControls()
	end

	m.Update = function(dt: number, figure: Model)
		activeFigure = figure
		humanoid = figure:FindFirstChildOfClass("Humanoid")
		root = figure:FindFirstChild("HumanoidRootPart")
		if flightEnabled then stopFootsteps(); return end
		local moving = humanoid and humanoid.MoveDirection.Magnitude > 0.05 and humanoid.FloorMaterial ~= Enum.Material.Air
		if moving then
			if not footstepSound or not footstepSound.Parent then
				footstepSound = playSound(SOUND_IDS.Footsteps, true, 0.55)
			end
		elseif footstepSound then
			stopFootsteps()
		end
		local wanted
		if humanoid and humanoid.Jump then
			wanted = "Jump"
		elseif humanoid and humanoid.MoveDirection.Magnitude > 0.05 then
			wanted = humanoid.WalkSpeed >= 20 and "Run" or "Walk"
		else
			wanted = "Idle"
		end
		if wanted ~= activeName then
			playAnimation(wanted, true)
		elseif activeAnimator and startedAt then
			activeAnimator:Step(os.clock() - startedAt)
		end
	end

	m.Destroy = function(figure: Model?)
		stopFlight()
		stopFootsteps()
		stopAnimation()
		if activeFigure then
			local visual = activeFigure:FindFirstChild("GojoInfinityVisual")
			if visual then visual:Destroy() end
		end
		infinityEnabled = false
		for _, connection in ipairs(guiConnections) do pcall(function() connection:Disconnect() end) end
		table.clear(guiConnections)
		local player = game:GetService("Players").LocalPlayer
		local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
		local hud = playerGui and playerGui:FindFirstChild("GojoAbilityHUD")
		if hud then hud:Destroy() end
		table.clear(buttons)
		activeFigure, humanoid, root = nil, nil, nil
	end
	return m
end)

return modules
