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

# Let's generate a perfectly centered, solid, filled Fibonacci spiral.
# Radii for centerline arcs:
# Arc 1: center C1 = (138, 142), r = 16. Angle from 0 to -pi/2 (quadrant 4)
# Arc 2: center C2 = (138, 142), wait, let's make tangent centers:
# Let C1 = (144, 140)
# Tangent progression:
# Arc 1 (r=14): center (144, 154), sweeps from (144, 140) to (130, 154).
# Arc 2 (r=28): center (158, 154), sweeps from (130, 154) to (158, 182).
# Arc 3 (r=46): center (158, 136), sweeps from (158, 182) to (204, 136).
# Arc 4 (r=76): center (128, 136), sweeps from (204, 136) to (128, 60).
# Arc 5 (r=106): center (128, 166), sweeps from (128, 60) to (22, 166).

# Centerline points and tangent arcs:
# Thickness W = 22. Half thickness h = 11.
# Outer arcs have radius r + h.
# Inner arcs have radius r - h.
# All tangent centers remain identical!
# Outer path (from center out):
# Arc 1 out: center (144, 154), r = 14 + 11 = 25.
# Arc 2 out: center (158, 154), r = 28 + 11 = 39.
# Arc 3 out: center (158, 136), r = 46 + 11 = 57.
# Arc 4 out: center (128, 136), r = 76 + 11 = 87.
# Arc 5 out: center (128, 166), r = 106 + 11 = 117.
# Outer terminal cap: semicircle of radius 11 at (22, 166).
# Inner arcs (from outer back to center):
# Arc 5 in: center (128, 166), r = 106 - 11 = 95.
# Arc 4 in: center (128, 136), r = 76 - 11 = 65.
# Arc 3 in: center (158, 136), r = 46 - 11 = 35.
# Arc 2 in: center (158, 154), r = 28 - 11 = 17.
# Arc 1 in: center (144, 154), r = 14 - 11 = 3.
# Inner terminal cap: semicircle of radius 11 at (144, 140).

# Let's shift all centers so the bounding box is centered in 256x256:
# Outer bounds:
# x_min = 128 - 117 = 11. x_max = 158 + 57 = 215. width = 204. mid_x = 113.
# y_min = 128 - 87 = 41. y_max = 158 + 39 = 197. height = 156. mid_y = 119.
# Shift: dx = 128 - 113 = +15. dy = 128 - 119 = +9.

dx, dy = 15, 9
c1 = (144 + dx, 154 + dy)
c2 = (158 + dx, 154 + dy)
c3 = (158 + dx, 136 + dy)
c4 = (128 + dx, 136 + dy)
c5 = (128 + dx, 166 + dy)

# Outer arc endpoints:
# Arc 1 out starts at (c1[0], c1[1] - 25) = (159, 138)
# Arc 1 out ends at (c1[0] - 25, c1[1]) = (134, 163)
# Arc 2 out ends at (c2[0], c2[1] + 39) = (173, 202)
# Arc 3 out ends at (c3[0] + 57, c3[1]) = (230, 145)
# Arc 4 out ends at (c4[0], c4[1] - 87) = (143, 58)
# Arc 5 out ends at (c5[0] - 117, c5[1]) = (26, 175)

# Outer cap from (26, 175) to inner start (c5[0] - 95, c5[1]) = (48, 175):
# Arc of radius 11 from (26, 175) to (48, 175)

# Inner arc endpoints:
# Arc 5 in ends at (c4[0], c4[1] - 65) = (143, 80)
# Arc 4 in ends at (c3[0] + 35, c3[1]) = (208, 145)
# Arc 3 in ends at (c2[0], c2[1] + 17) = (173, 180)
# Arc 2 in ends at (c1[0] - 3, c1[1]) = (156, 163)
# Arc 1 in ends at (c1[0], c1[1] - 3) = (159, 160)
# Inner cap from (159, 160) to (159, 138): semicircle radius 11!

svg_c_filled = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="title-c">
  <title id="title-c">fiBOnanci Golden Spiral Ribbon</title>
  <path fill="#0C0D11" d="
    M 159 138
    A 25 25 0 0 0 134 163
    A 39 39 0 0 0 173 202
    A 57 57 0 0 0 230 145
    A 87 87 0 0 0 143 58
    A 117 117 0 0 0 26 175
    A 11 11 0 0 0 48 175
    A 95 95 0 0 1 143 80
    A 65 65 0 0 1 208 145
    A 35 35 0 0 1 173 180
    A 17 17 0 0 1 156 163
    A 3 3 0 0 1 159 160
    A 11 11 0 0 0 159 138
    Z
  "/>
</svg>'''

with open("logo_concepts/concept_c.svg", "w") as f: f.write(svg_c_filled)

cmd = ["python3", "/Users/mac/.agents/skills/logo-design/scripts/render_png.py", "logo_concepts/concept_c.svg", "-o", "logo_concepts/concept_c.png", "--size", "256", "--bg", "#ffffff"]
subprocess.run(cmd, check=True)
print("Rendered concept_c")
