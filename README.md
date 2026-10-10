# NAM — by mamalalanam

A compact animation hub with a curated catalog.

## UI
- Top tabs: **NAM**, **ANIMS**, **LIMBS**, **SETTINGS**, and **ABOUT**.
- Keep the existing project name and file paths for compatibility.
- The original reanimation source is restored, including its existing hat/accessory and limb reanimation logic.

## Animation catalog
Each playable animation appears once. Source KeyframeSequence files and generated runtime tracks are technical assets, not separate catalog entries.

- **Gojo Awakening** — `content/GojoAwakening.anim` → `content/GojoAwakeningTrack.anim`; separate from Sukuna.
- **Maximum Hollow Purple** — `MaximumHollowPurple.anim` → `content/MaximumHollowPurpleTrack.anim`; airborne attack with lift and forward movement.
- **Sukuna Awakening** — `sukunaAwaken.anim` → `content/SukunaAwakeningTrack.anim`; uses `content/SukunaAwakening.mp3`.
- **Sokamona** — `Sokamona.anim` → `content/SokamonaTrack.anim`.
- **Cid Overdrive** — `CidOverdrive.anim` → `content/CidOverdriveTrack.anim`.
- **Hakari's Dance** — `content/Hakari.anim`; sound: `content/HakariDance.mp3`.
- **Restored emotes** — `content/v_dance2.lua` and its matching animation/audio assets restore the missing emote catalog.

## Asset hygiene
- Gojo Awakening and Sukuna Awakening are separate entries; never merge their animations or audio.
- Keep one visible catalog entry per animation.
- Audio filenames use clear, stable names; scripts must reference the exact filenames.
- Keep this README and the animation conversion workflow.
- The project contains baseline VR camera handling; validate controls and playback in a real VR session before claiming full immersive-VR support.
