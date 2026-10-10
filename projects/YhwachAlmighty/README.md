# Yhwach — The Almighty

A mobile-first, dark-glass UI concept and asset manifest for an authorized Roblox experience. The user will provide .anim and .mp3 files later; keep animation/audio integration pending until those files arrive.

## UI layout

- Compact dark-glass panel designed for 9:16 mobile screens and touch.
- Header: **YHWACH** with a state indicator.
- Primary action: **ALMIGHTY** — toggles Base and Almighty forms.
- Secondary actions: **Base Set**, **Aura**, **Stop Effects**, and **Reset Visuals**.
- Status line shows active form and any asset load failures.
- Use responsive constraints, large touch targets, safe-area padding, and a single GUI instance.
- Do not permanently change the user's actual character transparency; preserve and restore any visual properties changed by an authorized implementation.

## Base set — supplied IDs

The five IDs were also found grouped together as the “Lay rig” hat set in a community script listing. The first four catalog records are neck accessories; that does not mean they are anatomically mapped to arms/legs. Their exact role as rig pieces must be confirmed from accessory attachment geometry.

| Asset ID | Catalog name/type | Link |
|---|---|---|
| 87291559615126 | Literal Hammer Head [White] — Neck Accessory | https://www.rolimons.com/item/87291559615126 |
| 128893482026011 | Thin Hammer Head [White] — Neck Accessory | https://www.rolimons.com/item/128893482026011 |
| 120111604252410 | Thin Hammer Head [Black] — Neck Accessory | https://www.rolimons.com/item/120111604252410 |
| 90788603154080 | Hammer Head — Neck Accessory | https://www.rolimons.com/item/90788603154080 |
| 88886554182275 | Included in the community “Lay rig” list; exact catalog metadata not independently verified | https://www.roblox.com/catalog/88886554182275 |

## Almighty form — supplied IDs

| Asset ID | Verified name/type | Link |
|---|---|---|
| 108684178086287 | Yhwach Reishi Sword — Back Accessory | https://www.rolimons.com/item/108684178086287 |
| 75672773594451 | Yhwach Bleach TYBW Almighty King Hair — Hair Accessory | https://www.rolimons.com/item/75672773594451 |
| 83293970715566 | Linked from the Yhwach Almighty King Hair creator description; exact standalone title not independently verified | https://www.roblox.com/catalog/83293970715566 |
| 83293970715566 | Duplicate intentionally retained because the user supplied it twice; duplicate-wear support is unverified | https://www.roblox.com/catalog/83293970715566 |
| 122497534796344 | Linked from the Yhwach Almighty King Hair creator description; exact standalone title not independently verified | https://www.roblox.com/catalog/122497534796344 |
| 104304509923191 | Linked from the Yhwach Almighty King Hair creator description; exact standalone title not independently verified | https://www.roblox.com/catalog/104304509923191 |
| 87969060185631 | Soul king almighty aura — Back Accessory | https://www.rolimons.com/item/87969060185631 |
| 100693570818976 | User-designated Aura B; exact catalog metadata not independently verified | https://www.roblox.com/catalog/100693570818976 |

The three accessory IDs 83293970715566, 122497534796344 and 104304509923191 are linked in the description of the Almighty King Hair item, so they appear to belong to the same Yhwach set. Do not infer exact attachment locations from this alone.

## Intended behavior

1. Initialize the UI once and show Base state.
2. In an authorized experience, equip the Base set through supported avatar APIs when the assets are available and permitted.
3. Pressing **ALMIGHTY** requests a transition: switch to the Almighty set, enable the sword and both aura assets, and update the UI.
4. Pressing **ALMIGHTY** again returns to Base.
5. **Stop Effects** stops effects created by this system. **Reset Visuals** restores the original appearance and removes only objects created by this system.
6. Add the user's .anim and .mp3 files after they are uploaded. Do not invent animation IDs or substitute unrelated audio.

## Implementation boundaries

This repository document is a plan, not a working executor script. Client-only accessory or CFrame changes do not automatically replicate to other players. For an experience the user owns or is authorized to modify, use supported avatar APIs and server-approved state changes. Do not bypass network ownership, character deletion protections, or another experience's restrictions.

## Research notes

- Roblox catalog item IDs identify different kinds of assets; use catalog metadata rather than assuming every numeric ID is a hat or limb.
- Roblox's own documentation distinguishes Marketplace avatar assets from Creator Store assets such as models and audio: https://create.roblox.com/docs/projects/assets/api
- The asset list is preserved exactly as supplied, including the repeated ID 83293970715566.
