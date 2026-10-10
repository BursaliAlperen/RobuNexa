-- RobuNexa Syntax Reanimate (upstream pinned to 6085ed1cbfe47e837b4a9d8a48f0828525fc42eb)
-- R6/R15 support. Bullet/range-fling code is retained; it is not auto-triggered.
-- External LoadLibrary is disabled to avoid running an additional remote script.
local env = (getgenv and getgenv()) or shared or _G
if env.RobuNexaSyntaxRunning then
    warn("[RobuNexa] Syntax Reanimate is already running; respawn before restarting.")
    return
end
if (env.UhhhhhhLoaded or _G.UhhhhhhLoaded or env.NAMLoaded or _G.NAMLoaded)
    and not env.RobuNexaAllowSyntaxFromNAM then
    warn("[RobuNexa] NAM is active. Start Syntax from the RobuNexa menu.")
    return
end
if not game:IsLoaded() then game.Loaded:Wait() end
local priorSettings = env.Settings
local syntaxSettings = {
    VelocityForce = 10,
    AntiSleepForce = 1,
    DisableMovementVelocity = false,
    SingleThread = true,
    AntiVoid = true,
    LoadLibrary = false,
    R15ToR6 = false,
    EnableAnims = true,
    FullNoclip = false,
    KeepWeldedHair = true,
    HeadMovementMethod = false,
    -- Keep the upstream bullet/range-fling feature available; activation is manual.
    Bullet = true,
    BulletOnLoad = true,
    RainbowFlingPart = false,
    FlingHat = "",
}
env.Settings = syntaxSettings
Settings = syntaxSettings
local url = "https://raw.githubusercontent.com/Memeboiyot/Syntax-Reanimate/6085ed1cbfe47e837b4a9d8a48f0828525fc42eb/main.lua"
local ok, source = pcall(function() return game:HttpGet(url) end)
if not ok or type(source) ~= "string" or #source < 10000 then
    env.Settings = priorSettings
    Settings = priorSettings
    warn("[RobuNexa] Could not download Syntax Reanimate.")
    return
end
local compiled, chunk = pcall(loadstring, source)
if not compiled or type(chunk) ~= "function" then
    env.Settings = priorSettings
    Settings = priorSettings
    warn("[RobuNexa] Syntax source could not be compiled.")
    return
end
env.RobuNexaSyntaxRunning = true
local ran, err = pcall(chunk)
if not ran then
    env.RobuNexaSyntaxRunning = nil
    warn("[RobuNexa] Syntax Reanimate failed: " .. tostring(err))
end
