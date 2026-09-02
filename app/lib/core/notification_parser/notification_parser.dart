import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'parsed_notification.dart';

class NotificationParser {
  // Hard-drop regex blacklist for security tokens & marketing promotions
  static final RegExp _securityAndMarketingBlacklist = RegExp(
    r'\b(otp|kode|verifikasi|rahasia|password|token|pin|cvv|jangan berikan|promo|diskon|cashback|voucher|menangkan|klaim|hadiah)\b',
    caseSensitive: false,
  );

  /// Main entry point: Parses incoming push notification on-device
  static ParsedNotificationResult? parse({
    required String packageName,
    required String title,
    required String body,
    DateTime? timestamp,
  }) {
    final combinedText = '$title $body'.trim();

    // Stage 1: Security & Marketing Hard-Drop
    if (_securityAndMarketingBlacklist.hasMatch(combinedText)) {
      return null;
    }

    ParsedNotificationResult? result;
    final pkg = packageName.toLowerCase();

    // Stage 2A: Specific Provider Parser
    if (pkg.contains('seabank')) {
      result = _parseSeaBank(title, body);
    } else if (pkg.contains('bcadigital') || pkg.contains('blu')) {
      result = _parseBlu(title, body);
    } else if (pkg.contains('bca')) {
      result = _parseBca(title, body);
    } else if (pkg.contains('mandiri')) {
      result = _parseMandiri(title, body);
    } else if (pkg.contains('jago')) {
      result = _parseJago(title, body);
    } else if (pkg.contains('ovo')) {
      result = _parseOvo(title, body);
    } else if (pkg.contains('gojek') || pkg.contains('gopay')) {
      result = _parseGoPay(title, body);
    } else if (pkg.contains('dana')) {
      result = _parseDana(title, body);
    } else if (pkg.contains('shopee')) {
      result = _parseShopeePay(title, body);
    } else if (pkg.contains('brimo') || pkg.contains('bri')) {
      result = _parseBrimo(title, body);
    } else if (pkg.contains('wondr') || pkg.contains('bni')) {
      result = _parseWondr(title, body);
    }

    // Stage 2B: Universal Semantic Fallback Classifier (Handles ALL Income & Expense variations)
    result ??= _universalSemanticClassifier(title, body);

    if (result == null) return null;

    // Stage 3: Deduplication Fingerprint computation
    final timeBucket = (timestamp ?? DateTime.now()).minute;
    final rawHash = '$packageName|${result.amount}|${result.counterparty}|$timeBucket';
    final refHash = sha256.convert(utf8.encode(rawHash)).toString().substring(0, 16);

    return ParsedNotificationResult(
      amount: result.amount,
      type: result.type,
      counterparty: result.counterparty,
      source: result.source,
      externalRef: refHash,
    );
  }

