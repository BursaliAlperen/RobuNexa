-- NAM curated animation catalog.
-- All uploaded KeyframeSequence assets are converted to AnimLib tracks by GitHub Actions.
local modules = {}
local function AddModule(m) table.insert(modules, m) end

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
		m.Assets = config.sound and {config.asset, config.sound} or {config.asset}
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
			if config.sound then
				local soundOk, soundId = pcall(function()
					return AssetGetContentId(config.sound)
				end)
				if soundOk and soundId then
					pcall(function()
						SetOverrideDanceMusic(soundId, config.name, 1)
					end)
				end
			end
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
				local ramp = math.min(0.12, (windowEnd - windowStart) * 0.25)
				local lift = 0
				if progress >= windowStart and progress <= windowEnd then
					if progress < windowStart + ramp then
						local alpha = math.clamp((progress - windowStart) / ramp, 0, 1)
						local eased = alpha * alpha * (3 - 2 * alpha)
						lift = config.lift * eased
					elseif progress > windowEnd - ramp then
						local alpha = math.clamp((windowEnd - progress) / ramp, 0, 1)
						local eased = alpha * alpha * (3 - 2 * alpha)
						lift = config.lift * eased
					else
						lift = config.lift
					end
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
	name = "Imaginary Purple",
	description = "Hollow Purple attack animation adapted for R6.",
	asset = "HollowPurple1Track.anim",
	sound = "imaginary-hollow-purple_QmAgdbC.mp3",
	lift = 0,
	liftStart = 0,
	liftEnd = 0,
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
