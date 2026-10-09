-- NAM curated dance catalog
-- Only Hakari's Dance is shipped from the original dance pack.

cloneref = cloneref or function(o) return o end

local Debris = cloneref(game:GetService("Debris"))
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local StarterGui = cloneref(game:GetService("StarterGui"))
local HttpService = cloneref(game:GetService("HttpService"))
local TextService = cloneref(game:GetService("TextService"))
local TweenService = cloneref(game:GetService("TweenService"))
local TextChatService = cloneref(game:GetService("TextChatService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local ContextActionService = cloneref(game:GetService("ContextActionService"))

local Player = Players.LocalPlayer
local modules = {}
local function AddModule(m) table.insert(modules, m) end

AddModule(function()
	local m = {}
	m.ModuleType = "DANCE"
	m.Name = "Hakari's Dance"
	m.Description = "jujutsu shenanigans\nlets go gambling\naw dang it\naw dang it\naw dang it\naw dang it\naw dang it"
	m.InternalName = "TUKATUKADONKDONK"
	m.Assets = {"Hakari.anim", "Hakari.mp3"}

	m.Effects = false
	m.Config = function(parent: GuiBase2d)
		Util_CreateSwitch(parent, "Effects", m.Effects).Changed:Connect(function(val)
			m.Effects = val
		end)
	end
	m.LoadConfig = function(save: any)
		m.Effects = not not save.Effects
	end
	m.SaveConfig = function()
		return {
			Effects = m.Effects
		}
	end

	local animator = nil
	local instances = {}
	m.Init = function(figure: Model)
		SetOverrideDanceMusic(AssetGetContentId("Hakari.mp3"), "TUCA DONKA", 1)
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("Hakari.anim"))
		animator.looped = true
		animator.map = {{0, 73.845}, {0, 75.6}}
		instances = {}
		if m.Effects then
			local scale = figure:GetScale()
			local root = figure:FindFirstChild("HumanoidRootPart")
			local SmokeLight = Instance.new("ParticleEmitter")
			SmokeLight.Parent = root
			SmokeLight.LightInfluence = 0
			SmokeLight.LightEmission = 1
			SmokeLight.Brightness = 1
			SmokeLight.ZOffset = -2
			SmokeLight.Color = ColorSequence.new(Color3.fromRGB(67, 255, 167))
			SmokeLight.Orientation = Enum.ParticleOrientation.FacingCamera
			SmokeLight.Size = NumberSequence.new(0.625 * scale, 8.5 * scale)
			SmokeLight.Squash = NumberSequence.new(0)
			SmokeLight.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.4, 0.0625),
				NumberSequenceKeypoint.new(0.5, 0),
				NumberSequenceKeypoint.new(0.625, 0.0625),
				NumberSequenceKeypoint.new(0.75, 0.2),
				NumberSequenceKeypoint.new(0.875, 0.4),
				NumberSequenceKeypoint.new(0.95, 0.65),
				NumberSequenceKeypoint.new(1, 1),
			})
			SmokeLight.Texture = "rbxassetid://12585595946"
			SmokeLight.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
			SmokeLight.FlipbookMode = Enum.ParticleFlipbookMode.Loop
			SmokeLight.FlipbookFramerate = NumberRange.new(25)
			SmokeLight.FlipbookStartRandom = true
			SmokeLight.Lifetime = NumberRange.new(0.4, 0.7)
			SmokeLight.Rate = 25
			SmokeLight.Rotation = NumberRange.new(0, 360)
			SmokeLight.RotSpeed = NumberRange.new(-20, 20)
			SmokeLight.Speed = NumberRange.new(0)
			SmokeLight.Enabled = true
			SmokeLight.LockedToPart = true
			local SmokeThick = Instance.new("ParticleEmitter")
			SmokeThick.Parent = root
			SmokeThick.LightInfluence = 0
			SmokeThick.LightEmission = 1
			SmokeThick.Brightness = 1
			SmokeThick.ZOffset = -2
			SmokeThick.Color = ColorSequence.new(Color3.fromRGB(67, 255, 167))
			SmokeThick.Orientation = Enum.ParticleOrientation.FacingCamera
			SmokeThick.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.0625 * scale, 0),
				NumberSequenceKeypoint.new(0.36, 0.437 * scale, 0.437 * scale),
				NumberSequenceKeypoint.new(1, 8.65 * scale, 0.0625 * scale),
			})
			SmokeThick.Squash = NumberSequence.new(0)
			SmokeThick.Transparency = NumberSequence.new(0)
			SmokeThick.Texture = "rbxassetid://13681590856"
			SmokeThick.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
			SmokeThick.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
			SmokeThick.FlipbookStartRandom = false
			SmokeThick.Lifetime = NumberRange.new(0.4, 0.8)
			SmokeThick.Rate = 50
			SmokeThick.Rotation = NumberRange.new(0, 360)
			SmokeThick.RotSpeed = NumberRange.new(0)
			SmokeThick.Speed = NumberRange.new(0)
			SmokeThick.Enabled = true
			SmokeThick.LockedToPart = true
			instances = {SmokeLight, SmokeThick}
		end
	end
	m.Update = function(dt: number, figure: Model)
		local t = GetOverrideDanceMusicTime()
		animator:Step(t)
		local t2 = t / 0.461
		for _,v in instances do
			v.TimeScale = 0.7 + 0.3 * math.cos(t2 * math.pi * 2)
		end
	end
	m.Destroy = function(figure: Model?)
		animator = nil
		for _,v in instances do v:Destroy() end
		instances = {}
	end
	return m
