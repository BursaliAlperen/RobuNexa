-- NAM'S AIZEN configuration
-- Place this ModuleScript at ReplicatedStorage/NAMS_AIZEN/Config

local Config = {}

Config.AnimationFolderName = "Animations"
Config.Actions = {
    Idle = { looped = true, priority = Enum.AnimationPriority.Idle },
    Walk = { looped = true, priority = Enum.AnimationPriority.Movement },
    Run = { looped = true, priority = Enum.AnimationPriority.Movement },
    M1_1 = { looped = false, priority = Enum.AnimationPriority.Action },
    M1_2 = { looped = false, priority = Enum.AnimationPriority.Action },
    M1_3 = { looped = false, priority = Enum.AnimationPriority.Action },
    M1_4 = { looped = false, priority = Enum.AnimationPriority.Action },
    Skill_1 = { looped = false, priority = Enum.AnimationPriority.Action },
    Skill_2 = { looped = false, priority = Enum.AnimationPriority.Action },
    Domain = { looped = false, priority = Enum.AnimationPriority.Action4 },
}

Config.FadeTime = 0.12
Config.MovementThreshold = 0.5
Config.RunThreshold = 14
Config.DefaultWalkSpeed = 16
Config.RunWalkSpeed = 22
Config.EnableMobileTestUI = true

return Config