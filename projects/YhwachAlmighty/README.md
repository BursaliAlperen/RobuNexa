# Yhwach — The Almighty

The original Yhwach animation system has been restored from Git history, alongside the current cinematic helper and client starter. These are Roblox Studio scripts for a Roblox experience you own, not a Delta/executor loader.

## Restored system files

- `AlmightyController.client.lua` — client visual/animation controller.
- `YhwachUI.client.lua` — moveset UI shell.
- `YhwachMoveset.lua` — single-file moveset/animation UI option.
- `AnimLib.lua` — Studio-safe `.anim` keyframe reader/player helpers.
- `HatAnimation.lua` — poses an accessory already equipped on the character.
- `AccessoryConfig.lua` — accessory asset manifest/configuration.
- `YhwachClient.client.lua` — newer unified moveset + keyboard/touch buttons + awakening integration starter.
- `YhwachCutscenes.lua` — awakening camera, letterbox, subtitles, blur, and color grading.
- `Assets/Animations/` — original `.anim` source assets.

## Setup notes

These scripts are alternatives/parts from different iterations, not all meant to be dropped into the same place simultaneously. Start with `YhwachClient.client.lua` plus `YhwachCutscenes.lua` for the simple unified setup, or use the restored controller/UI/AnimLib set if you want the fuller modular version. Do not run two separate UI/controllers at once. Check each script's header for the expected Roblox Studio location and ModuleScript dependencies.

The `.anim` files must be published/imported through Roblox's animation tools for the correct rig and owner; source files do not automatically provide published asset IDs. Fill in IDs/configuration where requested and verify Output errors in Studio. The accessory IDs in the manifest are references only; the script does not guarantee catalog items can be equipped or that the IDs are usable by your experience.

## Immersive VR integration

No Immersive VR source file/module was found in this repository tree, so it has not been fabricated or replaced with a dummy script. Provide the exact file, repo path, or source link to integrate the real module safely.

## Scope

This repository version is for an experience you own. It does not include executor injection or a loader for third-party games. HatAnimation is an accessory-pose helper, not a full reanimation exploit. Server-authoritative combat, hitboxes, damage, and replication to other players must be implemented separately for a real multiplayer moveset.
