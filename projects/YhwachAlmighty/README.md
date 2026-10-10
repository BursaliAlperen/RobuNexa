# Yhwach — The Almighty

A mobile-first Yhwach-themed Roblox character presentation starter for an experience you own. Includes the dark-glass GUI, accessory manifest, a safe accessory-handle pose tween module, and a local controller scaffold for published animation/audio assets.

## Folder layout

```text
YhwachAlmighty/
├── README.md
├── YhwachUI.client.lua
├── AlmightyController.client.lua
├── AccessoryConfig.lua
├── HatAnimation.lua
└── Assets/
    ├── Animations/   # drop .anim source files here
    ├── Audio/        # drop .mp3 source files here
    ├── Accessories/  # notes / accessory metadata
    └── Effects/      # aura/effect source notes
```

## Setup

1. Put the four Lua files in `StarterPlayer > StarterPlayerScripts` in an experience you own.
2. Keep the names exact: `YhwachUI.client`, `AlmightyController.client`, `AccessoryConfig`, and `HatAnimation`. If Roblox renames a script on import, update the matching `WaitForChild` call.
3. Put your source `.anim` files in `Assets/Animations` and source `.mp3` files in `Assets/Audio` in the repository.
4. Import/publish animations and audio using Roblox's supported workflow, then add their published IDs to `AccessoryConfig.lua`.
5. Test with the same rig type your animations were authored for (R6 or R15).

## Animation and sound IDs

Six source animations are present in `Assets/Animations`:

| Source file | Config key | Intended action |
|---|---|---|
| `AlmightyAwake.anim` | `AlmightyAwakening` | Awakening sequence |
| `AlmightyAura.anim` | `AlmightyAura` | Looping Almighty/aura pose |
| `AlmightySlash.anim` | `AlmightySlash` | Move 1 |
| `Auswählen.anim` | `Auswahlen` | Move 2 |
| `Blut Vene Anhaben.anim` | `BlutVeneAnhaben` | Move 3 |
| `Sklaverei .anim` | `Sklaverei` | Move 4 |

Roblox does not play repository `.anim` / `.mp3` files directly by filename. Import and publish each animation through Roblox's supported workflow, then replace the empty values in `AnimationIds` and `SoundIds` in `AccessoryConfig.lua` with your authorized `rbxassetid://...` IDs. No audio source files are currently present in `Assets/Audio`; that folder only contains its placeholder note.

## Included modules

- `YhwachUI.client.lua`: responsive mobile-friendly GUI and local action events.
- `AlmightyController.client.lua`: plays the awakening, looping aura pose and four move animations after valid published IDs are configured; stops tracks and sounds on reset/respawn.
- `AccessoryConfig.lua`: user-supplied catalog IDs plus animation/audio ID placeholders.
- `HatAnimation.lua`: smoothly tweens a weld/Motor6D for an accessory already equipped by a supported experience. It does not create executor-style reanimation or bypass network/security restrictions.

## Supplied catalog manifest

### Base set
- `87291559615126` — Literal Hammer Head [White]
- `128893482026011` — Thin Hammer Head [White]
- `120111604252410` — Thin Hammer Head [Black]
- `90788603154080` — Hammer Head
- `88886554182275` — user-supplied, exact item metadata unverified

### Almighty set
- `108684178086287` — Yhwach Reishi Sword
- `75672773594451` — Yhwach Bleach TYBW Almighty King Hair
- `83293970715566` — user-supplied related item
- `122497534796344` — user-supplied related item
- `104304509923191` — user-supplied related item
- `87969060185631` — Soul king almighty aura
- `100693570818976` — user-designated Aura B; metadata unverified

These IDs are references, not embedded asset files. Asset availability and permission are controlled by Roblox.

## Current status

The UI and local animation controller are wired to the six source-animation roles, with four move buttons. Playback still requires published Roblox animation IDs; sound playback requires uploaded audio IDs. Accessory auto-equipping and custom aura particles are not yet implemented; the supplied catalog list alone does not grant access or replicate changes to other players.