end)


-- Additional converted R6 animations; kept in this loaded catalog so the UI can discover them.
local R6PoseAliases = {
	Root = "Torso",
	LowerTorso = "Torso",
	UpperTorso = "Torso",
	LeftUpperArm = "Left Arm",
	LeftLowerArm = "Left Arm",
	LeftHand = "Left Arm",
	RightUpperArm = "Right Arm",
	RightLowerArm = "Right Arm",
	RightHand = "Right Arm",
	LeftUpperLeg = "Left Leg",
	LeftLowerLeg = "Left Leg",
	LeftFoot = "Left Leg",
	RightUpperLeg = "Right Leg",
	RightLowerLeg = "Right Leg",
	RightFoot = "Right Leg",
}

local function notifyUser(message)
	if Util and type(Util.Notify) == "function" then
		local ok = pcall(function() Util.Notify(message) end)
		if ok then return end
	end
	warn(message)
end

local function makeR6Compatible(track)
	if type(track) ~= "table" or type(track.Keyframes) ~= "table" then return nil end
	for _, keyframe in track.Keyframes do
		if type(keyframe.Poses) == "table" then
			local merged, order = {}, {}
			for _, pose in keyframe.Poses do
				local target = R6PoseAliases[pose.Name] or pose.Name
				if not merged[target] then
					local copy = table.clone(pose)
					copy.Name = target
					merged[target] = copy
					table.insert(order, target)
				else
					local existing = merged[target]
					if typeof(existing.CFrame) == "CFrame" and typeof(pose.CFrame) == "CFrame" then
						existing.CFrame = existing.CFrame * pose.CFrame
					end
				end
			end
			local poses = {}
			for _, name in order do table.insert(poses, merged[name]) end
			keyframe.Poses = poses
		end
	end
	return track
end

