# RobuNexa — 2 Script Setup

This is the simplified runtime setup.

## Explorer

Create exactly two scripts:

- `ServerScriptService > RobuNexaServer` — **Script**
- `StarterPlayer > StarterPlayerScripts > MainClient` — **LocalScript**

Paste the contents of the matching files from this repository.

Then press **Play**.

The server script creates `ReplicatedStorage.RobuNexaRemotes` automatically. The client builds the complete Stage 2 responsive UI automatically.

## Important

This runtime version does **not** download Lua source from GitHub while the game is running. Roblox runtime scripts cannot rewrite arbitrary Script/LocalScript Source. GitHub remains the source repository; Studio is where the two scripts are installed.

The simplified server currently provides:
- 10 game IDs
- server-authoritative sessions
- server-side score calculation
- action throttling
- 30-second rounds
- basic persistence of best scores
- runtime leaderboard for active sessions
- responsive 16:9 / portrait UI
- no monetization

The older modular architecture remains in the repository as reference and can be restored when expanding Stage 3+.
