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

# Double Golden Wave (Fibonacci Dual Equilibrium)
# Symmetrical rotation of 180 degrees.
# Centered at (128, 128).
# Each arm is a bold tapered sweeping arc that spirals into the center origin.
# Outer radius = 96.
# Arm 1: sweeps from (128, 224) counterclockwise through (224, 128) up to (128, 32) and curls into center.
# Arm 2: 180 degree rotation of Arm 1.
# This gives a complete circular, perfectly balanced, near-square footprint!

svg_dual_wave = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-dualwave">
  <title id="t-dualwave">fiBOnanci Golden Wave Equilibrium</title>
  <!-- Arm 1 -->
  <path fill="none" stroke="#0C0D11" stroke-width="24" stroke-linecap="round" d="
    M 128 32
    A 96 96 0 0 1 224 128
    A 64 64 0 0 1 144 176
    A 32 32 0 0 1 116 136
  "/>
  <!-- Arm 2 (180 deg rotation) -->
  <path fill="none" stroke="#0C0D11" stroke-width="24" stroke-linecap="round" d="
    M 128 224
    A 96 96 0 0 1 32 128
    A 64 64 0 0 1 112 80
    A 32 32 0 0 1 140 120
  "/>
  <!-- Core balance seed -->
  <circle cx="128" cy="128" r="12" fill="#0C0D11" />
</svg>'''

with open("logo_concepts/test_dualwave.svg", "w") as f: f.write(svg_dual_wave)
run_render("logo_concepts/test_dualwave.svg", "logo_concepts/test_dualwave.png")
print("Rendered dual wave")
