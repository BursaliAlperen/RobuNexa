#!/usr/bin/env python3
"""Convert the uploaded Roblox KeyframeSequence RBXM into NAM AnimLib JSON."""
from __future__ import annotations

import json
import math
import sys
from pathlib import Path
from typing import Any

from rbxm_parser import parse_rbxm


POSE_EASING_STYLE = {
    0: "Linear",
    1: "Constant",
    2: "Elastic",
    3: "Cubic",
    4: "Bounce",
    5: "CubicV2",
}
POSE_EASING_DIRECTION = {
    0: "In",
    1: "Out",
    2: "InOut",
}


def descendants(instance: Any):
    yield instance
    for child in getattr(instance, "children", []):
        yield from descendants(child)


def prop(instance: Any, key: str, default=None):
    getter = getattr(instance, "get_property", None)
    return getter(key, default) if callable(getter) else getattr(instance, "properties", {}).get(key, default)


def enum_name(value: Any, mapping: dict[int, str], default: str) -> str:
    if isinstance(value, str):
        result = value.rsplit(".", 1)[-1]
        return result if result else default
    try:
        return mapping.get(int(value), default)
    except (TypeError, ValueError, OverflowError):
        return default


def cframe_components(cf: Any) -> list[float]:
    position = getattr(cf, "position", None)
    rotation = getattr(cf, "rotation", None)
    if position is None or rotation is None or len(rotation) != 3:
        raise ValueError(f"Unsupported CFrame value: {type(cf).__name__}")
    values = [
        float(position.x), float(position.y), float(position.z),
        float(rotation[0][0]), float(rotation[0][1]), float(rotation[0][2]),
        float(rotation[1][0]), float(rotation[1][1]), float(rotation[1][2]),
        float(rotation[2][0]), float(rotation[2][1]), float(rotation[2][2]),
    ]
    if not all(math.isfinite(value) for value in values):
        raise ValueError("Animation contains a non-finite CFrame component")
    return values


def main() -> int:
    if len(sys.argv) != 3:
        print("Usage: convert_gojo_animation.py INPUT_RBXM OUTPUT_JSON", file=sys.stderr)
        return 2

    source = Path(sys.argv[1])
    output = Path(sys.argv[2])
    if not source.is_file():
        raise FileNotFoundError(f"Input animation not found: {source}")

    # Always rebuild from the original RBXM source so updated uploads are converted too.

    model = parse_rbxm(str(source))
    all_instances = []
    for root in model.tree:
        all_instances.extend(descendants(root))

    sequences = [item for item in all_instances if getattr(item, "class_name", "") == "KeyframeSequence"]
    if not sequences:
        raise ValueError("No KeyframeSequence found inside the source animation (RBXM container).")

    candidates = []
    for sequence in sequences:
        frames = [child for child in getattr(sequence, "children", []) if getattr(child, "class_name", "") == "Keyframe"]
        candidates.append((len(frames), sequence, frames))
    frame_count, sequence, frames = max(candidates, key=lambda candidate: candidate[0])
    if frame_count < 2:
        raise ValueError(f"KeyframeSequence has only {frame_count} direct keyframes.")

    converted_frames = []
    for frame in sorted(frames, key=lambda item: float(prop(item, "Time", 0.0) or 0.0)):
        frame_time = float(prop(frame, "Time", 0.0) or 0.0)
        converted_poses = []
        for pose in descendants(frame):
            if getattr(pose, "class_name", "") != "Pose":
                continue
            name = prop(pose, "Name")
            cf = prop(pose, "CFrame")
            if not isinstance(name, str) or not name or cf is None:
                continue
            converted_poses.append({
                "Name": name,
                "Weight": float(prop(pose, "Weight", 1.0) or 0.0),
                "EasingStyle": enum_name(prop(pose, "EasingStyle", 0), POSE_EASING_STYLE, "Linear"),
                "EasingDirection": enum_name(prop(pose, "EasingDirection", 1), POSE_EASING_DIRECTION, "Out"),
                "CFrame": cframe_components(cf),
            })
        converted_frames.append({"Time": frame_time, "Poses": converted_poses})

    duration = max((frame["Time"] for frame in converted_frames), default=0.0)
    pose_count = sum(len(frame["Poses"]) for frame in converted_frames)
    if duration <= 0 or pose_count == 0:
        raise ValueError(f"Converted animation is empty (duration={duration}, poses={pose_count}).")

    document = {
        "Name": str(prop(sequence, "Name", output.stem.replace("Track", ""))),
        "Time": duration,
        "Keyframes": converted_frames,
    }
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(document, separators=(",", ":"), ensure_ascii=False), encoding="utf-8")
    print(
        f"Converted {source} -> {output}: "
        f"{len(converted_frames)} keyframes, {pose_count} poses, {duration:.3f}s"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
