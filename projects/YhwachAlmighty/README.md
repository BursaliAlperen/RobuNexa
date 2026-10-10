# Yhwach Almighty — Studio moveset

This folder contains a Roblox Studio implementation for **your own experience**. It is separate from `source/reanim.lua`; the existing glass UI / reanimation file is intentionally untouched.

## Install
1. In Roblox Studio, place `YhwachMoveset.client.lua` as a **LocalScript** under `StarterPlayer > StarterPlayerScripts`.
2. Use an R6 rig and publish each animation from the Animation Editor.
3. Put the numeric published animation IDs in `CONFIG.Animations` in the script (leave them empty until you have real IDs).
4. Ensure the character's `Humanoid` has a server-created `Animator`. Roblox animation playback uses `Animator:LoadAnimation()`; see the [official Animator documentation](https://create.roblox.com/docs/reference/engine/classes/Animator).

## Controls
- **Z** Almighty Awakening
- **X** Almighty Slash
- **C** Auswählen
- **V** Blut Vene
- **B** Sklaverei
- **G** local camera cutscene
- **Right Ctrl** toggle the panel

## Immersive VR
No verified Immersive VR module/source was present in this branch when checked, so no fake require ID or invented dependency is included. Share the exact module/file or its repository URL to integrate it safely. This Studio implementation does not inject into other people's experiences and does not use executor-only APIs.

## Notes
- The cutscene is local-camera-only; it does not force other players' cameras.
- Animation IDs must be published and permitted for the experience/creator.
- This is a baseline moveset/UI scaffold, not a claim that animation assets have already been uploaded.
