# RobuNexa RBXM moveset system

Runtime never downloads or reconstructs .rbxm or decoded .txt data. A real RBXM is imported once in Roblox Studio and cloned from the cached Instance tree.

Recommended cache:
ServerStorage/RBXMAssets/Garou
ServerStorage/RBXMAssets/Sukuna
ServerStorage/RBXMAssets/Cosmic

Skill discovery:
1. Moveset/Skills/SkillName
2. If Skills does not exist, direct Folder/Model children are treated as skills.

Generated Tool attributes:
Moveset, SkillName, RBXMAsset, Cooldown, optional Duration.

Activation:
Tool -> SkillController -> real RBXM skill clone -> real VFX/Sounds -> real Animation.

No player teleport is performed. The character CFrame is never overwritten.

Animation priority:
1. Imported Animation with AnimationId.
2. Imported KeyframeSequence is preserved and detected.
3. No fake/procedural animation is generated.

VFX:
Imported ParticleEmitter, Beam, Trail, Light, Sound, MeshPart, SpecialMesh, Attachment and other Instances are cloned. Source properties are not recreated from decoded manifests.

Shop integration:
Keep the existing GUI and Shop NPC code. From the existing successful purchase handler call:
require(game.ServerScriptService.ShopMovesetController).GrantPurchasedMoveset(player, "Sukuna")

One-time Studio setup:
1. Download the real .rbxm from GitHub with a browser.
2. Import it into ServerStorage/RBXMAssets.
3. Rename the imported root to the exact moveset name.
4. Do not rewrite the imported hierarchy/properties.
5. Install the scripts from Roblox/Studio into ServerScriptService.
6. Remove/disable CosmicLoader.server.lua, CosmicInstaller.server.lua and CosmicInstaller.commandbar.lua.
7. Stop using Cosmic_VFX_decoded.txt and CosmicG_VFX_decoded.txt.
8. Keep the existing GUI/Shop scripts unchanged.
9. If using GitHub source sync for Lua, HTTP can remain enabled in Studio. Runtime RBXM loading does not require GitHub HTTP.

Roblox limitation:
A game runtime cannot safely turn an arbitrary GitHub .rbxm URL into Instances using require() or normal HTTP. The reliable path is GitHub .rbxm -> Studio import -> ServerStorage/RBXMAssets -> runtime clone.
