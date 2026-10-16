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

# Let's design a magnificent filled Golden Spiral path.
# We want:
# 1. Stroke-less filled path (<path fill="#0C0D11" d="..."/>).
# 2. Perfect centering (equal L/R margins, optical T/B margins).
# 3. Canvas fill ~45-60%.
# 4. Pure circular arcs connecting tangentially.

# Outer radius R = 96. Center of outer arc = (cx, cy).
# Let's construct a continuous tapering ribbon or solid golden spiral:
# Outer arc: sweeps around through 4 quarter-turns:
# Let's use 5 tangent arcs:
# Radii: R1 = 18, R2 = 30, R3 = 50, R4 = 80, R5 = 110 (proportions roughly 1.618!)
# Thickness T = 24.
# Inner radii: r1 = R1 - T (or origin dot), r2 = R2 - T = 6, r3 = R3 - T = 26, r4 = R4 - T = 56, r5 = R5 - T = 86.
# Outer curve goes forward, end cap is a 180-deg semicircle (radius T/2 = 12), inner curve goes backward, inner cap is a circle/semicircle.

# Let's test a clean, balanced geometric formulation of this filled golden spiral:

# Let's write a script that calculates and optimizes it:
def build_filled_spiral():
    # Let's define the arcs in standard Cartesian coords
    # Center (128, 128)
    pass
