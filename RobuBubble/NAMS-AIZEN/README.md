# NAM'S AIZEN — Roblox Studio framework

This folder is an editable, Studio-side framework for **your own Roblox experience**. It is not an executor script and does not reproduce Genesis's proprietary code.

## Setup
1. In Roblox Studio, create `ReplicatedStorage/NAMS_AIZEN/Animations`.
2. Import each supplied `.anim` file through Roblox Studio's animation workflow / Animation Editor. A raw `.anim` file is not a runtime Animation object; publish the animation for the experience and set its published asset ID in an `Animation` instance's `AnimationId` property.
3. Put the ModuleScripts in `ReplicatedStorage/NAMS_AIZEN` and the LocalScript in `StarterPlayer/StarterPlayerScripts`.
4. Name each Animation instance exactly as its action: `Idle`, `Walk`, `Run`, `M1_1`, `M1_2`, `M1_3`, `M1_4`, `Skill_1`, `Skill_2`, `Domain`.
5. Use R6 or R15 animations that match the experience rig. The sample controller plays only animations present in the folder and warns for missing ones.

## Modules
- `Config.lua`: animation names and behavior.
- `AnimationManager.lua`: safe load/play/stop and cleanup.
- `RespawnController.lua`: character lifecycle and duplicate-start protection.
- `AizenController.lua`: action routing and movement state.
- `NAMS-AIZEN.client.lua`: compact mobile-friendly test controls.

The included framework intentionally does not implement exploit-based reanimation or bypass another game's character/network ownership.