-- NAM curated animation catalog
local modules = {}
local function AddModule(m) table.insert(modules, m) end
AddModule(function()
	local m = {}
	m.ModuleType = "DANCE"
	m.Name = "Gojo Awake"
	m.Description = "Gojo Awake animation"
	m.Assets = {"GojoAwake.anim"}
	m.Config = function(parent: GuiBase2d) end
	local animator
	local startedAt = 0
	m.Init = function(figure: Model)
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.looped = false
		animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("GojoAwake.anim"))
		startedAt = os.clock()
	end
	m.Update = function(dt: number, figure: Model)
		if animator then animator:Step(os.clock() - startedAt) end
	end
	m.Destroy = function(figure: Model?) animator = nil end
	return m
end)
return modules
