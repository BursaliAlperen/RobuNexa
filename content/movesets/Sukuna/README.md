# Sukuna Moveset — One-Finger / Cleave Focus

This NAM moveset keeps Cleave as the primary skill and adds three Dismantle buttons plus three Combo buttons. It sends no chat messages and does not expose Domain or Fuuga abilities.

## Separate animation files

Each action uses its own independent `.anim` file; Dismantle and Combo no longer reuse `DomainCombo.anim`.

- `content/animations/Sukuna/Cleave.anim` — Cleave animation (already referenced by the moveset).
- `content/animations/Sukuna/Dismantle.anim` — separate Dismantle animation file to add.
- `content/animations/Sukuna/Combo.anim` — separate Combo animation file to add.

The Dismantle and Combo files are optional during moveset startup, so missing files do not prevent the entire moveset from loading. Until the actual `.anim` files are added, those actions show a missing-animation notice and their custom animation will not play. This change wires up the file paths; it does not fabricate animation data.

## Equipped accessory

- Cleave accessory: `101090904148116`
- The moveset uses the accessory already equipped on the character; it does not create a replacement accessory.

## Skills and cooldowns

| Skill | Key | Cooldown |
|---|---|---:|
| Cleave | X | 2.25 s |
| Dismantle 1 | C | 3.5 s |
| Dismantle 2 | V | 3.5 s |
| Dismantle 3 | B | 3.5 s |
| Combo 1 | Z | 4.5 s |
| Combo 2 | G | 4.5 s |
| Combo 3 | H | 4.5 s |

Each Dismantle and Combo button has its own cooldown timestamp. Combo variants use the separate Combo animation and trigger three staggered local slash-effect pulses. On mobile, the seven skills appear as circular buttons on the right.

- **Domain** and **Fuuga** are disabled; their buttons are not shown.
- No chat announcements or finger-pickup chat system is started.
- Visibility of client-side visuals to other players depends on Roblox replication and the execution environment.
