# Sukuna Finger World + Session Permadeath

These are **Roblox Studio scripts for an experience you own**. A Delta/client-only script cannot replicate newly-created Workspace parts to every player or enforce server-wide permadeath.

## Shared Sukuna fingers

1. Put `SukunaFingerWorld.server.lua` in **ServerScriptService**.
2. Put `SukunaFingerCutscene.client.lua` in **StarterPlayer > StarterPlayerScripts**.
3. Start a server test with 2 players. The server spawns 11 grounded, glowing fingers; everyone sees the same fingers. The first player to collect a finger removes it for the whole server.
4. To play the actual laugh animation in this Studio setup, publish the extracted laugh animation under your account, create an `Animation` instance named `SukunaLaughAnimation` in **ReplicatedStorage**, and set its `AnimationId` to your published animation ID. Until then, the camera cutscene and pickup notification still work.

The NAM moveset checks for the server-created `Workspace.SukunaFingerWorld` folder and avoids creating duplicate local-only fingers when it exists.

## Session permadeath

Put `Permadeath.server.lua` in **ServerScriptService** only if you want this rule for your own game. It disables automatic respawns after a player's first death in that server session. Players can start fresh by leaving and rejoining. This script changes the game's normal respawn system; test it in a private server before enabling it publicly.

## Downloads

- [SukunaFingerWorld.server.lua](./SukunaFingerWorld.server.lua)
- [SukunaFingerCutscene.client.lua](./SukunaFingerCutscene.client.lua)
- [Permadeath.server.lua](./Permadeath.server.lua)
