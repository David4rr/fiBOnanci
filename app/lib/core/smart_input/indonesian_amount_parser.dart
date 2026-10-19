/// Pure Dart parser for Indonesian currency strings, shorthand ('45rb', '2,5jt'),
/// spoken Indonesian number words ('dua puluh lima ribu'), and multi-line OCR receipts.
class IndonesianAmountParser {
  static const Map<String, int> _unitWords = {
    'nol': 0, 'satu': 1, 'se': 1, 'dua': 2, 'tiga': 3, 'empat': 4,
    'lima': 5, 'enam': 6, 'tujuh': 7, 'delapan': 8, 'sembilan': 9,
    'sepuluh': 10, 'sebelas': 11,
  };

  /// Extracts the primary transaction amount from a multi-line receipt or OCR text.
  static double? parseReceiptAmount(String text) {
    final lines = text.split(RegExp(r'[\r\n]+')).map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    final priorityRegex = RegExp(
      r'\b(grand\s*total|total\s*bayar|total\s*belanja|total\s*pembayaran|total\s*transaksi|total\s*tagihan|nominal\s*transfer|jumlah\s*transfer|total\s*harga|harga\s*jual|jumlah\s*bayar|total|netto|net|tagihan|ttl|tot)\b',
      caseSensitive: false,
    );
    final ignoreLineRegex = RegExp(
      r'\b(kembali|kembalian|change|tunai|cash|diskon|hemat|voucher|ppn|tax|pajak|subtotal|sub\s*total|no\.?\s*trx|no\.?\s*ref|npwp|telp|tanggal|tgl|date|waktu|time|jam|pukul|kasir|cashier|meja|antrian)\b',
      caseSensitive: false,
    );
    final datePatternRegex = RegExp(
      r'\b(?:\d{1,2}[/.-]\d{1,2}[/.-]\d{2,4}|\d{1,2}\s+(?:jan|feb|mar|apr|mei|jun|jul|agu|aug|sep|okt|oct|nov|des)\b|\d{1,2}[:.]\d{2}(?:[:.]\d{2})?)',
      caseSensitive: false,
    );

    double? bestTotal;
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final isDate = datePatternRegex.hasMatch(line) && !priorityRegex.hasMatch(line);
      if (priorityRegex.hasMatch(line) && !ignoreLineRegex.hasMatch(line) && !isDate) {
        final sameLineAmt = _extractNumericAmountFromLine(line);
        if (sameLineAmt != null && sameLineAmt >= 500) {
          bestTotal = sameLineAmt;
        } else {
          for (int off = 1; off <= 3 && i + off < lines.length; off++) {
            final nextLine = lines[i + off];
            if (priorityRegex.hasMatch(nextLine)) break;
            if (ignoreLineRegex.hasMatch(nextLine) || datePatternRegex.hasMatch(nextLine)) continue;
            final nextLineAmt = _extractNumericAmountFromLine(nextLine);
            if (nextLineAmt != null && nextLineAmt >= 500) {
              bestTotal = nextLineAmt;
              break;
            }
          }
        }
      }
    }
    if (bestTotal != null) return bestTotal;

