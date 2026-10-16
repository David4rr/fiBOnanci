import os
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

# Concept 1: The Phi Vault (Phi / Golden Ratio Emblem)
# Circle of radius 84 bisected by a vertical bar of width 32, with 12px negative gap.
# Left lobe: x from 44 to 112-12=100. Right lobe: x from 144+12=156 to 212.
# Outer circle R=84 centered at (128,128).
# Central bar: x from 114 to 142 (w=28), y from 28 to 228 (h=200) with rx=14 (pill cap).
# Left lobe: arc from (102, 54) to (102, 202) following R=84 circle.
# Wait, let's write exact SVG path for Phi Vault.
svg_phi = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-phi">
  <title id="t-phi">fiBOnanci Phi Vault</title>
  <!-- Central monolithic axis -->
  <rect x="114" y="24" width="28" height="208" rx="14" fill="#0C0D11" />
  <!-- Left vault wing (arc R=84) -->
  <path fill="#0C0D11" d="
    M 98 48
    A 84 84 0 0 0 98 208
    H 104
    V 48
    H 98
    Z
  "/>
  <!-- Right vault wing (arc R=84) -->
  <path fill="#0C0D11" d="
    M 158 48
    V 208
    H 152
    A 84 84 0 0 0 152 48
    H 158
    Z
  "/>
</svg>'''

# Concept 2: The Golden Spiral Solid (Nautilus Ribbon)
# An elegant sweeping golden arc forming a solid nautilus.
# Outer curve sweeps from (128, 224) counterclockwise to (224, 128), (128, 32), (48, 128), (128, 192), (184, 128), (128, 80), (88, 128)...
# Let's construct a continuous tapered golden ribbon path.
svg_spiral_ribbon = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-spiral">
  <title id="t-spiral">fiBOnanci Golden Ribbon</title>
  <path fill="#0C0D11" fill-rule="evenodd" d="
    M 128 32
    A 96 96 0 1 1 32 128
    A 96 96 0 0 1 128 32
    Z
    M 128 68
    A 60 60 0 0 0 68 128
    A 60 60 0 1 0 168 84
    L 152 110
    A 34 34 0 1 1 128 94
    V 68
    Z
  "/>
</svg>'''

# Concept 3: Fibonacci Monolith Blocks (Geometric Mosaic)
# Three golden ratio rectangular monoliths arranged in a dynamic pinwheel / L-nesting
svg_blocks = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-blocks">
  <title id="t-blocks">fiBOnanci Fibonacci Monolith</title>
  <!-- Block 1: Large golden vertical monolith (89 units) -->
  <rect x="36" y="36" width="80" height="184" rx="16" fill="#0C0D11" />
  <!-- Block 2: Golden square block (55 units) -->
  <rect x="130" y="36" width="90" height="90" rx="16" fill="#0C0D11" />
  <!-- Block 3: Golden horizontal bar (34 units) -->
  <rect x="130" y="140" width="90" height="80" rx="16" fill="#0C0D11" />
</svg>'''

# Concept 4: The Golden F-Fold (Architectural Monogram)
# An F formed by a vertical spine and two horizontal cantilevered bars with pure golden ratio proportions and rounded exterior terminals
svg_f_architectural = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-farch">
  <title id="t-farch">fiBOnanci Architectural F</title>
  <path fill="#0C0D11" d="
    M 56 220
    V 52
    A 16 16 0 0 1 72 36
    H 184
    A 16 16 0 0 1 200 52
    V 64
    A 16 16 0 0 1 184 80
    H 104
    V 112
    H 160
    A 16 16 0 0 1 176 128
    V 136
    A 16 16 0 0 1 160 152
    H 104
    V 220
    H 56
    Z
  "/>
</svg>'''

with open("logo_concepts/test_phi.svg", "w") as f: f.write(svg_phi)
with open("logo_concepts/test_ribbon.svg", "w") as f: f.write(svg_spiral_ribbon)
with open("logo_concepts/test_blocks.svg", "w") as f: f.write(svg_blocks)
with open("logo_concepts/test_farch.svg", "w") as f: f.write(svg_f_architectural)

run_render("logo_concepts/test_phi.svg", "logo_concepts/test_phi.png")
run_render("logo_concepts/test_ribbon.svg", "logo_concepts/test_ribbon.png")
run_render("logo_concepts/test_blocks.svg", "logo_concepts/test_blocks.png")
run_render("logo_concepts/test_farch.svg", "logo_concepts/test_farch.png")
print("Rendered exploration concepts")
