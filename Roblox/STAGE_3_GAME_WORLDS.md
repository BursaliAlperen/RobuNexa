# Stage 3 — 10 Real Core Mechanics

The two-script runtime now contains playable server-authoritative core mechanics for all ten games.

- **Dodge Run:** physical obstacles damage/reset combo when touched; player must move through the arena.
- **Target Rush:** physical targets appear in the arena and reward contact.
- **Stack Tower:** each valid tap places another physical block and increases tower height/score.
- **Coin Rush:** physical neon coin pickups reward collection.
- **Jump Challenge:** a sequence of elevated platforms rewards reaching later platforms.
- **Reaction Test:** server-controlled signal windows reward fast taps and penalize early/late taps.
- **Color Rush:** server rounds issue objective prompts and taps advance rounds.
- **Memory Match:** server rounds issue sequence objectives and taps advance them.
- **Falling Platforms:** touched platforms temporarily disappear and return, rewarding traversal.
- **Floor Is Lava:** safe green tiles reward movement; lava tiles reset the player and combo.

The server owns scoring, game validation, sessions and world creation. Client input is only a request.

### Studio setup

Only two instances are required:
- ServerScriptService > RobuNexaServer (Script)
- StarterPlayer > StarterPlayerScripts > MainClient (LocalScript)

Press Play → OYUNLAR → select a game.
