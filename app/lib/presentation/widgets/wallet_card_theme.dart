import 'package:flutter/material.dart';
import '../../data/database/app_database.dart';
import 'modernist_card_theme.dart';

/// Complete dynamic palette of all 20 curated themes.
/// Orders themes with maximum visual contrast.
const List<ModernistCardTheme> kDynamicModernistThemes = [
  ModernistCardTheme.fiberInternet,
  ModernistCardTheme.utilitiesLemon,
  ModernistCardTheme.streamingCinematic,
  ModernistCardTheme.aiCloudProductivity,
  ModernistCardTheme.tokyoMidnight,
  ModernistCardTheme.fitnessLifestyle,
  ModernistCardTheme.audioEmerald,
  ModernistCardTheme.solarAmber,
  ModernistCardTheme.monochromeStark,
  ModernistCardTheme.arcticGlacier,
  ModernistCardTheme.copperPatina,
  ModernistCardTheme.cyberNeon,
  ModernistCardTheme.recurringSmartBill,
  ModernistCardTheme.cobaltVault,
  ModernistCardTheme.matchaZen,
  ModernistCardTheme.terracottaSunset,
  ModernistCardTheme.lavenderDusk,
  ModernistCardTheme.housingLiving,
  ModernistCardTheme.blushPop,
  ModernistCardTheme.nordicPine,
];

/// Curated list of wallet accent colors matching the expanded dynamic themes.
final List<Color> kWalletColors = kDynamicModernistThemes.map((t) {
  final config = ModernistCardConfig.forTheme(t);
  return config.backgroundColor.computeLuminance() < 0.35
      ? config.primaryGraphicColor
      : config.backgroundColor;
}).toList();

Color getWalletColor(int index, [String? colorHex]) {
  if (colorHex != null && colorHex != '#10B981' && colorHex != '#10b981') {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {}
  }
  final theme = kDynamicModernistThemes[index.abs() % kDynamicModernistThemes.length];
  final config = ModernistCardConfig.forTheme(theme);
  return config.backgroundColor.computeLuminance() < 0.35
      ? config.primaryGraphicColor
      : config.backgroundColor;
}

ModernistCardTheme resolveWalletTheme(
  WalletEntry wallet,
  int index, {
  List<WalletEntry>? allWallets,
  ModernistCardTheme? explicitTheme,
}) {
  if (explicitTheme != null) return explicitTheme;

  if (allWallets != null && allWallets.isNotEmpty) {
    final walletIdx = allWallets.indexWhere((w) => w.id == wallet.id);
    final effectiveIdx = walletIdx >= 0 ? walletIdx : index;
    return kDynamicModernistThemes[effectiveIdx.abs() % kDynamicModernistThemes.length];
  }

  return kDynamicModernistThemes[index.abs() % kDynamicModernistThemes.length];
}

String resolveWalletNetworkBadge(WalletEntry wallet, ModernistCardTheme theme) {
  switch (wallet.type.toLowerCase()) {
    case 'ewallet':
      return 'E-WALLET';
    case 'cash':
      return 'KAS TUNAI';
    case 'investment':
      return 'INVESTASI';
    case 'bank':
    default:
      return 'BANK';
  }
}
