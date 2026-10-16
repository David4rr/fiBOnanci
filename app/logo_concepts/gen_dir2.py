import math
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

# Direction 2: Architectural Golden F
# Spine: x 60..96 (w=36), y 32..224 (h=192).
# Top cantilever bar: x 96..204 (l=108), y 32..68 (h=36). Top-right corner rounded with r=18.
# Golden middle cantilever bar: length 108 / 1.618 = 66.8 -> l=67. x 96..163, y 110..146 (h=36). Right end rounded with r=18.
# At the junction of spine and top bar: an inner filleted corner with r=16 or crisp 90-degree corner.
# What if the spine top-left is also rounded with r=18, and spine bottom is rounded with r=18?
# Let's write the complete unified path:

svg_dir2 = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-dir2">
  <title id="t-dir2">fiBOnanci Architectural Golden F</title>
  <path fill="#0C0D11" d="
    M 78 32
    H 186
    A 18 18 0 0 1 204 50
    V 50
    A 18 18 0 0 1 186 68
    H 96
    V 110
    H 145
    A 18 18 0 0 1 163 128
    V 128
    A 18 18 0 0 1 145 146
    H 96
    V 206
    A 18 18 0 0 1 78 224
    H 78
    A 18 18 0 0 1 60 206
    V 50
    A 18 18 0 0 1 78 32
    Z
  "/>
</svg>'''

# Direction 3: Solid Expanding Fibonacci Golden Spiral (Continuous Logarithmic Ribbon)
# Origin at (140, 140).
# Constructed from 5 connecting golden quarter-circle arcs on the outer edge, and 4 on the inner edge, creating a solid tapering ribbon.
# Outer arcs (clockwise or counter-clockwise):
# Let's make a crisp, perfectly closing solid spiral:
# Outer edge:
# Point 1 (start at bottom): (128, 228)
# Arc to left: center (128, 148), r=80 -> reaches (48, 148)
# Arc to top: center (98, 148), r=50 -> reaches (98, 48)...
# Let's construct a continuous mathematical spiral using 8 arcs:
def make_spiral_path():
    # Fibonacci centers and radii
    # We want a smooth solid ribbon winding inward.
    # Let's create an outer spiral and an inner spiral connected at the tip and base.
    pass

with open("logo_concepts/test_dir2.svg", "w") as f: f.write(svg_dir2)
run_render("logo_concepts/test_dir2.svg", "logo_concepts/test_dir2.png")
print("Rendered dir2")
