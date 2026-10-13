import 'parsed_notification.dart';

/// Specialized parsers for Indonesian digital banks and e-wallets.
class BankNotificationParsers {
  /// Normalizes IDR currency string to double.
  static double parseIdr(String rawAmount) {
    String cleaned = rawAmount.replaceAll(' ', '');
    if (cleaned.contains(',') && cleaned.lastIndexOf(',') == cleaned.length - 3) {
      cleaned = cleaned.substring(0, cleaned.length - 3).replaceAll(RegExp(r'[.,]'), '');
    } else {
      cleaned = cleaned.replaceAll(RegExp(r'[.,]'), '');
    }
    return double.tryParse(cleaned) ?? 0.0;
  }

  static ParsedNotificationResult? parseProvider(String pkg, String title, String body) {
    if (pkg.contains('seabank') ||
        pkg.contains('bke') ||
        pkg.contains('digitalbank') ||
        pkg.contains('sea.bank') ||
        title.toLowerCase().contains('seabank')) {
      return _parseSeaBank(title, body);
    }
    if (pkg.contains('bcadigital') || pkg.contains('blu')) return _parseBlu(title, body);
    if (pkg.contains('bca')) return _parseBca(title, body);
    if (pkg.contains('mandiri')) return _parseMandiri(title, body);
    if (pkg.contains('jago') || title.toLowerCase().contains('jago')) return _parseJago(title, body);
    if (pkg.contains('ovo')) return _parseOvo(title, body);
    if (pkg.contains('gojek') || pkg.contains('gopay')) return _parseGoPay(title, body);
    if (pkg.contains('dana')) return _parseDana(title, body);
    if (pkg.contains('shopee')) return _parseShopeePay(title, body);
    if (pkg.contains('brimo') || pkg.contains('bri')) return _parseBrimo(title, body);
    if (pkg.contains('wondr') || pkg.contains('bni')) return _parseWondr(title, body);
    return null;
  }

  static ParsedNotificationResult? _parseSeaBank(String title, String body) {
    return _matchSeaBankPatterns(body) ?? _matchSeaBankPatterns('$title $body');
  }

  static ParsedNotificationResult? _matchSeaBankPatterns(String text) {
    final qris = RegExp(r'(?:Pembayaran\s+QRIS|Pembayaran|Bayar\s+QRIS)\s+(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:di|ke)\s+([^.]+?)(?:\s+berhasil|\s+pada|$|\.)', caseSensitive: false).firstMatch(text);
    if (qris != null) return ParsedNotificationResult(amount: parseIdr(qris.group(1)!), type: 'expense', counterparty: qris.group(2)!.trim());

    final dm = RegExp(r'(?:Kamu|Anda)\s+menerima\s+(?:dana|transfer)(?:\s+sebesar)?\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+dari\s+(.+?)(?:\s+pada|$|\.)', caseSensitive: false).firstMatch(text);
    if (dm != null) return ParsedNotificationResult(amount: parseIdr(dm.group(1)!), type: 'income', counterparty: dm.group(2)!.trim());
    final inM = RegExp(
      r'(?:Kamu|Anda)\s+menerima\s+transfer\s+(?:saldo\s+)?senilai\s+(?:Rp\.?|IDR)\s*([0-9.,]+)(?:\s+ke\s+rekening\s+([0-9]+))?',
      caseSensitive: false,
    ).firstMatch(text);
    if (inM != null) {
      final rek = inM.group(2);
      return ParsedNotificationResult(amount: parseIdr(inM.group(1)!), type: 'income', counterparty: rek != null ? 'Transfer Masuk (Rek. $rek)' : 'Transfer Masuk SeaBank');
    }

    final va = RegExp(r'(?:Kamu|Anda)\s+(?:telah|berhasil)\s+(?:melakukan\s+transfer|transfer|mengirim(?:\s+dana|\s+uang)?|membayar)\s+(?:virtual\s+account\s+)?(?:saldo\s+)?(?:sebesar\s+|senilai\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:kepada|ke)\s+(.+?)(?:\s+telah\s+berhasil|\s+berhasil|\s+pada|$|\.)', caseSensitive: false).firstMatch(text);
    if (va != null) return ParsedNotificationResult(amount: parseIdr(va.group(1)!), type: 'expense', counterparty: va.group(2)!.trim());

    final outM = RegExp(r'(?:Berhasil\s+transfer|Transfer\s+berhasil|Transfer\s+keluar|Transfer)\s+(?:saldo\s+)?(?:sebesar\s+|senilai\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:ke|kepada)\s+([^.]+?)(?:\s+telah\s+berhasil|\s+berhasil|\s+pada|$|\.)', caseSensitive: false).firstMatch(text);
    if (outM != null) return ParsedNotificationResult(amount: parseIdr(outM.group(1)!), type: 'expense', counterparty: outM.group(2)!.trim());

    final inTransfer = RegExp(r'(?:Transfer\s+masuk|Dana\s+masuk|Uang\s+masuk)\s+(?:saldo\s+)?(?:sebesar\s+|senilai\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+dari\s+([^.]+?)(?:\s+ke\s+rekening|\s+telah|\s+pada|$|\.)', caseSensitive: false).firstMatch(text);
    if (inTransfer != null) return ParsedNotificationResult(amount: parseIdr(inTransfer.group(1)!), type: 'income', counterparty: inTransfer.group(2)!.trim());

    final topup = RegExp(r'(?:Berhasil\s+top\s+up|Kamu\s+telah\s+melakukan\s+top\s+up|Top\s+up\s+berhasil)\s+(?:saldo\s+)?(.+?)\s+sebesar\s+(?:Rp\.?|IDR)\s*([0-9.,]+)', caseSensitive: false).firstMatch(text);
    if (topup != null) return ParsedNotificationResult(amount: parseIdr(topup.group(2)!), type: 'expense', counterparty: 'Top Up ${topup.group(1)!.trim()}');
    return null;
  }

