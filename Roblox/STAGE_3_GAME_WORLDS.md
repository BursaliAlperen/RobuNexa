# Stage 4 — 10 Detailed Playable Mechanics

The two-script runtime now includes detailed core gameplay instead of placeholder tap scoring.

## Games

1. **Dodge Run** — three-lane arena, moving obstacles, collision penalty, knockback, combo reset and camera feedback.
2. **Target Rush** — 3D neon targets; desktop mouse and mobile touch raycast to select targets; server validates target identity and player distance.
3. **Stack Tower** — moving block timing, overlap calculation, shrinking block width, miss/reset state and physical tower growth.
4. **Coin Rush** — rotating/bobbing 3D coin pickups, server touch validation, respawning coins, score bursts.
5. **Jump Challenge** — 18 elevated platforms, server checkpoints, progression tracking and checkpoint VFX.
6. **Reaction Test** — randomized server signal timing, reaction-time measurement, early-tap penalty and miss timeout.
7. **Color Rush** — four physical color pads plus mobile choice UI; the server selects the target color and validates the submitted choice.
8. **Memory Match** — server-generated 2–4 step sequences, animated reveal, player sequence input, server-side validation and round scoring.
9. **Falling Platforms** — 28 platforms that temporarily collapse after contact and restore for continued runs.
10. **Floor Is Lava** — safe/lava tile field with a rising lava volume, reset point, combo penalty and movement scoring.

## Feedback layer

- 3-2-1-GO countdown
- score/combo pulse
- hit/lava/incorrect flash
- camera shake on impact
- checkpoint bursts
- server-created ParticleEmitter bursts
- per-game objective text
- reaction-time display
- game-specific mobile controls
- local UI sound hooks using Roblox sound assets; project audio can later replace them without changing game logic

## Multiplayer isolation

Each player receives an isolated arena at a separate X-axis slot under workspace.RobuNexaWorld, so separate active sessions do not overlap.

## Security

The server owns:
- score
- round state
- target identity checks
- reaction timing
- color target
- memory sequence
- stack overlap calculation
- pickup touch handling
- lava/platform mechanics
- game duration
- DataStore best-score write

The client sends interaction requests; it does not authoritatively set score.

## Studio setup

Only two instances are required:

ServerScriptService > RobuNexaServer (Script)
StarterPlayer > StarterPlayerScripts > MainClient (LocalScript)

Press Play → OYUNLAR → choose a game.

### Important test note

Roblox Studio cannot be executed inside this chat environment, so this commit is code-complete from the repository side but still needs a Play/Test run in Studio for engine/runtime verification.