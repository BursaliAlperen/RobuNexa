# Server-replicated R6 animation example

This example is for a Roblox experience you own or are authorized to edit. It is **not** an executor script and cannot force replication inside arbitrary third-party games.

## Install

1. Put `Server.server.lua` in `ServerScriptService`.
2. Put `Client.client.lua` in `StarterPlayer > StarterPlayerScripts`.
3. In `Server.server.lua`, replace each `REPLACE_WITH_ANIMATION_ID` with an animation asset ID that is usable by your experience. Replace sound placeholders with permitted audio IDs, or remove the `soundId` entries.
4. Test with **Test > Start** and at least two players. A one-client Studio test cannot verify what another player sees.

The server creates the `ReplicatedStorage.R6AnimationRequest` RemoteEvent. The client sends only an allowlisted animation name; it cannot submit arbitrary asset IDs. The server checks R6, rate-limits requests, and starts the animation through the character's server-visible `Animator`.

## Limitations

- Animation assets must be accessible to the experience and compatible with R6. Permission/ownership errors can prevent loading.
- This replicates normal R6 joint animations started by the server. It does not turn a local fake rig into a replicated character and does not implement exploit-style hat reanimation.
- Sound playback is parented to the character root so nearby clients can hear it when the audio asset is permitted.
- Roblox server authority, experience settings, and asset permissions still apply.
