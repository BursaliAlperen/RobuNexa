-- R6 Animator Bootstrap
-- Place this Script in ServerScriptService in your own Roblox experience.
-- Keeps a server-created Animator available so standard AnimationTracks can replicate.
-- This intentionally does not delete Animate/Animator or modify hidden engine properties.

local Players = game:GetService("Players")

local function ensureAnimator(character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if not humanoid or not humanoid:IsA("Humanoid") then
		warn("[R6AnimatorBootstrap] Humanoid missing for", character:GetFullName())
		return
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Name = "Animator"
		animator.Parent = humanoid
	end
end

local function onPlayer(player: Player)
	player.CharacterAdded:Connect(function(character)
		task.spawn(ensureAnimator, character)
	end)

	if player.Character then
		task.spawn(ensureAnimator, player.Character)
	end
end

Players.PlayerAdded:Connect(onPlayer)
for _, player in Players:GetPlayers() do
	onPlayer(player)
end
