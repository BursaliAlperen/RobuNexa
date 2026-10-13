#!/usr/bin/env python3
"""Validate every animation/sound URL referenced by NAM moveset Lua files. Runs in CI after asset-path fixes."""
from __future__ import annotations

import math
import re
import struct
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parents[1]
MOVES = ROOT / "content" / "movesets"
URL_RE = re.compile(r"https?://[^\s\"'<>]+?\.(?:anim|mp3)(?:\?[^\s\"'<>]*)?", re.IGNORECASE)
USER_AGENT = "RobuNexa-NAM-Asset-Validator/1.0"


def read_u16(data: bytes, pos: int) -> tuple[int, int]:
    if pos + 2 > len(data):
        raise ValueError(f"truncated u16 at byte {pos}")
    return struct.unpack_from("<H", data, pos)[0], pos + 2


def read_u32(data: bytes, pos: int) -> tuple[int, int]:
    if pos + 4 > len(data):
        raise ValueError(f"truncated u32 at byte {pos}")
    return struct.unpack_from("<I", data, pos)[0], pos + 4


def read_f32(data: bytes, pos: int) -> tuple[float, int]:
    if pos + 4 > len(data):
        raise ValueError(f"truncated f32 at byte {pos}")
    value = struct.unpack_from("<f", data, pos)[0]
    if not math.isfinite(value):
        raise ValueError(f"non-finite float at byte {pos}")
    return value, pos + 4


def read_string(data: bytes, pos: int) -> tuple[str, int]:
    length, pos = read_u16(data, pos)
    end = pos + length
    if end > len(data):
        raise ValueError(f"truncated string at byte {pos} (length {length})")
    return data[pos:end].decode("utf-8"), end


def validate_anim(data: bytes) -> None:
    # Same binary layout as AnimLib.Track.frombuffer in source/reanim.lua.
    name, pos = read_string(data, 0)
    if not name:
        raise ValueError("empty animation name")
    count, pos = read_u32(data, pos)
    if count < 1 or count > 100000:
        raise ValueError(f"invalid keyframe count: {count}")
    total_poses = 0
    for _ in range(count):
        frame_time, pos = read_f32(data, pos)
        if frame_time < 0:
            raise ValueError("negative keyframe time")
        pose_count, pos = read_u32(data, pos)
        if pose_count > 10000:
            raise ValueError(f"unreasonable pose count: {pose_count}")
        total_poses += pose_count
        for _ in range(pose_count):
            pose_name, pos = read_string(data, pos)
            if not pose_name:
                raise ValueError("empty pose name")
            _, pos = read_f32(data, pos)  # weight
            style, pos = read_string(data, pos)
            direction, pos = read_string(data, pos)
            if not style or not direction:
                raise ValueError("missing easing style/direction")
            for _ in range(12):
                _, pos = read_f32(data, pos)  # CFrame components
    if total_poses < 1:
        raise ValueError("animation has no poses")
    if pos != len(data):
        raise ValueError(f"{len(data) - pos} trailing bytes after animation data")


def validate_payload(url: str, data: bytes) -> None:
    suffix = urlsplit(url).path.lower()
    if not data:
        raise ValueError("empty response")
    if data[:256].lstrip().lower().startswith((b"<!doctype html", b"<html")):
        raise ValueError("server returned an HTML error page")
    if suffix.endswith(".anim"):
        validate_anim(data)
    elif suffix.endswith(".mp3"):
        if len(data) < 128:
            raise ValueError(f"MP3 payload too small ({len(data)} bytes)")
        is_id3 = data.startswith(b"ID3")
        is_frame_sync = len(data) >= 2 and data[0] == 0xFF and (data[1] & 0xE0) == 0xE0
        if not (is_id3 or is_frame_sync):
            raise ValueError("payload does not have an MP3 ID3 header or MPEG frame sync")


def fetch_and_validate(url: str) -> int:
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    last_error = None
    # A second attempt handles transient CDN/raw-GitHub failures.
    for attempt in range(2):
        try:
            with urllib.request.urlopen(request, timeout=25) as response:
                status = getattr(response, "status", 200)
                payload = response.read()
            if status < 200 or status >= 300:
                raise ValueError(f"HTTP {status}")
            validate_payload(url, payload)
            return len(payload)
        except Exception as exc:  # report every broken URL instead of hiding failures
            last_error = exc
            if attempt == 0:
                time.sleep(1)
    raise RuntimeError(f"{url}: {last_error}")


def main() -> int:
    if not MOVES.is_dir():
        print(f"Moveset directory not found: {MOVES}", file=sys.stderr)
        return 2
    urls: dict[str, list[str]] = {}
    for file in MOVES.rglob("*.lua"):
        text = file.read_text(encoding="utf-8", errors="replace")
        for match in URL_RE.findall(text):
            url = match.rstrip("),;")
            urls.setdefault(url, []).append(str(file.relative_to(ROOT)))

    if not urls:
        print("No explicit .anim/.mp3 URLs found in content/movesets.")
        return 0

    failures = []
    print(f"Checking {len(urls)} unique animation/sound URLs referenced by movesets...")
    for index, (url, files) in enumerate(sorted(urls.items()), 1):
        try:
            size = fetch_and_validate(url)
            print(f"[{index}/{len(urls)}] OK {size} bytes | {url}")
        except Exception as exc:
            failures.append(str(exc))
            print(f"[{index}/{len(urls)}] FAIL | {exc}", file=sys.stderr)

    if failures:
        print(f"\\nFAILED: {len(failures)} of {len(urls)} URLs failed validation.", file=sys.stderr)
        return 1
    print(f"\\nPASS: all {len(urls)} referenced animation/sound URLs returned valid payloads.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
