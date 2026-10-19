/// Normalizes notification text, strips balance clauses to prevent amount confusion,
/// and extracts balance snapshots across all Indonesian banks and e-wallets.
class NotificationTextSanitizer {
  NotificationTextSanitizer._();

  /// Removes balance snapshot clauses (e.g. "Sisa saldo Rp 5.000.000" or "Saldo Rp 5.000.000")
  /// so they are never parsed as the transaction amount.
  static String stripBalance(String text) {
    var s = text.replaceAll(
      RegExp(
        r'(?:sisa\s+saldo|saldo\s+akhir|saldo\s+saat\s+ini|saldo\s+anda|saldo\s+tersedia|saldo\s+rekening)\s*[:=]?\s*(?:sebesar\s+)?(?:Rp\.?|IDR)?\s*[0-9.,]+',
        caseSensitive: false,
      ),
      '',
    );
    s = s.replaceAll(
      RegExp(
        r'(?<!pengisian\s)(?<!isi\s)(?<!tambah\s)\bsaldo\s*[:=]\s*(?:sebesar\s+)?(?:Rp\.?|IDR)?\s*[0-9.,]+',
        caseSensitive: false,
      ),
      '',
    );
    s = s.replaceAll(
      RegExp(
        r'(?<!pengisian\s)(?<!isi\s)(?<!tambah\s)\bsaldo\s+(?:Rp\.?|IDR)\s*[0-9.,]+',
        caseSensitive: false,
      ),
      '',
    );
    return s.trim();
  }

  /// Extracts the balance snapshot from the notification text if present.
  static double? extractBalance(String text) {
    final m = RegExp(
      r'(?:sisa\s+saldo|saldo\s+akhir|saldo\s+saat\s+ini|saldo\s+anda|saldo\s+tersedia|saldo\s+rekening)\s*[:=]?\s*(?:sebesar\s+)?(?:Rp\.?|IDR)?\s*([0-9.,]+)|(?<!pengisian\s)(?<!isi\s)(?<!tambah\s)\bsaldo\s*[:=]\s*(?:sebesar\s+)?(?:Rp\.?|IDR)?\s*([0-9.,]+)',
      caseSensitive: false,
    ).firstMatch(text);
    if (m == null) return null;
    final raw = m.group(1) ?? m.group(2);
    if (raw == null) return null;
    final val = parseIdr(raw);
    return val > 0 ? val : null;
  }

  /// Normalizes IDR currency string to double, correctly stripping decimal cents (,00 or .00).
  static double parseIdr(String rawAmount) {
    var cleaned = rawAmount.replaceAll(' ', '');
    if (cleaned.length > 3) {
      final sepIdx = cleaned.length - 3;
      final sepChar = cleaned[sepIdx];
      final tail = cleaned.substring(sepIdx + 1);
      if ((sepChar == ',' || sepChar == '.') && RegExp(r'^\d{2}$').hasMatch(tail)) {
        cleaned = cleaned.substring(0, sepIdx);
      }
    }
    cleaned = cleaned.replaceAll(RegExp(r'[.,]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }
}