  static ParsedNotificationResult? _parseBca(String title, String body) {
    final text = '$title $body';
    final qr = RegExp(r'Pembayaran\s+(?:QRIS|QR)\s+(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:di|ke)\s+([^.]+?)\s+berhasil', caseSensitive: false).firstMatch(text);
    if (qr != null) return ParsedNotificationResult(amount: parseIdr(qr.group(1)!), type: 'expense', counterparty: qr.group(2)!.trim());

    final outM = RegExp(r'(?:m-Transfer|Transfer)\s+(?:keluar\s+|berhasil[:\s]+)?(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:ke|kepada)\s+([^.]+?)(?:\s+berhasil|$|\.)', caseSensitive: false).firstMatch(text);
    if (outM != null) return ParsedNotificationResult(amount: parseIdr(outM.group(1)!), type: 'expense', counterparty: outM.group(2)!.trim());

    final inM = RegExp(r'(?:m-Transfer|Transfer|Dana|Uang)\s+masuk\s+(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+dari\s+([^.]+)', caseSensitive: false).firstMatch(text);
    if (inM != null) return ParsedNotificationResult(amount: parseIdr(inM.group(1)!), type: 'income', counterparty: inM.group(2)!.trim());
    return null;
  }

  static ParsedNotificationResult? _parseBlu(String title, String body) {
    final text = '$title $body';
    final qr = RegExp(r'(?:Pembayaran\s+QRIS|Pembayaran)\s+(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:di|ke)\s+([^.]+?)\s+(?:telah\s+berhasil|berhasil)', caseSensitive: false).firstMatch(text);
    if (qr != null) return ParsedNotificationResult(amount: parseIdr(qr.group(1)!), type: 'expense', counterparty: qr.group(2)!.trim());

    final outM = RegExp(r'Transfer\s+(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:ke|kepada)\s+([^.]+?)\s+(?:telah\s+berhasil|berhasil)', caseSensitive: false).firstMatch(text);
    if (outM != null) return ParsedNotificationResult(amount: parseIdr(outM.group(1)!), type: 'expense', counterparty: outM.group(2)!.trim());

    final inM = RegExp(r'(?:Kamu\s+menerima\s+transfer|Transfer\s+masuk|Dana\s+masuk)\s+(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+dari\s+([^.]+)', caseSensitive: false).firstMatch(text);
    if (inM != null) return ParsedNotificationResult(amount: parseIdr(inM.group(1)!), type: 'income', counterparty: inM.group(2)!.trim());
    return null;
  }

