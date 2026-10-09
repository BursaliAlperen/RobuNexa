# RobuNexa — R6 KeyframeSequences

This folder contains an original Studio-side generator for three classic R6 starter animations:

- `RobuNexa_R6_Idle` — gentle idle loop
- `RobuNexa_R6_Wave` — short wave gesture
- `RobuNexa_R6_Walk` — simple alternating walk cycle

## Create and export the KeyframeSequence files

1. Open a place you own in Roblox Studio and use a classic **R6** rig.
2. Paste `GenerateR6Keyframes.lua` into the Studio Command Bar (or run it as a temporary Script in Studio).
3. The script creates editable `KeyframeSequence` instances under `ReplicatedStorage`.
4. Inspect each sequence on an R6 rig in Animation Editor; adjust poses/timing if needed.
5. Move the sequence under the rig's `AnimSaves` folder and use **Save to File** to export it as `.rbxmx`.

These are starter animations generated locally in Studio, not published Roblox animation asset IDs. Publish them from Animation Editor if you need asset IDs. Studio-generated exports are preferable to hand-written XML because they preserve Roblox's expected serialization.

## Scope and safety

These files are for Roblox Studio projects you own. This folder intentionally does not alter `Reanim.txt` or connect animation loading to an executor, third-party remote code, or the former UHHH service. The existing `Reanim.txt` contains a WebSocket handler that executes received text with `loadstring`; changing its upstream URLs alone would not remove that remote-code-execution risk.

See the official [KeyframeSequence reference](https://create.roblox.com/docs/reference/engine/classes/KeyframeSequence) and [animation export guide](https://create.roblox.com/docs/education/build-it-play-it-island-of-move/sharing-animations).
