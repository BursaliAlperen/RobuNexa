# NAM → RobuNexa migration

## Changes made on this branch

- `Reanim.txt` now loads the legacy built-in module files from RobuNexa's `content/` directory.
- Vendored these upstream modules into `content/`: `v_moveset1.lua`, `v_moveset2.lua`, `v_moveset3.lua`, `v_dance1.lua`, `v_dance2.lua`, `d_limbmap.lua`, and `d_hatsmap.lua`.
- Preserved the upstream MIT license in `content/LICENSE-Uhhhhhh.txt`.
- Added a RobuNexa `CHANGELOGS` file and updated the changelog link.
- Removed the Pusher listener that executed arbitrary server-supplied Lua through `loadstring`.
- Added the R6 KeyframeSequence generator and guide under `Animations/R6/`.

## Important remaining limitations

This is a partial migration, not a verified end-to-end executor release. The legacy store still refers to `STEVE-916-create/Uhhhhhh-Store`; its store manifest and assets have not yet been copied. The startup UI also requests assets from RobuNexa's `uiassets/` folder, but the original image/music assets have not been mirrored there. Those features may be unavailable until their files are migrated.

The script still uses executor-specific APIs such as `request`, `readfile`, `writefile`, `loadstring`, and `getcustomasset`. This is not a Roblox Studio LocalScript and cannot run unchanged in Studio. The built-in modules are downloaded as Lua source and compiled locally; review them before use. Do not reintroduce the removed Pusher remote-code handler.

## Testing still required

- Test syntax and startup in the target executor; no live executor runtime was available for this edit.
- Verify the limb-map/hat-map modules and animation playback with a classic R6 avatar.
- Mirror and verify all referenced store/UI assets before claiming full dependency independence.
- Export generated KeyframeSequences from Studio and confirm they play before publishing asset IDs.

## R6 animation files

The generator creates starter KeyframeSequence instances in Studio. It does not contain already-published Roblox animation asset IDs or guarantee production-ready animation timing.
