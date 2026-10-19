import 'smart_transaction_draft.dart';

/// Centralized Indonesian NLP vocabulary, regex classifiers, and note cleaners
/// for Voice Speech-to-Text and smart text input.
class SmartInputRules {
  static const Map<String, List<String>> walletAliases = {
    'bca': ['bca', 'mybca', 'klikbca', 'tahapan'],
    'blu': ['blu', 'bca digital'],
    'mandiri': ['mandiri', 'livin'],
    'bri': ['bri', 'brimo'],
    'bni': ['bni', 'wondr'],
    'jago': ['jago', 'bank jago'],
    'seabank': ['seabank', 'sea bank'],
    'gopay': ['gopay', 'go pay', 'gojek'],
    'ovo': ['ovo'],
    'dana': ['dana'],
    'shopeepay': ['shopeepay', 'shopee pay'],
  };

  static const Map<String, List<String>> categoryRules = {
    'makanan': ['makan', 'minum', 'kopi', 'coffee', 'cafe', 'resto', 'warung', 'nasi', 'ayam', 'bakso', 'mie', 'gofood', 'grabfood', 'shopeefood', 'starbucks', 'kenangan', 'fore', 'roti', 'snack', 'sarapan', 'dinner', 'lunch'],
    'transportasi': ['bensin', 'pertamina', 'pertamax', 'pertalite', 'shell', 'parkir', 'tol', 'gojek', 'goride', 'gocar', 'grab', 'uber', 'kereta', 'krl', 'mrt', 'lrt', 'busway', 'transjakarta', 'tiket', 'taksi'],
    'belanja': ['belanja', 'indomaret', 'alfamart', 'alfamidi', 'superindo', 'hypermart', 'tokopedia', 'shopee', 'lazada', 'tiktok', 'baju', 'sepatu', 'sabun', 'minimarket', 'supermarket', 'mall'],
    'tagihan': ['listrik', 'pln', 'pdam', 'air', 'wifi', 'indihome', 'biznet', 'pulsa', 'paket data', 'telkomsel', 'xl', 'indosat', 'bpjs', 'pajak', 'tagihan', 'cicilan', 'kredit'],
    'hiburan': ['netflix', 'spotify', 'youtube', 'bioskop', 'xxi', 'cgv', 'game', 'steam', 'playstation', 'konser', 'liburan', 'hotel', 'hiburan'],
    'kesehatan': ['obat', 'apotek', 'kimia farma', 'k24', 'rs', 'rumah sakit', 'dokter', 'klinik', 'halodoc', 'vitamin', 'medis', 'lab'],
    'pendidikan': ['buku', 'gramedia', 'kursus', 'udemy', 'coursera', 'sekolah', 'kuliah', 'ukt', 'spp', 'seminar'],
    'gaji': ['gaji', 'gajian', 'salary', 'payroll', 'upah', 'thr', 'tunjangan', 'pendapatan', 'pemasukan', 'penghasilan', 'honor', 'pesangon'],
    'bonus': ['bonus', 'freelance', 'proyek', 'project', 'komisi', 'insentif', 'hadiah', 'reward', 'tips', 'jualan', 'dagang', 'laba', 'untung', 'profit', 'omset', 'omzet', 'cashback', 'refund'],
    'investasi': ['dividen', 'bunga', 'investasi', 'reksadana', 'saham', 'bibit', 'ajaib', 'deposito', 'emas', 'crypto', 'kripto'],
  };

