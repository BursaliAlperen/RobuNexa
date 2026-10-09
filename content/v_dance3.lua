-- NAM curated animation catalog
-- Self-contained Gojo Awake animation: no external .anim asset required.
local modules = {}
local function AddModule(m) table.insert(modules, m) end

AddModule(function()
	local m = {}
	m.ModuleType = "DANCE"
	m.Name = "Gojo Awake"
	m.Description = "A short anime-style awakening pose sequence for R6."
	m.Assets = {}
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
				CFrame.new(0, -0.08, 0) * CFrame.Angles(math.rad(8), 0, 0),
				CFrame.Angles(math.rad(12), 0, 0),
				CFrame.Angles(math.rad(12), 0, math.rad(-12)),
				CFrame.Angles(math.rad(12), 0, math.rad(12)),
				CFrame.identity, CFrame.identity),
			frame(0.65,
				CFrame.new(0, 0.02, 0) * CFrame.Angles(math.rad(-5), 0, 0),
				CFrame.Angles(math.rad(-10), 0, 0),
				CFrame.Angles(math.rad(-20), 0, math.rad(-38)),
				CFrame.Angles(math.rad(-20), 0, math.rad(38)),
				CFrame.identity, CFrame.identity),
			frame(1.45,
				CFrame.new(0, 0.08, 0) * CFrame.Angles(math.rad(-8), 0, 0),
				CFrame.Angles(math.rad(-8), math.rad(5), 0),
				CFrame.Angles(math.rad(-95), 0, math.rad(-22)),
				CFrame.Angles(math.rad(-95), 0, math.rad(22)),
				CFrame.Angles(math.rad(-4), 0, math.rad(-3)),
				CFrame.Angles(math.rad(-4), 0, math.rad(3))),
			frame(2.25,
				CFrame.new(0, 0.12, 0) * CFrame.Angles(math.rad(4), 0, 0),
				CFrame.Angles(math.rad(4), math.rad(-8), 0),
				CFrame.Angles(math.rad(-150), 0, math.rad(-16)),
				CFrame.Angles(math.rad(-150), 0, math.rad(16)),
				CFrame.identity, CFrame.identity),
			frame(3.2,
				CFrame.new(0, 0.04, 0) * CFrame.Angles(math.rad(-2), 0, 0),
				CFrame.Angles(math.rad(-4), math.rad(5), 0),
				CFrame.Angles(math.rad(-48), 0, math.rad(-48)),
				CFrame.Angles(math.rad(-48), 0, math.rad(48)),
				CFrame.identity, CFrame.identity),
		},
	}

	m.Init = function(figure: Model)
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.looped = false
		animator.track = awakeningTrack
		startedAt = os.clock()
	end
	m.Update = function(dt: number, figure: Model)
		if animator then animator:Step(os.clock() - startedAt) end
	end
	m.Destroy = function(figure: Model?) animator = nil end
	return m
end)

return modules
