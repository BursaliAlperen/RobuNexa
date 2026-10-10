-- Local cosmetic controller for an experience you own.
-- Place alongside YhwachUI.client.lua in StarterPlayerScripts.
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Config = require(script.Parent:WaitForChild("AccessoryConfig"))
local HatAnimation = require(script.Parent:WaitForChild("HatAnimation"))

local uiScript = script.Parent:WaitForChild("YhwachUI.client")
local actionEvent = uiScript:WaitForChild("ActionRequested")
local hatAnimator = HatAnimation.new()
local activeSounds = {}
local currentForm = "Base"
local auraOn = false

local function getCharacter()
	return player.Character or player.CharacterAdded:Wait()
end

local function playSound(key, looped)
	local id = Config.SoundIds[key]
	if not id or id == "" then
		warn("[Yhwach] SoundId not configured for: " .. key)
		return
	end
	local sound = Instance.new("Sound")
	sound.Name = "Yhwach_" .. key
	sound.SoundId = id:match("^rbxassetid://") and id or ("rbxassetid://" .. id)
	sound.Looped = looped == true
	sound.Volume = 0.65
	sound.Parent = SoundService
	sound:Play()
	activeSounds[key] = sound
	if not sound.Looped then
		sound.Ended:Once(function()
			if activeSounds[key] == sound then activeSounds[key] = nil end
			sound:Destroy()
		end)
	end
end

local function stopSounds()
	for key, sound in pairs(activeSounds) do
		if sound then sound:Stop(); sound:Destroy() end
		activeSounds[key] = nil
	end
end

local function playAnimation(key, looped)
	local id = Config.AnimationIds[key]
	if not id or id == "" then
		warn("[Yhwach] AnimationId not configured for: " .. key)
		return
	end
	local character = getCharacter()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
	local animation = Instance.new("Animation")
	animation.AnimationId = id:match("^rbxassetid://") and id or ("rbxassetid://" .. id)
	local ok, track = pcall(function() return animator:LoadAnimation(animation) end)
	animation:Destroy()
	if not ok then warn("[Yhwach] Could not load animation:", track); return end
	track.Looped = looped == true
	track.Priority = Enum.AnimationPriority.Action
	track:Play(0.15)
	return track
end

local activeTracks = {}
local function stopAnimations()
	for _, track in ipairs(activeTracks) do
		pcall(function() track:Stop(0.15); track:Destroy() end)
	end
	table.clear(activeTracks)
	hatAnimator:Stop()
end

local function setForm(form)
	currentForm = form
	stopAnimations()
	if form == "Almighty" then
		local track = playAnimation("AlmightyAwakening", false)
		if track then table.insert(activeTracks, track) end
		task.delay(1.2, function()
			if currentForm ~= "Almighty" then return end
			local idle = playAnimation("AlmightyIdle", true)
			if idle then table.insert(activeTracks, idle) end
		end)
		playSound("Awakening", false)
	else
		local track = playAnimation("FormReturn", false)
		if track then table.insert(activeTracks, track) end
		playSound("FormReturn", false)
	end
end

actionEvent.Event:Connect(function(action, payload)
	if action == "SetForm" then
		setForm(payload == "Almighty" and "Almighty" or "Base")
	elseif action == "SetAura" then
		auraOn = payload == true
		if auraOn then
			playSound("AuraOn", false)
			playSound("AlmightyLoop", true)
		else
			local loop = activeSounds.AlmightyLoop
			if loop then loop:Stop(); loop:Destroy(); activeSounds.AlmightyLoop = nil end
			playSound("AuraOff", false)
		end
	elseif action == "StopEffects" then
		stopSounds()
		stopAnimations()
	elseif action == "ResetVisuals" then
		auraOn = false
		currentForm = "Base"
		stopSounds()
		stopAnimations()
	end
end)

player.CharacterAdded:Connect(function()
	stopSounds()
	stopAnimations()
	currentForm = "Base"
	auraOn = false
end)

-- Keep the config reference visible to editors and avoid accidental unused-module confusion.
if not ReplicatedStorage then return end
print("[Yhwach] Controller ready. Add uploaded animation/audio IDs to AccessoryConfig.lua.")
