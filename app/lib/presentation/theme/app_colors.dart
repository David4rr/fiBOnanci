import 'package:flutter/material.dart';

import 'app_palette.dart';

export 'app_palette.dart' show AppPalette, DarkAppPalette, LightAppPalette;

/// Central design tokens delegating dynamically to the active [AppPalette].
class AppColors {
  static AppPalette _palette = const DarkAppPalette();

  static void updateBrightness(Brightness brightness) {
    _palette = brightness == Brightness.dark ? const DarkAppPalette() : const LightAppPalette();
  }

  static bool get isDark => _palette is DarkAppPalette;
  static AppPalette get palette => _palette;

  // Dynamic Theme-Adaptive Canvas & Surfaces
  static Color get canvasBg => _palette.canvasBg;
  static Color get canvasCardSurface => _palette.canvasCardSurface;
  static Color get canvasInputSearch => _palette.canvasInputSearch;
  static Color get canvasBorder => _palette.canvasBorder;
  static Color get canvasBorderSubtle => _palette.canvasBorderSubtle;

  // Dynamic Theme-Adaptive Typography & Text
  static Color get textWhite => _palette.textPrimary;
  static Color get textPrimary => _palette.textPrimary;
  static Color get textMuted => _palette.textMuted;
  static Color get textSubtle => _palette.textSubtle;
  static Color get textIncome => _palette.textIncome;
  static Color get textAccent => _palette.textAccent;
  static Color get cardIconBadgeBg => _palette.cardIconBadgeBg;

  // Dynamic Subtle Structural Helpers
  static Color get surfaceSubtle => _palette.surfaceSubtle;
  static Color get borderSubtle => _palette.borderSubtle;
  static Color get dividerSubtle => _palette.dividerSubtle;
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Constant Brand & Accent Palette (Identical in both themes)
  static const Color carbonBlack = Color(0xFF0C0A00);
  static const Color neoChartreuse = Color(0xFFD4F442);
  static const Color neoMint = Color(0xFF7DF24E);
  static const Color neoCoral = Color(0xFFFF7052);
  static const Color neoCyan = Color(0xFF26D9D9);
  static const Color neoPurple = Color(0xFFA855F7);

  // Constant Contrast Text on Accent Cards
  static const Color textDarkPrimary = Color(0xFF0A0B0E);
  static const Color textDarkSecondary = Color(0xFF2C303E);

  // Dynamic Financial Status Indicators
  static Color get statusComfortable => _palette.statusComfortable;
  static const Color statusCaution = Color(0xFFF59E0B);
  static const Color statusDeficit = Color(0xFFEF4444);

  static Color fromHex(String hex) =>
      Color(int.tryParse(hex.replaceAll('#', '0xFF')) ?? 0xFFD4F442);
}
