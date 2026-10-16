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

# Sequence of Fibonacci arcs starting from center out to 13u
# Box 1: (0,0) to (1,1) -> Arc 1 (r=1)
# Box 2: (-1,0) to (0,1) -> Arc 2 (r=1)
# Box 3: (-1,-2) to (1,0) -> Arc 3 (r=2)
# Box 4: (1,-2) to (4,1) -> Arc 4 (r=3)
# Box 5: (-1,1) to (4,6) -> Arc 5 (r=5)
# Box 6: (-9,-2) to (-1,6) -> Arc 6 (r=8)
# Box 7: (-9,-15) to (4,-2) -> Arc 7 (r=13)

# Let's write standard Fibonacci spiral centered:
# Centers for clockwise spiral:
# Center 1: (0, 0), r = 1
# Center 2: (-1, 0), r = 2
# Center 3: (-1, -1), r = 3
# Center 4: (1, -1), r = 5
# Center 5: (1, 2), r = 8
# Center 6: (-4, 2), r = 13
# Center 7: (-4, -6), r = 21

u = 7.0
# Radii: 7, 14, 21, 35, 56, 91
# Let's sample and find exact bounds
pts = []
def sample_arc(cx, cy, r, a_start, a_sweep, steps=25):
    for i in range(steps + 1):
        a = a_start + a_sweep * (i / steps)
        pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))

# Arc 1: r=7, center (0, 0), angle 0 to pi/2
sample_arc(0, 0, 7, 0, math.pi/2)
# Arc 2: r=14, center (0, -7), angle pi/2 to pi
sample_arc(0, -7, 14, math.pi/2, math.pi/2)
# Arc 3: r=21, center (7, -7), angle pi to 3*pi/2
sample_arc(7, -7, 21, math.pi, math.pi/2)
# Arc 4: r=35, center (7, 7), angle 3*pi/2 to 2*pi
sample_arc(7, 7, 35, 3*math.pi/2, math.pi/2)
# Arc 5: r=56, center (-14, 7), angle 0 to pi/2
sample_arc(-14, 7, 56, 0, math.pi/2)
# Arc 6: r=91, center (-14, -28), angle pi/2 to pi
sample_arc(-14, -28, 91, math.pi/2, math.pi/2)

min_x = min(p[0] for p in pts)
max_x = max(p[0] for p in pts)
min_y = min(p[1] for p in pts)
max_y = max(p[1] for p in pts)

mid_x = (min_x + max_x) / 2.0
mid_y = (min_y + max_y) / 2.0

dx = 128 - mid_x
dy = 128 - mid_y

# Generate SVG path
# Trace from outer (end of Arc 6) to inner (start of Arc 1) or vice versa
p_start = (dx - 14 - 91, dy - 28)
# From angle pi down to 0...
# Arc 6: center (dx - 14, dy - 28), r=91. from pi to pi/2
# Arc 5: center (dx - 14, dy + 7), r=56. from pi/2 to 0
# Arc 4: center (dx + 7, dy + 7), r=35. from 2*pi to 3*pi/2
# Arc 3: center (dx + 7, dy - 7), r=21. from 3*pi/2 to pi
# Arc 2: center (dx, dy - 7), r=14. from pi to pi/2
# Arc 1: center (dx, dy), r=7. from pi/2 to 0

p_end_6 = (dx - 14, dy - 28 + 91)
p_end_5 = (dx - 14 + 56, dy + 7)
p_end_4 = (dx + 7, dy + 7 - 35)
p_end_3 = (dx + 7 - 21, dy - 7)
p_end_2 = (dx, dy - 7 + 14)
p_end_1 = (dx + 7, dy)

svg_spiral_full = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-spfull">
  <title id="t-spfull">fiBOnanci Complete Golden Spiral</title>
  <path fill="none" stroke="#0C0D11" stroke-width="22" stroke-linecap="round" stroke-linejoin="round" d="
    M {p_start[0]:.2f} {p_start[1]:.2f}
    A 91 91 0 0 0 {p_end_6[0]:.2f} {p_end_6[1]:.2f}
    A 56 56 0 0 0 {p_end_5[0]:.2f} {p_end_5[1]:.2f}
    A 35 35 0 0 0 {p_end_4[0]:.2f} {p_end_4[1]:.2f}
    A 21 21 0 0 0 {p_end_3[0]:.2f} {p_end_3[1]:.2f}
    A 14 14 0 0 0 {p_end_2[0]:.2f} {p_end_2[1]:.2f}
    A 7 7 0 0 0 {p_end_1[0]:.2f} {p_end_1[1]:.2f}
  "/>
</svg>'''

with open("logo_concepts/test_spfull.svg", "w") as f: f.write(svg_spiral_full)
run_render("logo_concepts/test_spfull.svg", "logo_concepts/test_spfull.png")
print(f"Rendered spfull (box: {max_x - min_x:.1f}x{max_y - min_y:.1f})")
