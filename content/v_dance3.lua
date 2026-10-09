-- NAM curated animation catalog
-- Uses the user's uploaded GojoAwaken.anim file from the repository.
local modules = {}
local function AddModule(m) table.insert(modules, m) end

AddModule(function()
	local m = {}
	m.ModuleType = "DANCE"
	m.Name = "Gojo Awake"
	m.Description = "Gojo's uploaded awakening animation (R6)."
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
		local track = AnimLib.Track.fromfile(AssetGetPathFromFilename("GojoAwaken.anim"))
		if not track or type(track.Keyframes) ~= "table" or #track.Keyframes == 0 then
			animator = nil
			Util.Notify("GojoAwaken.anim could not be loaded. Check the downloaded animation file.")
			return
		end
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.looped = false
		animator.track = track
		duration = tonumber(track.Time) or duration
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
		animator:Step(elapsed)
	end
	m.Destroy = function(figure: Model?)
		animator = nil
		resetPose(figure)
	end
	return m
end)

return modules
