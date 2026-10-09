# .rbxmanims — Roblox animation upload folder

Upload your Aizen and Gojo animation model files here, for example:

- Aizen.rbxm
- Gojo.rbxm

Each file should contain a saved KeyframeSequence (or a model containing one), not only a single Keyframe. Please tell me whether each animation is R6 or R15 when you upload it. I can then inspect the structure and integrate compatible sequences into the NAM animation module.

## Export from Roblox Studio
1. Open the animation in Animation Editor and save it.
2. In Explorer, expand the rig's AnimSaves folder.
3. Right-click the named animation and choose Save to File.
4. Upload the resulting .rbxm here.

Roblox's official guide: https://create.roblox.com/docs/education/build-it-play-it-island-of-move/sharing-animations

Note: .rbxm is a model package, not a raw .anim binary. Simply uploading a model here does not automatically make the executor load it; it must be inspected and converted/integrated appropriately.