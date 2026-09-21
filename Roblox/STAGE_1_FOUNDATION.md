# Etap 1 — Foundation

Stage 1 establishes the Roblox runtime skeleton before visual polish and gameplay balancing.

## What Stage 1 guarantees

- Shared configuration is centralized in GameConfig.
- RemoteEvents are created/owned by the server-side Remotes module.
- The 10 mini-games have a common module boundary.
- Server gameplay services are separated from client UI code.
- DataStore/OrderedDataStore logic is not exposed to clients.
- The runtime does not use arbitrary Lua download + loadstring execution.
- Foundation.server.lua validates the expected tree when the server starts.

## Studio setup

Create the instances with the exact names/types already documented in the repository, then paste each matching source file into its corresponding Script, LocalScript or ModuleScript.

After pressing Play in Studio, the server output should contain:

    [RobuNexa][Stage 1] Foundation validated: modules, 10 mini-games, server services and client entry points.

## Important

This is an edit-time Studio project structure. A live LocalScript cannot create arbitrary server Script/ModuleScript source from GitHub and execute it. GitHub remains the source-control layer; Roblox Studio contains the actual runtime instances.