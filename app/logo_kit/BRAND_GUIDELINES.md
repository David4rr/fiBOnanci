# fiBOnanci Brand Identity Guidelines

## 1. Overview & Philosophy
**fiBOnanci** adalah aplikasi kecerdasan finansial pribadi *offline-first* dengan performa nol-latensi (<10 ms). Lambang resmi aplikasi adalah **The Phi Vault ($\Phi$)**, yang menyatukan dua pilar inti:
1. **Konstanta Rasio Emas ($\Phi = 1.618$)**: Fondasi matematika murni yang menggerakkan mesin alokasi *Safe-to-Spend* dan laju bakar harian (*daily burn pacing*).
2. **Brankas Kedaulatan Data (*On-Device Vault*)**: Pilar monolitik sentral yang diapit sepasang gerbang lengkung melambangkan enkripsi lokal SQLite on-device tanpa server cloud eksternal.

---

## 2. Mathematical Geometry & Proportions
Seluruh elemen lambang The Phi Vault dibangun di atas kanvas `viewBox="0 0 256 256"` dengan dimensi yang sepenuhnya diturunkan dari deret Fibonacci:
- **Pilar Monolitik Sentral**: Lebar $34\text{ px}$ (Fibonacci $F_9$), Tinggi $210\text{ px}$ (Fibonacci $F_8+F_9+F_8 \approx 210$), radius sudut $17\text{ px}$.
- **Radius Gerbang Brankas Dalam**: $r = 55\text{ px}$ (Fibonacci $F_{10}$).
- **Radius Gerbang Brankas Luar**: $R = 89\text{ px}$ (Fibonacci $F_{11}$).
- **Tebal Gerbang Lengkung**: $89 - 55 = 34\text{ px}$ (Fibonacci $F_9$).
- **Celah Udara (*Air Gap*)**: $14\text{ px}$ simetris di sisi kiri dan kanan pilar sentral.
- **Rasio Dimensi**: $89 / 55 \approx 1.61818$ ($\approx \Phi$ presisi emas).

---

## 3. Official Color Palette
| Peran | Nama Warna | Hex | RGB | Penggunaan |
|---|---|---|---|---|
| **Canvas Primary** | Obsidian Dark | `#0C0D11` | `rgb(12, 13, 17)` | Latar belakang kanvas aplikasi, splash screen, launcher background |
| **Accent Primary** | Neo-Chartreuse | `#D4F442` | `rgb(212, 244, 66)` | Simbol logo utama, aksen CTA, status finansial nyaman (*comfortable*) |
| **Accent Secondary**| Neo-Mint | `#72F5C8` | `rgb(114, 245, 200)` | Indikator tren positif, secondary hero, kartu aktif |
| **Surface Dark** | Deep Card | `#16181F` | `rgb(22, 24, 31)` | Kartu bento grid, modal sheet, floating dock |
| **Text Primary** | Crisp White | `#F4F5F8` | `rgb(244, 245, 248)` | Tipografi judul, wordmark 'fi' dan 'nanci' |
| **Text Muted** | Slate Gray | `#8E92A8` | `rgb(142, 146, 168)` | Subtitle, label tanggal, divider sekunder |

---

## 4. Minimum Sizes & Clear Space
- **Ukuran Minimum Digital**: $16\text{ px} \times 16\text{ px}$ (favicon / status bar icon).
- **Ukuran Minimum Cetak**: $5\text{ mm} \times 5\text{ mm}$.
- **Clear Space (Ruang Bebas)**: Ruang aman minimal di sekeliling logo setara dengan $1/4$ lebar pilar monolitik ($8.5\text{ px}$ pada kanvas 256 atau proporsional $0.25 \times \text{width}$).

---

## 5. File Inventory (`logo_kit/`)
- `fibonanci-symbol-obsidian.svg`: Master mark hitam obsidian (`#0C0D11`).
- `fibonanci-symbol-chartreuse.svg`: Master mark Neo-Chartreuse (`#D4F442`).
- `fibonanci-symbol-mint.svg`: Master mark Neo-Mint (`#72F5C8`).
- `fibonanci-symbol-white.svg`: Master mark putih (`#FFFFFF`).
- `fibonanci-symbol-black.svg`: Master mark hitam pekat (`#000000`).
- `fibonanci-app-icon.svg` & `fibonanci-app-icon-512.png`: Ikon aplikasi Android/iOS rounded tile.
- `fibonanci-lockup-dark.svg` & `.png`: Horizontal lockup dengan wordmark `fiBOnanci` di kanvas Obsidian.
- `web-icons/`: Set lengkap favicon (`favicon.ico`, `favicon-16/32/48.png`, `apple-touch-icon.png`, `icon-192.png`, `icon-512.png`, `site.webmanifest`).
- `presentation.html`: Lembar presentasi interaktif dengan 6 mockup industri finansial.
