# NAM → RobuNexa migration

## Changes made on robunexa-nam-adaptation

- Reanim.txt now uses RobuNexa-hosted built-in modules and a pinned immutable content snapshot.
- Vendored the upstream MIT modules: v_moveset1.lua, v_moveset2.lua, v_moveset3.lua, v_dance1.lua, v_dance2.lua, v_robunexa_anime.lua, d_limbmap.lua, and d_hatsmap.lua.
- Preserved the upstream MIT license in content/LICENSE-Uhhhhhh.txt.
- Added 15 original R6 animation sequences and a NAM dance module that exposes them in the Dances list.
- Added LoadRobuNexa.lua, a launcher pinned to a specific Reanim.txt commit.
- Removed the legacy Pusher listener that executed arbitrary server-supplied Lua through loadstring.
- Removed unnecessary third-party MP3 downloads that were only used for local file comparisons.
- Replaced the community store manifest with an intentionally empty RobuNexa manifest. Optional legacy UI media binaries have not been mirrored.

## Security and compatibility notes

This is a migration build, not a certified release. The script still uses executor-specific APIs such as request, readfile, writefile, loadstring, and getcustomasset. It is not a normal Roblox Studio LocalScript. Local files under NAMReanim/Modules/ are executable user code; only keep modules you wrote or reviewed.

Built-in Lua modules are downloaded from a pinned immutable commit and compiled locally. Animation payloads are data, Base64-decoded to the native KeyframeSequence format, and never compiled as Lua. The old Pusher jumpscare remote-code execution handler is removed.

## Testing still required

- Test startup and module parsing in the intended executor.
- Verify all 15 animation sequences on a classic R6 avatar; pose quality may need tuning.
- Verify limb/hat reanimation behavior in a private test place. Compatibility varies by experience and executor.
- Export the Studio-generated KeyframeSequences and publish them manually if public Roblox animation IDs are needed.

## Official documentation

- [Animation Editor](https://create.roblox.com/docs/animation/editor)
- [KeyframeSequence API](https://create.roblox.com/docs/reference/engine/classes/KeyframeSequence)
- [Export/import animations](https://create.roblox.com/docs/education/build-it-play-it-island-of-move/sharing-animations)