  static String detectTransactionType(String text) {
    final low = text.toLowerCase();
    final hasIncomingNotice = low.contains('terima transfer') ||
        low.contains('dapat transfer') ||
        low.contains('dapet transfer') ||
        low.contains('transferan masuk') ||
        low.contains('ada transfer');

    final isTransfer = !hasIncomingNotice &&
        (low.contains('transfer antar') ||
            low.contains('pindah dana') ||
            low.contains('pindah saldo') ||
            RegExp(r'\b(transfer|pindah|kirim|tarik|isi\s*saldo|top\s*up|topup)\b.*\bdari\b.*\bke\b').hasMatch(low) ||
            RegExp(r'\b(transfer|pindah|kirim|tarik|isi\s*saldo|top\s*up|topup)\b.*\bke\b.*\bdari\b').hasMatch(low) ||
            RegExp(r'\b(?:top\s*up|topup|isi\s*(?:saldo)?)\b\s+[a-z0-9]+\s+(?:dari|pakai|lewat|via)\s+[a-z0-9]+').hasMatch(low));
    if (isTransfer) return 'transfer';

    const expenseActions = [
      'beli', 'membeli', 'bayar', 'membayar', 'belanja', 'habis', 'ongkir',
      'jajan', 'makan', 'minum', 'langganan', 'cicilan', 'sewa', 'checkout',
      'tarik tunai', 'sedekah', 'donasi', 'zakat'
    ];
    final hasExpenseVerb = expenseActions.any((k) => RegExp(r'\b' + k + r'\b').hasMatch(low));

    const incomeKw = [
      'gaji', 'gajian', 'salary', 'payroll', 'upah', 'honor', 'tunjangan', 'thr',
      'pesangon', 'pemasukan', 'pendapatan', 'penghasilan', 'omset', 'omzet',
      'mendapat', 'mendapatkan', 'dapat', 'dapet', 'menerima', 'terima',
      'diterima', 'uang masuk', 'dana masuk', 'saldo masuk', 'transferan masuk',
      'transfer masuk', 'masuk ke', 'masuk di', 'masuk rekening', 'ditransfer',
      'bonus', 'insentif', 'komisi', 'tips', 'freelance', 'proyek', 'side job',
      'jualan', 'penjualan', 'laba', 'untung', 'profit', 'dividen', 'bunga bank',
      'bunga deposito', 'imbal hasil', 'hadiah', 'reward', 'menang', 'giveaway',
      'doorprize', 'cashback', 'refund', 'reimburse', 'reimbursement', 'klaim',
      'cair', 'pencairan', 'dikasih', 'kiriman',
    ];
    final hasIncomeKw = incomeKw.any((k) => RegExp(r'\b' + k + r'\b').hasMatch(low));

    if (hasIncomeKw && !hasExpenseVerb) return 'income';
    if (hasIncomeKw && hasExpenseVerb) {
      if (low.contains('cashback') || low.contains('refund') || low.contains('reimburse')) {
        return (low.startsWith('beli') || low.startsWith('bayar')) ? 'expense' : 'income';
      }
      final firstInc = incomeKw
          .map((k) => RegExp(r'\b' + k + r'\b').firstMatch(low)?.start)
          .whereType<int>()
          .fold<int?>(null, (min, pos) => min == null || pos < min ? pos : min);
      final firstExp = expenseActions
          .map((k) => RegExp(r'\b' + k + r'\b').firstMatch(low)?.start)
          .whereType<int>()
          .fold<int?>(null, (min, pos) => min == null || pos < min ? pos : min);
      if (firstInc != null && firstExp != null) {
        return firstInc < firstExp ? 'income' : 'expense';
      }
    }

    return hasIncomeKw ? 'income' : 'expense';
  }

  static (String?, String?) matchTransferWallets(String low) {
    final m1 = RegExp(r'\bdari\s+([a-z0-9\s]+?)\s+ke\s+([a-z0-9\s]+)').firstMatch(low);
    if (m1 != null) return (m1.group(1)!, m1.group(2)!);
    final m2 = RegExp(r'\bke\s+([a-z0-9\s]+?)\s+dari\s+([a-z0-9\s]+)').firstMatch(low);
    if (m2 != null) return (m2.group(2)!, m2.group(1)!);
    final m3 = RegExp(r'\b(?:top\s*up|topup|isi\s*(?:saldo)?)\s+([a-z0-9\s]+?)\s+(?:dari|pakai|lewat|via)\s+([a-z0-9\s]+)').firstMatch(low);
    if (m3 != null) return (m3.group(2)!, m3.group(1)!);
    return (null, null);
  }

