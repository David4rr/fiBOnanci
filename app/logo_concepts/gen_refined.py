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

# 1. Phi Ring Vault (Phi constant 1.618 / Golden Ratio)
# Outer circle R=92, inner circle r=54. Center (128, 128).
# Central vertical column: x from 114 to 142 (width 28), y from 20 to 236 with rx=14 (or flat).
# Negative gap = 12.
# Left wing: x_right = 114 - 12 = 102.
# Right wing: x_left = 142 + 12 = 154.
# Let's compute exact intersections for outer arc (R=92) and inner arc (r=54).
# For outer arc: dx = 128 - 102 = 26. dy_out = sqrt(92^2 - 26^2) = sqrt(8464 - 676) = sqrt(7788) = 88.25.
# For inner arc: dx = 26. dy_in = sqrt(54^2 - 26^2) = sqrt(2916 - 676) = sqrt(2240) = 47.33.
# Top edge connects (102, 128 - 88.25) = (102, 39.75) to (102, 128 - 47.33) = (102, 80.67).
# Outer arc sweeps from (102, 39.75) counterclockwise to (102, 216.25).
# Inner arc sweeps from (102, 175.33) clockwise to (102, 80.67).
# Let's write the SVG for Phi Ring Vault:

svg_phi_ring = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-phi-ring">
  <title id="t-phi-ring">fiBOnanci Phi Ring Vault</title>
  <!-- Central monolithic axis -->
  <rect x="114" y="24" width="28" height="208" rx="14" fill="#0C0D11" />
  <!-- Left wing -->
  <path fill="#0C0D11" d="
    M 102 39.75
    A 92 92 0 0 0 102 216.25
    V 175.33
    A 54 54 0 0 1 102 80.67
    Z
  "/>
  <!-- Right wing -->
  <path fill="#0C0D11" d="
    M 154 39.75
    V 80.67
    A 54 54 0 0 1 154 175.33
    V 216.25
    A 92 92 0 0 0 154 39.75
    Z
  "/>
</svg>'''

# 2. Golden Nautilus Core (Solid Sculptural Golden Spiral)
# Built from 3 logarithmic quarter-circle segments expanding by golden ratio, forming a solid tapering nautilus shell with a central pearl/core.
# Outer curve: sweeps from (128, 224) via (32, 128) via (128, 32) via (224, 128).
# Let's create an iconic geometric nautilus with an inner golden seed.
svg_nautilus = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-nautilus">
  <title id="t-nautilus">fiBOnanci Nautilus Core</title>
  <!-- Outer golden sweeping petal -->
  <path fill="#0C0D11" d="
    M 128 228
    A 100 100 0 0 1 28 128
    A 100 100 0 0 1 128 28
    A 100 100 0 0 1 228 128
    H 176
    A 48 48 0 0 0 128 80
    A 48 48 0 0 0 80 128
    A 48 48 0 0 0 128 176
    V 228
    Z
  "/>
  <!-- Inner golden nucleus/seed -->
  <circle cx="128" cy="128" r="26" fill="#0C0D11" />
</svg>'''

# 3. Golden Ratio 'F' Monogram (The Fibonacci Monogram)
# Lowercase 'f' with Fibonacci curve and floating balance crossbar, but carefully proportioned to NOT look like Facebook.
# Specifically: An uppercase/lowercase hybrid with a continuous architectural loop or a stepped double golden bar.
# Let's design a pure geometric 'F' where the stem is on the left, and two horizontal bars have rounded circular golden terminals.
svg_f_geometric = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-fgeo">
  <title id="t-fgeo">fiBOnanci Golden Monogram F</title>
  <!-- Vertical spine -->
  <rect x="52" y="32" width="36" height="192" rx="18" fill="#0C0D11" />
  <!-- Upper golden arm: length 136, height 36, rounded terminal -->
  <path fill="#0C0D11" d="
    M 88 32
    H 186
    A 18 18 0 0 1 204 50
    V 50
    A 18 18 0 0 1 186 68
    H 88
    Z
  "/>
  <!-- Lower golden arm: length 84 (136 / 1.618), height 36, rounded terminal -->
  <path fill="#0C0D11" d="
    M 88 114
    H 154
    A 18 18 0 0 1 172 132
    V 132
    A 18 18 0 0 1 154 150
    H 88
    Z
  "/>
</svg>'''

with open("logo_concepts/test_phi_ring.svg", "w") as f: f.write(svg_phi_ring)
with open("logo_concepts/test_nautilus.svg", "w") as f: f.write(svg_nautilus)
with open("logo_concepts/test_fgeo.svg", "w") as f: f.write(svg_f_geometric)

run_render("logo_concepts/test_phi_ring.svg", "logo_concepts/test_phi_ring.png")
run_render("logo_concepts/test_nautilus.svg", "logo_concepts/test_nautilus.png")
run_render("logo_concepts/test_fgeo.svg", "logo_concepts/test_fgeo.png")
print("Rendered refined concepts")
