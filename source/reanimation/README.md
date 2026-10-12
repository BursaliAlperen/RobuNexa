# RobuNexa Reanimation Engines

## Separate Gojo and Sukuna

The NAM built-in module loader registers Gojo and Sukuna as separate movesets. Do not merge their entries. The current `source/reanim.lua` keeps the built-in path list for both:
- `content/movesets/Gojo/module.lua`
- `content/movesets/Sukuna/v_sukuna.lua`

## Kade Krypton / Gelatek legacy selector

`source/reanimation/engine.lua` is a standalone engine selector:
- Default: KadeTheExploiter/Krypton with `PermanentDeath = true`.
- Optional legacy mode: Gelatekussy/GelatekReanimate with `PermanentDeath = true`.

Change `ENGINE` at the top of the file to `"GELATEK_LEGACY"` only when specifically testing the legacy engine. The Gelatek repository warns that its code no longer works reliably in modern games; Krypton is the recommended default.

**Do not run this standalone selector alongside `source/reanim.lua`.** Both engines manage the local character and would conflict. The selector is not yet a drop-in replacement for NAM's internal `Reanimate`, `HatReanimator`, and `LimbReanimator` APIs, so NAM movesets are not automatically compatible with this standalone entrypoint. A full replacement requires an adapter/port and in-game validation; this repository change does not claim that integration is complete.

Upstream references:
- Krypton: https://github.com/KadeTheExploiter/Krypton
- Gelatek legacy: https://github.com/Gelatekussy/GelatekReanimate
