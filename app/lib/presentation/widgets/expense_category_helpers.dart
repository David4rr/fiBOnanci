import 'package:flutter/material.dart';
import '../../data/database/app_database.dart';

class TransactionCardVisuals {
  final Color cardColor;
  final IconData iconData;
  final String categoryLabel;
  final String title;

  const TransactionCardVisuals({
    required this.cardColor,
    required this.iconData,
    required this.categoryLabel,
    required this.title,
  });
}

class TransactionVisualResolver {
  static const Color pocketGold = Color(0xFFF3C759);
  static const Color transferBlue = Color(0xFFA5B8D8);
  static const Color incomeMint = Color(0xFF7DE697);
  static const Color foodOchre = Color(0xFFD9B76A);
  static const Color transportTeal = Color(0xFF45C4B0);
  static const Color shoppingCoral = Color(0xFFFF8B73);
  static const Color billsPeriwinkle = Color(0xFF88A9E8);
  static const Color entertainmentLilac = Color(0xFFBCA0E8);
  static const Color healthRose = Color(0xFFF48FB1);
  static const Color educationCyan = Color(0xFF5DD5E8);
  static const Color loanTerracotta = Color(0xFFF98E56);
  static const Color donationLime = Color(0xFFB4E051);
  static const Color defaultSlate = Color(0xFFB8C2CC);

  static Color tintToPastel(String hex, {double mixWhite = 0.45}) {
    try {
      final clean = hex.replaceAll('#', '').trim();
      final intVal = int.parse(clean.length == 6 ? 'FF$clean' : clean, radix: 16);
      final base = Color(intVal);
      return Color.lerp(base, Colors.white, mixWhite) ?? base;
    } catch (_) {
      return defaultSlate;
    }
  }

  static IconData mapIconName(String? name, {IconData fallback = Icons.receipt_long_rounded}) {
    switch (name?.toLowerCase()) {
      case 'utensils': case 'restaurant': case 'fastfood': return Icons.restaurant_rounded;
      case 'car': case 'directions_car': return Icons.directions_car_rounded;
      case 'shopping_bag': case 'shopping_cart': return Icons.shopping_bag_rounded;
      case 'receipt': case 'receipt_long': return Icons.receipt_long_rounded;
      case 'film': case 'movie': case 'play': return Icons.play_circle_fill_rounded;
      case 'music': case 'music_note': return Icons.music_note_rounded;
      case 'heart_pulse': case 'favorite': return Icons.favorite_rounded;
      case 'graduation_cap': case 'school': return Icons.school_rounded;
      case 'banknote': case 'account_balance_wallet': case 'wallet': return Icons.account_balance_wallet_rounded;
      case 'sparkles': case 'auto_awesome': return Icons.auto_awesome_rounded;
      case 'trending_up': return Icons.trending_up_rounded;
      case 'repeat': case 'swap_horiz': return Icons.swap_horiz_rounded;
      case 'savings': return Icons.savings_rounded;
      case 'flag': return Icons.flag_rounded;
      default: return fallback;
    }
  }

