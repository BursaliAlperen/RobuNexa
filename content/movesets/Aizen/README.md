# Aizen NAM Moveset

`module.lua` is the NAM-style module factory for Aizen. It follows the same return shape as the Gojo and Sukuna built-ins: a table of factories, each returning a moveset with `ModuleType`, `Name`, `Config`, `Init`, `Update`, and `Destroy`.

## Included abilities

- **Kyoka Suigetsu** — local screen tint and expanding ring effect.
- **Shunpo** — short movement burst for the equipped rig.
- **Cero** — client-side projectile visual.
- **Kurohitsugi** — temporary dark-box visual.
- **Hadō 90** — temporary pillar effect.
- **Afterimage** — short-lived local character afterimage.
- **Hōgyoku** — temporary highlight aura.

All seven abilities have individual cooldowns and touch-friendly HUD buttons. Temporary instances, GUI connections, highlights, and screen effects are cleaned up by `Destroy`.

## Important scope and integration notes

- This is a **client-side visual/mobility implementation**. It does not claim to damage, stun, or replicate effects to other players. A client-only script cannot authoritatively implement multiplayer combat; that requires server-side game code and validated RemoteEvent handling in a game the developer owns.
- No Aizen animation or sound assets are referenced yet. The module intentionally avoids broken placeholder asset URLs and works with procedural visuals until verified `.anim`/audio assets are added.
- The legacy `v_aizen.lua` is an older standalone prototype. It requires `ReplicatedStorage` modules (`Reanim`, `FlingSystem`, `UISystem`, and `PassiveFeatures`) and APIs that are not supplied by the current Gojo/Sukuna module contract. Do not load that prototype as a NAM built-in.
- The NAM loader must explicitly include `movesets/Aizen/module.lua` in its built-in module list (the same list that includes `movesets/Gojo/module.lua` and `movesets/Sukuna/v_sukuna.lua`). The current `main` branch's `source/reanim.lua` does not expose that loader list, so this change adds the compatible module but does not silently rewrite or replace the reanimation entrypoint. Verify loader registration against the exact NAM source revision used by your client before expecting Aizen to appear automatically.

## Manual integration

In the NAM loader's built-in module list, add:

```lua
"movesets/Aizen/module.lua",
```

Then reload built-in modules. Confirm the client log reports one Aizen moveset registered, equip Aizen, and verify all seven HUD buttons and cleanup on unequip.
