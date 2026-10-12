# RobuNexa Reanimation Engines

## Important: choose one reanimation owner

The project has two separate entrypoints:

- **NAM + movesets:** `source/reanim.lua`. This contains NAM's native reanimation APIs and loads Gojo and Sukuna as separate movesets.
- **External engine selector:** `source/reanimation/engine.lua`. This is a standalone alternative for testing external engines.

**Do not execute both entrypoints in the same session.** They both manage the local character rig and can fight over the character, accessories, animation controller, and death state.

## Available external engines

Edit the `ENGINE` value near the top of `engine.lua`. Only these three options are included: `KRYPTON`, `GELATEK`, and `GELATEK_EDIT`. Only one option can run at a time.

| Value | Upstream | Notes |
|---|---|---|
| `KRYPTON` | [KadeTheExploiter/Krypton](https://github.com/KadeTheExploiter/Krypton) | Recommended current option. Configures `PermanentDeath = true`; fling is disabled. |
| `GELATEK` | [Gelatekussy/GelatekReanimate](https://github.com/Gelatekussy/GelatekReanimate) | Legacy limb handler. Its upstream warns it is unreliable in modern games. |
| `GELATEK_EDIT` | [InfinityNess/GelatekReanimateEdit](https://github.com/InfinityNess/GelatekReanimateEdit) | Community fork; configured with permanent death enabled and fling/bullet modes disabled. |

Krypton is the default. Upstream projects may change or become unavailable, and external executor scripts cannot be validated in every Roblox experience from a repository commit.

## NAM and movesets

Gojo and Sukuna stay **separate** in NAM's module list:

- `content/movesets/Gojo/module.lua`
- `content/movesets/Sukuna/v_sukuna.lua`

The external selector does **not** automatically adapt the NAM-specific `Reanimate`, `HatReanimator`, or `LimbReanimator` APIs. Therefore, using an external engine does not imply that NAM's movesets are compatible with it. For NAM movesets and their existing hat/limb handling, use `source/reanim.lua` alone.

## Sources

- [Krypton README](https://github.com/KadeTheExploiter/Krypton)
- [Gelatek legacy README](https://github.com/Gelatekussy/GelatekReanimate)
- [Gelatek Edit README](https://github.com/InfinityNess/GelatekReanimateEdit)
