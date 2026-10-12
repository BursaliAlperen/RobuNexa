--[[
RobuNexa Reanimation Engine Selector
Choose exactly ONE external engine below. Do not execute this file alongside source/reanim.lua (NAM):
both take ownership of the local character and will conflict.

Engines:
  KRYPTON             - Kade's current/recommended engine; R6/R15 support depends on game/executor.
  GELATEK             - original legacy limb reanimation; upstream says it is unreliable in modern games.
  GELATEK_EDIT        - community fork of GelatekReanimate with additional options.
  CATWARE_LEGACY      - discontinued; kept only for compatibility/testing.

NAM's built-in hat/limb reanimation remains in source/reanim.lua and is NOT an external-engine mode.
Gojo and Sukuna remain separate NAM movesets; this selector does not merge them.
]]

local Global = (getgenv and getgenv()) or shared

-- Change only this value. Never run multiple reanimation engines simultaneously.
local ENGINE = "KRYPTON"

-- Used by CATWARE_LEGACY: "Raw", "Fling", "Bullet", or "Godmode".
local CATWARE_TYPE = "Raw"

-- Used by GELATEK_EDIT.
local GELATEK_EDIT_CONFIG = {
    AnimationsDisabled = false,
    R15ToR6 = false,
    DontBreakHairWelds = true,
    PermanentDeath = true,
    Headless = false,
    TeleportBackWhenVoided = false,
    AlignReanimate = false,
    FullForceAlign = false,
    FasterHeartbeat = false,
    DynamicalVelocity = false,
    DisableTweaks = false,
    OptimizeGame = false,
    LoadLibrary = false,
    DetailedCredits = false,
    TorsoFling = false,
    BulletEnabled = false,
    BulletConfig = {
        RunAfterReanimate = false,
        LockBulletOnTorso = false,
        ElementalCrystalBullet = false,
    },
}

local SOURCES = {
    KRYPTON = "https://raw.githubusercontent.com/KadeTheExploiter/Krypton/main/Module.luau",
    GELATEK = "https://raw.githubusercontent.com/Gelatekussy/GelatekReanimate/main/Main.lua",
    GELATEK_EDIT = "https://raw.githubusercontent.com/InfinityNess/GelatekReanimateEdit/main/Main.lua",
    CATWARE_LEGACY = "https://raw.githubusercontent.com/StrokeThePea/CatwareReanimate/main/src/Source.lua",
}

local function loadRemote(url, label)
    local response = game:HttpGet(url)
    assert(type(response) == "string" and #response > 0, label .. " returned empty source")
    local chunk, compileError = loadstring(response)
    assert(type(chunk) == "function", compileError or (label .. " failed to compile"))
    local ok, result = pcall(chunk)
    assert(ok, label .. " failed to start: " .. tostring(result))
    return result
end

if ENGINE == "KRYPTON" then
    Global.KryptonConfiguration = {
        WaitTime = 0.251,
        FakeRigScale = 1,
        DestroyHeightOffset = 50,
        TeleportOffsetRadius = 20,
        RefitHatCount = 2,
        RigName = "RobuNexa",
        ReturnOnDeath = true,
        Flinging = {
            Enabled = false,
            MethodUsed = "Tool",
            FlingMagnitude = 8000,
        },
        Reclaim = false,
        Refit = true,
        SetCharacter = true,
        Animations = true,
        NoCollisions = true,
        AntiVoiding = false,
        SetSimulationRadius = false,
        DisableCharacterScripts = true,
        AccessoryFallbackDefaults = true,
        OverlayFakeCharacter = false,
        LimitHatsPerLimb = false,
        NoBodyNearby = true,
        PermanentDeath = true,
        Hats = {},
    }
    local ok, err = pcall(loadRemote, SOURCES.KRYPTON, "Krypton")
    if not ok then warn("[RobuNexa] Krypton failed: " .. tostring(err)) end

elseif ENGINE == "GELATEK" then
    Global.GelatekReanimateConfig = {
        AnimationsDisabled = false,
        R15ToR6 = false,
        DontBreakHairWelds = true,
        PermanentDeath = true,
        Headless = false,
        TeleportBackWhenVoided = false,
        AlignReanimate = false,
        FullForceAlign = false,
        FasterHeartbeat = false,
        DynamicalVelocity = false,
        DisableTweaks = false,
        OptimizeGame = false,
        LoadLibrary = false,
        DetailedCredits = false,
        TorsoFling = false,
        BulletEnabled = false,
        BulletConfig = {
            RunAfterReanimate = false,
            LockBulletOnTorso = false,
        },
    }
    local ok, err = pcall(loadRemote, SOURCES.GELATEK, "Gelatek")
    if not ok then warn("[RobuNexa] Gelatek legacy failed: " .. tostring(err)) end

elseif ENGINE == "GELATEK_EDIT" then
    Global.GelatekReanimateConfig = GELATEK_EDIT_CONFIG
    local ok, err = pcall(loadRemote, SOURCES.GELATEK_EDIT, "Gelatek Edit")
    if not ok then warn("[RobuNexa] Gelatek Edit failed: " .. tostring(err)) end

elseif ENGINE == "CATWARE_LEGACY" then
    Global.Options = {
        Jitteryness = Vector3.new(30.5, 0, 0),
        Jitterless = true,
        Type = CATWARE_TYPE,
        InstantBullet = {
            Bool = CATWARE_TYPE == "Bullet" or CATWARE_TYPE == "Godmode",
            SmartLock = true,
        },
        R15Method = "Align",
        R6Method = "Align",
        BonusProperties = true,
        RigAnimations = true,
        LoadLibrary = false,
        Logging = false,
    }
    local ok, err = pcall(loadRemote, SOURCES.CATWARE_LEGACY, "Catware legacy")
    if not ok then warn("[RobuNexa] Catware legacy failed: " .. tostring(err)) end

else
    error("[RobuNexa] Unknown ENGINE '" .. tostring(ENGINE) .. "'. Choose KRYPTON, GELATEK, GELATEK_EDIT, or CATWARE_LEGACY.")
end