  // ===========================================================================
  // UNIVERSAL SEMANTIC DIRECTION CLASSIFIER (ZERO MISSED TRANSACTIONS)
  // ===========================================================================
  static ParsedNotificationResult? _universalSemanticClassifier(String title, String body) {
    final fullText = '$title $body';

    // 1. Extract monetary amount (Rp or IDR format)
    final amountRegex = RegExp(
      r'(?:Rp\.?|IDR)\s*([0-9]{1,3}(?:[.,][0-9]{3})*(?:[.,][0-9]{2})?|[0-9]+)|(?:sebesar|senilai|amount|nominal)\s+(?:Rp\.?|IDR)?\s*([0-9]{1,3}(?:[.,][0-9]{3})*(?:[.,][0-9]{2})?|[0-9]+)|([0-9]{1,3}(?:[.,][0-9]{3})+)',
      caseSensitive: false,
    );
    final amtMatch = amountRegex.firstMatch(fullText);
    if (amtMatch == null) return null;

    final rawAmountStr = amtMatch.group(1) ?? amtMatch.group(2) ?? amtMatch.group(3);
    if (rawAmountStr == null) return null;

    final amount = _parseIdr(rawAmountStr);
    if (amount <= 0) return null;

    final lowText = fullText.toLowerCase();

    // 2. Classify Direction: Income vs Expense
    final isIncome = lowText.contains('masuk') ||
        lowText.contains('menerima') ||
        lowText.contains('kredit') ||
        lowText.contains('credit') ||
        lowText.contains('diterima') ||
        lowText.contains('cr ') ||
        lowText.contains('cr.') ||
        lowText.contains('cr:') ||
        lowText.contains('setoran') ||
        lowText.contains('setor tunai') ||
        lowText.contains('deposit') ||
        lowText.contains('top up') ||
        lowText.contains('top-up') ||
        lowText.contains('topup') ||
        lowText.contains('isi saldo') ||
        lowText.contains('pengisian saldo') ||
        lowText.contains('tambah saldo') ||
        lowText.contains('tambah dana') ||
        lowText.contains('penambahan saldo') ||
        lowText.contains('saldo bertambah') ||
        lowText.contains('add funds') ||
        lowText.contains('add fund') ||
        lowText.contains('added funds') ||
        lowText.contains('funds added') ||
        lowText.contains('fund added') ||
        lowText.contains('added to') ||
        lowText.contains('ditambahkan ke') ||
        lowText.contains('ditambahkan') ||
        lowText.contains('terima uang') ||
        lowText.contains('terima dana') ||
        lowText.contains('terima transfer') ||
        lowText.contains('incoming') ||
        lowText.contains('pemasukan') ||
        lowText.contains('received') ||
        lowText.contains('refund') ||
        lowText.contains('pengembalian');

    if (isIncome) {
      // Extract sender counterparty
      final senderRegex = RegExp(r'(?:dari|pengirim|from)\s+([^.,\n]+?)(?:\s+(?:pada|sebesar|senilai|ke|berhasil|telah|sukses)|$|\.)', caseSensitive: false);
      final sMatch = senderRegex.firstMatch(fullText);
      String sender = sMatch != null ? sMatch.group(1)!.trim() : '';
      if (sender.isEmpty) {
        if (lowText.contains('top up') || lowText.contains('topup') || lowText.contains('top-up')) {
          sender = 'Top Up Saldo';
        } else if (lowText.contains('isi saldo') || lowText.contains('pengisian saldo')) {
          sender = 'Isi Saldo';
        } else if (lowText.contains('add funds') || lowText.contains('add fund') || lowText.contains('tambah dana')) {
          sender = 'Add Funds';
        } else {
          sender = title.isNotEmpty ? title.trim() : 'Transfer Masuk';
        }
      }

      return ParsedNotificationResult(
        amount: amount,
        type: 'income',
        counterparty: sender,
      );
    } else {
      final recipientRegex = RegExp(r'(?:ke|kepada|di|to)\s+([^.,\n]+?)(?:\s+(?:sebesar|senilai|pada|berhasil|telah|sukses)|$|\.)', caseSensitive: false);
      final rMatch = recipientRegex.firstMatch(fullText);
      final recipient = rMatch != null ? rMatch.group(1)!.trim() : (title.isNotEmpty ? title.trim() : 'Pengeluaran Transaksi');

      return ParsedNotificationResult(
        amount: amount,
        type: 'expense',
        counterparty: recipient,
      );
    }
  }

  // ===========================================================================
  // PROVIDER SPECIFIC PARSERS
  // ===========================================================================

