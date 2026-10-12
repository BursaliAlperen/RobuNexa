# Sukuna Moveset — One-Finger / Cleave Focus

This NAM moveset keeps Cleave as the primary skill and adds three Dismantle buttons plus three Combo buttons. It sends no chat messages and does not expose Domain or Fuuga abilities.

## Separate animation files

The former Cleave animation is reassigned to Combo and should be stored as `Combo.anim`. Dismantle remains a separate optional animation.

- `content/animations/Sukuna/Combo.anim` — the former Cleave animation, used by all three Combo buttons.
- `content/animations/Sukuna/Dismantle.anim` — separate Dismantle animation file.

Combo will use the former Cleave animation after its binary file is moved to `Combo.anim`. Dismantle remains optional; if its file is absent, the moveset still loads but Dismantle custom animation will not play.

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

Each Dismantle and Combo button has its own cooldown timestamp. Combo variants use the former Cleave animation through `Combo.anim` and trigger three staggered local slash-effect pulses. On mobile, the seven skills appear as circular buttons on the right.

- **Domain** and **Fuuga** are disabled; their buttons are not shown.
- No chat announcements or finger-pickup chat system is started.
- Visibility of client-side visuals to other players depends on Roblox replication and the execution environment.
