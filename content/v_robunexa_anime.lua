-- RobuNexa original R6 anime-inspired dances for NAM Reanimate.
-- GitHub .anim files are Base64-encoded native STEVE KeyframeSequence data.
-- Reanim.txt decodes them before writing the local .anim file.
local modules = {}
local ROOT = "https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/0f521269b5a7673857b381d0f93bd62072c86c21/Animations/R6/"

local function addDance(displayName, description, localFile, sourceFile, looped, sourceUrl)
    table.insert(modules, function()
        local m = {}
        m.ModuleType = "DANCE"
        m.Name = displayName
        m.Description = description
        m.Assets = { localFile .. "@" .. (sourceUrl or (ROOT .. sourceFile)) }

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
addDance("RN Anime Run", "Original alternating R6 run cycle.", "RobuNexa_Run.anim", "run.anim", true)
addDance("RN Salute", "Original salute gesture.", "RobuNexa_Salute.anim", "salute.anim", false)
addDance("RN Bow", "Original bow gesture.", "RobuNexa_Bow.anim", "bow.anim", false)
addDance("RN Power Charge", "Original power-up pose loop.", "RobuNexa_PowerCharge.anim", "power_charge.anim", true)
addDance("RN Sword Slash", "Visual slash pose only; no weapon, hitbox or damage.", "RobuNexa_SwordSlash.anim", "sword_slash.anim", false)
addDance("RN Jump Land", "Original jump/landing pose sequence; no root movement.", "RobuNexa_JumpLand.anim", "jump_land.anim", false)
addDance("RN Point", "Original pointing gesture.", "RobuNexa_Point.anim", "point.anim", false)

-- Native binary animation mirrored from the upstream MIT-licensed Uhhhhhh content repository.
-- No third-party music or effects are included.
addDance("Hakari's Dance", "Jujutsu Shenanigans Hakari dance animation (animation only).", "RobuNexa_Hakari.anim", "Hakari.anim", true, "https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/54d3cd54638ad60028dbb4d0a54fe7278704df55/assets/anime/Hakari.anim")

return modules
