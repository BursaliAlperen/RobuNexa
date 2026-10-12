#!/usr/bin/env python3
"""Extract real KeyframeSequence instances from Sukuna .rbxm models into .anim XML."""
from pathlib import Path
import subprocess
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
MODELS = ROOT / "content" / "models" / "Sukuna"
OUT = ROOT / "content" / "animations" / "Sukuna"
# source filename -> preferred KeyframeSequence name substring -> output filename
ASSETS = [
    ("Sukuna Laugh.rbxm", "laugh", "Sukuna Laugh.anim"),
    ("Combo.rbxm", "combo", "Domain Combo.anim"),
    ("Domain Expansion: Malevolent Shrine.rbxm", "domain", "Malevolent Shrine.anim"),
    ("Cleave.rbxm", "cleave", "Cleave.anim"),
    ("Walk.rbxm", "walk", "Walk.anim"),
]

def local_name(tag):
    return tag.rsplit("}", 1)[-1]

def main():
    OUT.mkdir(parents=True, exist_ok=True)
    total = 0
    for source_name, preferred, output_name in ASSETS:
        source = MODELS / source_name
        if not source.is_file():
            raise SystemExit(f"Missing source model: {source}")
        converted = OUT / (source.stem + ".rbxmx")
        subprocess.run(["target/release/rbx_util", "convert", str(source), str(converted)], cwd=ROOT, check=True)
        tree = ET.parse(converted)
        root = tree.getroot()
        candidates = [node for node in root.iter() if local_name(node.tag) == "Item" and node.attrib.get("class") == "KeyframeSequence"]
        if not candidates:
            raise SystemExit(f"No KeyframeSequence found in {source_name}; refusing to create a fake .anim")
        chosen = next((node for node in candidates if preferred in node.findtext("Properties", default="").lower()), None)
        if chosen is None:
            # Prefer a sequence whose serialized Name property matches the requested name.
            def sequence_name(node):
                for prop in node.findall("./Properties/*"):
                    if prop.attrib.get("name") == "Name":
                        return prop.text or ""
                return ""
            chosen = next((node for node in candidates if preferred in sequence_name(node).lower()), candidates[0])
        anim_root = ET.Element("roblox", {"version": "4"})
        anim_root.append(chosen)
        output = OUT / output_name
        ET.ElementTree(anim_root).write(output, encoding="utf-8", xml_declaration=True)
        converted.unlink(missing_ok=True)
        print(f"Extracted {source_name} -> {output.relative_to(ROOT)} ({len(candidates)} sequence(s) found)")
        total += 1
    if total != len(ASSETS):
        raise SystemExit(f"Only extracted {total}/{len(ASSETS)} animations")
    print(f"Successfully extracted {total} real .anim files.")

if __name__ == "__main__":
    main()
