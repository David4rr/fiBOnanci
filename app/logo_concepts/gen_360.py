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

# Full 360-degree Golden Spiral Coil with balanced mass
# Canvas 256x256, center (128, 128)
# Starting at the outer right: (220, 128)
# Sweeps up and around (radius 92): through (128, 36), (36, 128), (128, 220)...
# Then spirals inward: radius reduces smoothly to 62, then to 38, ending in a solid origin dot!
# Stroke width is solid: 22px, with clean rounded terminals.

svg_spiral_360 = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-sp360">
  <title id="t-sp360">fiBOnanci Golden Spiral 360</title>
  <!-- Full golden spiral stroke -->
  <path fill="none" stroke="#0C0D11" stroke-width="22" stroke-linecap="round" stroke-linejoin="round" d="
    M 144 136
    A 16 16 0 0 0 128 152
    A 32 32 0 0 0 160 184
    A 56 56 0 0 0 216 128
    A 88 88 0 0 0 128 40
    A 92 92 0 0 0 36 132
    A 88 88 0 0 0 128 220
    A 76 76 0 0 0 196 172
  "/>
  <circle cx="144" cy="136" r="10" fill="#0C0D11" />
</svg>'''

with open("logo_concepts/test_sp360.svg", "w") as f: f.write(svg_spiral_360)
run_render("logo_concepts/test_sp360.svg", "logo_concepts/test_sp360.png")
print("Rendered 360 spiral")
