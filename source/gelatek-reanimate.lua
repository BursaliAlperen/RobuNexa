-- RobuNexa: optional second reanimation (Gelatek Reanimate fork)
-- Separate from source/reanim.lua. DO NOT run this together with NAM Reanimate.
-- Upstream: https://github.com/InfinityNess/GelatekReanimateEdit
-- Pinned source commit: 36d157beb69760a4878bd97e84e9b785958e1a15
-- License/credits: see upstream LICENSE.md; Gelatek and contributors retain ownership.
--
-- Start with conservative settings. Keep PermanentDeath, flinging, optimizer,
-- headless mode and extra LoadLibrary disabled unless you deliberately need them.
-- This requires an executor that supports game:HttpGet and loadstring.

local Global = (getgenv and getgenv()) or shared

if Global.RobuNexaGelatekRunning then
    warn("[RobuNexa] Gelatek Reanimate is already running.")
    return
end

if (Global.UhhhhhhLoaded or _G.UhhhhhhLoaded) and not Global.RobuNexaAllowGelatekFromNAM then
    warn("[RobuNexa] NAM Reanimate appears to be active. Stop it and respawn before switching.")
    return
end

Global.GelatekReanimateConfig = {
    AnimationsDisabled = false,
    R15ToR6 = false,
    DontBreakHairWelds = false,
    PermanentDeath = false,
    Headless = false,
    TeleportBackWhenVoided = false,

    AlignReanimate = false,
    FullForceAlign = false,
    FasterHeartbeat = false,
    DynamicalVelocity = false,
    DisableTweaks = false,

    OptimizeGame = false,
    LoadLibrary = false,
    DetailedCredits = true,

    TorsoFling = false,
    BulletEnabled = false,
    BulletConfig = {
        RunAfterReanimate = false,
        LockBulletOnTorso = false,
        ElementalCrystalBullet = false,
    },
}

local sourceUrl = "https://raw.githubusercontent.com/InfinityNess/GelatekReanimateEdit/36d157beb69760a4878bd97e84e9b785958e1a15/Main.lua"

local ok, source = pcall(function()
    return game:HttpGet(sourceUrl)
end)
if not ok or type(source) ~= "string" or #source < 1000 then
    warn("[RobuNexa] Could not download the pinned Gelatek source. NAM was not changed.")
    return
end

local compileOk, chunk = pcall(loadstring, source)
if not compileOk or type(chunk) ~= "function" then
    warn("[RobuNexa] Gelatek source could not be compiled. NAM was not changed.")
    return
end

Global.RobuNexaGelatekRunning = true
local runOk, runErr = pcall(chunk)
if not runOk then
    Global.RobuNexaGelatekRunning = nil
    warn("[RobuNexa] Gelatek failed to start: " .. tostring(runErr))
end
