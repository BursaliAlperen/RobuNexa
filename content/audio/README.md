# Audio assets and playback troubleshooting

The runtime downloader supports both repository layouts for MP3 assets:

- Preferred: `content/sounds/<file>.mp3`
- Legacy fallback: `content/audio/<file>.mp3`

The local executor cache is `NAMReanim/Content/Sounds/`. The downloader checks the HTTP status, rejects HTML error pages, verifies that bytes were written, and waits for asynchronous downloads before animation/dance callers continue.

## Important distinction

A raw GitHub MP3 URL is a file-download URL, not a Roblox `SoundId`. For Roblox-hosted sound IDs, use `rbxassetid://<id>` and make sure the experience/account has permission to use that sound. For executor-local audio files, the client must support `getcustomasset` / `getsynasset` and local filesystem APIs.

## When a sound is still silent

1. Check the console for `[NAM] Download failed`, `Asset unavailable after download wait`, or `[Gojo] Sound did not load`.
2. Open the exact raw URL and confirm it returns audio bytes, not a 404 page.
3. Confirm the file is actually committed under one of the paths above. Code cannot restore an audio file that is absent from the repository.
4. If using `rbxassetid://`, verify the asset is permitted for the experience. Successful GitHub download does not grant Roblox audio permissions.
5. Check mute settings and system/game volume.

Do not commit empty placeholder MP3 files. Keep the original audio bytes intact.
