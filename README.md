# RobuNexa — NAM Reanimate (R6)

RobuNexa is a repository-side adaptation of the NAM Reanimate script. This branch keeps the existing reanimation/moveset framework, hosts the built-in Lua modules in this repository, removes the old Pusher remote-code execution listener, and adds original R6 anime-inspired dance/pose modules.

> **Status:** migration build, not a certified release. It has not been executed in a live executor during this repository edit. Test in a private place or a Roblox Studio test project first.

## Contents

- `Reanim.txt` — main NAM Reanimate entry point.
- `LoadRobuNexa.lua` — GitHub loadstring launcher pinned to a specific Reanim.txt commit.
- `content/` — built-in NAM modules and the upstream MIT license notice.
- `Animations/R6/` — 15 original R6 animation sequences, plus the Studio generator.
- `Modules/RobuNexaConfig.lua` — passive URL/path configuration example.
- `NAM-ROBUNEXA-MIGRATION.md` — migration notes and remaining limitations.
- `store/list.txt` — intentionally empty community marketplace manifest for this release.

## Quick start (executor)

Use only an executor/environment you trust, and only in places where you have permission to test. The script requires executor-specific filesystem/network functions; it is **not** a normal Roblox Studio LocalScript.

Run this in the executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/2d1070e80dd105635ded81148a7976cf8314fd1e/Reanim.txt"))()
```

Or run the contents of `LoadRobuNexa.lua`.

The URL pins the entry point to an immutable commit. Built-in modules and animation files are also fetched from a pinned repository snapshot by the entry point. A pinned URL helps make the fetched version reproducible; it does not replace reviewing code before running it.

## First launch

1. Start with an R6 avatar. R15 is not supported by the included animation set.
2. Execute the launcher and allow the script to create its `NAMReanim/` folders.
3. Open the NAM UI and let the built-in modules finish loading.
4. Open the Dances list and choose one of the `RN ...` animations.
5. If a module fails, open **Init Logs** and inspect the first download/compile error. Do not keep retrying if the log reports an HTTP 404 or a compile error.
6. To reset a stale local cache, close the script and back up then remove the relevant files under `NAMReanim/BuiltinModules/` or `NAMReanim/Content/Anims/`. Do not delete your save file unless you want to reset settings.

## Included original R6 animations

The animation motions below were authored for this repository and are anime-inspired, not copies of a named anime character or show:

| Name in the Dances list | Behavior |
|---|---|
| RN Anime Idle | Looping idle pose |
| RN Anime Walk | Looping walk cycle |
| RN Anime Run | Looping run cycle |
| RN Wave | Greeting wave |
| RN Anime Guard | Looping guard pose |
| RN Anime Dash | Forward-lean pose; no root propulsion |
| RN Victory Pose | Celebration |
| RN Anime Punch | Visual pose only; no hitbox or damage |
| RN Spin Kick | Visual pose only; no hitbox or damage |
| RN Salute | Salute gesture |
| RN Bow | Bow gesture |
| RN Power Charge | Looping power-up pose |
| RN Sword Slash | Visual pose only; no weapon/hitbox/damage |
| RN Jump Land | Jump/landing pose sequence; no root movement |
| RN Point | Pointing gesture |

These are animation poses only. They do not implement attacks, damage, hitboxes, teleportation, or server-side movement.

## Security model

- The old Pusher WebSocket listener that compiled and executed remote `jumpscare` event text using `loadstring` has been removed.
- Built-in module and animation URLs are pinned to a reviewed immutable commit.
- Animation payloads are data. They are decoded and passed to NAM's KeyframeSequence parser; they are not compiled as Lua.
- The community store is intentionally empty. No third-party community module catalogue is loaded by default.
- NAM still uses executor APIs and `loadstring` to load its built-in Lua modules. Any local file placed in `NAMReanim/Modules/` is user code and may execute. Only keep modules you wrote or reviewed.
- Never paste an unknown loadstring, share account cookies/session tokens, or disable security protections to run an untrusted script.

## About the `.anim` files

NAM's `AnimLib.Track.fromfile` expects the little-endian STEVE KeyframeSequence format, not JSON. GitHub-hosted `.anim` files in this branch are stored as Base64 text so the repository editing interface can preserve the binary payload. The RobuNexa loader detects these pinned animation URLs, decodes them, and writes native binary `.anim` files to `NAMReanim/Content/Anims/` before NAM reads them.

If you download a raw `.anim` URL directly in a browser, you will get the encoded source text, not a ready-to-import binary file. Use the loader or decode the Base64 content before importing elsewhere.

## Remaining limitations

- No live executor test was available during this migration; executor API compatibility may vary.
- Legacy UI audio/image binaries have not been mirrored. Core modules and animations are hosted here, but optional UI media may be missing.
- The store is empty by design. Add only reviewed modules with clear licensing and pinned asset URLs.
- The R6 Studio generator creates editable `KeyframeSequence` objects; it does not publish animation asset IDs automatically.
- The repository does not promise compatibility with every Roblox experience or every executor.

## Official references

- [Roblox Animation Editor](https://create.roblox.com/docs/animation/editor)
- [KeyframeSequence API](https://create.roblox.com/docs/reference/engine/classes/KeyframeSequence)
- [Export and import animations in Studio](https://create.roblox.com/docs/education/build-it-play-it-island-of-move/sharing-animations)

## License and attribution

The vendored legacy built-in modules are under the upstream MIT license; see `content/LICENSE-Uhhhhhh.txt`. The RobuNexa animation motions are original repository content. Respect Roblox's terms, game owners' rules, and third-party asset licenses.
