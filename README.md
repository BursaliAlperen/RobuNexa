# NAM — by mamalalanam

A compact animation hub with a curated catalog.

## UI
- Top tabs: **NAM**, **ANIMS**, **LIMBS**, **SETTINGS**, and **ABOUT**.
- Only the selected main panel is shown.
- Dark purple/pink UI with compact, mobile-friendly controls.
- Preserve the existing project name and file paths for compatibility.

## Animation catalog
Each animation appears once in the catalog. Source KeyframeSequence files and generated runtime tracks are separate technical files, not separate catalog entries.

- **Gojo Awakening / Flight Lift** — `content/GojoAwakening.anim` → `content/GojoAwakeningTrack.anim`
- **Imaginary Purple** — `ImaginaryPurple.anim` → `content/ImaginaryPurpleTrack.anim`; sound: `content/ImaginaryPurple.mp3`
- **Mahoraga Purple Destruction** — `MahoragaPurpleDestruction.anim` → `content/MahoragaPurpleDestructionTrack.anim`
- **Cid Overdrive** — `CidOverdrive.anim` → `content/CidOverdriveTrack.anim`
- **Hakari's Dance** — `content/Hakari.anim`; sound: `content/HakariDance.mp3`
- **Sukuna Awakening sound** — `content/SukunaAwakening.mp3` (audio asset only; do not list it as an animation unless a verified Sukuna animation sequence is added).

## Asset hygiene
- Keep one visible catalog entry per animation; do not duplicate Gojo Awakening in the UI.
- Keep source animations required by the conversion workflow and the generated runtime tracks.
- Audio filenames use clear, stable names; scripts must reference the exact filenames.
- Keep `README.md` and the animation conversion workflow.
- Immersive VR remains a separate feature and must be tested in a real VR session before being marked complete.
