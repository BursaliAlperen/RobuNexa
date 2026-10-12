--[[
RobuNexa Reanimation Engine Selector
Primary: KadeTheExploiter/Krypton (PermanentDeath enabled)
Legacy option: Gelatekussy/GelatekReanimate (not recommended for modern games)
IMPORTANT: Run only one reanimation engine at a time. Do not execute this alongside
source/reanim.lua/NAM because both systems take ownership of the character rig.
This selector is a standalone engine entrypoint; NAM moveset API compatibility is not automatic.
]]
local Global = (getgenv and getgenv()) or shared

local ENGINE = "KRYPTON" -- "KRYPTON" or "GELATEK_LEGACY"

if ENGINE == "KRYPTON" then
	-- Based on Kade's published configuration; keep fling disabled because its README
	-- labels the flinging subsystem unfinished.
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
	local ok, err = pcall(function()
		local source = game:HttpGet("https://raw.githubusercontent.com/KadeTheExploiter/Krypton/main/Module.luau")
		assert(type(source) == "string" and #source > 0, "Krypton download returned empty source")
		local fn, compileError = loadstring(source)
		assert(fn, compileError or "Krypton compile failed")
		fn()
	end)
	if not ok then
		warn("[RobuNexa] Krypton failed to start: " .. tostring(err))
	end
elseif ENGINE == "GELATEK_LEGACY" then
	-- Legacy compatibility option only. Upstream warns this no longer functions
	-- reliably in modern games; use Krypton unless testing an older place.
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
	local ok, err = pcall(function()
		local source = game:HttpGet("https://raw.githubusercontent.com/Gelatekussy/GelatekReanimate/main/Main.lua")
		assert(type(source) == "string" and #source > 0, "Gelatek download returned empty source")
		local fn, compileError = loadstring(source)
		assert(fn, compileError or "Gelatek compile failed")
		fn()
	end)
	if not ok then
		warn("[RobuNexa] Legacy Gelatek failed to start: " .. tostring(err))
	end
else
	error("Unknown ENGINE. Choose KRYPTON or GELATEK_LEGACY.")
end
