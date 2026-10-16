import subprocess

# Generate horizontal lockup
# viewBox="0 0 840 256"
# Symbol: x=48, y=28, w=200, h=200 (scale 200/256 = 0.78125)
# In lockup, let's embed the exact symbol paths directly into a group with transform:
# transform="translate(48, 28) scale(0.78125)"

# For wordmark: "fiBOnanci"
# We can use clean geometric vector glyphs for each letter:
# Baseline at y=160, cap height = 64 (y=96..160), x-height = 48 (y=112..160).
# Font weight: Bold (stroke width 14).
# Colors:
# 'fi' -> #F4F5F8 (or #0C0D11 for light version)
# 'BO' -> #D4F442
# 'nanci' -> #F4F5F8 (or #0C0D11 for light version)

# Let's craft clean vector glyphs for "fiBOnanci":
# Let's test using SVG <path> elements for the wordmark:
# f: stem x=0..12, arch to x=28, bar at y=112
# i: stem x=38..50, dot at y=96
# B: stem x=62..74, bowls to x=102
# O: circle cx=136, cy=128, R=32, r=20
# n: stem x=180..192, arch to x=220
# a: stem x=232..244, bowl x=244..276
# n: stem x=288..300, arch to x=328
# c: bowl x=340..374
# i: stem x=386..398, dot at y=96

# Even better: we can also create clean lockups for dark (Obsidian) and light backgrounds!
def make_lockup_dark():
    return '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 840 256" width="840" height="256" role="img" aria-labelledby="t-lockup-dark">
  <title id="t-lockup-dark">fiBOnanci Horizontal Lockup Dark</title>
  <rect width="840" height="256" fill="#0C0D11" />
  
  <!-- Phi Vault Symbol in Neo-Chartreuse -->
  <g transform="translate(56, 36) scale(0.71875)">
    <rect x="111" y="23" width="34" height="210" rx="17" fill="#D4F442" />
    <path fill="#D4F442" d="M 97 39 A 89 89 0 0 0 39 128 A 89 89 0 0 0 97 217 V 183 A 55 55 0 0 1 73 128 A 55 55 0 0 1 97 73 Z" />
    <path fill="#D4F442" d="M 159 39 A 89 89 0 0 1 217 128 A 89 89 0 0 1 159 217 V 183 A 55 55 0 0 0 183 128 A 55 55 0 0 0 159 73 Z" />
  </g>
  
  <!-- Divider -->
  <line x1="280" y1="64" x2="280" y2="192" stroke="#252836" stroke-width="2" stroke-linecap="round" />
  
  <!-- Stylized Wordmark -->
  <!-- 'fi' in TextWhite #F4F5F8 -->
  <!-- 'f' -->
  <path fill="#F4F5F8" d="M 336 180 V 126 H 322 V 110 H 336 V 98 A 22 22 0 0 1 358 76 H 372 V 92 H 360 A 8 8 0 0 0 352 100 V 110 H 372 V 126 H 352 V 180 Z" />
  <!-- 'i' -->
  <path fill="#F4F5F8" d="M 384 180 V 110 H 400 V 180 Z" />
  <circle cx="392" cy="94" r="8" fill="#F4F5F8" />
  
  <!-- 'BO' in Neo-Chartreuse #D4F442 -->
  <!-- 'B' -->
  <path fill="#D4F442" fill-rule="evenodd" d="M 420 76 H 456 A 26 26 0 0 1 476 112 A 28 28 0 0 1 458 180 H 420 Z M 436 92 V 118 H 452 A 13 13 0 0 0 452 92 Z M 436 134 V 164 H 454 A 15 15 0 0 0 454 134 Z" />
  <!-- 'O' -->
  <path fill="#D4F442" fill-rule="evenodd" d="M 536 76 A 52 52 0 1 1 484 128 A 52 52 0 0 1 536 76 Z M 536 94 A 34 34 0 1 0 570 128 A 34 34 0 0 0 536 94 Z" />
  
  <!-- 'nanci' in TextWhite #F4F5F8 -->
  <!-- 'n' -->
  <path fill="#F4F5F8" d="M 600 180 V 110 H 615 V 124 A 26 26 0 0 1 645 110 A 24 24 0 0 1 668 134 V 180 H 652 V 136 A 14 14 0 0 0 638 124 A 15 15 0 0 0 616 138 V 180 Z" />
  <!-- 'a' -->
  <path fill="#F4F5F8" fill-rule="evenodd" d="M 714 180 V 166 A 26 26 0 0 1 688 182 A 28 28 0 0 1 674 134 A 28 28 0 0 1 714 126 V 122 A 12 12 0 0 0 702 110 A 18 18 0 0 0 682 118 L 674 104 A 32 32 0 0 1 704 94 A 26 26 0 0 1 730 120 V 180 Z M 714 140 A 14 14 0 0 0 690 148 A 14 14 0 0 0 714 154 Z" />
  <!-- 'n' -->
  <path fill="#F4F5F8" d="M 742 180 V 110 H 757 V 124 A 26 26 0 0 1 787 110 A 24 24 0 0 1 810 134 V 180 H 794 V 136 A 14 14 0 0 0 780 124 A 15 15 0 0 0 758 138 V 180 Z" />
</svg>'''

with open("logo_kit/fibonanci-lockup-dark.svg", "w") as f:
    f.write(make_lockup_dark())

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
print("Rendered lockup dark")
