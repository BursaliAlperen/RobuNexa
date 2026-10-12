# Sukuna Moveset

This folder contains the Sukuna moveset module for RobuNexa / NAM.

## Configured catalog accessories

- Malevolent Shrine: `18726352770`
- Fuga / Furnace: `124144353587446`
- Cleave/Dismantle aura: `100475161263482`
- Domain slash accessory: `97087028126781`
- Sukuna Finger accessory: `18762839664`

The first four accessories are used by the moveset's HatReanimator positioning logic. The Finger item is checked as equipped before local finger pickups can be collected.

## Current abilities

- **Domain**: camera cutscene and a slow Shrine rise from underground; slash accessories move continuously while active.
- **Cleave**: short, faster slash burst.
- **Dismantle**: a second short slash burst.

The module currently has no animation asset dependencies.

## Finger pickup prototype limitation

The eleven spinning finger pickups and their chat messages are currently client-local. A real shared-world collection system requires server-side scripts in the Roblox experience so every player sees the same spawn positions and the server validates collection.
