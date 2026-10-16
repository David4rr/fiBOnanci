import os
import subprocess

os.makedirs("logo_kit", exist_ok=True)

# Master Phi Vault Geometry (256x256)
phi_vault_d_left = """M 97 39
    A 89 89 0 0 0 39 128
    A 89 89 0 0 0 97 217
    V 183
    A 55 55 0 0 1 73 128
    A 55 55 0 0 1 97 73
    Z"""

phi_vault_d_right = """M 159 39
    A 89 89 0 0 1 217 128
    A 89 89 0 0 1 159 217
    V 183
    A 55 55 0 0 0 183 128
    A 55 55 0 0 0 159 73
    Z"""

def make_symbol_svg(color, title="fiBOnanci Phi Vault"):
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256" role="img" aria-labelledby="t-phi">
  <title id="t-phi">{title}</title>
  <rect x="111" y="23" width="34" height="210" rx="17" fill="{color}" />
  <path fill="{color}" d="{phi_vault_d_left}" />
  <path fill="{color}" d="{phi_vault_d_right}" />
</svg>'''

# Save color variants
variants = [
    ("fibonanci-symbol-obsidian.svg", "#0C0D11", "fiBOnanci Phi Vault Obsidian"),
    ("fibonanci-symbol-black.svg", "#000000", "fiBOnanci Phi Vault Black"),
    ("fibonanci-symbol-white.svg", "#FFFFFF", "fiBOnanci Phi Vault White"),
    ("fibonanci-symbol-chartreuse.svg", "#D4F442", "fiBOnanci Phi Vault Neo-Chartreuse"),
    ("fibonanci-symbol-mint.svg", "#72F5C8", "fiBOnanci Phi Vault Neo-Mint"),
]

for filename, color, title in variants:
    with open(f"logo_kit/{filename}", "w") as f:
        f.write(make_symbol_svg(color, title))

print("Saved symbol variants")
