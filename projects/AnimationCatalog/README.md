# RobuNexa Animation Catalog (Studio)

A small, executor-free animation and audio catalog for your own Roblox experience.

## Install
1. In Roblox Studio, create a LocalScript under StarterPlayer > StarterPlayerScripts.
2. Copy AnimationCatalog.client.lua into it.
3. Upload animations and audio you own or have permission to use to Roblox.
4. Replace the 0 values in CATALOG with their Roblox asset IDs.
5. Play-test. Press G to open/close the catalog; click an entry to play it.

## Important
- Raw GitHub .anim files and .mp3 files are not playable as Roblox animation/audio IDs. Upload permitted assets to Roblox and use the resulting IDs.
- Audio and animation permissions must allow the experience to use those assets.
- The script uses the character's existing Humanoid.Animator; it does not delete the Animator or use executor-only APIs.
- It does not include or mirror third-party animation/audio packs whose redistribution permissions are unclear.
- For animation replication, Roblox requires an Animator created by the server and replicated to clients. See https://create.roblox.com/docs/reference/engine/classes/Animator/LoadAnimation
