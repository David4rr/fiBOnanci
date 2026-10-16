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

# -------------------------------------------------------------
# Concept 1: The Phi Vault (Fibonacci Sequence: 34, 55, 89, 210)
# -------------------------------------------------------------
# Center: (128, 128)
# Outer radius R = 89 (Fibonacci)
# Inner radius r = 55 (Fibonacci)
# Ring thickness = 89 - 55 = 34 (Fibonacci!)
# Central monolith: width = 34 (Fibonacci!), height = 210 (y=23 to y=233, 233 is Fibonacci!), rx = 17 (pill cap)
# Precision gap between central monolith and side wings: G = 12
# Left wing:
# Inner vertical straight edge at x = (128 - 17) - 12 = 99.
# dx from center = 128 - 99 = 29.
# Outer arc intersection: dy_out = sqrt(89^2 - 29^2) = sqrt(7921 - 841) = sqrt(7080) ≈ 84.14.
# Inner arc intersection: dy_in = sqrt(55^2 - 29^2) = sqrt(3025 - 841) = sqrt(2184) ≈ 46.73.
# Top edge: (99, 128 - 84.14) = (99, 43.86) to (99, 128 - 46.73) = (99, 81.27)
# Bottom edge: (99, 128 + 46.73) = (99, 174.73) to (99, 128 + 84.14) = (99, 212.14)

dy_out = math.sqrt(89**2 - 29**2)
dy_in = math.sqrt(55**2 - 29**2)

y_out_top = 128 - dy_out
y_out_bot = 128 + dy_out
y_in_top = 128 - dy_in
y_in_bot = 128 + dy_in

svg_phi = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-phi">
  <title id="t-phi">fiBOnanci Phi Vault</title>
  <!-- Central monolithic axis (width 34, height 210, rounded pill caps) -->
  <rect x="111" y="23" width="34" height="210" rx="17" fill="#0C0D11" />
  <!-- Left vault wing (Fibonacci R=89 outer, r=55 inner) -->
  <path fill="#0C0D11" d="
    M 99 {y_out_top:.2f}
    A 89 89 0 0 0 99 {y_out_bot:.2f}
    V {y_in_bot:.2f}
    A 55 55 0 0 1 99 {y_in_top:.2f}
    Z
  "/>
  <!-- Right vault wing (Fibonacci R=89 outer, r=55 inner) -->
  <path fill="#0C0D11" d="
    M 157 {y_out_top:.2f}
    V {y_in_top:.2f}
    A 55 55 0 0 1 157 {y_in_bot:.2f}
    V {y_out_bot:.2f}
    A 89 89 0 0 0 157 {y_out_top:.2f}
    Z
  "/>
</svg>'''

with open("logo_concepts/concept_phi.svg", "w") as f: f.write(svg_phi)
run_render("logo_concepts/concept_phi.svg", "logo_concepts/concept_phi.png")
print("Rendered concept_phi")
