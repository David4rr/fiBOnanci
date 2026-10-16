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

# Compute exact points along the 5-arc Fibonacci spiral
u = 11.0
origin_x, origin_y = 0.0, 0.0

# Arc 1: center (0, u), r=u, angle from -pi/2 to -pi (counter-clockwise/sweep negative)
# Arc 2: center (u, u), r=2u, angle from pi to pi/2
# Arc 3: center (u, 0), r=3u, angle from pi/2 to 0
# Arc 4: center (-u, 0), r=5u, angle from 0 to -pi/2
# Arc 5: center (-u, 3u), r=8u, angle from -pi/2 to -pi/2 - 0.46*pi

# Let's trace points and compute bounds
pts = [(origin_x, origin_y)]

# Helper to sample arc
def sample_arc(cx, cy, r, a_start, a_sweep, steps=20):
    for i in range(1, steps + 1):
        a = a_start + a_sweep * (i / steps)
        pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))

sample_arc(origin_x, origin_y + u, u, -math.pi/2, -math.pi/2)
sample_arc(origin_x + u, origin_y + u, 2*u, math.pi, -math.pi/2)
sample_arc(origin_x + u, origin_y, 3*u, math.pi/2, -math.pi/2)
sample_arc(origin_x - u, origin_y, 5*u, 0, -math.pi/2)
sample_arc(origin_x - u, origin_y + 3*u, 8*u, -math.pi/2, -math.pi*0.46)

min_x = min(p[0] for p in pts)
max_x = max(p[0] for p in pts)
min_y = min(p[1] for p in pts)
max_y = max(p[1] for p in pts)

box_w = max_x - min_x
box_h = max_y - min_y
mid_x = (min_x + max_x) / 2.0
mid_y = (min_y + max_y) / 2.0

# Shift so mid is at (128, 128)
dx = 128 - mid_x
dy = 128 - mid_y

# Generate SVG path commands with exact shifted coords
# Arc 1: center (dx, dy + u)
# Arc 2: center (dx + u, dy + u)
# Arc 3: center (dx + u, dy)
# Arc 4: center (dx - u, dy)
# Arc 5: center (dx - u, dy + 3*u)

p0 = (dx, dy)
c1 = (dx, dy + u)
p1 = (c1[0] - u, c1[1])
c2 = (dx + u, dy + u)
p2 = (c2[0], c2[1] + 2*u)
c3 = (dx + u, dy)
p3 = (c3[0] + 3*u, c3[1])
c4 = (dx - u, dy)
p4 = (c4[0], c4[1] - 5*u)
c5 = (dx - u, dy + 3*u)
# end of arc 5:
a5_end = -math.pi/2 - math.pi*0.46
p5 = (c5[0] + 8*u * math.cos(a5_end), c5[1] + 8*u * math.sin(a5_end))

svg_golden_pure = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-gpure">
  <title id="t-gpure">fiBOnanci Golden Spiral Pure</title>
  <path fill="none" stroke="#0C0D11" stroke-width="22" stroke-linecap="round" stroke-linejoin="round" d="
    M {p0[0]:.2f} {p0[1]:.2f}
    A {u:.2f} {u:.2f} 0 0 0 {p1[0]:.2f} {p1[1]:.2f}
    A {2*u:.2f} {2*u:.2f} 0 0 0 {p2[0]:.2f} {p2[1]:.2f}
    A {3*u:.2f} {3*u:.2f} 0 0 0 {p3[0]:.2f} {p3[1]:.2f}
    A {5*u:.2f} {5*u:.2f} 0 0 0 {p4[0]:.2f} {p4[1]:.2f}
    A {8*u:.2f} {8*u:.2f} 0 0 0 {p5[0]:.2f} {p5[1]:.2f}
  "/>
</svg>'''

with open("logo_concepts/test_gpure.svg", "w") as f: f.write(svg_golden_pure)
run_render("logo_concepts/test_gpure.svg", "logo_concepts/test_gpure.png")
print(f"Rendered golden pure (box: {box_w:.1f}x{box_h:.1f})")