  static TransactionCardVisuals resolve({
    required TransactionEntry tx,
    List<CategoryEntry>? categories,
    List<PocketEntry>? pockets,
    String? destWalletName,
  }) {
    final notes = tx.notes ?? '';
    final lowNotes = notes.toLowerCase();
    final extRef = tx.externalRef ?? '';
    final isPocketRef = extRef.startsWith('pocket_') || extRef.startsWith('pocket_close_');
    final isPocket = isPocketRef || lowNotes.contains('kantong');

    if (isPocket) {
      PocketEntry? pocket;
      if (isPocketRef) {
        final pId = extRef.replaceFirst('pocket_close_', '').replaceFirst('pocket_', '');
        pocket = pockets?.where((p) => p.id == pId).firstOrNull;
      }
      pocket ??= pockets?.where((p) => lowNotes.contains(p.name.toLowerCase())).firstOrNull;
      final isWithdraw = lowNotes.contains('penarikan') || extRef.startsWith('pocket_close_');
      return TransactionCardVisuals(
        cardColor: pocket != null ? tintToPastel(pocket.colorHex) : pocketGold,
        iconData: isWithdraw ? Icons.north_east_rounded : Icons.savings_rounded,
        categoryLabel: pocket != null ? 'KANTONG • ${pocket.name.toUpperCase()}' : (isWithdraw ? 'PENARIKAN KANTONG' : 'KANTONG TABUNGAN'),
        title: notes.isNotEmpty ? notes : (isWithdraw ? 'Tarik dari Kantong' : 'Setor ke Kantong'),
      );
    }

    if (tx.type == 'transfer') {
      final t = notes.isNotEmpty ? notes : (destWalletName != null ? 'Transfer ke $destWalletName' : 'Transfer Antar Rekening');
      return TransactionCardVisuals(cardColor: transferBlue, iconData: Icons.swap_horiz_rounded, categoryLabel: 'TRANSFER SALDO', title: t);
    }

    final cat = categories?.where((c) => c.id == tx.categoryId).firstOrNull;
    final catName = (cat?.name ?? '').toLowerCase();

    if (tx.type == 'income') {
      if (catName.contains('gaji') || lowNotes.contains('gaji') || lowNotes.contains('salary')) {
        return TransactionCardVisuals(cardColor: incomeMint, iconData: Icons.account_balance_wallet_rounded, categoryLabel: 'GAJI & PENDAPATAN', title: notes.isNotEmpty ? notes : 'Gaji Bulanan');
      }
      if (catName.contains('bonus') || lowNotes.contains('bonus') || lowNotes.contains('freelance')) {
        return TransactionCardVisuals(cardColor: const Color(0xFF6EE7B7), iconData: Icons.auto_awesome_rounded, categoryLabel: 'BONUS & FREELANCE', title: notes.isNotEmpty ? notes : 'Bonus / Komisi');
      }
      if (catName.contains('investasi') || catName.contains('bunga') || lowNotes.contains('dividen')) {
        return TransactionCardVisuals(cardColor: const Color(0xFF86EFAC), iconData: Icons.trending_up_rounded, categoryLabel: 'INVESTASI & BUNGA', title: notes.isNotEmpty ? notes : 'Hasil Investasi');
      }
      if (lowNotes.contains('cashback') || lowNotes.contains('refund')) {
        return TransactionCardVisuals(cardColor: incomeMint, iconData: Icons.card_giftcard_rounded, categoryLabel: 'CASHBACK & REFUND', title: notes.isNotEmpty ? notes : 'Cashback');
      }
      return TransactionCardVisuals(
        cardColor: cat != null ? tintToPastel(cat.colorHex) : incomeMint,
        iconData: mapIconName(cat?.iconName, fallback: Icons.south_west_rounded),
        categoryLabel: cat != null ? cat.name.toUpperCase() : 'PEMASUKAN',
        title: notes.isNotEmpty ? notes : 'Pemasukan',
      );
    }

    final str = '$catName $lowNotes';
    if (str.contains('makan') || str.contains('food') || str.contains('resto') || str.contains('kopi') || str.contains('cafe')) {
      return TransactionCardVisuals(cardColor: foodOchre, iconData: Icons.restaurant_rounded, categoryLabel: cat?.name.toUpperCase() ?? 'MAKANAN & MINUMAN', title: notes.isNotEmpty ? notes : 'Makanan & Minuman');
    }
    if (str.contains('transport') || str.contains('gojek') || str.contains('grab') || str.contains('bensin') || str.contains('parkir') || str.contains('tol')) {
      return TransactionCardVisuals(cardColor: transportTeal, iconData: Icons.directions_car_rounded, categoryLabel: cat?.name.toUpperCase() ?? 'TRANSPORTASI', title: notes.isNotEmpty ? notes : 'Transportasi');
    }
    if (str.contains('belanja') || str.contains('shopee') || str.contains('tokopedia') || str.contains('mall') || str.contains('supermarket')) {
      return TransactionCardVisuals(cardColor: shoppingCoral, iconData: Icons.shopping_bag_rounded, categoryLabel: cat?.name.toUpperCase() ?? 'BELANJA', title: notes.isNotEmpty ? notes : 'Belanja');
    }
    if (str.contains('tagihan') || str.contains('listrik') || str.contains('pln') || str.contains('pdam') || str.contains('wifi') || str.contains('pulsa') || str.contains('bpjs')) {
      return TransactionCardVisuals(cardColor: billsPeriwinkle, iconData: Icons.receipt_long_rounded, categoryLabel: cat?.name.toUpperCase() ?? 'TAGIHAN & UTILITAS', title: notes.isNotEmpty ? notes : 'Tagihan & Utilitas');
    }
    if (str.contains('hiburan') || str.contains('netflix') || str.contains('spotify') || str.contains('film') || str.contains('movie') || str.contains('game')) {
      return TransactionCardVisuals(cardColor: entertainmentLilac, iconData: Icons.play_circle_fill_rounded, categoryLabel: cat?.name.toUpperCase() ?? 'HIBURAN', title: notes.isNotEmpty ? notes : 'Hiburan');
    }
    if (str.contains('kesehatan') || str.contains('obat') || str.contains('apotek') || str.contains('dokter') || str.contains('klinik')) {
      return TransactionCardVisuals(cardColor: healthRose, iconData: Icons.favorite_rounded, categoryLabel: cat?.name.toUpperCase() ?? 'KESEHATAN', title: notes.isNotEmpty ? notes : 'Kesehatan');
    }
    if (str.contains('pendidikan') || str.contains('buku') || str.contains('kursus') || str.contains('sekolah') || str.contains('kuliah')) {
      return TransactionCardVisuals(cardColor: educationCyan, iconData: Icons.school_rounded, categoryLabel: cat?.name.toUpperCase() ?? 'PENDIDIKAN', title: notes.isNotEmpty ? notes : 'Pendidikan');
    }
    if (str.contains('cicilan') || str.contains('pinjaman') || str.contains('kredit') || str.contains('kpr')) {
      return TransactionCardVisuals(cardColor: loanTerracotta, iconData: Icons.credit_card_rounded, categoryLabel: cat?.name.toUpperCase() ?? 'CICILAN', title: notes.isNotEmpty ? notes : 'Cicilan');
    }
    if (str.contains('donasi') || str.contains('amal') || str.contains('zakat') || str.contains('sedekah')) {
      return TransactionCardVisuals(cardColor: donationLime, iconData: Icons.volunteer_activism_rounded, categoryLabel: cat?.name.toUpperCase() ?? 'DONASI & SOSIAL', title: notes.isNotEmpty ? notes : 'Donasi & Sosial');
    }

    return TransactionCardVisuals(
      cardColor: cat != null ? tintToPastel(cat.colorHex) : defaultSlate,
      iconData: mapIconName(cat?.iconName, fallback: Icons.north_east_rounded),
      categoryLabel: cat != null ? cat.name.toUpperCase() : 'PENGELUARAN',
      title: notes.isNotEmpty ? notes : 'Pengeluaran',
    );
  }
}

