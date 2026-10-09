# RobuNexa — R6 animation library

This directory has 15 original R6 animation sequences (Base64-wrapped native data) and a Roblox Studio generator. A separate ready-to-use native binary Hakari dance is stored at assets/anime/Hakari.anim.

## Included animations

- idle — idle
- walk and run — locomotion loops
- wave, salute, bow, point — gestures
- anime_guard and power_charge — looping poses
- dash, punch, spin_kick, sword_slash, jump_land, victory_pose — short pose sequences

These are anime-inspired original motions, not extracted copies of specific anime scenes or characters. Punch/slash/kick animations are visual only: they do not add hitboxes, damage, root propulsion, or server-side effects.

## Using them in NAM Reanimate

1. Run LoadRobuNexa.lua from an executor environment you trust.
2. Wait for built-in modules to load.
3. Open the Dances list and select an RN ... entry.
4. The module downloads the pinned .anim source, decodes its Base64 wrapper to the native STEVE KeyframeSequence format, and saves it under NAMReanim/Content/Anims/.
5. If an animation fails, open Init Logs and inspect the download/parse error.

The GitHub text interface cannot store arbitrary binary bytes through the ordinary text-file action used for this repository. Therefore the .anim source files are Base64 text wrappers around the native binary format. They are **not JSON** and must be decoded before AnimLib.Track.fromfile reads them. The included pinned loader does that automatically.

## Studio workflow

1. Open a place you own in Roblox Studio and insert a classic **R6** rig.
2. Run GenerateR6Keyframes.lua in Studio's Command Bar.
3. Inspect the generated KeyframeSequence instances and adjust the timing/poses as needed.
4. Save/export through the Animation Editor. Roblox's native workflow exports a .rbxm/.rbxmx file and can publish an animation asset ID.

The generator creates editable starter sequences; it does not publish asset IDs automatically. See the official [Animation Editor docs](https://create.roblox.com/docs/animation/editor), [KeyframeSequence reference](https://create.roblox.com/docs/reference/engine/classes/KeyframeSequence), and [export/import guide](https://create.roblox.com/docs/education/build-it-play-it-island-of-move/sharing-animations).

## Ready-to-use native animation added

- assets/anime/Hakari.anim is the original native binary asset copied from [STEVE-916-create/Uhhhhhh, content/Hakari.anim](https://github.com/STEVE-916-create/Uhhhhhh/blob/5047db0f1880c8405546bf860db7bf6bf2f84e82/content/Hakari.anim). Its source blob SHA is 021b9bc624177cd1f56faabec91b362d1410a184. The upstream repository's MIT license is preserved at content/LICENSE-Uhhhhhh.txt; provenance and scope are recorded in assets/anime/README.md.

Other public Gojo/Sukuna/Kira results found during the search were Creator Store item listings, not distributable native .anim files. They are linked from the main README rather than copied into this repository.

## Compatibility

- R6 only. R15 poses use a different joint layout.
- The executor build uses NAM's AnimLib parser; this is not a standalone Roblox Studio LocalScript.
- No live executor test was available during the repository edit.
