import 'package:flutter/material.dart';

/// Preset theme for the Swiss-editorial modernist cards in ref1.jpg
enum ModernistCardTheme {
  streamingCinematic,
  audioEmerald,
  utilitiesLemon,
  fiberInternet,
  aiCloudProductivity,
  housingLiving,
  fitnessLifestyle,
  recurringSmartBill,
  tokyoMidnight,
  solarAmber,
  arcticGlacier,
  cyberNeon,
  matchaZen,
  terracottaSunset,
  monochromeStark,
  lavenderDusk,
  cobaltVault,
  blushPop,
  nordicPine,
  copperPatina,
}

/// Unified configuration for Modernist Cards matching the physical ATM reference.
class ModernistCardConfig {
  final Color backgroundColor;
  final Color primaryGraphicColor;
  final Color secondaryGraphicColor;
  final Color textColor;
  final Color badgeColor;
  final String networkBadgeText;

  const ModernistCardConfig({
    required this.backgroundColor,
    required this.primaryGraphicColor,
    required this.secondaryGraphicColor,
    required this.textColor,
    required this.badgeColor,
    required this.networkBadgeText,
  });

  static ModernistCardConfig forTheme(ModernistCardTheme theme) {
    switch (theme) {
      case ModernistCardTheme.streamingCinematic:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFF1E1418), primaryGraphicColor: Color(0xFFE50914),
          secondaryGraphicColor: Color(0xFFFF5252), textColor: Color(0xFFFFFFFF),
          badgeColor: Color(0xFFE50914), networkBadgeText: 'STREAMING',
        );
      case ModernistCardTheme.audioEmerald:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFF7CB88D), primaryGraphicColor: Color(0xFF183820),
          secondaryGraphicColor: Color(0xFF67A578), textColor: Color(0xFF0F2615),
          badgeColor: Color(0xFF0F2615), networkBadgeText: 'AUDIO',
        );
      case ModernistCardTheme.utilitiesLemon:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFFF3F76E), primaryGraphicColor: Color(0xFFE2E658),
          secondaryGraphicColor: Color(0xFF20221A), textColor: Color(0xFF1A1C16),
          badgeColor: Color(0xFF1A1C16), networkBadgeText: 'UTILITY',
        );
      case ModernistCardTheme.fiberInternet:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFF9EACF0), primaryGraphicColor: Color(0xFF1E2856),
          secondaryGraphicColor: Color(0xFF8697E6), textColor: Color(0xFF151C3E),
          badgeColor: Color(0xFF151C3E), networkBadgeText: 'INTERNET',
        );
      case ModernistCardTheme.aiCloudProductivity:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFFE5E3DC), primaryGraphicColor: Color(0xFFE84E38),
          secondaryGraphicColor: Color(0xFFE84E38), textColor: Color(0xFF181A1E),
          badgeColor: Color(0xFF181A1E), networkBadgeText: 'PRO CLOUD',
        );
      case ModernistCardTheme.housingLiving:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFF56626A), primaryGraphicColor: Color(0xFF455057),
          secondaryGraphicColor: Color(0xFF75838B), textColor: Color(0xFFFFFFFF),
          badgeColor: Color(0xFFFFFFFF), networkBadgeText: 'HOUSING',
        );
      case ModernistCardTheme.fitnessLifestyle:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFFF0715B), primaryGraphicColor: Color(0xFFE05640),
          secondaryGraphicColor: Color(0xFFF89280), textColor: Color(0xFFFFFFFF),
          badgeColor: Color(0xFFFFFFFF), networkBadgeText: 'FITNESS',
        );
      case ModernistCardTheme.recurringSmartBill:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFFDDD9D0), primaryGraphicColor: Color(0xFF333333),
          secondaryGraphicColor: Color(0xFF555555), textColor: Color(0xFF222222),
          badgeColor: Color(0xFF222222), networkBadgeText: 'RECURRING',
        );
      case ModernistCardTheme.tokyoMidnight:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFF0D1326), primaryGraphicColor: Color(0xFF3B82F6),
          secondaryGraphicColor: Color(0xFF60A5FA), textColor: Color(0xFFE2E8F0),
          badgeColor: Color(0xFF3B82F6), networkBadgeText: 'MIDNIGHT',
        );
      case ModernistCardTheme.solarAmber:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFFF59E0B), primaryGraphicColor: Color(0xFFB45309),
          secondaryGraphicColor: Color(0xFFFDE68A), textColor: Color(0xFF451A03),
          badgeColor: Color(0xFF78350F), networkBadgeText: 'SOLAR',
        );
      case ModernistCardTheme.arcticGlacier:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFFE0F2FE), primaryGraphicColor: Color(0xFF0284C7),
          secondaryGraphicColor: Color(0xFFBAE6FD), textColor: Color(0xFF0C4A6E),
          badgeColor: Color(0xFF0369A1), networkBadgeText: 'GLACIER',
        );
      case ModernistCardTheme.cyberNeon:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFF1E1035), primaryGraphicColor: Color(0xFFEC4899),
          secondaryGraphicColor: Color(0xFF06B6D4), textColor: Color(0xFFFDF4FF),
          badgeColor: Color(0xFFEC4899), networkBadgeText: 'CYBER',
        );
      case ModernistCardTheme.matchaZen:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFFD1E7D0), primaryGraphicColor: Color(0xFF3B6E44),
          secondaryGraphicColor: Color(0xFFA3D1A5), textColor: Color(0xFF1B3821),
          badgeColor: Color(0xFF2E5936), networkBadgeText: 'MATCHA',
        );
      case ModernistCardTheme.terracottaSunset:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFF993D29), primaryGraphicColor: Color(0xFFFDBA74),
          secondaryGraphicColor: Color(0xFFEA580C), textColor: Color(0xFFFFF7ED),
          badgeColor: Color(0xFFFDBA74), networkBadgeText: 'SUNSET',
        );
      case ModernistCardTheme.monochromeStark:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFF18181B), primaryGraphicColor: Color(0xFFFAFAFA),
          secondaryGraphicColor: Color(0xFF71717A), textColor: Color(0xFFFAFAFA),
          badgeColor: Color(0xFFFAFAFA), networkBadgeText: 'BAUHAUS',
        );
      case ModernistCardTheme.lavenderDusk:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFFDDD6FE), primaryGraphicColor: Color(0xFF6D28D9),
          secondaryGraphicColor: Color(0xFFC4B5FD), textColor: Color(0xFF3B0764),
          badgeColor: Color(0xFF5B21B6), networkBadgeText: 'LAVENDER',
        );
      case ModernistCardTheme.cobaltVault:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFF1D4ED8), primaryGraphicColor: Color(0xFF93C5FD),
          secondaryGraphicColor: Color(0xFF3B82F6), textColor: Color(0xFFEFF6FF),
          badgeColor: Color(0xFFDBEAFE), networkBadgeText: 'COBALT',
        );
      case ModernistCardTheme.blushPop:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFFFCE7F3), primaryGraphicColor: Color(0xFFDB2777),
          secondaryGraphicColor: Color(0xFFF472B6), textColor: Color(0xFF831843),
          badgeColor: Color(0xFFBE185D), networkBadgeText: 'BLUSH',
        );
      case ModernistCardTheme.nordicPine:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFF143026), primaryGraphicColor: Color(0xFF34D399),
          secondaryGraphicColor: Color(0xFF059669), textColor: Color(0xFFECFDF5),
          badgeColor: Color(0xFF10B981), networkBadgeText: 'NORDIC',
        );
      case ModernistCardTheme.copperPatina:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFF78350F), primaryGraphicColor: Color(0xFFF59E0B),
          secondaryGraphicColor: Color(0xFF2DD4BF), textColor: Color(0xFFFEF3C7),
          badgeColor: Color(0xFFF59E0B), networkBadgeText: 'COPPER',
        );
    }
  }
}
