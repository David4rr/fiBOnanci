import subprocess

# Precise glyph builder with explicit local coords and advance widths
# Origin at baseline (y=0), up is negative y
# Cap height = -64, x-height = -44

def f_glyph():
    # stem from x=8 to 22, y=0 down to -44
    # arch to x=36, y=-64
    # crossbar at y=-44, x=0 to 36
    path = "M 8 0 V -30 H 0 V -44 H 8 V -50 A 14 14 0 0 1 22 -64 H 36 V -50 H 28 A 4 4 0 0 0 24 -46 V -44 H 36 V -30 H 24 V 0 Z"
    return path, 40

def i_glyph():
    # stem x=4 to 18, y=0 to -44
    # dot cx=11, cy=-56, r=7
    path = "M 4 0 V -44 H 18 V 0 Z"
    dot = '<circle cx="11" cy="-56" r="7" />'
    return path, dot, 24

def B_glyph():
    # stem x=0 to 14, y=0 to -64
    # top bowl: y=-64 to -34, x_max=38
    # bottom bowl: y=-34 to 0, x_max=42
    path = """M 0 -64 H 26 A 15 15 0 0 1 38 -49 A 15 15 0 0 1 26 -34 H 0 Z
              M 0 -34 H 28 A 17 17 0 0 1 42 -17 A 17 17 0 0 1 28 0 H 0 Z
              M 14 -52 V -46 H 24 A 3 3 0 0 0 24 -52 Z
              M 14 -22 V -12 H 26 A 5 5 0 0 0 26 -22 Z"""
    return path, 46

def O_glyph():
    # Circle diameter 64, cx=32, cy=-32
    path = """M 32 -64 A 32 32 0 1 1 31.9 -64 Z
              M 32 -48 A 16 16 0 1 0 32.1 -48 Z"""
    return path, 68

def n_glyph():
    # left stem x=0 to 14, y=0 to -44
    # right stem x=26 to 40, y=0 to -44
    # arch across top y=-44 to -30
    path = """M 0 0 V -44 H 13 V -36 A 14 14 0 0 1 36 -44 A 12 12 0 0 1 40 -32 V 0 H 26 V -30 A 6 6 0 0 0 20 -36 A 8 8 0 0 0 14 -28 V 0 Z"""
    return path, 44

def a_glyph():
    # round bowl cx=20, cy=-22, stem on right x=28 to 42
    path = """M 40 0 V -8 A 18 18 0 0 1 22 2 A 20 20 0 0 1 0 -22 A 20 20 0 0 1 24 -44 A 18 18 0 0 1 40 -38 V -44 H 54 V 0 Z
              M 30 -14 A 10 10 0 1 0 30 -30 A 10 10 0 0 0 30 -14 Z"""
    return path, 52

def c_glyph():
    # open bowl cx=22, cy=-22, diameter 44
    path = """M 38 -12 A 18 18 0 0 1 20 2 A 22 22 0 1 1 20 -44 A 18 18 0 0 1 38 -32 L 28 -24 A 10 10 0 0 0 20 -32 A 10 10 0 1 0 20 -10 A 10 10 0 0 0 28 -18 Z"""
    return path, 42

# Let's assemble wordmark
start_x = 310
baseline_y = 168

# Build SVG groups with exact translate
f_p, f_adv = f_glyph()
i1_p, i1_d, i1_adv = i_glyph()
B_p, B_adv = B_glyph()
O_p, O_adv = O_glyph()
n1_p, n1_adv = n_glyph()
a_p, a_adv = a_glyph()
n2_p, n2_adv = n_glyph()
c_p, c_adv = c_glyph()
i2_p, i2_d, i2_adv = i_glyph()

glyphs = [
    (f_p, None, f_adv, "#F4F5F8", False),
    (i1_p, i1_d, i1_adv, "#F4F5F8", False),
    (B_p, None, B_adv, "#D4F442", True),
    (O_p, None, O_adv, "#D4F442", True),
    (n1_p, None, n1_adv, "#F4F5F8", False),
    (a_p, None, a_adv, "#F4F5F8", True),
    (n2_p, None, n2_adv, "#F4F5F8", False),
    (c_p, None, c_adv, "#F4F5F8", False),
    (i2_p, i2_d, i2_adv, "#F4F5F8", False),
]

svg_elements = []
cur_x = start_x
for p, dot, adv, col, evenodd in glyphs:
    rule_attr = ' fill-rule="evenodd"' if evenodd else ''
    elem = f'<path fill="{col}"{rule_attr} transform="translate({cur_x}, {baseline_y})" d="{p}" />'
    svg_elements.append(elem)
    if dot:
        # circle in dot has cx, cy
        # replace fill in dot
        d_elem = f'<g fill="{col}" transform="translate({cur_x}, {baseline_y})">{dot}</g>'
        svg_elements.append(d_elem)
    cur_x += adv

wordmark_markup = "\n  ".join(svg_elements)

final_lockup = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 840 256" width="840" height="256" role="img" aria-labelledby="t-lockup-dark">
  <title id="t-lockup-dark">fiBOnanci Horizontal Lockup</title>
  <rect width="840" height="256" fill="#0C0D11" />
  
  <!-- Phi Vault Symbol in Neo-Chartreuse -->
  <g transform="translate(48, 36) scale(0.71875)">
    <rect x="111" y="23" width="34" height="210" rx="17" fill="#D4F442" />
    <path fill="#D4F442" d="M 97 39 A 89 89 0 0 0 39 128 A 89 89 0 0 0 97 217 V 183 A 55 55 0 0 1 73 128 A 55 55 0 0 1 97 73 Z" />
    <path fill="#D4F442" d="M 159 39 A 89 89 0 0 1 217 128 A 89 89 0 0 1 159 217 V 183 A 55 55 0 0 0 183 128 A 55 55 0 0 0 159 73 Z" />
  </g>
  
  <!-- Divider -->
  <line x1="272" y1="64" x2="272" y2="192" stroke="#252836" stroke-width="2" stroke-linecap="round" />
  
  <!-- Wordmark -->
  {wordmark_markup}
</svg>'''

with open("logo_kit/fibonanci-lockup-dark.svg", "w") as f:
    f.write(final_lockup)

cmd = [
    "python3",
    "/Users/mac/.agents/skills/logo-design/scripts/render_png.py",
    "logo_kit/fibonanci-lockup-dark.svg",
    "-o",
    "logo_kit/fibonanci-lockup-dark.png",
    "--size",
    "840",
    "--bg",
    "#0C0D11"
]
subprocess.run(cmd, check=True)
print(f"Generated perfect kerning lockup (wordmark width: {cur_x - start_x}px)")
