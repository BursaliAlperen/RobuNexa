-- ServerScriptService/Server.server.lua
-- Example for YOUR OWN Roblox experience only.
-- Copy this file into ServerScriptService and replace the IDs below with
-- animation/sound assets that your experience is allowed to use.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = ReplicatedStorage:FindFirstChild("R6AnimationRequest")
if not remote then
	remote = Instance.new("RemoteEvent")
	remote.Name = "R6AnimationRequest"
	remote.Parent = ReplicatedStorage
end

-- Use animation assets owned by your account/group or explicitly permitted
-- for this experience. Do not accept arbitrary IDs from clients.
local ALLOWED = {
	GojoAwakening = {
		animationId = "rbxassetid://REPLACE_WITH_ANIMATION_ID",
		soundId = "rbxassetid://REPLACE_WITH_SOUND_ID",
		looped = false,
	},
	MaximumHollowPurple = {
		animationId = "rbxassetid://REPLACE_WITH_ANIMATION_ID",
		soundId = "rbxassetid://REPLACE_WITH_SOUND_ID",
		looped = false,
	},
	SukunaAwakening = {
		animationId = "rbxassetid://REPLACE_WITH_ANIMATION_ID",
		soundId = "rbxassetid://REPLACE_WITH_SOUND_ID",
		looped = false,
	},
	CidOverdrive = {
		animationId = "rbxassetid://REPLACE_WITH_ANIMATION_ID",
		looped = false,
	},
}

local lastRequest = {}
local playing = {}

local function stopPlayer(player)
	local state = playing[player]
	if not state then return end
	playing[player] = nil

	if state.track then
		pcall(function() state.track:Stop(0.15) end)
		pcall(function() state.track:Destroy() end)
	end
	if state.sound then
		pcall(function() state.sound:Stop() end)
		pcall(function() state.sound:Destroy() end)
	end
end

local function getR6Character(player)
	local character = player.Character
	if not character then return nil end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then return nil end
	if humanoid.RigType ~= Enum.HumanoidRigType.R6 then return nil end

	return character, humanoid, root
end

remote.OnServerEvent:Connect(function(player, action, animationName)
	-- Small server-side rate limit; never trust client-supplied asset IDs.
	local now = os.clock()
	if now - (lastRequest[player] or 0) < 0.35 then return end
	lastRequest[player] = now

	if action == "Stop" then
		stopPlayer(player)
		return
	end
	if action ~= "Play" or type(animationName) ~= "string" then return end

	local config = ALLOWED[animationName]
	if not config or not config.animationId
		or config.animationId:find("REPLACE_WITH", 1, true) then
		return
	end

	local character, humanoid, root = getR6Character(player)
	if not character then return end

	stopPlayer(player)

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = config.animationId

	local ok, trackOrError = pcall(function()
		return animator:LoadAnimation(animation)
	end)
	animation:Destroy()

	if not ok or not trackOrError then
		warn("[R6AnimationRequest] Animation failed to load for", player.Name, animationName, trackOrError)
		return
	end

	local track = trackOrError
	track.Priority = Enum.AnimationPriority.Action
	track.Looped = config.looped == true

	local sound
	if config.soundId and not config.soundId:find("REPLACE_WITH", 1, true) then
		sound = Instance.new("Sound")
		sound.Name = "R6AnimationSound"
		sound.SoundId = config.soundId
		sound.Volume = 0.7
		sound.RollOffMaxDistance = 90
		sound.Parent = root
	end

	playing[player] = {track = track, sound = sound}
	track.Stopped:Connect(function()
		local state = playing[player]
		if state and state.track == track then
			stopPlayer(player)
		end
	end)

	local playOK, playError = pcall(function()
		track:Play(0.12)
		if sound then sound:Play() end
	end)
	if not playOK then
		warn("[R6AnimationRequest] Playback failed:", playError)
		stopPlayer(player)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	stopPlayer(player)
	lastRequest[player] = nil
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterRemoving:Connect(function()
		stopPlayer(player)
	end)
end)

for _, player in ipairs(Players:GetPlayers()) do
	player.CharacterRemoving:Connect(function()
		stopPlayer(player)
	end)
end
