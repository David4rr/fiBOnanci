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

# Test Spiral 1: Sculptural Golden Ribbon with bold 28px monoline and rounded or chamfered terminals
# Centers on 256 canvas:
# u = 14
# r1 = 14, r2 = 28, r3 = 42, r4 = 70, r5 = 112...
# Center origin at (140, 132)

svg_spiral_bold = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-spbold">
  <title id="t-spbold">fiBOnanci Bold Golden Spiral</title>
  <path fill="none" stroke="#0C0D11" stroke-width="26" stroke-linecap="round" stroke-linejoin="round" d="
    M 146 132
    A 16 16 0 0 0 130 148
    A 32 32 0 0 0 162 180
    A 48 48 0 0 0 210 132
    A 80 80 0 0 0 130 52
    A 108 108 0 0 0 32 142
  "/>
</svg>'''

# Test Spiral 2: Solid Sculptural Nautilus (Filled Geometric Silhouette)
# A solid shape that uncurls like a stylized nautilus or shell:
# Outer edge: R=96 circle from (128, 224) counterclockwise to (224, 128) then (128, 32) then (32, 128) then (128, 224)
# With an inner spiral negative space carving
svg_nautilus_solid = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-nautsolid">
  <title id="t-nautsolid">fiBOnanci Solid Nautilus</title>
  <path fill="#0C0D11" fill-rule="evenodd" d="
    M 128 228
    A 100 100 0 1 1 228 128
    A 100 100 0 0 1 128 228
    Z
    M 128 200
    A 72 72 0 0 0 200 128
    A 72 72 0 0 0 128 56
    A 72 72 0 0 0 56 128
    A 72 72 0 0 0 128 200
    L 128 168
    A 40 40 0 1 1 168 128
    L 140 128
    A 12 12 0 1 0 128 140
    L 128 200
    Z
  "/>
</svg>'''

# Test Spiral 3: The Geometric Fibonacci Fan / Golden Arcs (3 sweeping precision bars)
# Three concentric arcs following Fibonacci radii (r = 34, 55, 89)
# All anchored along a clean 45-degree axis!
# Arc 1: radius 34, width 18
# Arc 2: radius 55, width 20
# Arc 3: radius 89, width 24
# All sweeping 180 degrees, perfectly nested!
svg_fan = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-fan">
  <title id="t-fan">fiBOnanci Golden Concentric Arcs</title>
  <!-- Arc 3 (Outer): R=92, width=22, stroke-linecap=round -->
  <path fill="none" stroke="#0C0D11" stroke-width="22" stroke-linecap="round" d="
    M 36 128
    A 92 92 0 0 1 220 128
  "/>
  <!-- Arc 2 (Middle): R=58, width=20, stroke-linecap=round -->
  <path fill="none" stroke="#0C0D11" stroke-width="20" stroke-linecap="round" d="
    M 70 128
    A 58 58 0 0 1 186 128
  "/>
  <!-- Arc 1 (Inner): R=28, width=18, stroke-linecap=round -->
  <path fill="none" stroke="#0C0D11" stroke-width="18" stroke-linecap="round" d="
    M 100 128
    A 28 28 0 0 1 156 128
  "/>
  <!-- Baseline balance beam -->
  <rect x="24" y="144" width="208" height="14" rx="7" fill="#0C0D11" />
</svg>'''

with open("logo_concepts/test_spbold.svg", "w") as f: f.write(svg_spiral_bold)
with open("logo_concepts/test_nautsolid.svg", "w") as f: f.write(svg_nautilus_solid)
with open("logo_concepts/test_fan.svg", "w") as f: f.write(svg_fan)

run_render("logo_concepts/test_spbold.svg", "logo_concepts/test_spbold.png")
run_render("logo_concepts/test_nautsolid.svg", "logo_concepts/test_nautsolid.png")
run_render("logo_concepts/test_fan.svg", "logo_concepts/test_fan.png")
print("Rendered spiral candidates")