  static String? extractCleanNotes(
    String text,
    SmartInputSource source,
    String type,
    String? matchedWalletName,
  ) {
    if (source == SmartInputSource.voice) {
      var note = text
          .replaceAll(RegExp(r'(?:Rp\.?|IDR)\s*[0-9.,]+', caseSensitive: false), '')
          .replaceAll(RegExp(r'\b\d+(?:[.,]\d+)?\s*(?:rb|ribu|rebu|k|jt|juta|miliar|milyar|rupiah|perak)?\b', caseSensitive: false), '')
          .replaceAll(RegExp(r'\b(?:satu|dua|tiga|empat|lima|enam|tujuh|delapan|sembilan|sepuluh|sebelas|belas|puluh|seratus|ratus|seribu|ribu|sejuta|juta|miliar|milyar|setengah|rupiah|perak|seceng|goceng|ceban|goban|cepek)\b', caseSensitive: false), '')
          .replaceAll(RegExp(r'\b(?:pakai|via|dari|ke|di|pada|masuk\s+(?:ke|di)|menggunakan|lewat|dengan)\s+(?:rekening(?:\s+[a-zA-Z0-9]+)?|dompet(?:\s+[a-zA-Z0-9]+)?|bank(?:\s+[a-zA-Z0-9]+)?|bca|mybca|klikbca|mandiri|livin|bri|brimo|bni|wondr|jago|seabank|gopay|ovo|dana|shopeepay|blu)\b', caseSensitive: false), '')
          .replaceAll(RegExp(r'\b(?:sebesar|senilai)\b.*$', caseSensitive: false), '')
          .replaceAll(RegExp(r'^\s*(?:tolong\s+)?(?:catat|masukkan|input)\s+', caseSensitive: false), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      const fillerWords = {
        'saya', 'aku', 'mendapat', 'mendapatkan', 'dapat', 'dapet', 'terima',
        'menerima', 'uang', 'dana', 'saldo', 'masuk', 'keluar', 'pengeluaran',
        'pemasukan', 'catat', 'ada', 'di', 'ke', 'dari', 'pada'
      };
      final words = RegExp(r'[a-zA-Z]+').allMatches(note).map((m) => m.group(0)!.toLowerCase()).toList();
      final isPureFiller = words.isEmpty || words.every((w) => fillerWords.contains(w));

      if (isPureFiller) {
        if (type == 'income') {
          return matchedWalletName != null ? 'Pemasukan $matchedWalletName' : 'Pemasukan';
        } else if (type == 'transfer') {
          return 'Transfer';
        } else {
          return 'Pengeluaran';
        }
      }
      return note[0].toUpperCase() + note.substring(1);
    }

    final lines = text.split(RegExp(r'[\r\n]+')).map((l) => l.trim()).where((l) => l.length >= 3).toList();
    for (final l in lines) {
      final m = RegExp(r'^(?:merchant|penerima|tujuan|toko|outlet)\s*[:\-]\s*(.+)$', caseSensitive: false).firstMatch(l);
      if (m != null && m.group(1)!.trim().isNotEmpty) return m.group(1)!.trim();
    }
    final skipHeader = RegExp(
      r'^(struk|bukti|transaksi|berhasil|sukses|tanggal|waktu|no\.|npwp|jl\.|jalan|telp|welcome|terima\s*kasih|kasir|copy|receipt|\d+)',
      caseSensitive: false,
    );
    for (final l in lines) {
      if (!skipHeader.hasMatch(l) && !l.contains('Rp') && !RegExp(r'\d{3}[.,]\d{3}').hasMatch(l)) {
        return l.length > 42 ? l.substring(0, 42).trim() : l;
      }
    }
    return lines.isNotEmpty ? (lines.first.length > 42 ? lines.first.substring(0, 42) : lines.first) : null;
  }
}
