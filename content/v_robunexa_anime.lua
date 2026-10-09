-- RobuNexa original R6 anime-inspired dances for NAM Reanimate.
-- GitHub .anim files are Base64-encoded native STEVE KeyframeSequence data.
-- Reanim.txt decodes them before writing the local .anim file.
local modules = {}
local ROOT = "https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/robunexa-nam-adaptation/Animations/R6/"

local function addDance(displayName, description, localFile, sourceFile, looped)
    table.insert(modules, function()
        local m = {}
        m.ModuleType = "DANCE"
        m.Name = displayName
        m.Description = description
        m.Assets = { localFile .. "@" .. ROOT .. sourceFile }

        local animator
        local startedAt = 0
        m.Config = function(parent: GuiBase2d) end

        m.Init = function(figure: Model)
            animator = AnimLib.Animator.new()
            animator.rig = figure
            animator.looped = looped
            animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename(localFile))
            startedAt = os.clock()
        end

        m.Update = function(dt: number, figure: Model)
            if animator then animator:Step(os.clock() - startedAt) end
        end

        m.Destroy = function(figure: Model?)
            animator = nil
        end
        return m
    end)
end

addDance("RN Anime Idle", "Original subtle R6 idle loop.", "RobuNexa_Idle.anim", "idle.anim", true)
addDance("RN Anime Walk", "Original R6 walk cycle.", "RobuNexa_Walk.anim", "walk.anim", true)
addDance("RN Wave", "Original greeting wave.", "RobuNexa_Wave.anim", "wave.anim", false)
addDance("RN Anime Guard", "Original defensive anime-inspired pose loop.", "RobuNexa_AnimeGuard.anim", "anime_guard.anim", true)
addDance("RN Anime Dash", "Forward-lean pose only; does not propel the character.", "RobuNexa_Dash.anim", "dash.anim", false)
addDance("RN Victory Pose", "Original celebratory pose.", "RobuNexa_Victory.anim", "victory_pose.anim", false)
addDance("RN Anime Punch", "Visual punch animation only; no hitbox or damage.", "RobuNexa_Punch.anim", "punch.anim", false)
addDance("RN Spin Kick", "Visual spin-kick animation only; no hitbox or damage.", "RobuNexa_SpinKick.anim", "spin_kick.anim", false)

return modules
