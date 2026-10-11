"""Convert the dog RBXM KeyframeSequence assets into NAM's local .anim format."""
import os
import sys
import importlib.util

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONTENT = os.path.join(ROOT, "content")
CONVERTER = os.path.join(ROOT, "tools", "rbxm2anim.py")
spec = importlib.util.spec_from_file_location("rbxm2anim", CONVERTER)
conv = importlib.util.module_from_spec(spec)
spec.loader.exec_module(conv)

SOURCES = {
    "DANCEDAWG.rbxm": "DANCEDAWG",
    "SITDAWG.rbxm": "SITDAWG",
    "Sleepp.rbxm": "Sleepp",
}

def descendants(inst):
    yield inst
    for child in inst.GetChildren():
        yield from descendants(child)

def main():
    old = os.getcwd()
    os.chdir(CONTENT)
    try:
        for filename, preferred in SOURCES.items():
            path = os.path.join(CONTENT, filename)
            if not os.path.isfile(path):
                raise FileNotFoundError(path)
            roots = conv.RBXModel.parse(open(path, "rb").read())
            sequences = [node for root in roots for node in descendants(root)
                         if node.ClassName == "KeyframeSequence"]
            if not sequences:
                raise RuntimeError(f"No KeyframeSequence found in {filename}")
            for index, sequence in enumerate(sequences, 1):
                original_name = sequence.Name
                sequence.Name = preferred if len(sequences) == 1 else f"{preferred}_{index}"
                conv.convert(sequence)
                sequence.Name = original_name
        print("Dog animation conversion completed.")
    finally:
        os.chdir(old)

if __name__ == "__main__":
    main()
