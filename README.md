# RobuNexa — NAM Reanimate

A work-in-progress NAM Reanimate adaptation. It has not been validated in a live executor.

## Your uploaded animations

The `.rbxmanims/` folder is the drop zone for your native Roblox animation model files:

- `aizen.rbxm` — contains a `KeyframeSequence` named `aizen`. The readable model data shows a `RootPart` pose, but no clear limb poses, so it needs further compatibility inspection before it can be treated as a usable character animation.
- `gojo awake.rbxm` — contains a `KeyframeSequence` named `gojo awake` and readable R6-style body part names such as `Torso`, `Head`, `Left Leg`, and `Right Arm`. This looks more promising for R6, but still needs runtime validation.

I have verified that both files are Roblox binary model packages and that each contains a `KeyframeSequence`. They are stored in the repository, but they have **not yet been converted into NAM's custom `.anim` format or wired into the Dances list**. That conversion is the next step; simply uploading `.rbxm` files does not make the current executor loader play them.

For future files, upload them to `.rbxmanims/` and use descriptive names. Keep the original files unchanged until their sequences and rig compatibility have been checked.

## Repository files

- `Reanim.txt` — main NAM Reanimate script.
- `LoadRobuNexa.lua` — pinned GitHub launcher.
- `content/` — NAM built-in modules and upstream license notice.
- `assets/anime/Hakari.anim` — native binary Hakari dance asset mirrored with attribution.
- `.rbxmanims/` — uploaded Aizen and Gojo animation models.

## Animation format and import/export

Roblox Studio exports saved animations as `.rbxm` model files containing a `KeyframeSequence`. NAM's current animation reader expects a different native `.anim` format, so each model must be inspected and converted or loaded through a compatible path before integration.

Official documentation: [Export and Import Animations](https://create.roblox.com/docs/education/build-it-play-it-island-of-move/sharing-animations) · [KeyframeSequence API](https://create.roblox.com/docs/reference/engine/classes/KeyframeSequence)

## Security and licensing

- The legacy Pusher listener that compiled and executed arbitrary remote event text was removed from the adaptation.
- Review Lua modules before running them; executor scripts depend on executor-specific APIs and this project has not been live-tested.
- `content/LICENSE-Uhhhhhh.txt` is retained because upstream-derived modules require their license notice. It is not a runtime script; no separate `Uhhh.txt` or `Uhhh.tct` file exists in the current repository tree.
- Only add third-party animation files when you have permission to use and redistribute them.
