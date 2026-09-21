# Stage 3 — Game Selection → 3D World

The two-script runtime now turns a selected game into a real server-built 3D arena.

## Flow

Games screen → Start RemoteEvent → server validates game ID → server creates `workspace.RobuNexaWorld/ActiveGameWorld` → player is moved into the arena → `WorldReady` is sent to the client → game HUD continues.

## Current arenas

All 10 game IDs have distinct arena colors and dimensions:
- Dodge Run
- Target Rush
- Stack Tower
- Coin Rush
- Jump Challenge
- Reaction Test
- Color Rush
- Memory Match
- Falling Platforms
- Floor Is Lava

Stage 3 currently establishes the reusable 3D arena pipeline. The individual game mechanics, hazards, targets, coins, platforms, checkpoints, VFX/SFX and camera sequences are next.

## Studio setup

Keep only:
- `ServerScriptService > RobuNexaServer` (Script)
- `StarterPlayer > StarterPlayerScripts > MainClient` (LocalScript)

Press Play, open OYUNLAR, select a game. The server builds the corresponding 3D arena automatically.

## Safety

The server validates the requested game ID and owns world creation. The client only requests a game; it does not create or award the authoritative world/score.
