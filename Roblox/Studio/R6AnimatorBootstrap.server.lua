-- R6 Animator Bootstrap + Rig Diagnostics
-- Place this Script in ServerScriptService in YOUR Roblox experience.
-- Creates Animator on the server when missing and reports incomplete R6 rigs.
-- Does not delete Animate/Animator or touch unsupported hidden properties.

local Players = game:GetService("Players")

local REQUIRED_R6_MOTORS = {
	"RootJoint",
	"Neck",
	"Right Shoulder",
	"Left Shoulder",
	"Right Hip",
	"Left Hip",
}

local function validateR6(character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if not humanoid or not humanoid:IsA("Humanoid") then
		warn("[R6AnimatorBootstrap] Humanoid missing:", character:GetFullName())
		return
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Name = "Animator"
		animator.Parent = humanoid
	end

	if humanoid.RigType ~= Enum.HumanoidRigType.R6 then
		return
	end

	-- Allow Roblox a moment to finish assembling the character before checking joints.
	task.wait(0.25)
	local found = {}
	for _, descendant in character:GetDescendants() do
		if descendant:IsA("Motor6D") then
			found[descendant.Name] = true
		end
	end

	local missing = {}
	for _, motorName in REQUIRED_R6_MOTORS do
		if not found[motorName] then
			table.insert(missing, motorName)
		end
	end

	if #missing > 0 then
		warn("[R6AnimatorBootstrap] Incomplete R6 rig for "
			.. character.Name .. "; missing Motor6D(s): "
			.. table.concat(missing, ", "))
	end
end

local function watchPlayer(player: Player)
	player.CharacterAdded:Connect(function(character)
		task.spawn(validateR6, character)
	end)

	if player.Character then
		task.spawn(validateR6, player.Character)
	end
end

Players.PlayerAdded:Connect(watchPlayer)
for _, player in Players:GetPlayers() do
	watchPlayer(player)
end
