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
    String? activeProfileId,
  }) async {
    final wallets = await (db.select(db.wallets)..where((t) => t.isDeleted.equals(false))).get();
    if (wallets.isEmpty) return null;

    final lowText = '$title $text'.toLowerCase();

    // 1. Tier 1: Matching Account Number (Suffix or Exact Number) across all profiles
    final accMatch = _matchAccountNumber(wallets, lowText);
    if (accMatch != null) return accMatch;

    final activeProf = activeProfileId != null ? null : await db.getActiveProfile();
    final effectiveProfileId = activeProfileId ?? activeProf?.id;

    // 2. Tier 2: Check user-configured notification rule
    if (effectiveProfileId != null) {
      final rule = await db.getNotificationRuleForPackage(pkg, profileId: effectiveProfileId);
      if (rule != null) {
        final matched = wallets.where((w) => w.id == rule.walletId).firstOrNull;
        if (matched != null) return matched;
      }
    }

    final generalRule = await db.getNotificationRuleForPackage(pkg);
    if (generalRule != null) {
      final matched = wallets.where((w) => w.id == generalRule.walletId).firstOrNull;
      if (matched != null) return matched;
    }

    // 3. Tier 3: Keyword / Provider Heuristic (prioritizing active profile)
    final profileWallets = effectiveProfileId != null
        ? wallets.where((w) => w.profileId == effectiveProfileId).toList()
        : <WalletEntry>[];
    final searchPool = profileWallets.isNotEmpty ? profileWallets : wallets;

    final providerMatch = _matchProvider(pkg, lowText, searchPool);
    if (providerMatch != null) return providerMatch;

    // Fallback search across all wallets if not found in profileWallets
    if (profileWallets.isNotEmpty) {
      final globalProviderMatch = _matchProvider(pkg, lowText, wallets);
      if (globalProviderMatch != null) return globalProviderMatch;
    }

    // Special ShopeePay auto-provisioning
    if (pkg.contains('shopee') || lowText.contains('shopee')) {
      final shopeeWallets = wallets.where((w) => w.name.toLowerCase().contains('shopee')).toList();
      if (shopeeWallets.isNotEmpty) return shopeeWallets.first;
      return _autoProvisionShopeePay(db, effectiveProfileId);
    }

    // 4. Check if notification text names a wallet
    for (final w in searchPool) {
      if (lowText.contains(w.name.toLowerCase())) return w;
    }
    for (final w in wallets) {
      if (lowText.contains(w.name.toLowerCase())) return w;
    }

    return searchPool.firstOrNull ?? wallets.first;
  }

  static WalletEntry? _matchAccountNumber(List<WalletEntry> wallets, String lowText) {
    for (final w in wallets) {
      final acc = w.accountNumber?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
      if (acc.length >= 3) {
        // Full exact account number match
        if (acc.length >= 5 && lowText.contains(acc)) {
          return w;
        }
        // Last 4 digits suffix match (e.g. *1234, ...1234, rek 1234)
        final suffix = acc.length >= 4 ? acc.substring(acc.length - 4) : acc;
        final patterns = [
          RegExp('(?:rekening|rek\\.?|a\\/c|account|no\\.?\\s*rek)\\s*(?:\\*+|\\.{2,}|x+)?\\s*$suffix'),
          RegExp('(?:\\*+|\\.{2,}|x+)$suffix'),
        ];
        for (final p in patterns) {
          if (p.hasMatch(lowText)) return w;
        }
      }
    }
    return null;
  }

  static WalletEntry? _matchProvider(String pkg, String lowText, List<WalletEntry> list) {
    if (pkg.contains('seabank') || pkg.contains('bke') || pkg.contains('digitalbank') || pkg.contains('sea.bank') || lowText.contains('seabank')) {
      return list.where((w) => w.name.toLowerCase().contains('seabank')).firstOrNull;
    } else if (pkg.contains('bcadigital') || pkg.contains('blu') || lowText.contains('blu')) {
      return list.where((w) => w.name.toLowerCase().contains('blu')).firstOrNull;
    } else if (pkg.contains('bca') || lowText.contains('bca')) {
      return list.where((w) => w.name.toLowerCase().contains('bca')).firstOrNull;
    } else if (pkg.contains('mandiri') || lowText.contains('mandiri') || lowText.contains('livin')) {
      return list.where((w) => w.name.toLowerCase().contains('mandiri')).firstOrNull;
    } else if (pkg.contains('jago') || lowText.contains('jago')) {
      return list.where((w) => w.name.toLowerCase().contains('jago')).firstOrNull;
    } else if (pkg.contains('ovo') || lowText.contains('ovo')) {
      return list.where((w) => w.name.toLowerCase().contains('ovo')).firstOrNull;
    } else if (pkg.contains('dana') || lowText.contains('dana')) {
      return list.where((w) => w.name.toLowerCase().contains('dana')).firstOrNull;
    } else if (pkg.contains('gojek') || pkg.contains('gopay') || lowText.contains('gopay')) {
      return list.where((w) => w.name.toLowerCase().contains('gopay') || w.name.toLowerCase().contains('gojek')).firstOrNull;
    } else if (pkg.contains('brimo') || pkg.contains('bri') || lowText.contains('brimo') || lowText.contains('bri')) {
      return list.where((w) => w.name.toLowerCase().contains('bri')).firstOrNull;
    } else if (pkg.contains('wondr') || pkg.contains('bni') || lowText.contains('wondr') || lowText.contains('bni')) {
      return list.where((w) => w.name.toLowerCase().contains('bni') || w.name.toLowerCase().contains('wondr')).firstOrNull;
    }
    return null;
  }

  static Future<WalletEntry> _autoProvisionShopeePay(AppDatabase db, String? activeProfileId) async {
    final newId = const Uuid().v4();
    final now = DateTime.now().toUtc();
    await db.into(db.wallets).insert(
      WalletsCompanion(
        id: drift.Value(newId),
        profileId: drift.Value(activeProfileId),
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