Color getExpenseCategoryColor(String? category, String? title, String? type, int index) {
  final str = '${category ?? ''} ${title ?? ''}'.toLowerCase();
  if (type == 'transfer' || str.contains('transfer')) return TransactionVisualResolver.transferBlue;
  if (type == 'income') return TransactionVisualResolver.incomeMint;
  if (str.contains('kantong')) return TransactionVisualResolver.pocketGold;
  if (str.contains('makan') || str.contains('food') || str.contains('resto') || str.contains('kopi')) return TransactionVisualResolver.foodOchre;
  if (str.contains('transport') || str.contains('grab') || str.contains('gojek') || str.contains('bensin')) return TransactionVisualResolver.transportTeal;
  if (str.contains('belanja') || str.contains('shopee') || str.contains('tokopedia') || str.contains('shop')) return TransactionVisualResolver.shoppingCoral;
  if (str.contains('tagihan') || str.contains('listrik') || str.contains('wifi') || str.contains('pulsa')) return TransactionVisualResolver.billsPeriwinkle;
  if (str.contains('hiburan') || str.contains('spotify') || str.contains('netflix') || str.contains('game')) return TransactionVisualResolver.entertainmentLilac;
  if (str.contains('kesehatan') || str.contains('obat') || str.contains('dokter')) return TransactionVisualResolver.healthRose;
  if (str.contains('pendidikan') || str.contains('buku') || str.contains('kursus')) return TransactionVisualResolver.educationCyan;
  return TransactionVisualResolver.defaultSlate;
}

IconData getExpenseCategoryIcon(String? category, String? title) {
  final str = '${category ?? ''} ${title ?? ''}'.toLowerCase();
  if (str.contains('kantong')) return Icons.savings_rounded;
  if (str.contains('transfer')) return Icons.swap_horiz_rounded;
  if (str.contains('makan') || str.contains('food') || str.contains('resto') || str.contains('kopi')) return Icons.restaurant_rounded;
  if (str.contains('transport') || str.contains('grab') || str.contains('gojek') || str.contains('bensin')) return Icons.directions_car_rounded;
  if (str.contains('belanja') || str.contains('shopee') || str.contains('tokopedia') || str.contains('shop')) return Icons.shopping_bag_rounded;
  if (str.contains('tagihan') || str.contains('listrik') || str.contains('wifi') || str.contains('pulsa')) return Icons.receipt_long_rounded;
  if (str.contains('hiburan') || str.contains('netflix') || str.contains('spotify') || str.contains('film')) return Icons.play_circle_fill_rounded;
  if (str.contains('kesehatan') || str.contains('obat')) return Icons.favorite_rounded;
  if (str.contains('pendidikan') || str.contains('buku')) return Icons.school_rounded;
  return Icons.receipt_long_rounded;
}
