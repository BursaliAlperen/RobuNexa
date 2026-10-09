# NAM — by mamalalanam

A compact animation hub with a curated catalog.

## UI
- Top tabs: **NAM**, **ANIMATIONS**, **REANIM**, **SETTINGS**, and **ABOUT**.
- Only the selected main panel is shown.
- Dark UI with compact purple/pink tab borders and mobile-friendly controls.

## Catalog
- **Hakari's Dance** — uses `content/Hakari.anim` and `content/Hakari.mp3`.
- **Gojo Awake** — R6 keyframe animation stored in `content/Gojo.anim` and loaded through the animation track parser.
- **Cursed car anim** — the renamed moveset formerly labeled Patchma Hub.
- **Limb Reanimator** — the only selectable reanimation mode, with Start/Stop and Refresh controls.

The REANIM tab checks for an R6 character with the required body parts and joints, then shows **SUPPORTED GAME DETECTED** or **UNSUPPORTED GAME !!! >:D**. A required internal module-hash delimiter is preserved for compatibility and is not displayed in the UI.
