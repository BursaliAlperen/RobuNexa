# Yhwach — The Almighty

A mobile-friendly Yhwach-themed animation and visual-control starter for a Roblox experience you own. The project includes a dark violet UI, a local animation controller, an accessory manifest, a safe pose tween helper, and six source animation files.

## Files

- `YhwachUI.client.lua` — responsive GUI; emits local action requests and displays controller status.
- `AlmightyController.client.lua` — loads published Roblox animations and optional sounds; stops tracks on reset/respawn.
- `AccessoryConfig.lua` — ModuleScript containing animation, sound, and catalog-reference configuration.
- `HatAnimation.lua` — ModuleScript for posing an accessory already equipped on the character.
- `YhwachMoveset.lua` — standalone all-in-one alternative. **Do not install this together with the modular UI/controller**, or you will get duplicate interfaces.

## Recommended Studio setup

In an experience you own, place these four scripts under `StarterPlayer > StarterPlayerScripts`:

| File | Roblox instance type |
|---|---|
| `YhwachUI.client.lua` | LocalScript |
| `AlmightyController.client.lua` | LocalScript |
| `AccessoryConfig.lua` | ModuleScript |
| `HatAnimation.lua` | ModuleScript |

Keep the instance names exact: `YhwachUI.client`, `AlmightyController.client`, `AccessoryConfig`, and `HatAnimation`. The controller listens to the UI's local `ActionRequested` event and reports playback/errors back through `StatusChanged`.

## Animation setup

Six source animations are present in `Assets/Animations`:

| Source file | Config key | Intended action |
|---|---|---|
| `AlmightyAwake.anim` | `AlmightyAwakening` | Awakening sequence |
| `AlmightyAura.anim` | `AlmightyAura` | Looping Almighty pose |
| `AlmightySlash.anim` | `AlmightySlash` | Move 1 |
| `Auswählen.anim` | `Auswahlen` | Move 2 |
| `Blut Vene Anhaben.anim` | `BlutVeneAnhaben` | Move 3 |
| `Sklaverei .anim` | `Sklaverei` | Move 4 |

Roblox cannot play a GitHub `.anim` file directly by filename. Import each source into Roblox Studio using the supported Animation Editor workflow, publish it for the correct owner/experience, then replace the empty values in `Config.AnimationIds` with the published `rbxassetid://...` IDs. Use the same rig type the animations were authored for (R6 or R15).

The UI shows missing animation IDs and load failures in its footer. An animation may still fail if its asset is private, owned by another account/group, uploaded for the wrong rig, or unavailable to the experience.

## Audio setup

No audio source files are currently present in `Assets/Audio`; it only contains a placeholder note. Upload audio you own or have permission to use, then fill `Config.SoundIds` with the published Roblox audio IDs. Empty sound IDs are skipped with a warning.

## Accessory references and limits

The IDs in `Config.BaseAccessories` and `Config.AlmightyAccessories` are catalog references only; they do not automatically equip items. The accessory pose helper only animates a matching accessory already equipped on the local character. This project does not use executor-based reanimation, bypass Roblox permissions, or guarantee that local visual changes replicate to other players.

## Included catalog references

### Base set
- `87291559615126` — Literal Hammer Head [White]
- `128893482026011` — Thin Hammer Head [White]
- `120111604252410` — Thin Hammer Head [Black]
- `90788603154080` — Hammer Head
- `88886554182275` — user-supplied, exact item metadata unverified

### Almighty set
- `108684178086287` — Yhwach Reishi Sword
- `75672773594451` — Yhwach Bleach TYBW Almighty King Hair
- `83293970715566`, `122497534796344`, `104304509923191` — related item references, metadata unverified
- `87969060185631` — Soul King Almighty Aura
- `100693570818976` — Aura B, metadata unverified

## Current status

The modular UI and controller are connected. Actual animation playback requires the source animations to be published and their IDs entered in `AccessoryConfig.lua`. The audio placeholders are empty, and accessory auto-equipping/custom particle VFX are not implemented yet.
