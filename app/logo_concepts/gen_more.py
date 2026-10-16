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

# 1. Elegant 'fi' Minimalist Ligature
# 'f': vertical stem at x=72..104 (w=32), y from 220 up to 96, arch sweeps to x=156, y=32 with flat terminal.
# 'i': vertical stem at x=148..180 (w=32), y from 136 to 220.
# The crossbar of 'f' connects at y=104..136 across from x=48 to x=180, seamlessly forming the top of the 'i' stem!
# And above the 'i' (at x=164, y=68): a pristine circular golden dot (radius 16)!
# Let's write the SVG:

svg_fi_ligature = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-filig">
  <title id="t-filig">fiBOnanci 'fi' Ligature</title>
  <!-- Main ligature path -->
  <path fill="#0C0D11" d="
    M 72 224
    V 136
    H 48
    V 104
    H 72
    V 88
    A 48 48 0 0 1 120 40
    H 144
    V 72
    H 120
    A 16 16 0 0 0 104 88
    V 104
    H 184
    V 224
    H 152
    V 136
    H 104
    V 224
    H 72
    Z
  "/>
  <!-- 'i' golden dot -->
  <circle cx="168" cy="64" r="16" fill="#0C0D11" />
</svg>'''

# 2. Golden S-Curve / Infinite Cashflow (Continuous Sigmoid Spline)
# A sweeping S-ribbon with golden ratio proportions
svg_scurve = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-scurve">
  <title id="t-scurve">fiBOnanci Golden S-Curve</title>
  <path fill="none" stroke="#0C0D11" stroke-width="32" stroke-linecap="round" d="
    M 64 64
    C 160 64, 96 192, 192 192
  "/>
</svg>'''

# 3. Geometric Fibonacci Spiral (Refined Monolithic Arc)
# Let's center and balance the bold golden spiral:
# Center origin at (136, 138)
# Bounds: x in [36..220], y in [36..220]
svg_spiral_refined = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-spref">
  <title id="t-spref">fiBOnanci Golden Spiral Nautilus</title>
  <path fill="none" stroke="#0C0D11" stroke-width="24" stroke-linecap="round" stroke-linejoin="round" d="
    M 148 138
    A 18 18 0 0 0 130 156
    A 36 36 0 0 0 166 192
    A 54 54 0 0 0 220 138
    A 90 90 0 0 0 130 48
    A 120 120 0 0 0 36 150
  "/>
  <circle cx="148" cy="138" r="12" fill="#0C0D11" />
</svg>'''

with open("logo_concepts/test_fi_lig.svg", "w") as f: f.write(svg_fi_ligature)
with open("logo_concepts/test_scurve.svg", "w") as f: f.write(svg_scurve)
with open("logo_concepts/test_spref.svg", "w") as f: f.write(svg_spiral_refined)

run_render("logo_concepts/test_fi_lig.svg", "logo_concepts/test_fi_lig.png")
run_render("logo_concepts/test_scurve.svg", "logo_concepts/test_scurve.png")
run_render("logo_concepts/test_spref.svg", "logo_concepts/test_spref.png")
print("Rendered new ideas")
