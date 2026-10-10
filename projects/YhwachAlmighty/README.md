# Yhwach — The Almighty

A mobile-friendly Yhwach-themed animation and visual-control starter for a Roblox experience you own. The project includes a dark violet UI, a local animation controller, an accessory manifest, a safe pose tween helper, and six source animation files.

## Files

- `YhwachUI.client.lua` — responsive GUI; emits local action requests and displays controller status.
- `AlmightyController.client.lua` — loads published Roblox animations and optional sounds; stops tracks on reset/respawn.
- `AccessoryConfig.lua` — ModuleScript containing sequence-name, animation-ID fallback, sound, and catalog-reference configuration.
- `AnimLib.lua` — Studio-safe local player that parses Uhhhhhh-style binary .anim data or native KeyframeSequence instances, interpolates poses, and applies them to Motor6D.Transform.
- `HatAnimation.lua` — ModuleScript for posing an accessory already equipped on the character.
- `YhwachMoveset.lua` — standalone all-in-one alternative. **Do not install this together with the modular UI/controller**, or you will get duplicate interfaces.

## Recommended Studio setup

In an experience you own, place these four scripts under `StarterPlayer > StarterPlayerScripts`:

| File | Roblox instance type |
|---|---|
| `YhwachUI.client.lua` | LocalScript |
| `AlmightyController.client.lua` | LocalScript |
| `AccessoryConfig.lua` | ModuleScript |
| `AnimLib.lua` | ModuleScript |
| `HatAnimation.lua` | ModuleScript |

Keep the instance names exact: `YhwachUI.client`, `AlmightyController.client`, `AccessoryConfig`, and `HatAnimation`. The controller listens to the UI's local `ActionRequested` event and reports playback/errors back through `StatusChanged`.

## Playing the repository's original binary .anim files

The controller now supports a `YhwachAnimData` Folder beside the LocalScripts. For each move, put a ModuleScript in that folder with the exact name below; have the ModuleScript return a table containing a Base64 string:

- `AlmightyAwake`
- `AlmightyAura`
- `AlmightySlash`
- `Auswahlen`
- `BlutVeneAnhaben`
- `Sklaverei`

Example ModuleScript body: `return { Base64 = "PASTE_BASE64_HERE" }`. Encode the original binary `.anim` file as Base64 without changing its bytes. The controller decodes it and passes the raw bytes to `AnimLib.Track.frombuffer()`, which reads the same field order used by Uhhhhhh: animation name, keyframe count, timestamp, pose count, pose name, weight, easing style/direction, and twelve CFrame floats. The raw file itself must not be pasted as ordinary text.

The controller checks binary ModuleScripts first, then native KeyframeSequences in `YhwachSequences`, then published AnimationIds as a fallback. Use one data source per move to avoid confusing duplicates.

## Native keyframe playback (AnimLib)

The controller checks for a Folder named `YhwachSequences` beside the scripts. Put Roblox `KeyframeSequence` instances inside it using the exact names below:

- `AlmightyAwake`
- `AlmightyAura`
- `AlmightySlash`
- `Auswahlen`
- `BlutVeneAnhaben`
- `Sklaverei`

When a matching sequence exists, the controller plays it with `AnimLib.lua` locally and does not require a published AnimationId for that move. The player interpolates keyframe poses and applies them to matching `Motor6D` joints. Stopping playback restores the joint transforms captured when the sequence was loaded.

**Important:** this player consumes actual Roblox `KeyframeSequence` instances. It does not yet decode Uhhhhhh's private/binary `.anim` format directly. Raw files in `Assets/Animations` are not automatically turned into instances by Roblox Studio. You must convert/import each source into a valid KeyframeSequence first, then add it to `YhwachSequences`. If no matching sequence is found, the controller falls back to `Config.AnimationIds`.

This is a local visual animation player for a Studio experience you own. Local `Motor6D.Transform` edits are not guaranteed to replicate to other players. The custom player is intentionally not an executor or permission bypass.

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
