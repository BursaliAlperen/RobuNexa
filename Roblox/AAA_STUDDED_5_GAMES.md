# ROBUNEXA — AAA STUDDED EDITION

## Visual direction
The runtime is now a focused five-game lineup with a Roblox-inspired **Stud Lab** command deck:
- dark industrial surfaces
- cream/orange metal accents
- visible stud/rivet details on panels and buttons
- chunky high-contrast touch controls
- 16:9 primary layout
- portrait fallback
- safe-area support
- no store, premium currency, or pay-to-win UI

## GUI screens
Boot → Command Deck → Game Select → Run HUD → Game Over.
Supporting screens: Leaderboard, Profile, Settings.

## Five games
01 Dodge Run — three lanes, moving steel obstacles, progress gates, combo resets and impact feedback.
02 Target Rush — rotating 3D targets, desktop mouse and mobile touch raycast, server validation.
03 Stack Tower — moving block timing, overlap math, shrinking width and collapse/reset.
04 Coin Rush — 36 rotating physical coin pickups, respawns and combo scoring.
05 Floor Is Lava — safe grid, rising lava, reset point and survival scoring.

## Two-script rule
ServerScriptService > RobuNexaServer (Script)
StarterPlayer > StarterPlayerScripts > MainClient (LocalScript)

No additional runtime script is required.

## Test
Repository code is updated, but Roblox Studio itself is not runnable in this chat environment. Play/Test in Studio after syncing the two scripts.
