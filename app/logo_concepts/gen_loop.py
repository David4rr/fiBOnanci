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

# Continuous Architectural Golden F Ribbon:
# Rises from (76, 224) to (76, 88),
# Sweeps across the top arc to (180, 88),
# Curves inward to (180, 136),
# Horizontal bar cuts back left to (76, 136)!
# This forms an unbroken, flowing, closed/open 'F' loop!
svg_f_loop = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-floop">
  <title id="t-floop">fiBOnanci Golden F Loop</title>
  <path fill="none" stroke="#0C0D11" stroke-width="26" stroke-linecap="round" stroke-linejoin="round" d="
    M 76 220
    V 92
    A 52 52 0 0 1 180 92
    V 112
    A 24 24 0 0 1 156 136
    H 76
  "/>
</svg>'''

# Let's also test a Golden Spiral carved into a Solid Circle (Negative Space Nautilus)
# Solid circle R=96 at (128, 128)
# A negative space spiral channel of width 18 cuts into it from the perimeter!
svg_negative_nautilus = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-negnaut">
  <title id="t-negnaut">fiBOnanci Negative Spiral Monolith</title>
  <mask id="spiral-cut">
    <rect width="256" height="256" fill="white" />
    <path fill="none" stroke="black" stroke-width="20" stroke-linecap="round" d="
      M 128 32
      A 96 96 0 0 1 224 128
      A 68 68 0 0 1 156 196
      A 44 44 0 0 1 112 152
      A 24 24 0 0 1 136 128
    "/>
  </mask>
  <circle cx="128" cy="128" r="96" fill="#0C0D11" mask="url(#spiral-cut)" />
</svg>'''

with open("logo_concepts/test_floop.svg", "w") as f: f.write(svg_f_loop)
with open("logo_concepts/test_negnaut.svg", "w") as f: f.write(svg_negative_nautilus)

run_render("logo_concepts/test_floop.svg", "logo_concepts/test_floop.png")
run_render("logo_concepts/test_negnaut.svg", "logo_concepts/test_negnaut.png")
print("Rendered loop and negative nautilus")
