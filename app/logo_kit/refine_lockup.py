import subprocess

# Let's refine the glyphs so each letterform is a pristine, crisp geometric sans glyph:
def f_glyph():
    path = "M 8 0 V -30 H 0 V -44 H 8 V -52 A 12 12 0 0 1 20 -64 H 36 V -50 H 26 A 4 4 0 0 0 22 -46 V -44 H 36 V -30 H 22 V 0 Z"
    return path, None, 40

def i_glyph():
    path = "M 4 0 V -44 H 18 V 0 Z"
    dot = '<circle cx="11" cy="-56" r="7" />'
    return path, dot, 24

def B_glyph():
    path = """M 0 -64 H 26 A 15 15 0 0 1 38 -49 A 15 15 0 0 1 26 -34 H 0 Z
              M 0 -34 H 28 A 17 17 0 0 1 42 -17 A 17 17 0 0 1 28 0 H 0 Z
              M 14 -50 V -48 H 22 A 2 2 0 0 0 22 -50 Z
              M 14 -20 V -14 H 24 A 4 4 0 0 0 24 -20 Z"""
    return path, None, 46

def O_glyph():
    path = """M 32 -64 A 32 32 0 1 1 31.9 -64 Z
              M 32 -48 A 16 16 0 1 0 32.1 -48 Z"""
    return path, None, 68

def n_glyph():
    path = """M 0 0 V -44 H 14 V -36 A 15 15 0 0 1 36 -44 A 12 12 0 0 1 42 -32 V 0 H 28 V -30 A 6 6 0 0 0 22 -36 A 8 8 0 0 0 14 -28 V 0 Z"""
    return path, None, 48

def a_glyph():
    # Outer circle R=22 (center 22, -22), right stem from 30 to 44
    path = """M 22 -44 A 22 22 0 0 0 0 -22 A 22 22 0 0 0 22 0 A 21 21 0 0 0 34 -4 V 0 H 46 V -44 H 34 V -38 A 20 20 0 0 0 22 -44 Z
              M 22 -30 A 10 10 0 1 1 21.9 -30 Z"""
    return path, None, 52

def c_glyph():
    path = """M 40 -10 A 18 18 0 0 1 22 0 A 22 22 0 1 1 22 -44 A 18 18 0 0 1 40 -34 L 30 -26 A 10 10 0 0 0 22 -32 A 10 10 0 1 0 22 -12 A 10 10 0 0 0 30 -18 Z"""
    return path, None, 46

glyphs = [
    (f_glyph(), "#F4F5F8", False),
    (i_glyph(), "#F4F5F8", False),
    (B_glyph(), "#D4F442", True),
    (O_glyph(), "#D4F442", True),
    (n_glyph(), "#F4F5F8", False),
    (a_glyph(), "#F4F5F8", True),
    (n_glyph(), "#F4F5F8", False),
    (c_glyph(), "#F4F5F8", False),
    (i_glyph(), "#F4F5F8", False),
]

start_x = 300
baseline_y = 164

svg_elements = []
cur_x = start_x
for (p, dot, adv), col, evenodd in glyphs:
    rule_attr = ' fill-rule="evenodd"' if evenodd else ''
    elem = f'<path fill="{col}"{rule_attr} transform="translate({cur_x}, {baseline_y})" d="{p}" />'
    svg_elements.append(elem)
    if dot:
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
  <line x1="266" y1="64" x2="266" y2="192" stroke="#252836" stroke-width="2" stroke-linecap="round" />
  
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
print(f"Refined lockup (wordmark width: {cur_x - start_x}px)")
