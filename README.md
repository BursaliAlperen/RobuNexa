# NAM — by mamalalanam

A compact animation hub with a curated catalog.

## UI
- Top tabs: **NAM**, **ANIMS**, **LIMBS**, **SETTINGS**, and **ABOUT**.
- Only the selected main panel is shown.
- Dark purple/pink UI with compact, mobile-friendly controls.
- Preserve the existing project name and file paths for compatibility.

## Animation catalog
Each playable animation appears once. Source KeyframeSequence files and generated runtime tracks are technical assets, not separate catalog entries.

- **Maximum Hollow Purple** — `MaximumHollowPurple.anim` → `content/MaximumHollowPurpleTrack.anim`; airborne attack with lift and forward movement.
- **Imaginary Purple** — `ImaginaryPurple.anim` is retained as the source for the normal, non-flying Hollow Purple. Its generated Track and catalog entry are removed for now; add the replacement animation before re-enabling it.
- **Cid Overdrive** — `CidOverdrive.anim` → `content/CidOverdriveTrack.anim`.
- **Hakari's Dance** — `content/Hakari.anim`; sound: `content/HakariDance.mp3`.
- **Sukuna Awakening sound** — `content/SukunaAwakening.mp3`; audio only until the new Sukuna animation is provided.

## Asset hygiene
- Removed the old Gojo Awakening source and generated Track; no Gojo Awakening entry remains.
- Keep one visible catalog entry per animation.
- Audio filenames use clear, stable names; scripts must reference the exact filenames.
- Keep `README.md` and the animation conversion workflow.
- Existing camera code detects `VRService.VREnabled` and adapts the camera to headset orientation. This is baseline VR handling, not a claim that the full UI has been tested; validate controls, comfort, and animation playback in a real VR session before marking immersive VR complete.