  static ParsedNotificationResult? _parseSeaBank(String title, String body) {
    // Dana Masuk: Kamu menerima dana sebesar Rp10.000 dari ShopeePay DAVID ARROZAQI...
    final dmRegex = RegExp(r'Kamu\s+menerima\s+dana\s+sebesar\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+dari\s+(.+?)(?:\s+pada|$)', caseSensitive: false);
    final dmMatch = dmRegex.firstMatch(body);
    if (dmMatch != null) {
      return ParsedNotificationResult(amount: _parseIdr(dmMatch.group(1)!), type: 'income', counterparty: dmMatch.group(2)!.trim());
    }

    // Transfer Virtual Account / Pembayaran: Kamu telah melakukan transfer virtual account sebesar Rp10.000 kepada ShopeePay...
    final vaRegex = RegExp(r'Kamu\s+telah\s+melakukan\s+transfer\s+(?:virtual\s+account\s+)?sebesar\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+kepada\s+(.+?)(?:\s+pada|$)', caseSensitive: false);
    final vaMatch = vaRegex.firstMatch(body);
    if (vaMatch != null) {
      return ParsedNotificationResult(amount: _parseIdr(vaMatch.group(1)!), type: 'expense', counterparty: vaMatch.group(2)!.trim());
    }

    // Transfer Masuk Rekening: Kamu menerima transfer saldo senilai Rp40.000 ke rekening 7776...
    final inRegex = RegExp(r'Kamu\s+menerima\s+transfer\s+(?:saldo\s+)?senilai\s+(?:Rp\.?|IDR)\s*([0-9.,]+)(?:\s+ke\s+rekening\s+([0-9]+))?', caseSensitive: false);
    final inMatch = inRegex.firstMatch(body);
    if (inMatch != null) {
      final rek = inMatch.group(2);
      return ParsedNotificationResult(amount: _parseIdr(inMatch.group(1)!), type: 'income', counterparty: rek != null ? 'Transfer Masuk (Rek. $rek)' : 'Transfer Masuk SeaBank');
    }

    // Transfer Keluar
    final outRegex = RegExp(r'Berhasil\s+transfer\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+ke\s+([^.]+)', caseSensitive: false);
    final outMatch = outRegex.firstMatch(body);
    if (outMatch != null) {
      return ParsedNotificationResult(amount: _parseIdr(outMatch.group(1)!), type: 'expense', counterparty: outMatch.group(2)!.trim());
    }

    return null;
  }

  static ParsedNotificationResult? _parseBca(String title, String body) {
    final qrRegex = RegExp(r'Pembayaran\s+QR\s+sebesar\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+di\s+([^.]+)\s+berhasil', caseSensitive: false);
    final qrMatch = qrRegex.firstMatch(body);
    if (qrMatch != null) {
      return ParsedNotificationResult(amount: _parseIdr(qrMatch.group(1)!), type: 'expense', counterparty: qrMatch.group(2)!.trim());
    }

    final transferOutRegex = RegExp(r'(?:m-Transfer|Transfer)\s+keluar\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+ke\s+([^.]+)\s+berhasil', caseSensitive: false);
    final transferOutMatch = transferOutRegex.firstMatch(body);
    if (transferOutMatch != null) {
      return ParsedNotificationResult(amount: _parseIdr(transferOutMatch.group(1)!), type: 'expense', counterparty: transferOutMatch.group(2)!.trim());
    }

    final transferInRegex = RegExp(r'(?:m-Transfer|Transfer)\s+masuk\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+dari\s+([^.]+)', caseSensitive: false);
    final transferInMatch = transferInRegex.firstMatch(body);
    if (transferInMatch != null) {
      return ParsedNotificationResult(amount: _parseIdr(transferInMatch.group(1)!), type: 'income', counterparty: transferInMatch.group(2)!.trim());
    }
    return null;
  }

