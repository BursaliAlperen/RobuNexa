# RobuNexa shared player/NPC movesets

This adapter lets a game you own use the same moveset API for player character Models and NPC Models. It does not make R6-only animation assets automatically compatible with R15; register the rig types the animation was authored for.

## 1. Install

Put `RobuNexa_MovesetCompatibility.lua` in `ReplicatedStorage` as a ModuleScript named `MovesetCompatibility`.

## 2. Register weapon movesets

Require the module from a Script or LocalScript, then register your uploaded animation IDs. Replace the sample IDs with animations you own or are permitted to use.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Movesets = require(ReplicatedStorage:WaitForChild("MovesetCompatibility"))

Movesets.RegisterMoveset("Sword", {
    RigTypes = { R6 = true }, -- change to R15=true for R15-authored assets
    Animations = {
        Idle = "0000000000",
        Equip = "0000000000",
        M1 = "0000000000",
        M2 = "0000000000",
        Finisher = "0000000000",
    },
})

Movesets.RegisterMoveset("AK47", {
    RigTypes = { R6 = true },
    Animations = {
        Idle = "0000000000",
        Equip = "0000000000",
        Fire = "0000000000",
        Reload = "0000000000",
    },
    LoopedActions = { Idle = true },
})
```

## 3. Play on a player or NPC

The target is the character Model in either case. For player characters, run the playback from that player's LocalScript for responsive local playback. For NPCs whose animation must replicate to everyone, run it on the server.

```lua
local ok, result = Movesets.Play(characterModel, "Sword", "M1")
if not ok then
    warn(result)
end

-- Switch to another weapon's moveset:
Movesets.Play(characterModel, "AK47", "Reload")

-- Stop one action:
Movesets.Stop(characterModel, "AK47", "Reload")
```

## Compatibility notes

- The API accepts any Model with a Humanoid and uses its Animator.
- `GetAvailableMovesets(model)` returns registered movesets whose `RigTypes` include the target's rig.
- Sword and AK47 are separate move definitions, so each weapon can have its own idle, equip, attack/fire, reload, and finisher animations.
- Animation IDs are intentionally not fabricated. Replace the sample values with valid uploaded IDs before testing.
- Animation ownership/permissions still apply. NPC replication should be tested in Studio with server and client sessions.
- This adapter is for a Roblox experience you own or are authorized to develop; it is not an executor feature for forcing animations on other players in someone else's game.
