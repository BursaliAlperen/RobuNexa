#!/usr/bin/env python3
"""Convert the Gojo/movement RBXM KeyframeSequences into NAM AnimLib .anim files.

Inputs live in content/models (not the content root). Outputs are placed in
content/animations/Gojo because source/reanim.lua downloads .anim files from
that repository directory.
"""
from __future__ import annotations

import struct
from pathlib import Path

from rbxm_parser import parse_rbxm_bytes

ROOT = Path(__file__).resolve().parents[1]
CONTENT = ROOT / "content"
OUT = CONTENT / "animations" / "Gojo"

# Exact repository paths -> stable output names.
SOURCES = {
    "models/Gojo/Gojo Idle.rbxm": "GojoIdle.anim",
    "models/Gojo/Gojo Walk.rbxm": "GojoWalk.anim",
    "models/Gojo/Gojo Run.rbxm": "GojoRun.anim",
    "models/Run.rbxm": "GojoRun.anim",
    "models/Gojo/Run.rbxm": "GojoRun.anim",
    "models/Jump.rbxm": "GojoJump.anim",
    "models/Gojo/Gojo Jump.rbxm": "GojoJump.anim",
    "models/Fall.rbxm": "GojoFall.anim",
    "models/Gojo/Gojo Fall.rbxm": "GojoFall.anim",
    "models/Gojo/Gojo Lapse Blue.rbxm": "GojoLapseBlue.anim",
    "models/Gojo/Cursed Technique Red.rbxm": "CursedTechniqueRed.anim",
    "models/Gojo/Red Reversal.rbxm": "RedReversal.anim",
    "models/Gojo/Hollow Purple.rbxm": "HollowPurple.anim",
    # This repository entry is an RBXM binary mistakenly stored with an .anim suffix.
    # Parse it as a model first, then overwrite it with real AnimLib bytes.
    "animations/Gojo/Sokamona.anim": "Sokamona.anim",
}

EASING_STYLE = {
    0: "Linear", 1: "Sine", 2: "Back", 3: "Quad", 4: "Quart",
    5: "Quint", 6: "Bounce", 7: "Elastic", 8: "Exponential",
    9: "Circular", 10: "Cubic", 11: "Constant",
}
EASING_DIRECTION = {0: "In", 1: "Out", 2: "InOut"}


def descendants(node):
    for child in getattr(node, "children", []):
        yield child
        yield from descendants(child)


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
        sequences.extend(
            item for item in descendants(root)
            if item.class_name == "KeyframeSequence"
        )
    if not sequences:
        raise ValueError(f"{source_name}: no KeyframeSequence found in RBXM")

    sequence = max(
        sequences,
        key=lambda item: len([
            child for child in item.children if child.class_name == "Keyframe"
        ]),
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


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    converted = 0
    missing = []
    failures = []
    for relative, output_name in SOURCES.items():
        source = CONTENT / relative
        if not source.is_file():
            missing.append(relative)
            continue
        try:
            result = convert(source.read_bytes(), source.name)
            if len(result) < 16:
                raise ValueError("converted data unexpectedly small")
            target = OUT / output_name
            target.write_bytes(result)
            converted += 1
            print(f"{source.relative_to(ROOT)} -> {target.relative_to(ROOT)} ({len(result)} bytes)")
        except Exception as exc:
            failures.append(f"{relative}: {exc}")
            print(f"ERROR {relative}: {exc}")

    if missing:
        print("Optional/missing source RBXM files:")
        for path in missing:
            print(f"  - {path}")
    if failures:
        raise RuntimeError("Some RBXM files could not be converted: " + "; ".join(failures))
    if not converted:
        raise RuntimeError("No Gojo/movement RBXM files were found under content/models.")


if __name__ == "__main__":
    main()
