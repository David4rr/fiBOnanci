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

# Concept: Nested Golden Arcs (Fibonacci Pacing Spiral)
# Three concentric curved bars with golden ratio radii and offsets:
# Arc 1: R_out = 96, R_in = 68 (thickness 28). Sweeps 210 degrees from angle 30 to 240. Rounded caps.
# Arc 2: R_out = 56, R_in = 32 (thickness 24). Sweeps 210 degrees from angle 210 to 60. Rounded caps.
# Arc 3: Center solid dot/capsule at (128, 128) with radius 16.

# Let's write helper for curved circular bar with rounded caps
def curved_bar(cx, cy, r_out, r_in, start_deg, sweep_deg):
    cap_r = (r_out - r_in) / 2.0
    r_mid = (r_out + r_in) / 2.0
    a0 = math.radians(start_deg)
    a1 = math.radians(start_deg + sweep_deg)
    
    # Outer start and end
    p_out_start = (cx + r_out * math.cos(a0), cy + r_out * math.sin(a0))
    p_out_end = (cx + r_out * math.cos(a1), cy + r_out * math.sin(a1))
    # Inner start and end
    p_in_start = (cx + r_in * math.cos(a0), cy + r_in * math.sin(a0))
    p_in_end = (cx + r_in * math.cos(a1), cy + r_in * math.sin(a1))
    
    large_arc = 1 if abs(sweep_deg) > 180 else 0
    sweep_flag = 1 if sweep_deg > 0 else 0
    
    d = [
        f"M {p_out_start[0]:.2f} {p_out_start[1]:.2f}",
        f"A {r_out} {r_out} 0 {large_arc} {sweep_flag} {p_out_end[0]:.2f} {p_out_end[1]:.2f}",
        # Cap at end
        f"A {cap_r:.2f} {cap_r:.2f} 0 0 {sweep_flag} {p_in_end[0]:.2f} {p_in_end[1]:.2f}",
        # Inner arc back
        f"A {r_in} {r_in} 0 {large_arc} {1 - sweep_flag} {p_in_start[0]:.2f} {p_in_start[1]:.2f}",
        # Cap at start
        f"A {cap_r:.2f} {cap_r:.2f} 0 0 {sweep_flag} {p_out_start[0]:.2f} {p_out_start[1]:.2f}",
        "Z"
    ]
    return " ".join(d)

d1 = curved_bar(128, 128, 96, 68, -45, 230)
d2 = curved_bar(128, 128, 54, 30, 135, 230)

svg_nested = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-nest">
  <title id="t-nest">fiBOnanci Nested Golden Spiral</title>
  <path fill="#0C0D11" d="{d1}" />
  <path fill="#0C0D11" d="{d2}" />
  <circle cx="128" cy="128" r="14" fill="#0C0D11" />
</svg>'''

with open("logo_concepts/test_nested.svg", "w") as f: f.write(svg_nested)
run_render("logo_concepts/test_nested.svg", "logo_concepts/test_nested.png")
print("Rendered nested golden arcs")
