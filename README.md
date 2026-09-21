# RobuNexa

Mobile-first Roblox mini-game hub.

## 10-stage development

1. Foundation — folder architecture, shared config, remotes, bootstrap.
2. Responsive GUI — 16:9 landscape, portrait fallback, safe-area, scalable cards.
3. Game selection — data-driven 10-game catalog.
4. Mini-game framework — server sessions, start/finish lifecycle, cleanup.
5. World generation — procedural hub and per-game world construction.
6. Feedback layer — score/combo UI, motion, camera feedback, VFX hooks, audio hooks.
7. Persistence — DataStore best scores and player stats.
8. Leaderboards — OrderedDataStore submission, retries and rank lookup.
9. Security/performance — server-authoritative scoring, action throttling, score clamps, low-part budget.
10. Release QA — Studio Play test, mobile touch test, DataStore test on a published experience, then Publish to Roblox.

## Current delivery

The gameplay/runtime hub files are now on the main branch. The original RBXM/moveset work remains available on the development branch/PR for later integration.

## 10 games

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

## Studio

The project uses real Roblox Script, LocalScript and ModuleScript instances. It does not depend on downloading arbitrary Lua and executing it with loadstring at runtime.

Before publishing, test every game in Roblox Studio and verify DataStore behavior in a published test experience.
