import '../../data/database/app_database.dart';
import 'indonesian_amount_parser.dart';
import 'smart_transaction_draft.dart';

export 'indonesian_amount_parser.dart';
export 'smart_transaction_draft.dart';

/// Deterministic on-device NLP & OCR parser converting Voice transcripts or
/// Receipt/Proof OCR text into a pre-filled [SmartTransactionDraft].
class SmartTransactionParser {
  static const Map<String, List<String>> _walletAliases = {
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

  static const Map<String, List<String>> _categoryRules = {
    'makanan': ['makan', 'minum', 'kopi', 'coffee', 'cafe', 'resto', 'warung', 'nasi', 'ayam', 'bakso', 'mie', 'gofood', 'grabfood', 'shopeefood', 'starbucks', 'kenangan', 'fore', 'roti', 'snack', 'sarapan', 'dinner', 'lunch'],
    'transportasi': ['bensin', 'pertamina', 'pertamax', 'pertalite', 'shell', 'parkir', 'tol', 'gojek', 'goride', 'gocar', 'grab', 'uber', 'kereta', 'krl', 'mrt', 'lrt', 'busway', 'transjakarta', 'tiket', 'taksi'],
    'belanja': ['belanja', 'indomaret', 'alfamart', 'alfamidi', 'superindo', 'hypermart', 'tokopedia', 'shopee', 'lazada', 'tiktok', 'baju', 'sepatu', 'sabun', 'minimarket', 'supermarket', 'mall'],
    'tagihan': ['listrik', 'pln', 'pdam', 'air', 'wifi', 'indihome', 'biznet', 'pulsa', 'paket data', 'telkomsel', 'xl', 'indosat', 'bpjs', 'pajak', 'tagihan', 'cicilan', 'kredit'],
    'hiburan': ['netflix', 'spotify', 'youtube', 'bioskop', 'xxi', 'cgv', 'game', 'steam', 'playstation', 'konser', 'liburan', 'hotel', 'hiburan'],
    'kesehatan': ['obat', 'apotek', 'kimia farma', 'k24', 'rs', 'rumah sakit', 'dokter', 'klinik', 'halodoc', 'vitamin', 'medis', 'lab'],
    'pendidikan': ['buku', 'gramedia', 'kursus', 'udemy', 'coursera', 'sekolah', 'kuliah', 'ukt', 'spp', 'seminar'],
    'gaji': ['gaji', 'salary', 'payroll', 'upah', 'thr', 'tunjangan'],
    'bonus': ['bonus', 'freelance', 'proyek', 'project', 'komisi', 'insentif', 'hadiah'],
    'investasi': ['dividen', 'bunga', 'investasi', 'reksadana', 'saham', 'bibit', 'ajaib', 'deposito', 'emas'],
  };

  static SmartTransactionDraft parse({
    required String rawText,
    required SmartInputSource source,
    required List<WalletEntry> wallets,
    required List<CategoryEntry> categories,
    String? preferredWalletId,
  }) {
    final cleaned = rawText.trim();
    if (cleaned.isEmpty) return SmartTransactionDraft(rawText: rawText, source: source);

    final amount = source == SmartInputSource.voice
        ? IndonesianAmountParser.parseVoiceOrInlineAmount(cleaned)
        : IndonesianAmountParser.parseReceiptAmount(cleaned);
    final type = _detectTransactionType(cleaned);
    final walletPair = _matchWallets(cleaned, type, wallets, preferredWalletId);
    final categoryId = type == 'transfer'
        ? '11111111-1111-4111-8111-111111111111'
        : _matchCategory(cleaned, type, categories);
    final notes = _extractCleanNotes(cleaned, source);

    return SmartTransactionDraft(
      amount: amount,
      type: type,
      walletId: walletPair.$1,
      destinationWalletId: walletPair.$2,
      categoryId: categoryId,
      notes: notes,
      rawText: cleaned,
      source: source,
    );
  }

  static String _detectTransactionType(String text) {
    final low = text.toLowerCase();
    final isTransfer = (low.contains('transfer antar') ||
            low.contains('pindah dana') ||
            low.contains('pindah saldo') ||
            RegExp(r'\b(transfer|pindah|kirim)\b.*\bdari\b.*\bke\b').hasMatch(low)) &&
        !low.contains('terima transfer');
    if (isTransfer) return 'transfer';

    const incomeKw = [
      'gaji', 'pemasukan', 'terima uang', 'terima dana', 'terima transfer',
      'uang masuk', 'dana masuk', 'dapat bonus', 'bonus ', 'freelance',
      'dividen', 'bunga bank', 'refund', 'cashback',
    ];
    if (incomeKw.any((k) => low.contains(k))) return 'income';
    return 'expense';
  }

  static (String?, String?) _matchWallets(
    String text,
    String type,
    List<WalletEntry> wallets,
    String? preferredWalletId,
  ) {
    if (wallets.isEmpty) return (null, null);
    final low = text.toLowerCase();

    if (type == 'transfer') {
      final m = RegExp(r'\bdari\s+([a-z0-9\s]+?)\s+ke\s+([a-z0-9\s]+)', caseSensitive: false).firstMatch(low);
      if (m != null) {
        final fromW = _findWalletByHint(m.group(1)!, wallets);
        final toW = _findWalletByHint(m.group(2)!, wallets, excludeId: fromW?.id);
        final srcId = fromW?.id ?? preferredWalletId ?? wallets.first.id;
        final dstId = toW?.id ?? wallets.where((w) => w.id != srcId).map((w) => w.id).firstOrNull;
        return (srcId, dstId);
      }
    }

    final matched = _findWalletByHint(low, wallets);
    final primaryId = matched?.id ??
        (preferredWalletId != null && wallets.any((w) => w.id == preferredWalletId)
            ? preferredWalletId
            : wallets.first.id);
    final secondaryId = type == 'transfer'
        ? wallets.where((w) => w.id != primaryId).map((w) => w.id).firstOrNull
        : null;
    return (primaryId, secondaryId);
  }

  static WalletEntry? _findWalletByHint(String text, List<WalletEntry> wallets, {String? excludeId}) {
    final low = text.toLowerCase();
    for (final w in wallets) {
      if (excludeId != null && w.id == excludeId) continue;
      final wName = w.name.toLowerCase();
      if (low.contains(wName)) return w;
      for (final entry in _walletAliases.entries) {
        if (wName.contains(entry.key) && entry.value.any((a) => low.contains(a))) return w;
      }
    }
    return null;
  }

  static String? _matchCategory(String text, String type, List<CategoryEntry> categories) {
    final matching = categories.where((c) => c.type == type).toList();
    if (matching.isEmpty) return null;
    final low = text.toLowerCase();
    final firstLine = low.split(RegExp(r'[\r\n]+')).first;
    CategoryEntry? bestCat;
    int bestScore = 0;
    for (final c in matching) {
      final cLow = c.name.toLowerCase();
      int score = 0;
      for (final entry in _categoryRules.entries) {
        if (cLow.contains(entry.key)) {
          for (final kw in entry.value) {
            if (firstLine.contains(kw)) score += 3;
            if (low.contains(kw)) score += 1;
          }
        }
      }
      if (score > bestScore) {
        bestScore = score;
        bestCat = c;
      }
    }
    return (bestCat ?? matching.first).id;
  }

  static String? _extractCleanNotes(String text, SmartInputSource source) {
    if (source == SmartInputSource.voice) {
      var note = text
          .replaceAll(RegExp(r'(?:Rp\.?|IDR)\s*[0-9.,]+', caseSensitive: false), '')
          .replaceAll(RegExp(r'\b\d+(?:[.,]\d+)?\s*(?:rb|ribu|k|jt|juta|miliar|milyar|rupiah)?\b', caseSensitive: false), '')
          .replaceAll(RegExp(r'\b(?:satu|dua|tiga|empat|lima|enam|tujuh|delapan|sembilan|sepuluh|sebelas|belas|puluh|seratus|ratus|seribu|ribu|sejuta|juta|miliar|milyar|setengah|rupiah)\b', caseSensitive: false), '')
          .replaceAll(RegExp(r'\b(?:pakai|via|dari|ke|masuk\s+ke|menggunakan|lewat)\s+(?:rekening\s+|dompet\s+|bank\s+)?[a-zA-Z0-9]+\b', caseSensitive: false), '')
          .replaceAll(RegExp(r'\b(?:sebesar|senilai)\b.*$', caseSensitive: false), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (note.isEmpty) note = text.trim();
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
