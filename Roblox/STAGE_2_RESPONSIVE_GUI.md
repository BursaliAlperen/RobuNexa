# Etap 2 — Responsive GUI

Stage 2 focuses on a single UI that adapts between 16:9 landscape and portrait/mobile.

Implemented:
- DeviceSafeInsets safe-area handling on the ScreenGui.
- 16:9 landscape composition with portrait fallback.
- UISizeConstraint prevents the desktop canvas from growing indefinitely.
- UITextSizeConstraint keeps labels readable on smaller screens.
- Activated events are used for mouse/touch/gamepad-friendly buttons.
- Roblox-stud inspired micro-details are used on panels without adding heavy geometry.
- Game cards are data-driven from GameConfig.
- No Robux, ads or monetization UI.

Studio test matrix:
1. Play Solo at a desktop 16:9 viewport.
2. Resize the Studio game window to a narrow portrait-like viewport.
3. Verify Home, Games, Leaderboard, Stats and Settings remain reachable.
4. Verify every primary touch button is visually large enough to tap.
5. Verify the Game Select list scrolls instead of overflowing the screen.

Known bridge rule:
The GitHub bridge imports text source into real Studio Script/LocalScript/ModuleScript instances. Binary RBXM assets are not downloaded as Lua source; they remain a separate Studio asset/import step.