  static ParsedNotificationResult? _parseMandiri(String title, String body) {
    final text = '$title $body';
    final qr = RegExp(r"Transaksi\s+(?:Livin'\s+)?(?:QRIS|QR)\s+(?:sebesar\s+)?(?:IDR|Rp\.?)\s*([0-9.,]+)\s+(?:di|ke)\s+(.+?)\s+berhasil", caseSensitive: false).firstMatch(text);
    if (qr != null) return ParsedNotificationResult(amount: parseIdr(qr.group(1)!), type: 'expense', counterparty: qr.group(2)!.trim());

    final debit = RegExp(r'(?:Debit\s+rekening\s+\*+[0-9]+|Transfer(?:\s+keluar)?)\s+(?:berhasil!?\s+)?(?:sebesar\s+)?(?:IDR|Rp\.?)\s*([0-9.,]+)\s+(?:ke|kepada)\s+(.+?)(?:\s+berhasil|$|\.)', caseSensitive: false).firstMatch(text);
    if (debit != null) return ParsedNotificationResult(amount: parseIdr(debit.group(1)!), type: 'expense', counterparty: debit.group(2)!.trim());

    final inM = RegExp(r'(?:Kredit\s+rekening\s+\*+[0-9]+|Transfer\s+masuk|Uang\s+masuk|Dana\s+masuk)\s+(?:sebesar\s+)?(?:IDR|Rp\.?)\s*([0-9.,]+)\s+dari\s+(.+?)(?:\s+berhasil|$|\.)', caseSensitive: false).firstMatch(text);
    if (inM != null) return ParsedNotificationResult(amount: parseIdr(inM.group(1)!), type: 'income', counterparty: inM.group(2)!.trim());
    return null;
  }

  static ParsedNotificationResult? _parseBrimo(String title, String body) {
    final text = '$title $body';
    final m = RegExp(r'Debit\s+(?:Tabungan\s+BRI|Rekening).*?(?:Sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:ke|di)\s+(.+?)(?:\.|$|\s+pada|\s+berhasil)', caseSensitive: false).firstMatch(text);
    if (m != null) return ParsedNotificationResult(amount: parseIdr(m.group(1)!), type: 'expense', counterparty: m.group(2)!.trim());
    final inM = RegExp(r'Kredit\s+(?:Tabungan\s+BRI|Rekening).*?(?:Sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+dari\s+(.+?)(?:\.|$|\s+pada|\s+berhasil)', caseSensitive: false).firstMatch(text);
    if (inM != null) return ParsedNotificationResult(amount: parseIdr(inM.group(1)!), type: 'income', counterparty: inM.group(2)!.trim());
    return null;
  }

  static ParsedNotificationResult? _parseWondr(String title, String body) {
    final text = '$title $body';
    final m = RegExp(r'Transaksi\s+(?:wondr\s+)?QRIS\s+(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:di|ke)\s+(.+?)\s+berhasil', caseSensitive: false).firstMatch(text);
    if (m != null) return ParsedNotificationResult(amount: parseIdr(m.group(1)!), type: 'expense', counterparty: m.group(2)!.trim());
    return null;
  }
  static ParsedNotificationResult? _parseJago(String title, String body) {
    return _matchJagoPatterns(body) ?? _matchJagoPatterns('$title $body');
  }

