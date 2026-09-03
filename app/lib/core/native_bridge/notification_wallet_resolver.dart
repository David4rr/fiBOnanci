import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../../data/database/app_database.dart';

/// Resolves or auto-provisions the appropriate wallet for an incoming notification.
class NotificationWalletResolver {
  static Future<WalletEntry?> resolve({
    required AppDatabase db,
    required String pkg,
    required String title,
    required String text,
  }) async {
    final wallets = await db.select(db.wallets).get();
    if (wallets.isEmpty) return null;

    // 1. Check user-configured notification rule
    final rule = await db.getNotificationRuleForPackage(pkg);
    if (rule != null) {
      final matched = wallets.where((w) => w.id == rule.walletId).firstOrNull;
      if (matched != null) return matched;
    }

    // 2. Secondary heuristic keywords
    final lowText = '$title $text'.toLowerCase();

    if (pkg.contains('seabank') ||
        pkg.contains('bke') ||
        pkg.contains('digitalbank') ||
        pkg.contains('sea.bank') ||
        lowText.contains('seabank')) {
      return wallets.firstWhere((w) => w.name.toLowerCase().contains('seabank'), orElse: () => wallets.first);
    } else if (pkg.contains('bcadigital') || pkg.contains('blu') || lowText.contains('blu')) {
      return wallets.firstWhere((w) => w.name.toLowerCase().contains('blu'), orElse: () => wallets.first);
    } else if (pkg.contains('bca') || lowText.contains('bca')) {
      return wallets.firstWhere((w) => w.name.toLowerCase().contains('bca utama'), orElse: () => wallets.first);
    } else if (pkg.contains('mandiri') || lowText.contains('mandiri') || lowText.contains('livin')) {
      return wallets.firstWhere((w) => w.name.toLowerCase().contains('mandiri'), orElse: () => wallets.first);
    } else if (pkg.contains('jago') || lowText.contains('jago')) {
      return wallets.firstWhere((w) => w.name.toLowerCase().contains('jago'), orElse: () => wallets.first);
    } else if (pkg.contains('ovo') || lowText.contains('ovo')) {
      return wallets.firstWhere((w) => w.name.toLowerCase().contains('ovo'), orElse: () => wallets.first);
    } else if (pkg.contains('shopee') || lowText.contains('shopee')) {
      final shopeeWallets = wallets.where((w) => w.name.toLowerCase().contains('shopee')).toList();
      if (shopeeWallets.isNotEmpty) {
        return shopeeWallets.first;
      } else {
        final newId = const Uuid().v4();
        final now = DateTime.now().toUtc();
        await db.into(db.wallets).insert(
          WalletsCompanion(
            id: drift.Value(newId),
            name: const drift.Value('ShopeePay'),
            type: const drift.Value('ewallet'),
            balance: const drift.Value(0.0),
            colorHex: const drift.Value('#EE4D2D'),
            iconName: const drift.Value('shopping_bag'),
            createdAt: drift.Value(now),
            updatedAt: drift.Value(now),
          ),
        );
        return (db.select(db.wallets)..where((t) => t.id.equals(newId))).getSingle();
      }
    }

    // 3. Check if notification text names a wallet
    for (final w in wallets) {
      if (lowText.contains(w.name.toLowerCase())) {
        return w;
      }
    }

    return wallets.first;
  }
}
