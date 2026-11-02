# Sukuna Moveset — Cleave Focus

This NAM moveset keeps Cleave as the signature slash and includes Dismantle, Combo, Rush, Laugh, and an NPC-only Fling skill. Domain and Fuuga remain disabled.

## Animation and effects

- `content/animations/Sukuna/Cleave.anim` — used by Cleave and the NPC Fling impact.
- `content/animations/Sukuna/Dismantle.anim` — Dismantle animation.
- `content/animations/Sukuna/Combo.anim` — Combo animation.
- `content/animations/Sukuna/Rushbeatdown.anim` — Rush animation.
- `content/sounds/sukuna-slash.mp3` — slash and impact sound.

Cleave now drives three timed slash-effect passes using the existing equipped accessory. This adds hit rhythm without introducing duplicate animation assets.

## Equipped accessory

- Cleave accessory: `101090904148116`
- The moveset uses the accessory already equipped on the character; it does not create a replacement accessory.

## Skills and cooldowns

| Skill | Key | Cooldown |
|---|---|---:|
| Cleave | X | 5 s |
| Dismantle | C | 7 s |
| Combo | Z | 15 s |
| Rush | R | 18 s |
| Laugh | L | 12 s |
| NPC Fling | F | 10 s |

Each skill has an independent cooldown. On touch devices, all six skills appear in the Sukuna ability panel.

## NPC Fling behaviour and limits

- Searches a 32-stud radius, then selects the nearest living Humanoid NPC in front of Sukuna.
- Player characters and the local/reanimated character are explicitly excluded.
- Uses Roblox `BasePart:ApplyImpulse()` and a small angular impulse; it does not use a fake teleport or repeatedly overwrite the NPC's position.
- Adds a short local impact highlight and reuses the existing Cleave animation and slash sound.
- This moveset is client-side. The impulse is a real physics call, but whether other players see the NPC move depends on network ownership. A server-owned NPC needs the impulse applied by a server Script in the experience for reliable replicated knockback.

## Disabled / excluded systems

- **Domain** and **Fuuga** remain disabled; their buttons are not shown.
- No chat announcements or finger-pickup mechanic is started.
- The old standalone FlingLab and player-targeting UniversalFling modules are removed; NPC Fling now lives in the Sukuna moveset and cannot select player characters.
