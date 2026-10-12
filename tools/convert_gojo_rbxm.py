#!/usr/bin/env python3
"""Convert the Gojo KeyframeSequence .rbxm files into RobuNexa's custom .anim format.

The format is the one consumed by AnimLib.Track.frombuffer in source/reanim.lua:
string name, u32 keyframe count, then each keyframe's time and poses.
"""
from __future__ import annotations

import os
import struct
import urllib.request
from pathlib import Path

from rbxm_parser import parse_rbxm_bytes

ROOT = "https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/"
FILES = {
    "Gojo Idle.rbxm": "GojoIdle.anim",
    "Gojo Walk.rbxm": "GojoWalk.anim",
    "Jump.rbxm": "GojoJump.anim",
    "Gojo Lapse Blue.rbxm": "GojoLapseBlue.anim",
    "Cursed Technique Red.rbxm": "CursedTechniqueRed.anim",
    "Red Reversal.rbxm": "RedReversal.anim",
    "Hollow Purple.rbxm": "HollowPurple.anim",
}
OUT = Path("content")

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
    # rbxm_parser.CFrame stores rotation as three rows.
    p = cf.position
    r = cf.rotation
    return [p.x, p.y, p.z, r[0][0], r[0][1], r[0][2],
            r[1][0], r[1][1], r[1][2], r[2][0], r[2][1], r[2][2]]


def convert(data: bytes, source_name: str) -> bytes:
    model = parse_rbxm_bytes(data)
    instances = []
    for root in model.tree:
        if root.class_name == "KeyframeSequence":
            instances.append(root)
        instances.extend(x for x in descendants(root) if x.class_name == "KeyframeSequence")
    if not instances:
        raise ValueError(f"{source_name}: no KeyframeSequence found in RBXM")

    # Prefer a sequence named like the source file; otherwise use the sequence
    # with the largest number of keyframes to avoid accidentally exporting a prop.
    sequence = max(instances, key=lambda x: len([c for c in x.children if c.class_name == "Keyframe"]))
    keyframes = sorted(
        (x for x in sequence.children if x.class_name == "Keyframe"),
        key=lambda x: float(x.get_property("Time", 0.0)),
    )
    if not keyframes:
        raise ValueError(f"{source_name}: KeyframeSequence has no Keyframe children")

    out = bytearray()
    out += u16_string(str(sequence.get_property("Name", source_name)))
    out += struct.pack("<I", len(keyframes))
    for keyframe in keyframes:
        out += f32(keyframe.get_property("Time", 0.0))
        poses = [x for x in descendants(keyframe) if x.class_name == "Pose"]
        out += struct.pack("<I", len(poses))
        for pose in poses:
            out += u16_string(str(pose.get_property("Name", "Unknown")))
            out += f32(pose.get_property("Weight", 1.0))
            style = pose.get_property("EasingStyle", 0)
            direction = pose.get_property("EasingDirection", 2)
            out += u16_string(EASING_STYLE.get(style, "Linear"))
            out += u16_string(EASING_DIRECTION.get(direction, "InOut"))
            cf = pose.get_property("CFrame")
            if cf is None or not hasattr(cf, "rotation") or not hasattr(cf, "position"):
                raise ValueError(f"{source_name}: Pose is missing a parsed CFrame")
            for component in cframe_components(cf):
                out += f32(component)
    return bytes(out)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for source, target in FILES.items():
        url = ROOT + urllib.parse.quote(source)
        with urllib.request.urlopen(url, timeout=30) as response:
            data = response.read()
        result = convert(data, source)
        if len(result) < 16:
            raise ValueError(f"{source}: converted data unexpectedly small")
        path = OUT / target
        path.write_bytes(result)
        print(f"{source} -> {path} ({len(result)} bytes)")


if __name__ == "__main__":
    main()
