# Mobile Game Hub

## Design
- Mobile-first, one-tap gameplay.
- Free, no ads, no Robux sales or developer products.
- Palette: #F5821E orange, #FADCA0 cream, #2D2D32 dark.
- Studded Roblox-style procedural worlds.
- Every score action can emit VFX, sound, camera punch and popup.
- Combo multiplier up to x5 and speed ramp.

## Auto-registration
To add a game:
1. Add one entry to ReplicatedStorage/Modules/GameConfig.lua.
2. Add one ModuleScript with the same Id under ReplicatedStorage/MiniGames.
3. Implement start(ctx), cleanup(player), and the ctx finish/action callbacks.
No Hub card or portal code needs to be edited.

## Required Studio hierarchy

ReplicatedStorage
- Modules
  - GameConfig
  - Remotes
  - UITheme
  - Anim
  - AudioKit
  - FxKit
- MiniGames
  - _Util
  - DodgeRun
  - TargetRush
  - StackTower
  - CoinRush
  - JumpChallenge
  - ReactionTest
  - ColorRush
  - MemoryMatch
  - FallingPlatforms
  - FloorIsLava

ServerScriptService
- ServerModules
  - WorldBuilder
  - LightingService
  - GameService
  - DataService
  - LeaderboardService
- GameServer.server.lua

StarterPlayer
- StarterPlayerScripts
  - MainClient.client.lua
  - ScoreHUD.client.lua

## Safety
All client module loads use WaitForChild and pcall. Remote payloads are checked with
typeof, string length limits and per-player action throttling. Sessions lock a player
to one active game. Server score is clamped to the configured MaxScore.

DataStore and OrderedDataStore operations retry five times with exponential backoff.

## Performance budget
Procedural worlds intentionally keep primitive counts low. Particle emitters are
limited by design to <=12 per effect burst; textures should stay <=1024; generated
worlds target <=250 Parts per active game.

## Creator Store policy
Only free, scriptless, low-poly textures and icons should be imported manually.
Do not insert arbitrary third-party scripts, plugins, packages, free models with
scripts, or monetization assets into the Hub.

## Monetization
No MarketplaceService purchase flow is included. No Developer Product, Game Pass,
paid random item, or advertising code is included.
