import subprocess

# Generate full horizontal lockup with exact kerning for "fiBOnanci"
# Total width = 840, height = 256
# Symbol on left: center at (150, 128)
# Divider at x = 270
# Wordmark x from 310 to 770

# Detailed clean path definitions for each letterform:
# Baseline = 172
# Cap height = 70 (y = 102 to 172)
# x-height = 50 (y = 122 to 172)
# Stem width = 16

# 'f': x in [310..344]
# stem from x=318 to 334, y=122..172
# arch from x=334 curving right to x=348 at y=102
# crossbar at y=122 from x=310 to 344
f_path = """
  M 318 172 V 136 H 310 V 120 H 318 V 114 A 20 20 0 0 1 338 94 H 348 V 110 H 340 A 6 6 0 0 0 334 116 V 120 H 348 V 136 H 334 V 172 Z
"""

# 'i': x in [356..372]
# stem: x=356..372, y=120..172
# dot: cx=364, cy=102, r=8
i1_stem = "M 356 172 V 120 H 372 V 172 Z"
i1_dot = '<circle cx="364" cy="104" r="8" fill="#F4F5F8" />'

# 'B': x in [388..434] (cap height 94..172)
# stem: x=388..404, y=94..172
# top bowl: outer y=94..134, inner y=108..124
# bottom bowl: outer y=132..172, inner y=144..160
B_path = """
  M 388 94 H 420 A 20 20 0 0 1 434 114 A 19 19 0 0 1 422 133 A 20 20 0 0 1 436 153 A 19 19 0 0 1 417 172 H 388 Z
  M 404 108 V 124 H 418 A 8 8 0 0 0 418 108 Z
  M 404 138 V 158 H 419 A 10 10 0 0 0 419 138 Z
"""

# 'O': x in [446..514] (circle diameter 68, cx=480, cy=133)
O_path = """
  M 480 94 A 39 39 0 1 1 479.9 94 Z
  M 480 110 A 23 23 0 1 0 480.1 110 Z
"""

# 'n': x in [526..568] (y=120..172)
n1_path = """
  M 526 172 V 120 H 542 V 131 A 18 18 0 0 1 568 120 V 172 H 552 V 138 A 8 8 0 0 0 542 138 V 172 Z
"""

# 'a': x in [580..622] (y=120..172)
a_path = """
  M 622 172 V 160 A 20 20 0 0 1 598 174 A 19 19 0 0 1 580 148 A 20 20 0 0 1 608 135 L 622 133 V 130 A 10 10 0 0 0 610 120 A 14 14 0 0 0 594 126 L 588 114 A 26 26 0 0 1 612 106 A 24 24 0 0 1 638 128 V 172 Z
  M 622 147 L 610 148 A 8 8 0 0 0 596 151 A 6 6 0 0 0 606 160 A 16 16 0 0 0 622 153 Z
"""

# 'n': x in [634..676] (y=120..172)
n2_path = """
  M 634 172 V 120 H 650 V 131 A 18 18 0 0 1 676 120 V 172 H 660 V 138 A 8 8 0 0 0 650 138 V 172 Z
"""

# 'c': x in [688..726] (y=120..172)
c_path = """
  M 724 133 L 712 141 A 15 15 0 0 0 706 134 A 12 12 0 1 0 706 158 A 15 15 0 0 0 724 151 L 728 163 A 26 26 0 1 1 726 120 Z
"""

# 'i': x in [738..754]
i2_stem = "M 738 172 V 120 H 754 V 172 Z"
i2_dot = '<circle cx="746" cy="104" r="8" fill="#F4F5F8" />'

lockup_dark_svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 840 256" width="840" height="256" role="img" aria-labelledby="t-lockup-dark">
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
  
  <!-- Wordmark "fiBOnanci" -->
  <path fill="#F4F5F8" d="{f_path}" />
  <path fill="#F4F5F8" d="{i1_stem}" />
  {i1_dot}
  
  <!-- BO in Neo-Chartreuse -->
  <path fill="#D4F442" fill-rule="evenodd" d="{B_path}" />
  <path fill="#D4F442" fill-rule="evenodd" d="{O_path}" />
  
  <!-- nanci in TextWhite -->
  <path fill="#F4F5F8" d="{n1_path}" />
  <path fill="#F4F5F8" fill-rule="evenodd" d="{a_path}" />
  <path fill="#F4F5F8" d="{n2_path}" />
  <path fill="#F4F5F8" d="{c_path}" />
  <path fill="#F4F5F8" d="{i2_stem}" />
  {i2_dot}
</svg>'''

with open("logo_kit/fibonanci-lockup-dark.svg", "w") as f:
    f.write(lockup_dark_svg)

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
print("Updated lockup dark")
