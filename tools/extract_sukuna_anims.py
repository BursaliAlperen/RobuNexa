#!/usr/bin/env python3
"""Extract real NAM AnimLib .anim binary files from Roblox KeyframeSequence models."""
from pathlib import Path
import struct
import subprocess
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
CONTENT = ROOT / "content"
OUT = CONTENT / "animations" / "Sukuna"
ASSETS = [
    # Existing converted Cleave is retained when its original source has been cleaned up.
    ("animations/Sukuna/Kai.rbxm", "cleave", "Cleave.anim"),
    # Extract the real KeyframeSequence clips from the committed RBXM assets.
    ("animations/Sukuna/Dismantle.rbxm", "dismantle", "Dismantle.anim"),
    ("animations/Sukuna/Rushbeatdown.rbxm", "rush", "Rushbeatdown.anim"),
]
STYLE = {0: "Linear", 1: "Constant", 2: "Elastic", 3: "Cubic", 4: "Bounce",
         5: "Sine", 6: "Exponential", 7: "Quad", 8: "Quart", 9: "Quint",
         10: "Back"}
DIRECTION = {0: "In", 1: "Out", 2: "InOut"}

def local(tag):
    return tag.rsplit("}", 1)[-1]

def prop(item, name):
    props = item.find("Properties")
    if props is None:
        return None
    for node in list(props):
        if node.attrib.get("name") == name:
            return node
    return None

def value(item, name, default=None):
    node = prop(item, name)
    if node is None:
        return default
    return (node.text or "").strip()

def sequence_name(item):
    return value(item, "Name", "")

def enum_name(item, prop_name, mapping, default):
    raw = value(item, prop_name)
    if raw is None:
        return default
    try:
        return mapping.get(int(raw), default)
    except ValueError:
        return raw.rsplit(".", 1)[-1] or default

def read_cframe(pose):
    node = prop(pose, "CFrame")
    if node is None:
        raise ValueError(f"Pose {value(pose, 'Name', '?')} has no CFrame")
    fields = {local(child.tag): (child.text or "").strip() for child in list(node)}
    names = ["X", "Y", "Z", "R00", "R01", "R02", "R10", "R11", "R12", "R20", "R21", "R22"]
    return [float(fields.get(name, "0")) for name in names]

def pack_string(text):
    data = text.encode("utf-8")
    if len(data) > 65535:
        raise ValueError("String exceeds AnimLib .anim string limit")
    return struct.pack("<H", len(data)) + data

def pack_animation(sequence):
    # This is the exact binary layout consumed by source/reanim.lua AnimLib.Track.frombuffer:
    # string name; u32 keyframe count; per keyframe f32 time, u32 pose count;
    # per pose string name, f32 weight, string easing style, string easing direction,
    # then twelve f32 CFrame components.
    keyframes = [node for node in sequence.findall("./Item") if node.attrib.get("class") == "Keyframe"]
    keyframes.sort(key=lambda k: float(value(k, "Time", "0")))
    if not keyframes:
        raise ValueError(f"KeyframeSequence {sequence_name(sequence)!r} has no keyframes")
    data = bytearray(pack_string(sequence_name(sequence) or "SukunaAnimation"))
    data += struct.pack("<I", len(keyframes))
    for keyframe in keyframes:
        data += struct.pack("<f", float(value(keyframe, "Time", "0")))
        poses = [node for node in keyframe.iter() if node is not keyframe and node.attrib.get("class") == "Pose"]
        data += struct.pack("<I", len(poses))
        for pose in poses:
            data += pack_string(value(pose, "Name", "Pose"))
            data += struct.pack("<f", float(value(pose, "Weight", "1")))
            data += pack_string(enum_name(pose, "EasingStyle", STYLE, "Linear"))
            data += pack_string(enum_name(pose, "EasingDirection", DIRECTION, "In"))
            data += struct.pack("<12f", *read_cframe(pose))
    return bytes(data), len(keyframes)

def main():
    OUT.mkdir(parents=True, exist_ok=True)
    converted_dir = OUT / ".converted"
    converted_dir.mkdir(exist_ok=True)
    total = 0
    for source_name, preferred, output_name in ASSETS:
        source = CONTENT / source_name
        if not source.is_file():
            if output_name == "Cleave.anim" and (OUT / output_name).is_file():
                print(f"Source {source_name} has been cleaned up; keeping existing converted {output_name}.")
                continue
            raise SystemExit(f"Missing source model: {source}")
        converted = converted_dir / (source.stem + ".rbxmx")
        subprocess.run([str(ROOT / "target/release/rbx_util"), "convert", str(source), str(converted)], cwd=ROOT, check=True)
        root = ET.parse(converted).getroot()
        candidates = [node for node in root.iter() if local(node.tag) == "Item" and node.attrib.get("class") == "KeyframeSequence"]
        if not candidates:
            raise SystemExit(f"No KeyframeSequence found in {source_name}; refusing to create fake animation data")
        chosen = next((node for node in candidates if preferred in sequence_name(node).lower()), None)
        if chosen is None:
            if len(candidates) == 1:
                chosen = candidates[0]
            else:
                names = ", ".join(sequence_name(node) for node in candidates)
                raise SystemExit(f"Cannot select {preferred!r} sequence from {source_name}: {names}")
        binary, count = pack_animation(chosen)
        output = OUT / output_name
        output.write_bytes(binary)
        print(f"Extracted {source_name} [{sequence_name(chosen)}]: {count} keyframes -> {output.relative_to(ROOT)} ({len(binary)} bytes)")
        total += 1
    if total == 0:
        print("No source RBXM files remain; existing converted .anim files were preserved.")
        return
    print(f"Successfully extracted {total} valid NAM AnimLib .anim binary files.")

if __name__ == "__main__":
    main()
