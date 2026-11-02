-- RobuNexa Accessory Cleave Fling
-- Client-side accessory-triggered cleave that targets nearby NPCs.
-- Intended as a module-style utility and follows the existing repo module patterns.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local AccessoryCleaveFling = {}
AccessoryCleaveFling.Enabled = false
AccessoryCleaveFling.MaxRange = 18
AccessoryCleaveFling.Damage = 35
AccessoryCleaveFling.FlingPower = 60
AccessoryCleaveFling.Cooldown = 0.6
AccessoryCleaveFling.AnimationId = "rbxassetid://YOUR_ANIMATION_ID"

local lastUse = 0
local accessoryHandle = nil

local function isPlayerCharacter(model)
	return model and Players:GetPlayerFromCharacter(model) ~= nil
end

local function getRoot(model)
	if not model then return nil end
	return model:FindFirstChild("HumanoidRootPart")
		or model:FindFirstChild("Torso")
		or model:FindFirstChild("UpperTorso")
end

local function findAccessoryHandle(character)
	if not character then return nil end
	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("Accessory") then
			local handle = descendant:FindFirstChild("Handle")
			if handle then
				return handle
			end
		end
	end
	return nil
end

local function findNearestNPC()
	local character = LocalPlayer.Character
	local myRoot = character and getRoot(character)
	if not myRoot then return nil end

	local nearest, nearestDistance = nil, AccessoryCleaveFling.MaxRange
	for _, instance in ipairs(workspace:GetDescendants()) do
		if instance:IsA("Model") and instance ~= character and not isPlayerCharacter(instance) then
			local humanoid = instance:FindFirstChildOfClass("Humanoid")
			local root = getRoot(instance)
			if humanoid and humanoid.Health > 0 and root and not root.Anchored then
				local distance = (root.Position - myRoot.Position).Magnitude
				if distance < nearestDistance then
					nearest, nearestDistance = instance, distance
				end
			end
		end
	end
	return nearest, myRoot
end

local function playAnimation()
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local animation = Instance.new("Animation")
	animation.AnimationId = AccessoryCleaveFling.AnimationId
	local track = humanoid:LoadAnimation(animation)
	if track then
		track:Play(0.1, 1, 1.3)
	end
end

local function spawnEffect(position)
	local effect = Instance.new("Part")
	effect.Name = "AccessoryCleaveFX"
	effect.Size = Vector3.new(1, 1, 1)
	effect.Material = Enum.Material.Neon
	effect.Color = Color3.fromRGB(255, 140, 60)
	effect.Anchored = true
	effect.CanCollide = false
	effect.Transparency = 0.2
	effect.CFrame = CFrame.new(position)
	effect.Parent = workspace

	local tween = TweenService:Create(effect, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(4, 4, 10),
		Transparency = 1,
	})
	tween:Play()
	tween.Completed:Connect(function()
		effect:Destroy()
	end)
end

local function flingTarget(targetModel)
	if not targetModel then return false end
	local root = getRoot(targetModel)
	local humanoid = targetModel:FindFirstChildOfClass("Humanoid")
	if not humanoid or not root or humanoid.Health <= 0 then return false end

	local character = LocalPlayer.Character
	local myRoot = character and getRoot(character)
	if not myRoot then return false end

	humanoid:TakeDamage(AccessoryCleaveFling.Damage)

	local direction = root.Position - myRoot.Position
	if direction.Magnitude < 0.01 then
		direction = myRoot.CFrame.LookVector
	end
	direction = direction.Unit

	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(30000, 30000, 30000)
	bodyVelocity.Velocity = (direction * AccessoryCleaveFling.FlingPower + Vector3.new(0, 16, 0))
	bodyVelocity.Parent = root

	task.delay(0.18, function()
		if bodyVelocity and bodyVelocity.Parent then
			bodyVelocity:Destroy()
		end
	end)

	return true
end

function AccessoryCleaveFling.SetEnabled(enabled)
	AccessoryCleaveFling.Enabled = enabled == true
end

function AccessoryCleaveFling.TriggerNearest()
	if os.clock() - lastUse < AccessoryCleaveFling.Cooldown then
		return false
	end

	local target, myRoot = findNearestNPC()
	if not target or not myRoot then
		return false
	end

	local root = getRoot(target)
	if not root then
		return false
	end

	playAnimation()
	spawnEffect(root.Position)
	local didFling = flingTarget(target)
	if didFling then
		lastUse = os.clock()
		return true
	end

	return false
end

function AccessoryCleaveFling.SetAnimationId(id)
	AccessoryCleaveFling.AnimationId = id
end

function AccessoryCleaveFling.SetDamage(value)
	AccessoryCleaveFling.Damage = math.clamp(value, 1, 200)
end

function AccessoryCleaveFling.SetRange(value)
	AccessoryCleaveFling.MaxRange = math.clamp(value, 5, 100)
end

function AccessoryCleaveFling.SetFlingPower(value)
	AccessoryCleaveFling.FlingPower = math.clamp(value, 10, 200)
end

function AccessoryCleaveFling.SetCooldown(value)
	AccessoryCleaveFling.Cooldown = math.clamp(value, 0.1, 5)
end

function AccessoryCleaveFling.AttachToggle(parent)
	local button = Instance.new("TextButton")
	button.Name = "AccessoryCleaveFlingToggle"
	button.Size = UDim2.fromOffset(180, 36)
	button.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Text = "Accessory Cleave: OFF"
	button.Font = Enum.Font.GothamSemibold
	button.TextSize = 12
	button.Parent = parent

	button.Activated:Connect(function()
		AccessoryCleaveFling.SetEnabled(not AccessoryCleaveFling.Enabled)
		button.Text = AccessoryCleaveFling.Enabled and "Accessory Cleave: ON" or "Accessory Cleave: OFF"
		button.BackgroundColor3 = AccessoryCleaveFling.Enabled and Color3.fromRGB(255, 120, 60) or Color3.fromRGB(45, 45, 52)
	end)

	local connection
	connection = RunService.Heartbeat:Connect(function()
		if not button.Parent then
			connection:Disconnect()
			return
		end
		if AccessoryCleaveFling.Enabled then
			AccessoryCleaveFling.TriggerNearest()
		end
	end)

	return button
end

local function setupAccessoryTrigger()
	local character = LocalPlayer.Character
	if not character then
		return
	end

	accessoryHandle = findAccessoryHandle(character)
	if not accessoryHandle then
		return
	end

	accessoryHandle.Touched:Connect(function(hit)
		if not hit or not hit.Parent then
			return
		end

		local model = hit.Parent
		if model == character or isPlayerCharacter(model) then
			return
		end

		local humanoid = model:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			local root = getRoot(model)
			if root then
				local distance = (root.Position - (accessoryHandle.CFrame.Position)).Magnitude
				if distance <= AccessoryCleaveFling.MaxRange then
					playAnimation()
					spawnEffect(root.Position)
					flingTarget(model)
				end
			end
		end
	end)
end

local function onCharacterAdded(character)
	if character then
		accessoryHandle = nil
		task.defer(function()
			setupAccessoryTrigger()
		end)
	end
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
task.defer(function()
	setupAccessoryTrigger()
end)

return AccessoryCleaveFling
