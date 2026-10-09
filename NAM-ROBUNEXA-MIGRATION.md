# NAM → RobuNexa migration notes

This branch prepares the repository-side migration without replacing the existing 7,407-line `Reanim.txt` blindly.

## Current state

- Existing entry point: `Reanim.txt` (preserved unchanged on this branch).
- R6 animation starter: `Animations/R6/GenerateR6Keyframes.lua`.
- R6 export instructions: `Animations/R6/README.md`.
- New content root for RobuNexa-hosted static files: `https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/`.

## Why the old content URLs cannot be mechanically replaced

The current script requests UHHH-specific paths such as `content/`, `uiassets/`, `CHANGELOGS`, and the UHHH-Store `list.txt`. Those paths and the file manifest have not been verified to exist in RobuNexa. Replacing only the hostname would produce broken paths and potentially execute unexpected files.

## Critical security finding

The old entry point subscribes to Pusher channels and calls `loadstring(data.content)` on a received `jumpscare` event, then invokes the resulting function. The function environment is also populated with NAM functions. This is remote code execution by design. Do not carry this handler into a RobuNexa build. This branch deliberately does not reproduce it.

Other dynamic execution sites load local module files and modules downloaded from remote manifests. A safe migration should either:
1. use reviewed, versioned local modules; or
2. download passive data/assets only, validate response status, content type, size and hashes, and never compile downloaded text as code.

A URL rename or a cache hash alone is not a signature or trust boundary.

## Migration checklist

- [ ] Inventory the files RobuNexa actually hosts; don't assume UHHH's directory structure.
- [ ] Replace each UHHH content/asset/changelog/store path with a verified RobuNexa path.
- [ ] Remove the Pusher `jumpscare` code-execution handler and unused subscriptions.
- [ ] Audit every remaining `loadstring`, `getfenv`, `setfenv`, `request`, `HttpGet`, `readfile`, and `writefile` use.
- [ ] Test only in a Roblox Studio place and on a classic R6 rig you control.
- [ ] Export and inspect the generated R6 KeyframeSequences before publishing.

## Branch scope

This is a preparation/documentation branch. It does not replace `Reanim.txt`, publish animation asset IDs, or claim that the legacy executor script is compatible with Studio.
