-- RobuNexa Universal Fling System
-- Works on both NPC and Player characters
-- High-performance physics-based flinging

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local UniversalFling = {}
UniversalFling.Enabled = false
UniversalFling.MaxRange = 50
UniversalFling.Impulse = 85
UniversalFling.Cooldown = 0.6
UniversalFling.Targets = {} -- Track recently flung targets to prevent re-fling
UniversalFling.TargetCooldown = 2

local lastLaunch = 0

local function getRoot(model)
	return model:FindFirstChild("HumanoidRootPart")
		or model:FindFirstChild("Torso")
		or model:FindFirstChild("UpperTorso")
end

local function isValidTarget(model, myCharacter)
	if not model or model == myCharacter then return false end
	if not model:IsA("Model") then return false end
	
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local root = getRoot(model)
	
	if not humanoid or humanoid.Health <= 0 then return false end
	if not root or root.Anchored then return false end
	
	return true
end

local function findNearestTarget()
	local character = LocalPlayer.Character
	local myRoot = character and getRoot(character)
	if not myRoot then return nil end
	
	local nearest, nearestDistance = nil, UniversalFling.MaxRange
	
	for _, instance in ipairs(workspace:GetDescendants()) do
		if isValidTarget(instance, character) then
			local root = getRoot(instance)
			local distance = (root.Position - myRoot.Position).Magnitude
			
			if distance < nearestDistance then
				-- Check if target was recently flung
				local now = tick()
				local lastFlingTime = UniversalFling.Targets[instance] or 0
				
				if now - lastFlingTime >= UniversalFling.TargetCooldown then
					nearest, nearestDistance = instance, distance
				end
			end
		end
	end
	
	return nearest, myRoot
end

function UniversalFling.SetEnabled(enabled)
	UniversalFling.Enabled = enabled == true
end

function UniversalFling.Step()
	if not UniversalFling.Enabled or os.clock() - lastLaunch < UniversalFling.Cooldown then
		return false
	end
	
	local target, myRoot = findNearestTarget()
	if not target then return false end
	
	local root = getRoot(target)
	if not root then return false end
	
	-- Calculate direction
	local direction = root.Position - myRoot.Position
	if direction.Magnitude < 0.01 then 
		direction = myRoot.CFrame.LookVector 
	end
	direction = direction.Unit
	
	-- Apply physics impulse
	local mass = root.AssemblyMass
	local impulse = (direction * UniversalFling.Impulse + Vector3.new(0, UniversalFling.Impulse * 0.75, 0)) * math.clamp(mass, 1, 30)
	
	pcall(function()
		root:ApplyImpulse(impulse)
	end)
	
	-- Mark target as recently flung
	UniversalFling.Targets[target] = tick()
	
	lastLaunch = os.clock()
	return true, target.Name
end

function UniversalFling.AttachToggle(parent)
	local button = Instance.new("TextButton")
	button.Name = "UniversalFlingToggle"
	button.Size = UDim2.fromOffset(150, 36)
	button.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Text = "Universal Fling: OFF"
	button.Font = Enum.Font.GothamSemibold
	button.TextSize = 12
	button.Parent = parent
	
	button.Activated:Connect(function()
		UniversalFling.SetEnabled(not UniversalFling.Enabled)
		button.Text = UniversalFling.Enabled and "Universal Fling: ON" or "Universal Fling: OFF"
		button.BackgroundColor3 = UniversalFling.Enabled
			and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(45, 45, 52)
	end)
	
	local connection
	connection = RunService.Heartbeat:Connect(function()
		if not button.Parent then
			connection:Disconnect()
			return
		end
		UniversalFling.Step()
	end)
	
	return button
end

function UniversalFling.SetImpulse(value)
	UniversalFling.Impulse = math.clamp(value, 20, 200)
end

function UniversalFling.SetRange(value)
	UniversalFling.MaxRange = math.clamp(value, 10, 200)
end

function UniversalFling.SetCooldown(value)
	UniversalFling.Cooldown = math.clamp(value, 0.1, 5)
end

return UniversalFling
