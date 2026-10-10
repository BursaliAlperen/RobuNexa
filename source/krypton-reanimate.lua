-- RobuNexa optional reanimation: Krypton 1.8 (pinned upstream commit).
-- Upstream: https://github.com/KadeTheExploiter/Krypton
-- Safe defaults: flinging and permanent death are disabled.
local env = (getgenv and getgenv()) or shared or _G
if env.RobuNexaKryptonRunning then
    warn("[RobuNexa] Krypton is already running.")
    return
end
if (env.UhhhhhhLoaded or _G.UhhhhhhLoaded or env.NAMLoaded or _G.NAMLoaded)
    and not env.RobuNexaAllowKryptonFromNAM then
    warn("[RobuNexa] NAM is active. Stop it and respawn before switching.")
    return
end
if not game:IsLoaded() then game.Loaded:Wait() end
env.KryptonConfiguration = {
    WaitTime = 0.251,
    FakeRigScale = 1,
    DestroyHeightOffset = 50,
    TeleportOffsetRadius = 20,
    RefitHatCount = 2,
    RigName = "RobuNexaKrypton",
    ReturnOnDeath = true,
    Flinging = {
        Flinging = false,
        Enabled = false,
        MethodUsed = "Tool",
        Velocity = 8000,
    },
    Reclaim = false,
    Refit = false,
    SetCharacter = true,
    Animations = true,
    NoCollisions = true,
    AntiVoiding = false,
    SetSimulationRadius = false,
    DisableCharacterScripts = true,
    AccessoryFallbackDefaults = true,
    OverlayFakeCharacter = false,
    LimitHatsPerLimb = false,
    NoBodyNearby = false,
    PermanentDeath = false,
    Hats = {},
}
local url = "https://raw.githubusercontent.com/KadeTheExploiter/Krypton/46caefc79b80565df65bbaa987d5b89caaec5d29/Module.luau"
local ok, source = pcall(function() return game:HttpGet(url) end)
if not ok or type(source) ~= "string" or #source < 1000 then
    warn("[RobuNexa] Could not download Krypton. NAM was not changed.")
    return
end
local compiled, chunk = pcall(loadstring, source)
if not compiled or type(chunk) ~= "function" then
    warn("[RobuNexa] Krypton source could not be compiled.")
    return
end
env.RobuNexaKryptonRunning = true
local ran, result = pcall(chunk)
if not ran then
    env.RobuNexaKryptonRunning = nil
    warn("[RobuNexa] Krypton failed: " .. tostring(result))
end