  static ParsedNotificationResult? _matchJagoPatterns(String text) {
    final pay = RegExp(
      r'(?:Kamu|Anda)\s+(?:telah|berhasil)\s+(?:membayar|mengirim(?:\s+uang|\s+dana)?|transfer)\s+(?:sebesar\s+|senilai\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:ke|kepada|di)\s+(.+?)(?:\s+menggunakan|\s+dari\s+kantong|\s+berhasil|\s+pada|$|\.)',
      caseSensitive: false,
    ).firstMatch(text);
    if (pay != null) return ParsedNotificationResult(amount: parseIdr(pay.group(1)!), type: 'expense', counterparty: pay.group(2)!.trim());

    final outM = RegExp(
      r'(?:Berhasil\s+(?:kirim|transfer|bayar)|Kiriman\s+uang|Transfer\s+keluar|Uang\s+keluar)\s+(?:sebesar\s+|senilai\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:ke|kepada|di)\s+(.+?)(?:\s+dari\s+kantong|\s+berhasil|\s+pada|$|\.)',
      caseSensitive: false,
    ).firstMatch(text);
    if (outM != null) return ParsedNotificationResult(amount: parseIdr(outM.group(1)!), type: 'expense', counterparty: outM.group(2)!.trim());

    final inM = RegExp(
      r'(?:Kantong\s+[^.]*?\s+menerima|(?:Kamu|Anda)\s+(?:telah\s+)?menerima|Ada\s+uang\s+masuk|Uang\s+masuk|Dana\s+masuk|Transfer\s+masuk)\s+(?:transfer\s+|dana\s+|uang\s+)?(?:sebesar\s+|senilai\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:ke\s+kantong\s+.+?\s+)?dari\s+(.+?)(?:\s+ke\s+kantong|\s+pada|$|\.)',
      caseSensitive: false,
    ).firstMatch(text);
    if (inM != null) return ParsedNotificationResult(amount: parseIdr(inM.group(1)!), type: 'income', counterparty: inM.group(2)!.trim());

    final inEn = RegExp(
      r"(?:You(?:'ve|\s+have)?\s+received|Pocket\s+.*?\s+received|.+?\s+Pocket\s+received)\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+from\s+(.+?)(?:\s+to\s+|\s+in\s+|$|\.)",
      caseSensitive: false,
    ).firstMatch(text);
    if (inEn != null) return ParsedNotificationResult(amount: parseIdr(inEn.group(1)!), type: 'income', counterparty: inEn.group(2)!.trim());

    return null;
  }

  static ParsedNotificationResult? _parseGoPay(String title, String body) {
    final text = '$title $body';
    final pay = RegExp(r'Pembayaran\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:ke|di)\s+(.+?)\s+berhasil', caseSensitive: false).firstMatch(text);
    if (pay != null) return ParsedNotificationResult(amount: parseIdr(pay.group(1)!), type: 'expense', counterparty: pay.group(2)!.trim());
    final tx = RegExp(r'Kamu\s+telah\s+transfer\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+ke\s+(.+?)(?:\.|$|!)', caseSensitive: false).firstMatch(text);
    if (tx != null) return ParsedNotificationResult(amount: parseIdr(tx.group(1)!), type: 'expense', counterparty: tx.group(2)!.trim());
    return null;
  }

  static ParsedNotificationResult? _parseOvo(String title, String body) {
    final text = '$title $body';
    final m = RegExp(r'Berhasil\s+bayar\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:di|ke)\s+(.+?)(?:\.|$|!)', caseSensitive: false).firstMatch(text);
    if (m != null) return ParsedNotificationResult(amount: parseIdr(m.group(1)!), type: 'expense', counterparty: m.group(2)!.trim());
    return null;
  }

  static ParsedNotificationResult? _parseDana(String title, String body) {
    final text = '$title $body';
    final pay = RegExp(r'Pembayaran\s+berhasil!?\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:ke|di)\s+(.+?)(?:\.|$|!)', caseSensitive: false).firstMatch(text);
    if (pay != null) return ParsedNotificationResult(amount: parseIdr(pay.group(1)!), type: 'expense', counterparty: pay.group(2)!.trim());
    final tx = RegExp(r'Kirim\s+uang\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+ke\s+(.+?)\s+berhasil', caseSensitive: false).firstMatch(text);
    if (tx != null) return ParsedNotificationResult(amount: parseIdr(tx.group(1)!), type: 'expense', counterparty: tx.group(2)!.trim());
    return null;
  }

  static ParsedNotificationResult? _parseShopeePay(String title, String body) {
    final text = '$title $body';
    final topup = RegExp(r'(?:pengisian\s+saldo|isi\s+saldo)\s+(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)', caseSensitive: false).firstMatch(text);
    if (topup != null) return ParsedNotificationResult(amount: parseIdr(topup.group(1)!), type: 'income', counterparty: 'Isi Saldo ShopeePay');
    final pay = RegExp(r'(?:Pembayaran\s+ShopeePay|Pembayaran)\s+(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:ke\s+([^.]+?)\s+)?berhasil', caseSensitive: false).firstMatch(text);
    if (pay != null) return ParsedNotificationResult(amount: parseIdr(pay.group(1)!), type: 'expense', counterparty: pay.group(2)?.trim() ?? 'ShopeePay Merchant');
    return null;
  }
}