  static ParsedNotificationResult? _parseBlu(String title, String body) {
    final qrRegex = RegExp(r'(?:Pembayaran\s+QRIS|Pembayaran)\s+sebesar\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:di|ke)\s+([^.]+?)\s+(?:telah\s+berhasil|berhasil)', caseSensitive: false);
    final qrMatch = qrRegex.firstMatch(body);
    if (qrMatch != null) {
      return ParsedNotificationResult(amount: _parseIdr(qrMatch.group(1)!), type: 'expense', counterparty: qrMatch.group(2)!.trim());
    }

    final transferOutRegex = RegExp(r'Transfer\s+sebesar\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+ke\s+([^.]+?)\s+berhasil', caseSensitive: false);
    final transferOutMatch = transferOutRegex.firstMatch(body);
    if (transferOutMatch != null) {
      return ParsedNotificationResult(amount: _parseIdr(transferOutMatch.group(1)!), type: 'expense', counterparty: transferOutMatch.group(2)!.trim());
    }

    final transferInRegex = RegExp(r'Kamu\s+menerima\s+transfer\s+sebesar\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+dari\s+([^.]+)', caseSensitive: false);
    final transferInMatch = transferInRegex.firstMatch(body);
    if (transferInMatch != null) {
      return ParsedNotificationResult(amount: _parseIdr(transferInMatch.group(1)!), type: 'income', counterparty: transferInMatch.group(2)!.trim());
    }
    return null;
  }

  static ParsedNotificationResult? _parseMandiri(String title, String body) {
    final qrRegex = RegExp(r"Transaksi\s+Livin'\s+QR\s+sebesar\s+(?:IDR|Rp\.?)\s*([0-9.,]+)\s+di\s+(.+?)\s+berhasil", caseSensitive: false);
    final qrMatch = qrRegex.firstMatch(body);
    if (qrMatch != null) {
      return ParsedNotificationResult(amount: _parseIdr(qrMatch.group(1)!), type: 'expense', counterparty: qrMatch.group(2)!.trim());
    }

    final debitRegex = RegExp(r'Debit\s+rekening\s+\*+[0-9]+\s+sebesar\s+(?:IDR|Rp\.?)\s*([0-9.,]+)\s+ke\s+(.+?)\s+berhasil', caseSensitive: false);
    final debitMatch = debitRegex.firstMatch(body);
    if (debitMatch != null) {
      return ParsedNotificationResult(amount: _parseIdr(debitMatch.group(1)!), type: 'expense', counterparty: debitMatch.group(2)!.trim());
    }
    return null;
  }

  static ParsedNotificationResult? _parseBrimo(String title, String body) {
    final regex = RegExp(r'Debit\s+Tabungan\s+BRI\s+.*?\s+Sebesar\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+ke\s+(.+?)(?:\.|$|\s+pada)', caseSensitive: false);
    final match = regex.firstMatch(body);
    if (match != null) {
      return ParsedNotificationResult(amount: _parseIdr(match.group(1)!), type: 'expense', counterparty: match.group(2)!.trim());
    }
    return null;
  }

  static ParsedNotificationResult? _parseWondr(String title, String body) {
    final regex = RegExp(r'Transaksi\s+wondr\s+QRIS\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+di\s+(.+?)\s+berhasil', caseSensitive: false);
    final match = regex.firstMatch(body);
    if (match != null) {
      return ParsedNotificationResult(amount: _parseIdr(match.group(1)!), type: 'expense', counterparty: match.group(2)!.trim());
    }
    return null;
  }

  static ParsedNotificationResult? _parseJago(String title, String body) {
    final regex = RegExp(r'Kamu\s+telah\s+membayar\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+ke\s+(.+?)\s+menggunakan', caseSensitive: false);
    final match = regex.firstMatch(body);
    if (match != null) {
      return ParsedNotificationResult(amount: _parseIdr(match.group(1)!), type: 'expense', counterparty: match.group(2)!.trim());
    }
    return null;
  }

