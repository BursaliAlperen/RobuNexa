-- Yhwach Almighty accessory manifest.
-- Catalog IDs are references only; equip items only through supported experience APIs.
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
}

-- Source files live in Assets/Animations. Roblox cannot play .anim files from GitHub:
-- import/publish each one and replace the blank value with its published Animation ID.
Config.AnimationIds = {
	AlmightyAwakening = "", -- AlmightyAwake.anim
	AlmightyAura = "",      -- AlmightyAura.anim; looping aura/form pose
	AlmightySlash = "",     -- AlmightySlash.anim
	Auswahlen = "",         -- Auswählen.anim
	BlutVeneAnhaben = "",   -- Blut Vene Anhaben.anim
	Sklaverei = "",         -- Sklaverei .anim
}

-- MP3 source files likewise need to be uploaded to Roblox before playback.
Config.SoundIds = {
	Awakening = "",
	AlmightyLoop = "",
	AuraOn = "",
	AuraOff = "",
	FormReturn = "",
}

return Config