local function addAnimationModule(config)
	AddModule(function()
		local m = {}
		m.NAMShow = true -- explicitly allow this custom animation in AddDance
		m.ModuleType = "DANCE"
		m.Name = config.name
		m.Description = config.description
		m.Assets = {config.asset}
		m.Config = function(parent: GuiBase2d) end

		local animator
		local startedAt = 0
		local duration = 0
		local lastLift = 0
		local rootPart

		local function resetPose(figure: Model?)
			if not figure then return end
			for _, joint in figure:GetDescendants() do
				if joint:IsA("Motor6D") then joint.Transform = CFrame.identity end
			end
		end

		local function releaseLift()
			if rootPart and rootPart.Parent and lastLift ~= 0 then
				rootPart.CFrame = rootPart.CFrame - Vector3.new(0, lastLift, 0)
			end
			lastLift = 0
			rootPart = nil
		end

		m.Init = function(figure: Model)
			animator = nil
			releaseLift()
			resetPose(figure)
			local ok, track = pcall(function()
				return AnimLib.Track.fromfile(AssetGetPathFromFilename(config.asset))
			end)
			if not ok or not track then
				notifyUser("NAM: " .. config.asset .. " could not be read. Wait for the animation conversion workflow to finish.")
				return
			end
			track = makeR6Compatible(track)
			if not track or #track.Keyframes == 0 then
				notifyUser("NAM: " .. config.asset .. " has no usable keyframes.")
				return
			end
			local actualDuration = tonumber(track.Time) or 0
			if actualDuration <= 0 then
				for _, keyframe in track.Keyframes do
					actualDuration = math.max(actualDuration, tonumber(keyframe.Time) or 0)
				end
			end
			if actualDuration <= 0 then
				notifyUser("NAM: " .. config.asset .. " has an invalid duration.")
				return
			end
			duration = actualDuration
			animator = AnimLib.Animator.new()
			animator.rig = figure
			animator.looped = false
			animator.map = nil
			animator.track = track
			rootPart = figure:FindFirstChild("HumanoidRootPart")
			lastLift = 0
			startedAt = os.clock()
		end

		m.Update = function(dt: number, figure: Model)
			if not animator then return end
			local elapsed = os.clock() - startedAt
			if elapsed >= duration then
				animator = nil
				releaseLift()
				resetPose(figure)
				return
			end
			local ok = pcall(function() animator:Step(elapsed) end)
			if not ok then
				animator = nil
				releaseLift()
				resetPose(figure)
				notifyUser("NAM: " .. config.name .. " stopped safely; this rig/animation format is incompatible.")
				return
			end

			-- Smooth lift during the configured central action window.
			if rootPart and rootPart.Parent and config.lift > 0 then
				local progress = math.clamp(elapsed / duration, 0, 1)
				local windowStart, windowEnd = config.liftStart, config.liftEnd
				local lift = 0
				if progress > windowStart and progress < windowEnd then
					local alpha = (progress - windowStart) / (windowEnd - windowStart)
					lift = config.lift * math.sin(math.pi * alpha)
				end
				rootPart.CFrame = rootPart.CFrame + Vector3.new(0, lift - lastLift, 0)
				lastLift = lift
			end
		end

		m.Destroy = function(figure: Model?)
			animator = nil
			releaseLift()
			resetPose(figure)
		end
		return m
	end)
end


addAnimationModule({
	name = "Gojo Awake",
	description = "Gojo awakening animation adapted for R6, with a smooth timed lift.",
	asset = "GojoAwakeTrack.anim",
	lift = 18,
	liftStart = 0.18,
	liftEnd = 0.72,
})

addAnimationModule({
	name = "Gojo 200% Hollow Purple",
	description = "Hollow Purple attack animation adapted for R6.",
	asset = "HollowPurple1Track.anim",
	lift = 0,
	liftStart = 0,
	liftEnd = 0,
})

addAnimationModule({
	name = "Mahoraga Destroy Purple",
	description = "Mahoraga Purple destruction animation adapted for R6, with a smooth timed lift.",
	asset = "MahoragaDestroyPurpleTrack.anim",
	lift = 34,
	liftStart = 0.16,
	liftEnd = 0.82,
})

addAnimationModule({
	name = "Cid Overdrive",
	description = "Cid Overdrive animation adapted for R6.",
	asset = "CidOverdriveTrack.anim",
	lift = 0,
	liftStart = 0,
	liftEnd = 0,
})

return modules
