# Yhwach — The Almighty

A unified **in-experience** client starter for a Roblox experience you own. The client moveset UI, keybinds, animation playback, and awakening cinematic are included as source files; original .anim assets remain separate source assets.

## Files

- YhwachClient.client.lua — LocalScript with on-screen move buttons, keyboard bindings, animation playback, cooldown guard, respawn cleanup, and awakening integration.
- YhwachCutscenes.lua — cinematic letterbox, subtitles, camera shots, blur, color grading, and skip button.
- Assets/Animations/ — source animation files: AlmightyAura, AlmightyAwake, AlmightySlash, Auswählen, Blut Vene Anhaben, and Sklaverei.
- Assets/Audio/, Assets/Effects/, Assets/Accessories/ — asset folders/placeholders for project assets.

## Roblox Studio setup

1. In a place you own, add YhwachClient.client.lua as a LocalScript and YhwachCutscenes.lua as a ModuleScript beside it under StarterPlayer > StarterPlayerScripts. Preserve the ModuleScript name exactly.
2. Upload each animation through Roblox animation tools for the correct rig and experience/owner. A source .anim file is not automatically a published asset ID.
3. Replace the 0 values in CONFIG.Animations with the published numeric animation IDs.
4. Test in Studio with an R6 or R15 character matching the animation rig. Check Output for missing IDs or permissions.

## Controls

- Z — Almighty Slash
- X — Auswählen
- C — Blut Vene
- V — Sklaverei
- G — Awakening + cinematic

The on-screen buttons also work on touch devices. These are animation triggers and cinematic scaffolding, not server-authoritative combat: damage, hitboxes, server-validated cooldowns, and effects that other players must see should be implemented and validated by the server in your own game.

## Scope and limitations

This is a Roblox Studio in-experience setup, not a Delta/executor loader. It does not inject into third-party games, fetch executable code at runtime, or provide hat/limb reanimation in someone else's experience. No animation IDs or audio IDs are fabricated; configure assets you own or have permission to use.
