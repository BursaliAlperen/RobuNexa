-- RobuNexa original R6 anime-inspired dances for NAM Reanimate.
-- The .anim files in this repository are Base64-encoded native STEVE KeyframeSequence files.
-- Reanim.txt decodes them before saving to NAMReanim/Content/Anims/.
local modules = {}

local ROOT = "https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/robunexa-nam-adaptation/Animations/R6/"

local function addDance(displayName, description, fileName, looped)
    table.insert(modules, function()
        local m = {}
        m.ModuleType = "DANCE"
        m.Name = displayName
        m.Description = description
        m.Assets = {
            fileName .. "@" .. ROOT .. fileName:gsub("%.anim$", ".anim")
        }

        local animator
        local startedAt = 0

        m.Config = function(parent: GuiBase2d)
        end

        m.Init = function(figure: Model)
            animator = AnimLib.Animator.new()
            animator.rig = figure
            animator.looped = looped
            animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename(fileName))
            startedAt = os.clock()
        end

        m.Update = function(dt: number, figure: Model)
            if animator then
                animator:Step(os.clock() - startedAt)
            end
        end

        m.Destroy = function(figure: Model?)
            animator = nil
        end

        return m
    end)
end

addDance("RN Anime Idle", "Original subtle R6 idle loop.", "idle.anim", true)
addDance("RN Anime Walk", "Original R6 walk cycle.", "walk.anim", true)
addDance("RN Wave", "Original greeting wave.", "wave.anim", false)
addDance("RN Anime Guard", "Original defensive anime-inspired pose loop.", "anime_guard.anim", true)
addDance("RN Anime Dash", "Original forward-lean dash pose; does not propel the character.", "dash.anim", false)
addDance("RN Victory Pose", "Original celebratory pose.", "victory_pose.anim", false)
addDance("RN Anime Punch", "Original punch pose; visual animation only, no hitbox or damage.", "punch.anim", false)
addDance("RN Spin Kick", "Original spin-kick pose; visual animation only, no hitbox or damage.", "spin_kick.anim", false)

return modules
