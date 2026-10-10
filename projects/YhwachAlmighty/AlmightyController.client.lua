-- Local visual controller for an experience you own.
-- This intentionally uses published Roblox asset IDs; repository .anim/.mp3 files are not runtime assets.
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local Config = require(script.Parent:WaitForChild("AccessoryConfig"))
local HatAnimation = require(script.Parent:WaitForChild("HatAnimation"))
local uiScript = script.Parent:WaitForChild("YhwachUI.client")
local actionEvent = uiScript:WaitForChild("ActionRequested")
local statusEvent = uiScript:WaitForChild("StatusChanged")
local hatAnimator = HatAnimation.new()

local function reportStatus(message, color)
	statusEvent:Fire(message, color or Color3.fromRGB(157, 148, 190))
end

local activeSounds = {}
local activeTracks = {}
local currentForm = "Base"
local auraOn = false
local formToken = 0

local allowedMoves = {
	AlmightySlash = true,
	Auswahlen = true,
	BlutVeneAnhaben = true,
	Sklaverei = true,
}

local function getCharacter()
	return player.Character or player.CharacterAdded:Wait()
end

local function stopSound(key)
	local sound = activeSounds[key]
	if sound then
		activeSounds[key] = nil
		pcall(function() sound:Stop(); sound:Destroy() end)
	end
end

local function playSound(key, looped)
	local id = Config.SoundIds[key]
	if not id or id == "" then
		warn("[Yhwach] SoundId not configured for: " .. key)
		return
	end
	stopSound(key)
	local sound = Instance.new("Sound")
	sound.Name = "Yhwach_" .. key
	sound.SoundId = id:match("^rbxassetid://") and id or ("rbxassetid://" .. id)
	sound.Looped = looped == true
	sound.Volume = 0.65
	sound.Parent = SoundService
	activeSounds[key] = sound
	sound:Play()
	if not sound.Looped then
		sound.Ended:Once(function()
			if activeSounds[key] == sound then
				activeSounds[key] = nil
				sound:Destroy()
			end
		end)
	end
end

local function stopSounds()
	local keys = {}
	for key in pairs(activeSounds) do table.insert(keys, key) end
	for _, key in ipairs(keys) do stopSound(key) end
end

local function stopAnimations()
	for key, track in pairs(activeTracks) do
		activeTracks[key] = nil
		pcall(function() track:Stop(0.15); track:Destroy() end)
	end
	hatAnimator:Stop()
end

local function playAnimation(key, looped, keepOtherTracks)
	local id = Config.AnimationIds[key]
	if not id or id == "" then
		local message = "Animation ID missing: " .. key
		warn("[Yhwach] Publish the matching .anim file and set AnimationIds." .. key)
		reportStatus(message, Color3.fromRGB(255, 196, 94))
		return nil
	end
	if not keepOtherTracks then stopAnimations() end

	local character = getCharacter()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		reportStatus("Humanoid not found on character.", Color3.fromRGB(255, 120, 120))
		return nil
	end
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = id:match("^rbxassetid://") and id or ("rbxassetid://" .. id)
	local ok, trackOrError = pcall(function() return animator:LoadAnimation(animation) end)
	animation:Destroy()
	if not ok then
		warn("[Yhwach] Could not load " .. key .. ":", trackOrError)
		reportStatus("Load failed: " .. key .. " (check ID / permissions)", Color3.fromRGB(255, 120, 120))
		return nil
	end

	local track = trackOrError
	track.Looped = looped == true
	track.Priority = Enum.AnimationPriority.Action
	activeTracks[key] = track
	track:Play(0.15)
	reportStatus("Playing: " .. key, Color3.fromRGB(213, 188, 255))
	track.Stopped:Once(function()
		if activeTracks[key] == track then activeTracks[key] = nil end
	end)
	return track
end

local function setForm(form)
	formToken += 1
	local thisToken = formToken
	currentForm = form
	stopAnimations()

	if form == "Almighty" then
		playSound("Awakening", false)
		local awakening = playAnimation("AlmightyAwakening", false, true)
		local delaySeconds = 1.2
		if awakening and awakening.Length > 0 then
			delaySeconds = math.min(awakening.Length, 3.5)
		end
		task.delay(delaySeconds, function()
			if currentForm ~= "Almighty" or formToken ~= thisToken then return end
			playAnimation("AlmightyAura", true, false)
		end)
	else
		stopSound("AlmightyLoop")
		playSound("FormReturn", false)
	end
end

actionEvent.Event:Connect(function(action, payload)
	if action == "SetForm" then
		setForm(payload == "Almighty" and "Almighty" or "Base")
		reportStatus(payload == "Almighty" and "Almighty form selected" or "Base form selected", Color3.fromRGB(213, 188, 255))
	elseif action == "SetAura" then
		auraOn = payload == true
		if auraOn then
			playSound("AuraOn", false)
			playSound("AlmightyLoop", true)
			if currentForm == "Almighty" then
				playAnimation("AlmightyAura", true, false)
			end
		else
			stopSound("AlmightyLoop")
			playSound("AuraOff", false)
			local auraTrack = activeTracks.AlmightyAura
			if auraTrack then
				activeTracks.AlmightyAura = nil
				pcall(function() auraTrack:Stop(0.15); auraTrack:Destroy() end)
			end
		end
	elseif action == "PlayMove" and allowedMoves[payload] then
		if currentForm ~= "Almighty" then
			warn("[Yhwach] Awaken Almighty before playing this move.")
			return
		end
		playAnimation(payload, false, false)
	elseif action == "StopEffects" then
		formToken += 1
		stopSounds()
		stopAnimations()
		reportStatus("Animations and sounds stopped", Color3.fromRGB(180, 220, 255))
	elseif action == "ResetVisuals" then
		formToken += 1
		auraOn = false
		currentForm = "Base"
		stopSounds()
		stopAnimations()
		reportStatus("Visual state reset", Color3.fromRGB(180, 220, 255))
	end
end)

player.CharacterAdded:Connect(function()
	formToken += 1
	stopSounds()
	stopAnimations()
	currentForm = "Base"
	auraOn = false
end)

print("[Yhwach] Controller ready. Upload the six .anim sources to Roblox and fill AnimationIds.")
