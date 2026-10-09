-- NAM curated animation catalog
-- Gojo Awake loads its animation track from content/Gojo.anim.
local modules = {}
local function AddModule(m) table.insert(modules, m) end

AddModule(function()
	local m = {}
	m.ModuleType = "DANCE"
	m.Name = "Gojo Awake"
	m.Description = "Gojo Awake R6 keyframe animation loaded from Gojo.anim."
	m.Assets = {"Gojo.anim"}
	m.Config = function(parent: GuiBase2d) end

	local animator
	local startedAt = 0
	local function pose(name, cf)
		return {
			Name = name,
			Weight = 1,
			EasingStyle = "Sine",
			EasingDirection = "InOut",
			CFrame = cf,
		}
	end
	local function frame(time, torso, head, leftArm, rightArm, leftLeg, rightLeg)
		return {
			Time = time,
			Poses = {
				pose("Torso", torso),
				pose("Head", head),
				pose("Left Arm", leftArm),
				pose("Right Arm", rightArm),
				pose("Left Leg", leftLeg),
				pose("Right Leg", rightLeg),
			},
		}
	end

	local awakeningTrack = {
		Name = "Gojo Awake",
		Time = 3.2,
		Keyframes = {
			frame(0,
				CFrame.new(0, -0.08, 0) * CFrame.Angles(math.rad(10), 0, 0),
				CFrame.Angles(math.rad(18), math.rad(-4), 0),
				CFrame.Angles(math.rad(12), 0, math.rad(-10)),
				CFrame.Angles(math.rad(-92), 0, math.rad(34)),
				CFrame.identity, CFrame.identity),
			frame(0.65,
				CFrame.new(0, 0.02, 0) * CFrame.Angles(math.rad(-4), 0, 0),
				CFrame.Angles(math.rad(-12), math.rad(6), 0),
				CFrame.Angles(math.rad(-18), 0, math.rad(-24)),
				CFrame.Angles(math.rad(-125), 0, math.rad(18)),
				CFrame.identity, CFrame.identity),
			frame(1.45,
				CFrame.new(0, 0.08, 0) * CFrame.Angles(math.rad(-8), 0, 0),
				CFrame.Angles(math.rad(-6), math.rad(8), 0),
				CFrame.Angles(math.rad(-82), 0, math.rad(-62)),
				CFrame.Angles(math.rad(-78), 0, math.rad(62)),
				CFrame.Angles(math.rad(-4), 0, math.rad(-3)),
				CFrame.Angles(math.rad(-4), 0, math.rad(3))),
			frame(2.25,
				CFrame.new(0, 0.12, 0) * CFrame.Angles(math.rad(4), 0, 0),
				CFrame.Angles(math.rad(4), math.rad(-8), 0),
				CFrame.Angles(math.rad(-128), 0, math.rad(-24)),
				CFrame.Angles(math.rad(-150), 0, math.rad(32)),
				CFrame.identity, CFrame.identity),
			frame(3.2,
				CFrame.new(0, 0.04, 0) * CFrame.Angles(math.rad(-2), 0, 0),
				CFrame.Angles(math.rad(-4), math.rad(5), 0),
				CFrame.Angles(math.rad(-38), 0, math.rad(-52)),
				CFrame.Angles(math.rad(-118), 0, math.rad(12)),
				CFrame.identity, CFrame.identity),
		},
	}

	m.Init = function(figure: Model)
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.looped = false
		animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("Gojo.anim")) or awakeningTrack
		startedAt = os.clock()
	end
	local function resetPose(figure: Model?)
		if not figure then return end
		for _, joint in figure:GetDescendants() do
			if joint:IsA("Motor6D") then joint.Transform = CFrame.identity end
		end
	end
	m.Update = function(dt: number, figure: Model)
		if not animator then return end
		local elapsed = os.clock() - startedAt
		if elapsed >= (animator.track and animator.track.Time or awakeningTrack.Time) then
			animator = nil
			resetPose(figure)
			return
		end
		animator:Step(elapsed)
	end
	m.Destroy = function(figure: Model?)
		animator = nil
		resetPose(figure)
	end
	return m
end)

return modules
