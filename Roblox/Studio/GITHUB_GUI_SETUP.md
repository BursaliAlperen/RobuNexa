# GitHub -> Roblox GUI runtime bridge

## What changed

The old GitHubBootstrap.client.lua only checked whether GitHub was reachable.
It now acts as the StarterPlayerScripts client-side bridge.

The actual download/compile step lives in:

- Roblox/Studio/GitHubGuiLoader.server.lua

The GitHub-hosted GUI factory lives in:

- Roblox/GitHubGUI/Main.lua

Runtime flow:

1. StarterPlayerScripts/GitHubBootstrap.client.lua starts on the client.
2. ServerScriptService/GitHubGuiLoader.server.lua fetches the raw GitHub file.
3. The server compiles the trusted source with loadstring.
4. The source must return function(player).
5. The factory creates that player's ScreenGui.
6. The resulting GUI replicates to the client.
7. Existing GUI objects are not replaced by this bridge.

## Required Studio settings

Enable:

File -> Experience Settings -> Security -> Allow HTTP Requests

Also enable ServerScriptService.LoadStringEnabled.

loadstring is server-only in Roblox. A LocalScript in StarterPlayerScripts cannot
reproduce game:HttpGet(...):loadstring(...).

## Production hardening

During development the loader uses:

GITHUB_REF = "rbxm-moveset-system"

After the PR is merged, change it to main or, preferably, an immutable commit SHA.

Do not point the loader at an untrusted repository. The downloaded source executes
with server permissions.

## GUI contract

Roblox/GitHubGUI/Main.lua must return:

function(player)

It can create ScreenGui, Frames, TextButtons, Images, UIStroke,
UICorner, UIGradient, sounds, animations, and other trusted Roblox instances.

For client-only input/animation code, put a LocalScript in the GUI itself or
use a small client module that is already present in the place. Do not put
server secrets into this GitHub source.

## Important

This bridge is for Lua source. It does not turn arbitrary .rbxm binary data
into Roblox Instances. RBXM assets remain handled by the existing imported-asset
pipeline.
