-- NAM curated animation catalog
-- Gojo Awake supports R6 by collapsing common R15 limb pose names to R6 joints.
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

local function makeR6Compatible(track)
	if type(track) ~= "table" or type(track.Keyframes) ~= "table" then return nil end
	for _, keyframe in track.Keyframes do
		if type(keyframe.Poses) == "table" then
			local merged = {}
			local order = {}
			for _, pose in keyframe.Poses do
				local target = R6PoseAliases[pose.Name] or pose.Name
				if not merged[target] then
					local copy = table.clone(pose)
					copy.Name = target
					merged[target] = copy
					table.insert(order, target)
				else
					-- R15 upper/lower limb joints collapse into one R6 limb.
					-- Compose their offsets so the major movement is retained.
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

AddModule(function()
	local m = {}
	m.ModuleType = "DANCE"
	m.Name = "Gojo Awake"
	m.Description = "Gojo awakening animation, adapted for R6 rigs."
	m.Assets = {"GojoAwaken.anim"}
	m.Config = function(parent: GuiBase2d) end

	local animator
	local startedAt = 0
	local duration = 3.2
	local function resetPose(figure: Model?)
		if not figure then return end
		for _, joint in figure:GetDescendants() do
			if joint:IsA("Motor6D") then joint.Transform = CFrame.identity end
		end
	end

	m.Init = function(figure: Model)
		animator = nil
		resetPose(figure)
		local ok, track = pcall(function()
			return AnimLib.Track.fromfile(AssetGetPathFromFilename("GojoAwaken.anim"))
		end)
		if not ok or not track then
			Util.Notify("NAM: GojoAwaken.anim could not be read.")
			return
		end
		track = makeR6Compatible(track)
		if not track or #track.Keyframes == 0 then
			Util.Notify("NAM: GojoAwaken.anim has no usable keyframes.")
			return
		end
		local actualDuration = tonumber(track.Time)
		if not actualDuration or actualDuration <= 0 then
			for _, keyframe in track.Keyframes do
				actualDuration = math.max(actualDuration or 0, tonumber(keyframe.Time) or 0)
			end
		end
		if not actualDuration or actualDuration <= 0 then
			Util.Notify("NAM: GojoAwaken.anim has an invalid duration.")
			return
		end
		duration = actualDuration
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.looped = false
		animator.track = track
		startedAt = os.clock()
	end
	m.Update = function(dt: number, figure: Model)
		if not animator then return end
		local elapsed = os.clock() - startedAt
		if elapsed >= duration then
			animator = nil
			resetPose(figure)
			return
		end
		local ok = pcall(function() animator:Step(elapsed) end)
		if not ok then
			animator = nil
			resetPose(figure)
			Util.Notify("NAM: Gojo Awake stopped safely; this rig/animation format is incompatible.")
		end
	end
	m.Destroy = function(figure: Model?)
		animator = nil
		resetPose(figure)
	end
	return m
end)

return modules