  static ParsedNotificationResult? _parseGoPay(String title, String body) {
    final payRegex = RegExp(r'Pembayaran\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+ke\s+(.+?)\s+berhasil', caseSensitive: false);
    final payMatch = payRegex.firstMatch(body);
    if (payMatch != null) {
      return ParsedNotificationResult(amount: _parseIdr(payMatch.group(1)!), type: 'expense', counterparty: payMatch.group(2)!.trim());
    }

    final transferRegex = RegExp(r'Kamu\s+telah\s+transfer\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+ke\s+(.+?)(?:\.|$|!)', caseSensitive: false);
    final transferMatch = transferRegex.firstMatch(body);
    if (transferMatch != null) {
      return ParsedNotificationResult(amount: _parseIdr(transferMatch.group(1)!), type: 'expense', counterparty: transferMatch.group(2)!.trim());
    }
    return null;
  }

  static ParsedNotificationResult? _parseOvo(String title, String body) {
    final regex = RegExp(r'Berhasil\s+bayar\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+di\s+(.+?)(?:\.|$|!)', caseSensitive: false);
    final match = regex.firstMatch(body);
    if (match != null) {
      return ParsedNotificationResult(amount: _parseIdr(match.group(1)!), type: 'expense', counterparty: match.group(2)!.trim());
    }
    return null;
  }

  static ParsedNotificationResult? _parseDana(String title, String body) {
    final payRegex = RegExp(r'Pembayaran\s+berhasil!?\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+ke\s+(.+?)(?:\.|$|!)', caseSensitive: false);
    final payMatch = payRegex.firstMatch(body);
    if (payMatch != null) {
      return ParsedNotificationResult(amount: _parseIdr(payMatch.group(1)!), type: 'expense', counterparty: payMatch.group(2)!.trim());
    }

    final transferRegex = RegExp(r'Kirim\s+uang\s+(?:Rp\.?|IDR)\s*([0-9.,]+)\s+ke\s+(.+?)\s+berhasil', caseSensitive: false);
    final transferMatch = transferRegex.firstMatch(body);
    if (transferMatch != null) {
      return ParsedNotificationResult(amount: _parseIdr(transferMatch.group(1)!), type: 'expense', counterparty: transferMatch.group(2)!.trim());
    }
    return null;
  }

  static ParsedNotificationResult? _parseShopeePay(String title, String body) {
    // 1. Top Up / Isi Saldo (from user real notification):
    // "Pengisian saldo sebesar Rp.10.000 telah ditambahkan ke ShopeePay-mu. Saldo saat ini sebesar Rp.19.259"
    final topupRegex = RegExp(
      r'(?:pengisian\s+saldo|isi\s+saldo)\s+(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)',
      caseSensitive: false,
    );
    final topupMatch = topupRegex.firstMatch(body);
    if (topupMatch != null) {
      final amount = _parseIdr(topupMatch.group(1)!);
      return ParsedNotificationResult(
        amount: amount,
        type: 'income',
        counterparty: 'Isi Saldo ShopeePay',
      );
    }

    // 2. Transfer / Pembayaran Keluar
    final payRegex = RegExp(
      r'(?:Pembayaran\s+ShopeePay|Pembayaran)\s+(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)\s+(?:ke\s+([^.]+?)\s+)?berhasil',
      caseSensitive: false,
    );
    final match = payRegex.firstMatch(body);
    if (match != null) {
      final amount = _parseIdr(match.group(1)!);
      final merchant = match.group(2)?.trim() ?? 'ShopeePay Merchant';
      return ParsedNotificationResult(amount: amount, type: 'expense', counterparty: merchant);
    }

    return null;
  }

  // ===========================================================================
  // CURRENCY NORMALIZER HELPER
  // ===========================================================================
  static double _parseIdr(String rawAmount) {
    String cleaned = rawAmount.replaceAll(' ', '');
    
    if (cleaned.contains(',') && cleaned.lastIndexOf(',') == cleaned.length - 3) {
      cleaned = cleaned.substring(0, cleaned.length - 3).replaceAll(RegExp(r'[.,]'), '');
    } else {
      cleaned = cleaned.replaceAll(RegExp(r'[.,]'), '');
    }

    return double.tryParse(cleaned) ?? 0.0;
  }
}
