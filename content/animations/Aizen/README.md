# Aizen TYBW — R6 animation assets

This moveset is intentionally **R6-only** and uses local NAM/AnimLib `.anim` files plus catalog accessories. It does not implement R15 support, damage, hitboxes, or VFX.

Convert/upload R6-compatible animation files with these exact names:

- `ChairIdle.anim` — seated intro pose
- `StandUp.anim` — automatic awakening / stand-up transition
- `Idle.anim` — awakened idle loop
- `Walk.anim` — awakened walk loop
- `KyokaSuigetsu.anim` — Kyoka Suigetsu ability animation
- `Hado90.anim` — Hado 90 ability animation
- `FlashStep.anim` — Flash Step animation
- `Butterfly.anim` — optional butterfly/idle animation

Expected directory: `content/animations/Aizen/`

The moveset references these raw URLs through its `Assets` list. The animation files themselves must be valid NAM/AnimLib `.anim` text files. Do not rename an R15 animation to R6; use an R6 rig's keyframe sequence.

Accessory IDs currently configured:
- Chair: `103501121910392`
- Aizen Goryutenmetsu back accessory: `114712538192357`
- Purple Sparkling Aura: `83002193396907`
- Aizen TYBW 3D head item: `96379261062372`
- `106080031550988`: type not verified; intentionally not auto-equipped.

Roblox may block `InsertService:LoadAsset` for some catalog assets or executor contexts. A successful GitHub commit does not prove the game client can load every catalog asset.