    final rpMatches = RegExp(
      r'(?:Rp\.?|IDR)\s*([0-9]{1,3}(?:[.,][0-9]{3})+(?:[.,][0-9]{1,2})?|[0-9]{4,})',
      caseSensitive: false,
    ).allMatches(text);
    double? maxRp;
    for (final m in rpMatches) {
      final lineOfMatch = lines.firstWhere((l) => l.contains(m.group(0)!), orElse: () => '');
      if (ignoreLineRegex.hasMatch(lineOfMatch) || (datePatternRegex.hasMatch(lineOfMatch) && !priorityRegex.hasMatch(lineOfMatch))) continue;
      final raw = m.group(1);
      if (raw != null) {
        final val = parseFormattedIdr(raw);
        if (val >= 500 && (maxRp == null || val > maxRp)) maxRp = val;
      }
    }
    return maxRp ?? parseVoiceOrInlineAmount(text);
  }

  /// Extracts an amount from a natural spoken sentence or inline text.
  static double? parseVoiceOrInlineAmount(String text) {
    final normalized = text.toLowerCase();
    final shorthandRegex = RegExp(
      r'(\d+(?:[.,]\d+)?)\s*(?:setengah\s*)?(rb|ribu|rebu|k|jt|juta|miliar|milyar)\b',
      caseSensitive: false,
    );
    final shMatch = shorthandRegex.firstMatch(normalized);
    if (shMatch != null) {
      final base = double.tryParse(shMatch.group(1)!.replaceAll(',', '.'));
      final unit = shMatch.group(2)!.toLowerCase();
      if (base != null) {
        final mult = (unit == 'jt' || unit == 'juta')
            ? 1000000.0
            : (unit == 'miliar' || unit == 'milyar') ? 1000000000.0 : 1000.0;
        final hasHalf = shMatch.group(0)!.contains('setengah');
        return base * mult + (hasHalf ? 0.5 * mult : 0.0);
      }
    }

    final digitAmt = _extractNumericAmountFromLine(text);
    if (digitAmt != null && digitAmt > 0) return digitAmt;
    return _parseSpokenIndonesianWords(normalized);
  }

  static double? _extractNumericAmountFromLine(String line) {
    final sanitized = line
        .replaceAll(RegExp(r'\b\d{1,2}[/.-]\d{1,2}[/.-]\d{2,4}\b'), '')
        .replaceAll(RegExp(r'\b\d{1,2}[:.]\d{2}(?:[:.]\d{2})?\b'), '');

    final shMatch = RegExp(
      r'\b(\d+(?:[.,]\d+)?)\s*(k|rb|ribu|rebu|jt|juta|miliar|milyar)\b',
      caseSensitive: false,
    ).firstMatch(sanitized);
    if (shMatch != null) {
      final base = double.tryParse(shMatch.group(1)!.replaceAll(',', '.'));
      final unit = shMatch.group(2)!.toLowerCase();
      if (base != null) {
        final mult = (unit == 'jt' || unit == 'juta')
            ? 1000000.0
            : (unit == 'miliar' || unit == 'milyar') ? 1000000000.0 : 1000.0;
        final val = base * mult;
        if (val >= 500) return val;
      }
    }

    final regex = RegExp(
      r'(?:Rp\.?|IDR)?\s*([0-9]{1,3}(?:[.,][0-9]{3})+(?:[.,][0-9]{1,2})?|\b[0-9]{3,9}\b(?:\s*(?:rupiah|perak))?|\b[0-9]{4,9}\b)',
      caseSensitive: false,
    );
    final matches = regex.allMatches(sanitized).toList();
    for (final m in matches.reversed) {
      final raw = m.group(1);
      if (raw == null) continue;
      final val = parseFormattedIdr(raw);
      final fullM = m.group(0)!.toLowerCase();
      final hasPrefix = fullM.contains('rp') || fullM.contains('idr') || fullM.contains('rupiah') || fullM.contains('perak');
      if (!hasPrefix && val >= 2020 && val <= 2035 && !raw.contains('.') && !raw.contains(',')) continue;
      if (val > 0) return val;
    }
    return null;
  }

  static double parseFormattedIdr(String raw) {
    var clean = raw.trim();
    if (clean.length > 3) {
      final tail = clean.substring(clean.length - 3);
      if (RegExp(r'^[.,]\d{2}$').hasMatch(tail)) clean = clean.substring(0, clean.length - 3);
    }
    clean = clean.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

  static double? _parseSpokenIndonesianWords(String text) {
    const colloquial = {'seceng': 1000.0, 'goceng': 5000.0, 'ceban': 10000.0, 'goban': 50000.0, 'cepek': 100.0};
    for (final entry in colloquial.entries) {
      if (RegExp(r'\b' + entry.key + r'\b').hasMatch(text)) return entry.value;
    }
    final tokens = text.replaceAll(RegExp(r'[^a-z\s]'), ' ').split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
    double total = 0, currentGroup = 0, currentNumber = 0;
    bool matchedAny = false;

    for (final w in tokens) {
      if (_unitWords.containsKey(w)) {
        currentNumber += _unitWords[w]!;
        matchedAny = true;
      } else if (w == 'belas') {
        currentNumber = (currentNumber == 0 ? 1 : currentNumber) + 10;
        matchedAny = true;
      } else if (w == 'puluh') {
        currentGroup += (currentNumber == 0 ? 1 : currentNumber) * 10;
        currentNumber = 0;
        matchedAny = true;
      } else if (w == 'seratus') {
        currentGroup += 100;
        matchedAny = true;
      } else if (w == 'ratus') {
        currentGroup += (currentNumber == 0 ? 1 : currentNumber) * 100;
        currentNumber = 0;
        matchedAny = true;
      } else if (w == 'setengah') {
        currentNumber += 0.5;
        matchedAny = true;
      } else if (w == 'seribu' || w == 'sejuta') {
        total += w == 'seribu' ? 1000 : 1000000;
        currentGroup = 0;
        currentNumber = 0;
        matchedAny = true;
      } else if (w == 'ribu' || w == 'rebu' || w == 'juta' || w == 'miliar' || w == 'milyar') {
        final mult = currentGroup + currentNumber;
        final factor = (w == 'ribu' || w == 'rebu') ? 1000.0 : (w == 'juta' ? 1000000.0 : 1000000000.0);
        total += (mult == 0 ? 1 : mult) * factor;
        currentGroup = 0;
        currentNumber = 0;
        matchedAny = true;
      }
    }

    total += currentGroup + currentNumber;
    return (matchedAny && total >= 100) ? total : null;
  }
}
