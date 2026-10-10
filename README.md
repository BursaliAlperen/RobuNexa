# NAM — by mamalalanam

A compact animation hub with a curated catalog.

## UI
- Top tabs: **NAM**, **ANIMS**, **LIMBS**, **SETTINGS**, and **ABOUT**.
- Only the selected main panel is shown.
- Dark purple/pink UI with compact, mobile-friendly controls.
- Preserve the existing project name and file paths for compatibility.

## Animation catalog
Display each animation exactly once. Source files and generated runtime tracks are separate formats and must not be treated as duplicate catalog entries.

- **Hakari's Dance** — `content/Hakari.anim`; audio asset should be verified before wiring.
- **Awaken Anime Sukuna** — use only after verifying the source sequence is actually Sukuna's awakening; do not relabel a Gojo sequence as Sukuna.
- **Imaginary Purple** — use the intended Hollow Purple sequence and `imaginary-hollow-purple_QmAgdbC.mp3`.
- **Cid Overdrive** — `CidOverdrive.anim` and its generated track.
- **Gojo flight** — a distinct animation/action that smoothly lifts the character, supports a stable airborne hold, and returns control safely. Do not fake flight by duplicating catalog entries.

## Asset hygiene
- Keep one visible catalog entry per animation.
- Keep a source KeyframeSequence when the conversion workflow needs it, and keep its generated runtime track when the player needs it. These are not interchangeable.
- Do not create numbered copies or duplicate audio assets.
- Keep the existing `imaginary-hollow-purple_QmAgdbC.mp3` and `soka-mona.mp3` assets as the intended named sound files.
- Remove obsolete documentation or binary assets only after confirming they are unreferenced by the UI, runtime loader, and GitHub Actions workflow.
- Do not remove `README.md` or the animation conversion workflow as part of cleanup.

## Immersive VR
Treat VR support as a separate feature using supported Roblox VR APIs. Keep the normal desktop/mobile controls working, and do not mark VR support complete until it has been tested in a VR session.
