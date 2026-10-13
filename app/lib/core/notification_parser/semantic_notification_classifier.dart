import 'parsed_notification.dart';

/// Fallback semantic classifier handling arbitrary Indonesian financial notifications.
class SemanticNotificationClassifier {
  static ParsedNotificationResult? classify({
    required String title,
    required String body,
    required double Function(String) parseIdr,
  }) {
    final fullText = '$title $body';

    final explicitMatches = RegExp(
      r'(?:Rp\.?|IDR)\s*([0-9]{1,3}(?:[.,][0-9]{3})*(?:[.,][0-9]{2})?|[0-9]+)|(?:sebesar|senilai|amount|nominal)\s+(?:Rp\.?|IDR)?\s*([0-9]{1,3}(?:[.,][0-9]{3})*(?:[.,][0-9]{2})?|[0-9]+)',
      caseSensitive: false,
    ).allMatches(fullText);
    double amount = 0;
    for (final m in explicitMatches) {
      final raw = m.group(1) ?? m.group(2);
      if (raw != null) {
        final parsed = parseIdr(raw);
        if (parsed > 0) {
          amount = parsed;
          break;
        }
      }
    }
    if (amount <= 0) {
      final fallbackMatch = RegExp(r'([0-9]{1,3}(?:[.,][0-9]{3})+)').firstMatch(fullText);
      if (fallbackMatch != null) amount = parseIdr(fallbackMatch.group(1)!);
    }
    if (amount <= 0) return null;
    final lowText = fullText.toLowerCase();

    final hasExpenseAction = lowText.contains('pembayaran') ||
        lowText.contains('bayar') ||
        lowText.contains('membayar') ||
        lowText.contains('dibayar') ||
        lowText.contains('debit') ||
        lowText.contains('debited') ||
        lowText.contains('terdebit') ||
        lowText.contains('terpotong') ||
        lowText.contains('tagihan') ||
        lowText.contains('tarik tunai') ||
        lowText.contains('transfer keluar') ||
        lowText.contains('mengirim') ||
        lowText.contains('berhasil kirim') ||
        lowText.contains('baru aja kirim') ||
        lowText.contains('kirim ke') ||
        lowText.contains('berhasil transfer') ||
        lowText.contains('uang keluar') ||
        lowText.contains('kirim uang');
    final isIncome = (lowText.contains('masuk') ||
        lowText.contains('menerima') ||
        lowText.contains('kredit') ||
        lowText.contains('credit') ||
        (!hasExpenseAction && (lowText.contains('diterima') || lowText.contains('received'))) ||
        lowText.contains('cr ') ||
        lowText.contains('cr.') ||
        lowText.contains('cr:') ||
        lowText.contains('setoran') ||
        lowText.contains('setor tunai') ||
        (lowText.contains('deposit') && !lowText.contains('deposito')) ||
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
        lowText.contains('refund') ||
        lowText.contains('pengembalian')) &&
        (!hasExpenseAction || lowText.contains('menerima') || lowText.contains('masuk') || lowText.contains('refund') || lowText.contains('top up') || lowText.contains('isi saldo') || lowText.contains('tambah dana') || lowText.contains('add funds'));

    final isExpense = lowText.contains('keluar') ||
        lowText.contains('bayar') ||
        lowText.contains('membayar') ||
        lowText.contains('pembayaran') ||
        lowText.contains('dibayar') ||
        lowText.contains('payment') ||
        lowText.contains('paid') ||
        lowText.contains('debit') ||
        lowText.contains('debited') ||
        lowText.contains('terdebit') ||
        lowText.contains('terpotong') ||
        lowText.contains('pemotongan') ||
        lowText.contains('potong saldo') ||
        lowText.contains('saldo terpotong') ||
        lowText.contains('saldo berkurang') ||
        lowText.contains('db ') ||
        lowText.contains('db.') ||
        lowText.contains('db:') ||
        lowText.contains('dr ') ||
        lowText.contains('dr.') ||
        lowText.contains('dr:') ||
        lowText.contains('transfer ke') ||
        lowText.contains('transfer keluar') ||
        lowText.contains('transfer kepada') ||
        lowText.contains('transfer sebesar') ||
        lowText.contains('kirim uang') ||
        lowText.contains('kirim dana') ||
        lowText.contains('baru aja kirim') ||
        lowText.contains('kirim rp') ||
        lowText.contains('kirim idr') ||
        lowText.contains('kirim ke') ||
        lowText.contains('mengirim') ||
        lowText.contains('dikirim') ||
        lowText.contains('terkirim') ||
        lowText.contains('berhasil kirim') ||
        lowText.contains('berhasil transfer') ||
        lowText.contains('transfer berhasil') ||
        lowText.contains('uang keluar') ||
        lowText.contains('dana keluar') ||
        lowText.contains('sent to') ||
        lowText.contains('send to') ||
        lowText.contains('transferred to') ||
        lowText.contains('transferred') ||
        lowText.contains('transaction') ||
        lowText.contains('qris') ||
        lowText.contains('pembelian') ||
        lowText.contains('purchase') ||
        lowText.contains('purchased') ||
        lowText.contains('belanja di') ||
        lowText.contains('tarik tunai') ||
        lowText.contains('penarikan') ||
        lowText.contains('withdrawal') ||
        lowText.contains('withdrawn') ||
        lowText.contains('tagihan') ||
        lowText.contains('bill') ||
        lowText.contains('autodebet') ||
        lowText.contains('auto debit') ||
        lowText.contains('biaya admin') ||
        lowText.contains('admin fee') ||
        lowText.contains('pengeluaran') ||
        lowText.contains('outgoing');

    if (isIncome) {
      final senderRegex = RegExp(r'(?:dari|pengirim|from)\s+([^.,\n]+?)(?:\s+(?:pada|sebesar|senilai|ke\s+rekening|ke\s+kantong|ke\s+saldo|ke\s+tabungan|berhasil|telah|sukses)|$|\.)', caseSensitive: false);
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
      return ParsedNotificationResult(amount: amount, type: 'income', counterparty: sender);
    } else if (isExpense) {
      final recipientRegex = RegExp(r'(?:ke|kepada|di|to)\s+([^.,\n]+?)(?:\s+(?:sebesar|senilai|pada|menggunakan|dari\s+kantong|dari\s+rekening|berhasil|telah|sukses)|$|\.)', caseSensitive: false);
      final rMatch = recipientRegex.firstMatch(fullText);
      final recipient = rMatch != null ? rMatch.group(1)!.trim() : (title.isNotEmpty ? title.trim() : 'Pengeluaran Transaksi');
      return ParsedNotificationResult(amount: amount, type: 'expense', counterparty: recipient);
    }
    return null;
  }
}
