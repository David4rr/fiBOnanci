import math
import subprocess

# Concept A: fi Monogram
# Perfectly centered in 256x256
# Let's verify every coordinate:
# 'f' stem: x in [80..112] (w=32), y in [136..224] (h=88)
# 'i' stem: x in [160..192] (w=32), y in [136..224] (h=88)
# Crossbar: x in [56..192] (w=136), y in [104..136] (h=32)
# Arch of 'f':
# Left outer edge of arch rises from (80, 104) up to (80, 88), then arc to (128, 40), then flat top to (148, 40)
# Outer radius = 48 from center (128, 88).
# Inner edge: from (112, 104) up to (112, 88), then arc to (128, 72), then flat to (148, 72)
# Inner radius = 16 from center (128, 88).
# Terminal at x = 148: flat vertical cut from (148, 40) to (148, 72).
# 'i' dot: circle cx = 176, cy = 68, r = 16.
# Distance from x=148 to x=176 - 16 = 160 is 12px gap! Perfect!
# Bounding box:
# x: from 56 to 192 -> width = 136. Center = (56 + 192)/2 = 124. Let's shift by +4 so cx = 128!
# Shifted x:
# 'f' stem: x in [84..116]
# 'i' stem: x in [164..196]
# Crossbar: x in [60..196]
# Arch outer: rises at x = 84, arc center at (132, 88), outer top at (132, 40), flat to x = 152.
# Arch inner: rises at x = 116, arc center at (132, 88), inner top at (132, 72), flat to x = 152.
# 'i' dot: cx = 180, cy = 68, r = 16.
# Bounding box x: 60 to 196 -> width 136, center 128!
# Bounding box y: 40 to 224 -> height 184, center 132!

svg_a = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="title-a">
  <title id="title-a">fiBOnanci 'fi' Monogram</title>
  <path fill="#0C0D11" d="
    M 84 224
    V 136
    H 60
    V 104
    H 84
    V 88
    A 48 48 0 0 1 132 40
    H 152
    V 72
    H 132
    A 16 16 0 0 0 116 88
    V 104
    H 196
    V 224
    H 164
    V 136
    H 116
    V 224
    H 84
    Z
  "/>
  <circle cx="180" cy="68" r="16" fill="#0C0D11" />
</svg>'''

with open("logo_concepts/concept_a.svg", "w") as f: f.write(svg_a)

cmd = ["python3", "/Users/mac/.agents/skills/logo-design/scripts/render_png.py", "logo_concepts/concept_a.svg", "-o", "logo_concepts/concept_a.png", "--size", "256", "--bg", "#ffffff"]
subprocess.run(cmd, check=True)
print("Rendered concept_a")
