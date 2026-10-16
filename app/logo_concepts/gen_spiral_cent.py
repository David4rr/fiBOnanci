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

# Precision Fibonacci Spiral:
# 5 quarter arcs:
# Radii in Fibonacci sequence: 13, 21, 34, 55, 89
# Stroke width = 24.
# Centers chosen so arcs connect tangentially.
# Let's compute:
# Center 1 (origin): (cx, cy)
# Arc 1: r=13. From angle 180 to 270 (quadrant 3)
# Arc 2: r=21. From angle 270 to 360 (quadrant 4)
# Arc 3: r=34. From angle 0 to 90 (quadrant 1)
# Arc 4: r=55. From angle 90 to 180 (quadrant 2)
# Arc 5: r=89. From angle 180 to 270 (quadrant 3)

# Let's compute exact arc centers:
# Let center 5 be (c5x, c5y).
# Arc 5 has radius 89. It goes from (c5x - 89, c5y) to (c5x, c5y + 89) or similar.
# Let's write an exact tangent spiral generator:

def generate_fibonacci_spiral():
    # Sequence: 14, 22, 36, 58, 94
    # Arcs connect smoothly:
    # Let's trace from outer to inner:
    # Outer start: (x0, y0)
    # Arc 5 (r=96): center (132, 128), start at (132, 32), sweeps 90 deg clockwise to (228, 128) -> center is (132, 128)
    # Then Arc 4 (r=60): center (132, 128 + 36 = 164), sweeps 90 deg clockwise from (228, 128) to (168, 224)?
    # Better: standard Fibonacci box layout:
    # Box 1: 13x13 at (0, 8)
    # Box 2: 21x21 ...
    pass

# Let's test a clean, perfectly centered Golden Spiral SVG:
svg_spiral_centered = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-spcent">
  <title id="t-spcent">fiBOnanci Pure Golden Spiral</title>
  <!-- Main Golden Spiral Stroke: bold 24px with flat terminal -->
  <path fill="none" stroke="#0C0D11" stroke-width="24" stroke-linecap="square" stroke-linejoin="round" d="
    M 144 140
    A 14 14 0 0 0 130 154
    A 28 28 0 0 0 158 182
    A 46 46 0 0 0 204 136
    A 76 76 0 0 0 128 60
    A 106 106 0 0 0 22 148
  "/>
  <!-- Central origin seed/dot -->
  <circle cx="144" cy="140" r="10" fill="#0C0D11" />
</svg>'''

# Let's also test a version with round cap:
svg_spiral_round = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-spround">
  <title id="t-spround">fiBOnanci Pure Golden Spiral Round</title>
  <!-- Main Golden Spiral Stroke: bold 26px with round cap -->
  <path fill="none" stroke="#0C0D11" stroke-width="26" stroke-linecap="round" stroke-linejoin="round" d="
    M 144 140
    A 14 14 0 0 0 130 154
    A 28 28 0 0 0 158 182
    A 46 46 0 0 0 204 136
    A 76 76 0 0 0 128 60
    A 106 106 0 0 0 36 154
  "/>
  <circle cx="144" cy="140" r="11" fill="#0C0D11" />
</svg>'''

with open("logo_concepts/test_spcent.svg", "w") as f: f.write(svg_spiral_centered)
with open("logo_concepts/test_spround.svg", "w") as f: f.write(svg_spiral_round)

run_render("logo_concepts/test_spcent.svg", "logo_concepts/test_spcent.png")
run_render("logo_concepts/test_spround.svg", "logo_concepts/test_spround.png")
print("Rendered centered spirals")
