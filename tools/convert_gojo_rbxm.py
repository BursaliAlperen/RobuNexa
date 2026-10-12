#!/usr/bin/env python3
"""Convert root-level animation RBXM files to NAM AnimLib .anim files.

Known Gojo movement/skill clips are written to content/Gojo so the module's
raw URLs and AssetGetPathFromFilename paths match. Other root-level RBXMs that
contain a KeyframeSequence are exported to content/animations/.
"""
from __future__ import annotations

import re
import struct
from pathlib import Path

from rbxm_parser import parse_rbxm_bytes

CONTENT = Path("content")
GOJO_OUT = CONTENT / "Gojo"
OTHER_OUT = CONTENT / "animations"

EASING_STYLE = {
    0: "Linear", 1: "Sine", 2: "Back", 3: "Quad", 4: "Quart",
    5: "Quint", 6: "Bounce", 7: "Elastic", 8: "Exponential",
    9: "Circular", 10: "Cubic", 11: "Constant",
}
EASING_DIRECTION = {0: "In", 1: "Out", 2: "InOut"}

# normalized source stem -> target filename in content/Gojo/
GOJO_NAMES = {
    "gojoidle": "GojoIdle.anim", "idle": "GojoIdle.anim",
    "gojowalk": "GojoWalk.anim", "walk": "GojoWalk.anim",
    "gojorun": "GojoRun.anim", "run": "GojoRun.anim",
    "gojosprint": "GojoRun.anim", "sprint": "GojoRun.anim",
    "gojojump": "GojoJump.anim", "jump": "GojoJump.anim",
    "gojofall": "GojoFall.anim", "fall": "GojoFall.anim",
    "freefall": "GojoFall.anim", "gojofreefall": "GojoFall.anim",
    "gojolapseblue": "GojoLapseBlue.anim", "lapseblue": "GojoLapseBlue.anim",
    "cursedtechniquered": "CursedTechniqueRed.anim",
    "redreversal": "RedReversal.anim",
    "hollowpurple": "HollowPurple.anim",
    "sokamona": "Sokamona.anim",
}


def descendants(node):
    for child in getattr(node, "children", []):
        yield child
        yield from descendants(child)


def normalized_stem(path: Path) -> str:
    stem = re.sub(r"[^a-z0-9]", "", path.stem.lower())
    if stem.endswith("animation"):
        stem = stem[:-9]
    return stem


def u16_string(value: str) -> bytes:
    data = value.encode("utf-8")
    if len(data) > 65535:
        raise ValueError(f"String too long: {value[:40]}")
    return struct.pack("<H", len(data)) + data


def f32(value) -> bytes:
    return struct.pack("<f", float(value))


def cframe_components(cf):
    p, r = cf.position, cf.rotation
    return [p.x, p.y, p.z, r[0][0], r[0][1], r[0][2],
            r[1][0], r[1][1], r[1][2], r[2][0], r[2][1], r[2][2]]


def convert(data: bytes, source_name: str) -> bytes:
    model = parse_rbxm_bytes(data)
    sequences = []
    for root in model.tree:
        if root.class_name == "KeyframeSequence":
            sequences.append(root)
        sequences.extend(x for x in descendants(root) if x.class_name == "KeyframeSequence")
    if not sequences:
        raise ValueError(f"{source_name}: no KeyframeSequence found in RBXM")

    sequence = max(
        sequences,
        key=lambda item: len([child for child in item.children if child.class_name == "Keyframe"]),
    )
    keyframes = sorted(
        (item for item in sequence.children if item.class_name == "Keyframe"),
        key=lambda item: float(item.get_property("Time", 0.0)),
    )
    if not keyframes:
        raise ValueError(f"{source_name}: KeyframeSequence has no Keyframe children")

    out = bytearray()
    out += u16_string(str(sequence.get_property("Name", Path(source_name).stem)))
    out += struct.pack("<I", len(keyframes))
    for keyframe in keyframes:
        out += f32(keyframe.get_property("Time", 0.0))
        poses = [item for item in descendants(keyframe) if item.class_name == "Pose"]
        out += struct.pack("<I", len(poses))
        for pose in poses:
            out += u16_string(str(pose.get_property("Name", "Unknown")))
            out += f32(pose.get_property("Weight", 1.0))
            out += u16_string(EASING_STYLE.get(pose.get_property("EasingStyle", 0), "Linear"))
            out += u16_string(EASING_DIRECTION.get(pose.get_property("EasingDirection", 2), "InOut"))
            cf = pose.get_property("CFrame")
            if cf is None or not hasattr(cf, "rotation") or not hasattr(cf, "position"):
                raise ValueError(f"{source_name}: Pose is missing a parsed CFrame")
            for component in cframe_components(cf):
                out += f32(component)
    return bytes(out)


def target_for(source: Path) -> Path:
    stem = normalized_stem(source)
    gojo_name = GOJO_NAMES.get(stem)
    if gojo_name:
        return GOJO_OUT / gojo_name
    safe_name = re.sub(r"[^A-Za-z0-9_-]+", "", source.stem).strip("_-") or "Animation"
    return OTHER_OUT / f"{safe_name}.anim"


def main():
    CONTENT.mkdir(parents=True, exist_ok=True)
    sources = sorted(CONTENT.glob("*.rbxm"), key=lambda p: (0 if p.stem.lower().startswith("gojo") else 1, p.name.lower()))
    if not sources:
        print("No root-level content/*.rbxm files found; nothing to convert.")
        return

    written_targets = set()
    failures = []
    for source in sources:
        target = target_for(source)
        # Prefer explicitly Gojo-named files over generic Run/Walk/Jump/Fall
        # aliases when both versions are present in the same repository.
        if target in written_targets:
            print(f"SKIP {source}: {target} already supplied by a higher-priority source")
            continue
        try:
            result = convert(source.read_bytes(), source.name)
            if len(result) < 16:
                raise ValueError("converted data unexpectedly small")
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(result)
            written_targets.add(target)
            print(f"{source} -> {target} ({len(result)} bytes)")
        except Exception as exc:
            # RBXM files may also be models/accessories. Do not abort all
            # animation conversion because one file has no KeyframeSequence.
            failures.append(f"{source.name}: {exc}")
            print(f"SKIP {source.name}: {exc}")

    if not written_targets:
        raise RuntimeError("No RBXM animations were converted. Check that uploaded files contain KeyframeSequence instances.")
    if failures:
        print("Files skipped (not animation sequences or invalid RBXM):")
        for failure in failures:
            print(f"  - {failure}")


if __name__ == "__main__":
    main()
