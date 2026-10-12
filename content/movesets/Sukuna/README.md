# Sukuna Moveset

This folder contains the Sukuna moveset module for RobuNexa / NAM.

## Strict accessory allowlist

The moveset accepts only these seven catalog asset IDs; other equipped accessories are ignored by its target-matching logic:

- Domain / Malevolent Shrine (active target): `18445594182`
- Additional supplied asset: `131873641508713`
- Sukuna's Finger (pickup check): `18762839664`
- Legacy Shrine asset ID (allowlisted, not used as the active Domain target): `18726352770`
- Fuga / Furnace: `124144353587446`
- Cleave/Dismantle aura: `100475161263482`
- Domain slash accessory: `97087028126781`

The moveset only matches accessories already equipped on the character; it does not fetch catalog items or create replacement accessories. The Finger check accepts the exact asset ID from the applied HumanoidDescription or supported accessory attributes, with an exact-name fallback for clients that omit ID metadata.

## Current abilities

- **Domain**: camera cutscene and a slow Shrine rise from underground; slash accessories move continuously while active.
- **Cleave**: short, faster slash burst.
- **Dismantle**: a second short slash burst.
- **Fuuga**: flame-arrow visual prototype.

## Finger pickup prototype limitation

The eleven spinning finger pickups and their chat messages are currently client-local. A real shared-world collection system requires server-side scripts in the Roblox experience so every player sees the same spawn positions and the server validates collection.
