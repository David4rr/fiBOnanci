import 'package:flutter/material.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';

/// Dynamic theme configuration for Kantong Tabungan (Savings Pockets).
/// Guarantees that every card looks unique even when dozens of pockets exist.
class PocketCardThemeConfig {
  final Color backgroundColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color tertiaryTextColor;
  final Color iconColor;
  final Color iconBgColor;
  const PocketCardThemeConfig({
    required this.backgroundColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.tertiaryTextColor,
    required this.iconColor,
    required this.iconBgColor,
  });

  /// Curated base neo-pastel & deep-jewel seed colors for early cards.
  static const List<Color> _curatedSeeds = [
    Color(0xFFA855F7), // Amethyst
    Color(0xFFD4F442), // Neo-Chartreuse
    Color(0xFF26D9D9), // Neo-Cyan
    Color(0xFFFF7052), // Neo-Coral
    Color(0xFF7DF24E), // Neo-Mint
    Color(0xFF3B82F6), // Electric Cobalt
    Color(0xFFF59E0B), // Solar Amber
    Color(0xFFEC4899), // Cyber Pink
    Color(0xFF10B981), // Emerald
    Color(0xFF8B5CF6), // Royal Purple
    Color(0xFF06B6D4), // Glacier Aqua
    Color(0xFFF97316), // Vivid Tangerine
  ];

  /// Resolves a completely unique, dynamic theme for a savings pocket.
  static PocketCardThemeConfig resolve(
    PocketEntry pocket,
    int index, {
    List<PocketEntry>? allPockets,
  }) {
    final effectiveIndex = allPockets != null && allPockets.isNotEmpty
        ? allPockets.indexWhere((p) => p.id == pocket.id)
        : index;
    final i = effectiveIndex >= 0 ? effectiveIndex : index;

    // Use golden-angle hue stepping to guarantee non-repeating hues across dozens of cards
    final double goldenHue = (145.0 + (i * 137.508) + (pocket.id.hashCode.abs() % 23)) % 360.0;
    final bool isDark = i % 2 == 0;

    if (isDark) {
      // Rich deep jewel / obsidian surface with luminous accent typography
      final baseColor = HSLColor.fromAHSL(1.0, goldenHue, 0.58, 0.16).toColor();
      final accentColor = HSLColor.fromAHSL(1.0, goldenHue, 0.85, 0.65).toColor();

      return PocketCardThemeConfig(
        backgroundColor: baseColor,
        primaryTextColor: AppColors.textWhite,
        secondaryTextColor: Colors.white.withValues(alpha: 0.95),
        tertiaryTextColor: Colors.white.withValues(alpha: 0.68),
        iconColor: accentColor,
        iconBgColor: accentColor.withValues(alpha: 0.18),
      );
    } else {
      // Vibrant neo-pastel surface with crisp high-contrast dark typography
      final seedColor = i < _curatedSeeds.length
          ? _curatedSeeds[i]
          : HSLColor.fromAHSL(1.0, goldenHue, 0.78, 0.74).toColor();
      return PocketCardThemeConfig(
        backgroundColor: seedColor,
        primaryTextColor: AppColors.textDarkPrimary,
        secondaryTextColor: AppColors.textDarkPrimary,
        tertiaryTextColor: AppColors.textDarkSecondary,
        iconColor: AppColors.textDarkPrimary,
        iconBgColor: AppColors.cardIconBadgeBg,
      );
    }
  }
}
