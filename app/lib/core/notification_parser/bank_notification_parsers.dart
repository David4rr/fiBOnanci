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
    if (pkg.contains('seabank')) return _parseSeaBank(title, body);
    if (pkg.contains('bcadigital') || pkg.contains('blu')) return _parseBlu(title, body);
    if (pkg.contains('bca')) return _parseBca(title, body);
    if (pkg.contains('mandiri')) return _parseMandiri(title, body);
    if (pkg.contains('jago')) return _parseJago(title, body);
    if (pkg.contains('ovo')) return _parseOvo(title, body);
    if (pkg.contains('gojek') || pkg.contains('gopay')) return _parseGoPay(title, body);
    if (pkg.contains('dana')) return _parseDana(title, body);
    if (pkg.contains('shopee')) return _parseShopeePay(title, body);
    if (pkg.contains('brimo') || pkg.contains('bri')) return _parseBrimo(title, body);
    if (pkg.contains('wondr') || pkg.contains('bni')) return _parseWondr(title, body);
    return null;
  }

  static ParsedNotificationResult? _parseSeaBank(String title, String body) {
    final dm = RegExp(r'Kamu\s+menerima\s+dana\s+sebesar\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+dari\s+(.+?)(?:\s+pada|$)', caseSensitive: false).firstMatch(body);
    if (dm != null) return ParsedNotificationResult(amount: parseIdr(dm.group(1)!), type: 'income', counterparty: dm.group(2)!.trim());

    final va = RegExp(r'Kamu\s+telah\s+melakukan\s+transfer\s+(?:virtual\s+account\s+)?sebesar\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+kepada\s+(.+?)(?:\s+pada|$)', caseSensitive: false).firstMatch(body);
    if (va != null) return ParsedNotificationResult(amount: parseIdr(va.group(1)!), type: 'expense', counterparty: va.group(2)!.trim());

    final inM = RegExp(r'Kamu\s+menerima\s+transfer\s+(?:saldo\s+)?senilai\s+(?:Rp\.?|IDR)\s*([0-9.,]+)(?:\s+ke\s+rekening\s+([0-9]+))?', caseSensitive: false).firstMatch(body);
    if (inM != null) {
      final rek = inM.group(2);
      return ParsedNotificationResult(amount: parseIdr(inM.group(1)!), type: 'income', counterparty: rek != null ? 'Transfer Masuk (Rek. $rek)' : 'Transfer Masuk SeaBank');
    }

    final outM = RegExp(r'Berhasil\s+transfer\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+ke\s+([^.]+)', caseSensitive: false).firstMatch(body);
    if (outM != null) return ParsedNotificationResult(amount: parseIdr(outM.group(1)!), type: 'expense', counterparty: outM.group(2)!.trim());
    return null;
  }

  static ParsedNotificationResult? _parseBca(String title, String body) {
    final qr = RegExp(r'Pembayaran\s+QR\s+sebesar\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+di\s+([^.]+)\s+berhasil', caseSensitive: false).firstMatch(body);
    if (qr != null) return ParsedNotificationResult(amount: parseIdr(qr.group(1)!), type: 'expense', counterparty: qr.group(2)!.trim());

    final outM = RegExp(r'(?:m-Transfer|Transfer)\s+keluar\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+ke\s+([^.]+)\s+berhasil', caseSensitive: false).firstMatch(body);
    if (outM != null) return ParsedNotificationResult(amount: parseIdr(outM.group(1)!), type: 'expense', counterparty: outM.group(2)!.trim());

    final inM = RegExp(r'(?:m-Transfer|Transfer)\s+masuk\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+dari\s+([^.]+)', caseSensitive: false).firstMatch(body);
    if (inM != null) return ParsedNotificationResult(amount: parseIdr(inM.group(1)!), type: 'income', counterparty: inM.group(2)!.trim());
    return null;
  }

  static ParsedNotificationResult? _parseBlu(String title, String body) {
    final qr = RegExp(r'(?:Pembayaran\s+QRIS|Pembayaran)\s+sebesar\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:di|ke)\s+([^.]+?)\s+(?:telah\s+berhasil|berhasil)', caseSensitive: false).firstMatch(body);
    if (qr != null) return ParsedNotificationResult(amount: parseIdr(qr.group(1)!), type: 'expense', counterparty: qr.group(2)!.trim());

    final outM = RegExp(r'Transfer\s+sebesar\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+ke\s+([^.]+?)\s+berhasil', caseSensitive: false).firstMatch(body);
    if (outM != null) return ParsedNotificationResult(amount: parseIdr(outM.group(1)!), type: 'expense', counterparty: outM.group(2)!.trim());

    final inM = RegExp(r'Kamu\s+menerima\s+transfer\s+sebesar\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+dari\s+([^.]+)', caseSensitive: false).firstMatch(body);
    if (inM != null) return ParsedNotificationResult(amount: parseIdr(inM.group(1)!), type: 'income', counterparty: inM.group(2)!.trim());
    return null;
  }

  static ParsedNotificationResult? _parseMandiri(String title, String body) {
    final qr = RegExp(r"Transaksi\s+Livin'\s+QR\s+sebesar\s+(?:IDR|Rp\.?)\s*([0-9.,]+)\s+di\s+(.+?)\s+berhasil", caseSensitive: false).firstMatch(body);
    if (qr != null) return ParsedNotificationResult(amount: parseIdr(qr.group(1)!), type: 'expense', counterparty: qr.group(2)!.trim());

    final debit = RegExp(r'Debit\s+rekening\s+\*+[0-9]+\s+sebesar\s+(?:IDR|Rp\.?)\s*([0-9.,]+)\s+ke\s+(.+?)\s+berhasil', caseSensitive: false).firstMatch(body);
    if (debit != null) return ParsedNotificationResult(amount: parseIdr(debit.group(1)!), type: 'expense', counterparty: debit.group(2)!.trim());
    return null;
  }

  static ParsedNotificationResult? _parseBrimo(String title, String body) {
    final m = RegExp(r'Debit\s+Tabungan\s+BRI\s+.*?\s+Sebesar\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+ke\s+(.+?)(?:\.|$|\s+pada)', caseSensitive: false).firstMatch(body);
    if (m != null) return ParsedNotificationResult(amount: parseIdr(m.group(1)!), type: 'expense', counterparty: m.group(2)!.trim());
    return null;
  }

  static ParsedNotificationResult? _parseWondr(String title, String body) {
    final m = RegExp(r'Transaksi\s+wondr\s+QRIS\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+di\s+(.+?)\s+berhasil', caseSensitive: false).firstMatch(body);
    if (m != null) return ParsedNotificationResult(amount: parseIdr(m.group(1)!), type: 'expense', counterparty: m.group(2)!.trim());
    return null;
  }

  static ParsedNotificationResult? _parseJago(String title, String body) {
    final m = RegExp(r'Kamu\s+telah\s+membayar\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+ke\s+(.+?)\s+menggunakan', caseSensitive: false).firstMatch(body);
    if (m != null) return ParsedNotificationResult(amount: parseIdr(m.group(1)!), type: 'expense', counterparty: m.group(2)!.trim());
    return null;
  }

  static ParsedNotificationResult? _parseGoPay(String title, String body) {
    final pay = RegExp(r'Pembayaran\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+ke\s+(.+?)\s+berhasil', caseSensitive: false).firstMatch(body);
    if (pay != null) return ParsedNotificationResult(amount: parseIdr(pay.group(1)!), type: 'expense', counterparty: pay.group(2)!.trim());

    final tx = RegExp(r'Kamu\s+telah\s+transfer\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+ke\s+(.+?)(?:\.|$|!)', caseSensitive: false).firstMatch(body);
    if (tx != null) return ParsedNotificationResult(amount: parseIdr(tx.group(1)!), type: 'expense', counterparty: tx.group(2)!.trim());
    return null;
  }

  static ParsedNotificationResult? _parseOvo(String title, String body) {
    final m = RegExp(r'Berhasil\s+bayar\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+di\s+(.+?)(?:\.|$|!)', caseSensitive: false).firstMatch(body);
    if (m != null) return ParsedNotificationResult(amount: parseIdr(m.group(1)!), type: 'expense', counterparty: m.group(2)!.trim());
    return null;
  }

  static ParsedNotificationResult? _parseDana(String title, String body) {
    final pay = RegExp(r'Pembayaran\s+berhasil!?\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+ke\s+(.+?)(?:\.|$|!)', caseSensitive: false).firstMatch(body);
    if (pay != null) return ParsedNotificationResult(amount: parseIdr(pay.group(1)!), type: 'expense', counterparty: pay.group(2)!.trim());

    final tx = RegExp(r'Kirim\s+uang\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+ke\s+(.+?)\s+berhasil', caseSensitive: false).firstMatch(body);
    if (tx != null) return ParsedNotificationResult(amount: parseIdr(tx.group(1)!), type: 'expense', counterparty: tx.group(2)!.trim());
    return null;
  }

  static ParsedNotificationResult? _parseShopeePay(String title, String body) {
    final topup = RegExp(r'(?:pengisian\s+saldo|isi\s+saldo)\s+(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)', caseSensitive: false).firstMatch(body);
    if (topup != null) {
      return ParsedNotificationResult(amount: parseIdr(topup.group(1)!), type: 'income', counterparty: 'Isi Saldo ShopeePay');
    }

    final pay = RegExp(r'(?:Pembayaran\s+ShopeePay|Pembayaran)\s+(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:ke\s+([^.]+?)\s+)?berhasil', caseSensitive: false).firstMatch(body);
    if (pay != null) {
      final merchant = pay.group(2)?.trim() ?? 'ShopeePay Merchant';
      return ParsedNotificationResult(amount: parseIdr(pay.group(1)!), type: 'expense', counterparty: merchant);
    }
    return null;
  }
}
