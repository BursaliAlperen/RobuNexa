# Yhwach — The Almighty

A mobile-first, dark glass UI concept and asset manifest for an authorized Roblox experience.

## UI layout

- Compact draggable panel, optimized for phone screens and touch.
- Header: **YHWACH** with a small status indicator.
- Main toggle: **ALMIGHTY** — switches between Base and Almighty visual states.
- Secondary controls: **Equip Base Set**, **Equip Almighty Set**, **Aura**, **Stop Effects**, and **Reset Visuals**.
- Status line reports the current state and any accessory that could not be loaded.
- Avoid duplicate GUIs, runaway loops, and changes to the player's real character transparency.
- Use safe-area padding and scalable UI constraints; keep buttons large enough for touch.

## Base set — supplied catalog IDs

| Asset ID | Catalog lookup |
|---|---|
| 87291559615126 | https://www.roblox.com/catalog/87291559615126 |
| 128893482026011 | https://www.roblox.com/catalog/128893482026011 |
| 120111604252410 | https://www.roblox.com/catalog/120111604252410 |
| 90788603154080 | https://www.roblox.com/catalog/90788603154080 |
| 88886554182275 | https://www.roblox.com/catalog/88886554182275 |

The first four IDs were found as Hammer Head / Thin Hammer Head UGC neck accessories. Confirm the fifth item's name and type in the Roblox catalog before wiring it into a rig.

## Almighty state — supplied catalog IDs

| Purpose | Asset ID |
|---|---|
| Yhwach Reishi Sword | 108684178086287 |
| Hair / Almighty set | 75672773594451 |
| Almighty accessory | 83293970715566 |
| Almighty accessory | 83293970715566 |
| Almighty accessory | 122497534796344 |
| Almighty accessory | 104304509923191 |
| Aura A | 87969060185631 |
| Aura B | 100693570818976 |

The repeated 83293970715566 ID is preserved as supplied. Confirm whether the experience permits duplicate instances of that accessory. The exact item identity of 100693570818976 also needs catalog verification.

## Behavior

1. On start, initialize the UI once and show the Base state.
2. The authorized avatar system equips the Base set when those assets are available to the experience.
3. Pressing **ALMIGHTY** requests a state transition: replace the Base accessories with the Almighty set, enable the sword and aura effects, and update the UI state.
4. Pressing **ALMIGHTY** again returns to Base.
5. **Stop Effects** removes only effects created by this system; **Reset Visuals** restores the previous appearance.

## Technical boundaries

This document is an implementation plan, not an executor script. A client-only GUI or local CFrame change does not make changes replicate to other players. In an experience you own or are authorized to modify, use supported avatar APIs and server-approved state changes for replication. It does not attempt to bypass Roblox network ownership, character deletion protections, or another experience's restrictions.
