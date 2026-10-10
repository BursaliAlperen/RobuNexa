# Yhwach — The Almighty

Mobile-first, dark-glass Yhwach UI and asset manifest for an authorized Roblox experience. Animation and sound integration is pending the user's .anim and .mp3 files.

## UI

- 9:16 mobile-first, responsive panel with touch-friendly controls.
- Header: YHWACH and current form status.
- Primary toggle: ALMIGHTY — switches between Base and Almighty states.
- Secondary controls: Base Form, Aura, Stop Effects, Reset Visuals.
- Avoid duplicate GUIs, runaway loops, and permanent character transparency changes.
- Current UI file: [YhwachUI.client.lua](./YhwachUI.client.lua). It is a UI shell only; the avatar/effect handler is not wired yet.

## Base set — exact IDs supplied by user

A community script listing groups these five IDs as the **“Lay rig”** accessory set. This confirms they are intended to be used together as a rig-style set, but does not make them native Roblox limbs. Four individual catalog records identify neck accessories.

| Asset ID | Verified catalog title/type | Evidence |
|---|---|---|
| 87291559615126 | Literal Hammer Head [White] — Neck Accessory | [Rolimon's](https://www.rolimons.com/item/87291559615126) |
| 128893482026011 | Thin Hammer Head [White] — Neck Accessory | [Rolimon's](https://www.rolimons.com/item/128893482026011) |
| 120111604252410 | Thin Hammer Head [Black] — Neck Accessory | [Rolimon's](https://www.rolimons.com/item/120111604252410) |
| 90788603154080 | Hammer Head — Neck Accessory | [Rolimon's](https://www.rolimons.com/item/90788603154080) |
| 88886554182275 | Included in the community “Lay rig” list; exact catalog title/type not independently verified | [Community listing](https://scriptblox.com/script/UP-Just-a-baseplate.-Just-a-baseplate-Rigs-u-have-to-copy-them-in-scriptblox-114053) |

## Almighty form — exact IDs supplied by user

| Asset ID | Verified catalog title/type | Evidence |
|---|---|---|
| 108684178086287 | Yhwach Reishi Sword — Back Accessory | [Rolimon's](https://www.rolimons.com/item/108684178086287) |
| 75672773594451 | Yhwach Bleach TYBW Almighty King Hair — Hair Accessory | [Rolimon's](https://www.rolimons.com/item/75672773594451) |
| 83293970715566 | Linked in the description of the Yhwach Almighty King Hair item; exact standalone title/type not independently verified | [Hair item page](https://www.rolimons.com/item/75672773594451) |
| 83293970715566 | Duplicate preserved because it was supplied twice; whether Roblox permits wearing both copies is unverified | [Hair item page](https://www.rolimons.com/item/75672773594451) |
| 122497534796344 | Linked in the description of the Yhwach Almighty King Hair item; exact standalone title/type not independently verified | [Hair item page](https://www.rolimons.com/item/75672773594451) |
| 104304509923191 | Linked in the description of the Yhwach Almighty King Hair item; exact standalone title/type not independently verified | [Hair item page](https://www.rolimons.com/item/75672773594451) |
| 87969060185631 | Soul king almighty aura — Back Accessory | [Rolimon's](https://www.rolimons.com/item/87969060185631) |
| 100693570818976 | User-designated Aura B; exact catalog title/type could not be independently verified in indexed results | [Roblox catalog lookup](https://www.roblox.com/catalog/100693570818976) |

### Verified set relationships

The creator description for item 75672773594451 explicitly links 92221423556955, 122497534796344, 104304509923191, and 83293970715566 as part of the Yhwach Almighty King set. Item 92221423556955 was not in the user's supplied list, so it is not added to the equip manifest automatically.

The description for 87969060185631 lists a Soul King Almighty set and references separate torso, left shoulder, right shoulder, waist, and outer aura accessories. The supplied ID 87969060185631 is specifically the outer/back aura, not the torso or arms.

## Intended form flow

1. Start in Base state and initialize one UI instance.
2. In an authorized experience, equip the five Base assets if available and permitted.
3. ALMIGHTY switches to the second form, replaces the Base set with the supplied Almighty set, and enables both aura IDs and the sword.
4. ALMIGHTY again or Base Form returns to Base.
5. Stop Effects removes effects created by the system; Reset Visuals restores the initial appearance and clears only objects created by this system.
6. Integrate the user's .anim and .mp3 files after upload. Do not invent asset IDs or substitute unrelated audio.

## Technical boundaries

This is not an executor script. Client-only GUI, accessory, and CFrame changes do not automatically replicate to other players. For an experience the user owns or is authorized to modify, use supported avatar APIs and server-approved state changes. Do not bypass network ownership, character deletion protections, or another experience's restrictions.

## Research links

- [Roblox asset API documentation](https://create.roblox.com/docs/projects/assets/api)
- [Community “Lay rig” grouping](https://scriptblox.com/script/UP-Just-a-baseplate.-Just-a-baseplate-Rigs-u-have-to-copy-them-in-scriptblox-114053)
- [Yhwach Almighty King Hair and linked set pieces](https://www.rolimons.com/item/75672773594451)
- [Soul King Almighty aura and set description](https://www.rolimons.com/item/87969060185631)
