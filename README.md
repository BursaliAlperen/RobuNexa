# NAM — by mamalalanam

A compact animation hub with a curated catalog.

## UI
- Top tabs: **NAM**, **ANIMS**, **LIMBS**, **SETTINGS**, and **ABOUT**.
- Only the selected main panel is shown.
- Dark purple/pink UI with compact, mobile-friendly controls.
- Preserve the existing project name and file paths for compatibility.

## Animation catalog
Each playable animation appears once. Source KeyframeSequence files and generated runtime tracks are technical assets, not separate catalog entries.

- **Gojo Awakening** — `content/GojoAwakening.anim` → `content/GojoAwakeningTrack.anim`; separate Gojo animation with flight movement.
- **Maximum Hollow Purple** — `MaximumHollowPurple.anim` → `content/MaximumHollowPurpleTrack.anim`; airborne attack with lift and forward movement.
- **Imaginary Purple** — `ImaginaryPurple.anim` is the source for the normal, non-flying Hollow Purple. Its generated Track and playable catalog entry remain removed until the replacement/track is ready.
- **Sukuna Awakening** — reserved as a separate animation slot; `content/SukunaAwakening.mp3` is only its sound for now. Add the animation when provided.
- **Cid Overdrive** — `CidOverdrive.anim` → `content/CidOverdriveTrack.anim`.
- **Hakari's Dance** — `content/Hakari.anim`; sound: `content/HakariDance.mp3`.

## Asset hygiene
- Gojo Awakening and Sukuna Awakening are separate entries; never merge their animations or audio.
- Keep one visible catalog entry per animation.
- Audio filenames use clear, stable names; scripts must reference the exact filenames.
- Keep `README.md` and the animation conversion workflow.
- Existing camera code detects `VRService.VREnabled` and adapts the camera to headset orientation. This is baseline VR handling, not a claim that the full UI has been tested; validate controls, comfort, and animation playback in a real VR session before marking immersive VR complete.
