"""Convert dog KeyframeSequence RBXMs into NAM AnimLib .anim files."""
import os
from pathlib import Path
import importlib.util

ROOT = Path(__file__).resolve().parents[1]
CONTENT = ROOT / "content"
SOURCE_DIR = CONTENT / "models" / "Dog"
OUT = CONTENT / "animations" / "Dog"
CONVERTER = ROOT / "tools" / "rbxm2anim.py"

spec = importlib.util.spec_from_file_location("rbxm2anim", CONVERTER)
conv = importlib.util.module_from_spec(spec)
spec.loader.exec_module(conv)

SOURCES = {
    "DANCEDAWG.rbxm": "DANCEDAWG",
    "SITDAWG.rbxm": "SITDAWG",
    "Sleepp.rbxm": "Sleepp",
    "DOGRUN.rbxm": "DOGRUN",
    "JUMPDOG.rbxm": "JUMPDOG",
    "IDLEDOGSMOOTH.rbxm": "IDLEDOGSMOOTH",
}


def descendants(inst):
    yield inst
    for child in inst.GetChildren():
        yield from descendants(child)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    old = os.getcwd()
    converted = 0
    try:
        for filename, preferred in SOURCES.items():
            source = SOURCE_DIR / filename
            if not source.is_file():
                raise FileNotFoundError(f"Missing dog RBXM source: {source.relative_to(ROOT)}")
            raw = source.read_bytes()
            if not raw or not any(raw):
                raise RuntimeError(f"RBXM source is empty/all-zero: {source.relative_to(ROOT)}")
            roots = conv.RBXModel.parse(raw)
            sequences = [node for root in roots for node in descendants(root)
                         if node.ClassName == "KeyframeSequence"]
            if not sequences:
                raise RuntimeError(f"No KeyframeSequence found in {source.relative_to(ROOT)}")
            os.chdir(OUT)
            for index, sequence in enumerate(sequences, 1):
                original_name = sequence.Name
                sequence.Name = preferred if len(sequences) == 1 else f"{preferred}_{index}"
                conv.convert(sequence)
                sequence.Name = original_name
                output = OUT / (preferred if len(sequences) == 1 else f"{preferred}_{index}")
                output = output.with_suffix(".anim")
                if not output.is_file() or output.stat().st_size < 8 or not any(output.read_bytes()):
                    raise RuntimeError(f"Converted output is invalid: {output}")
                converted += 1
                print(f"{source.relative_to(ROOT)} -> {output.relative_to(ROOT)} ({output.stat().st_size} bytes)")
    finally:
        os.chdir(old)
    print(f"Converted {converted} dog animation(s).")


if __name__ == "__main__":
    main()
