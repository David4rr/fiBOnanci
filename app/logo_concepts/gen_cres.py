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

# 1. Dual Golden Interlocking Crescents (Safe-to-Spend Financial Equilibrium)
# Two interlocking golden ratio crescents that curl towards each other:
# Top crescent: starts at (128, 36), sweeps around to right and down.
# Bottom crescent: starts at (128, 220), sweeps around to left and up.
# When nested, they form a dynamic S-spiral of continuous cashflow balance.
svg_dual_crescent = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-dualcres">
  <title id="t-dualcres">fiBOnanci Equilibrium Arcs</title>
  <!-- Top crescent -->
  <path fill="#0C0D11" d="
    M 128 36
    A 92 92 0 0 1 220 128
    A 92 92 0 0 1 184 196
    A 64 64 0 0 0 196 128
    A 68 68 0 0 0 128 60
    A 68 68 0 0 0 72 88
    A 92 92 0 0 1 128 36
    Z
  "/>
  <!-- Bottom crescent -->
  <path fill="#0C0D11" d="
    M 128 220
    A 92 92 0 0 1 36 128
    A 92 92 0 0 1 72 60
    A 64 64 0 0 0 60 128
    A 68 68 0 0 0 128 196
    A 68 68 0 0 0 184 168
    A 92 92 0 0 1 128 220
    Z
  "/>
  <circle cx="128" cy="128" r="14" fill="#0C0D11" />
</svg>'''

# 2. The Solid Tapering Golden Nautilus
# A continuous solid path forming the Fibonacci logarithmic spiral
# Points computed along r = a * exp(b * theta)
def make_solid_nautilus():
    a = 18.0
    b = 0.30635  # golden ratio spiral growth factor (ln(phi)/(pi/2))
    outer_pts = []
    inner_pts = []
    
    # theta from 0 to 3.5 * pi
    steps = 60
    for i in range(steps + 1):
        t = (3.5 * math.pi) * (i / steps)
        # outer radius
        r_out = a * math.exp(b * t)
        # inner radius (offset by golden thickness)
        r_in = max(0, r_out - (10.0 + 14.0 * (t / (3.5 * math.pi))))
        
        # Center around (136, 136)
        cx, cy = 136, 136
        # Rotate by 45 deg for optimal dynamic stance
        rot = t - math.pi * 0.25
        
        x_out = cx + r_out * math.cos(rot)
        y_out = cy + r_out * math.sin(rot)
        outer_pts.append((x_out, y_out))
        
        x_in = cx + r_in * math.cos(rot)
        y_in = cy + r_in * math.sin(rot)
        inner_pts.append((x_in, y_in))
        
    return outer_pts, inner_pts

# Let's test a clean geometric 4-arc Golden Spiral Nautilus where the path has solid thickness and flat modern terminals:
svg_nautilus_clean = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-nautclean">
  <title id="t-nautclean">fiBOnanci Golden Nautilus</title>
  <path fill="#0C0D11" d="
    M 128 224
    A 96 96 0 0 1 32 128
    A 96 96 0 0 1 128 32
    A 96 96 0 0 1 224 128
    A 96 96 0 0 1 196 196
    L 174 174
    A 66 66 0 0 0 194 128
    A 66 66 0 0 0 128 62
    A 66 66 0 0 0 62 128
    A 66 66 0 0 0 128 194
    A 66 66 0 0 0 162 184
    L 172 212
    A 96 96 0 0 1 128 224
    Z
  "/>
  <circle cx="128" cy="128" r="22" fill="#0C0D11" />
</svg>'''

with open("logo_concepts/test_dualcres.svg", "w") as f: f.write(svg_dual_crescent)
with open("logo_concepts/test_nautclean.svg", "w") as f: f.write(svg_nautilus_clean)

run_render("logo_concepts/test_dualcres.svg", "logo_concepts/test_dualcres.png")
run_render("logo_concepts/test_nautclean.svg", "logo_concepts/test_nautclean.png")
print("Rendered dual crescents and nautilus clean")
