import os
import subprocess

def run_render(svg_path, png_path, size=256):
    cmd = [
        "python3",
        "/Users/mac/.agents/skills/logo-design/scripts/render_png.py",
        svg_path,
        "-o",
        png_path,
        "--size",
        str(size),
        "--bg",
        "#ffffff"
    ]
    subprocess.run(cmd, check=True)

# Candidate A1: Architectural Lowercase 'f' with Golden Ratio Arc and Cantilever Bar
svg_a1 = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="title-a1">
  <title id="title-a1">fiBOnanci Golden F</title>
  <!-- Combined clean path with evenodd fill -->
  <path fill="#0C0D11" d="
    M 76 112
    L 48 112
    A 6 6 0 0 0 42 118
    L 42 142
    A 6 6 0 0 0 48 148
    L 76 148
    L 76 226
    A 8 8 0 0 0 84 234
    L 112 234
    A 8 8 0 0 0 120 226
    L 120 148
    L 190 148
    A 6 6 0 0 0 196 142
    L 196 118
    A 6 6 0 0 0 190 112
    L 120 112
    L 120 96
    A 38 38 0 0 1 158 58
    L 178 58
    A 6 6 0 0 0 184 52
    L 184 28
    A 6 6 0 0 0 178 22
    L 156 22
    A 76 76 0 0 0 80 98
    L 80 112
    Z
  "/>
</svg>'''

# Candidate A2: Ultra-minimalist Lowercase 'f' with sharp terminals, pure circular arc & precision floating balance bar
svg_a2 = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="title-a2">
  <title id="title-a2">fiBOnanci Golden f Minimal</title>
  <!-- Main stem and golden arch -->
  <path fill="#0C0D11" d="
    M 84 228
    V 102
    A 66 66 0 0 1 150 36
    H 188
    V 72
    H 150
    A 30 30 0 0 0 120 102
    V 228
    H 84
    Z
  "/>
  <!-- Floating precision crossbar at golden ratio height -->
  <rect x="52" y="116" width="136" height="36" rx="0" fill="#0C0D11" />
</svg>'''

# Candidate A3: Monolithic Geometric 'F' with Golden Spiral Stepped Bars
svg_a3 = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="title-a3">
  <title id="title-a3">fiBOnanci Geometric Capital F</title>
  <!-- Pillar -->
  <path fill="#0C0D11" d="
    M 64 224
    V 32
    H 196
    V 68
    H 104
    V 112
    H 168
    V 148
    H 104
    V 224
    H 64
    Z
  "/>
</svg>'''

with open("logo_concepts/test_a1.svg", "w") as f: f.write(svg_a1)
with open("logo_concepts/test_a2.svg", "w") as f: f.write(svg_a2)
with open("logo_concepts/test_a3.svg", "w") as f: f.write(svg_a3)

run_render("logo_concepts/test_a1.svg", "logo_concepts/test_a1.png")
run_render("logo_concepts/test_a2.svg", "logo_concepts/test_a2.png")
run_render("logo_concepts/test_a3.svg", "logo_concepts/test_a3.png")
print("Rendered A candidates")
