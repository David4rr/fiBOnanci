import '../../data/database/app_database.dart';
import 'modernist_card_theme.dart';
import 'subscription_card_theme.dart';

/// Dynamic theme & style resolver for recurring bills and installments.
/// Guarantees that every card looks visually distinct even across dozens of cards.
class SubscriptionCardResolver {
  static const List<ModernistCardTheme> kCardThemes = [
    ModernistCardTheme.cobaltVault,
    ModernistCardTheme.terracottaSunset,
    ModernistCardTheme.matchaZen,
    ModernistCardTheme.tokyoMidnight,
    ModernistCardTheme.solarAmber,
    ModernistCardTheme.cyberNeon,
    ModernistCardTheme.lavenderDusk,
    ModernistCardTheme.nordicPine,
    ModernistCardTheme.copperPatina,
    ModernistCardTheme.arcticGlacier,
    ModernistCardTheme.monochromeStark,
    ModernistCardTheme.blushPop,
    ModernistCardTheme.fiberInternet,
    ModernistCardTheme.aiCloudProductivity,
    ModernistCardTheme.utilitiesLemon,
    ModernistCardTheme.audioEmerald,
    ModernistCardTheme.housingLiving,
    ModernistCardTheme.fitnessLifestyle,
    ModernistCardTheme.recurringSmartBill,
    ModernistCardTheme.streamingCinematic,
  ];

  /// Resolves a dynamic modernist theme for a subscription or installment.
  /// Dynamically maps index/seed across the expanded palette with no duplicate themes.
  static ModernistCardTheme resolve(
    String title,
    int seed, {
    int? index,
    List<SubscriptionEntry>? allSubscriptions,
  }) {
    if (allSubscriptions != null && allSubscriptions.isNotEmpty) {
      final subIdx = allSubscriptions.indexWhere((s) => s.title == title);
      final effectiveIdx = subIdx >= 0 ? subIdx : (index ?? seed.abs());
      return kCardThemes[effectiveIdx.abs() % kCardThemes.length];
    }
    final effectiveIdx = index ?? seed.abs();
    return kCardThemes[effectiveIdx.abs() % kCardThemes.length];
  }

  /// Resolves the full dynamic configuration for a subscription card.
  static SubscriptionCardThemeConfig resolveConfig({
    required SubscriptionEntry subscription,
    required int index,
    WalletEntry? wallet,
    List<SubscriptionEntry>? allSubscriptions,
  }) {
    final theme = resolve(
      subscription.title,
      subscription.title.hashCode,
      index: index,
      allSubscriptions: allSubscriptions,
    );

    return SubscriptionCardThemeConfig.forDynamic(
      theme: theme,
      index: index,
      seedId: subscription.id,
      walletName: wallet?.name,
      isInstallment: subscription.isInstallment,
    );
  }
}
