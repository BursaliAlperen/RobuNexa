# Sukuna Moveset — One-Finger / Cleave Focus

This NAM moveset is focused on the equipped Cleave accessory. It does not send chat messages and does not expose Domain or Fuuga abilities.

## Equipped accessory

- Cleave accessory: `101090904148116`
- The moveset only matches accessories already equipped on the character; it does not fetch catalog items or create replacement accessories.

## Abilities and cooldowns

- **Cleave** — primary slash animation and target marker; 2.25-second cooldown.
- **Dismantle** — secondary slash; 3.5-second cooldown.
- Cooldowns use `os.clock()` timestamps and repeated input is ignored while an ability is cooling down.
- **Domain** and **Fuuga** are disabled; their buttons are not shown.
- No chat announcements or finger-pickup chat system is started.

The moveset uses NAM's bundled `.anim` loader and the currently equipped accessory. Visibility of client-side visuals to other players depends on Roblox replication and the execution environment.
