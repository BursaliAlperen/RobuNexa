-- Yhwach Almighty accessory manifest.
-- Intended for an experience you own. Catalog IDs are references; this file does not bypass asset permissions.
local Config = {}

Config.BaseAccessories = {
	{ name = "Literal Hammer Head [White]", assetId = 87291559615126, slot = "Neck" },
	{ name = "Thin Hammer Head [White]", assetId = 128893482026011, slot = "Neck" },
	{ name = "Thin Hammer Head [Black]", assetId = 120111604252410, slot = "Neck" },
	{ name = "Hammer Head", assetId = 90788603154080, slot = "Neck" },
	{ name = "Unverified Lay Rig Piece", assetId = 88886554182275, slot = "Unverified" },
}

Config.AlmightyAccessories = {
	{ name = "Yhwach Reishi Sword", assetId = 108684178086287, slot = "Back" },
	{ name = "Yhwach Almighty King Hair", assetId = 75672773594451, slot = "Hair" },
	{ name = "Related Set Item A", assetId = 83293970715566, slot = "Unverified" },
	{ name = "Related Set Item B", assetId = 122497534796344, slot = "Unverified" },
	{ name = "Related Set Item C", assetId = 104304509923191, slot = "Unverified" },
	{ name = "Soul King Almighty Aura", assetId = 87969060185631, slot = "Back" },
	{ name = "Aura B", assetId = 100693570818976, slot = "Unverified" },
	-- 83293970715566 was supplied twice; kept once in the executable config to avoid double-equipping.
}

-- Fill these with Roblox-published Animation asset IDs after importing each .anim file.
Config.AnimationIds = {
	BaseIdle = "",
	AlmightyAwakening = "",
	AlmightyIdle = "",
	HatPose = "",
	FormReturn = "",
}

-- Fill with uploaded Roblox audio asset IDs; raw MP3 files cannot be played directly by SoundId.
Config.SoundIds = {
	Awakening = "",
	AlmightyLoop = "",
	AuraOn = "",
	AuraOff = "",
	FormReturn = "",
}

return Config
