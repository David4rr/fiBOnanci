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

  /// Curated solid flat Neo-Pastel & vibrant colors (no gradients).
  static const List<Color> _curatedSeeds = [
    Color(0xFFD4F442), // Neo-Chartreuse
    Color(0xFF7DF24E), // Neo-Mint
    Color(0xFF26D9D9), // Neo-Cyan
    Color(0xFFFF7052), // Neo-Coral
    Color(0xFFA855F7), // Amethyst
    Color(0xFF3B82F6), // Electric Cobalt
    Color(0xFFF59E0B), // Solar Amber
    Color(0xFFEC4899), // Cyber Pink
    Color(0xFF10B981), // Emerald
    Color(0xFF8B5CF6), // Royal Purple
    Color(0xFF06B6D4), // Glacier Aqua
    Color(0xFFF97316), // Vivid Tangerine
  ];

  /// Resolves a solid flat theme (no gradient) for a savings pocket.
  static PocketCardThemeConfig resolve(
    PocketEntry pocket,
    int index, {
    List<PocketEntry>? allPockets,
  }) {
    final effectiveIndex = allPockets != null && allPockets.isNotEmpty
        ? allPockets.indexWhere((p) => p.id == pocket.id)
        : index;
    final i = effectiveIndex >= 0 ? effectiveIndex : index;

    final double goldenHue = (145.0 + (i * 137.508) + (pocket.id.hashCode.abs() % 19)) % 360.0;
    final Color solidColor = i < _curatedSeeds.length
        ? _curatedSeeds[i]
        : HSLColor.fromAHSL(1.0, goldenHue, 0.78, 0.72).toColor();

    final bool isDark = ThemeData.estimateBrightnessForColor(solidColor) == Brightness.dark;
    if (isDark) {
      return PocketCardThemeConfig(
        backgroundColor: solidColor,
        primaryTextColor: AppColors.textWhite,
        secondaryTextColor: Colors.white.withValues(alpha: 0.95),
        tertiaryTextColor: Colors.white.withValues(alpha: 0.75),
        iconColor: AppColors.textWhite,
        iconBgColor: Colors.white.withValues(alpha: 0.18),
      );
    }
    return PocketCardThemeConfig(
      backgroundColor: solidColor,
      primaryTextColor: AppColors.textDarkPrimary,
      secondaryTextColor: AppColors.textDarkPrimary,
      tertiaryTextColor: AppColors.textDarkSecondary,
      iconColor: AppColors.textDarkPrimary,
      iconBgColor: AppColors.cardIconBadgeBg,
    );
  }
}
