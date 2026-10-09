# NAM — by mamalalanam

## Main catalog
- Dances: Hakari's Dance, Gojo Awake
- Moveset: Cursed car anim (formerly Patchma Hub)
- Reanimation: Limb Reanimator only
- Supported notification: R6 + Torso detected -> `Supported game detect`
- Unsupported notification: otherwise -> `Unsupported game !!! >:D`

The original `content/GojoAwaken.anim` is a Roblox binary KeyframeSequence (RBXM), not the custom binary format consumed by `AnimLib.Track.fromfile`. The workflow `convert-gojo-track.yml` converts it into `content/GojoAwakeTrack.anim` as AnimLib-compatible JSON. The Gojo module loads that converted track and sets `animator.map = nil`, preventing the default time map from freezing playback at t=0.
