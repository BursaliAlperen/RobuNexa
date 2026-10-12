# Sukuna Moveset — One-Finger / Cleave Focus

This NAM moveset keeps Cleave as the primary skill and adds three Dismantle buttons plus three Combo buttons. It sends no chat messages and does not expose Domain or Fuuga abilities.

## Equipped accessory

- Cleave accessory: `101090904148116`
- The moveset only matches accessories already equipped on the character; it does not fetch catalog items or create replacement accessories.

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

Each Dismantle and Combo button has its own cooldown timestamp. Combo variants play the bundled combo animation and trigger three staggered local slash-effect pulses. On mobile, the seven skills appear as circular buttons on the right.

- **Domain** and **Fuuga** are disabled; their buttons are not shown.
- No chat announcements or finger-pickup chat system is started.
- The moveset uses NAM's bundled `.anim` loader and the currently equipped accessory. Visibility of client-side visuals to other players depends on Roblox replication and the execution environment.
