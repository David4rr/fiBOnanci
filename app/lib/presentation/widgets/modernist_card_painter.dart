import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Preset theme for the Swiss-editorial modernist cards in ref1.jpg
enum ModernistCardTheme {
  // Base 8 themes (kept as base)
  streamingCinematic,   // Dark Obsidian Crimson with bold curves (Netflix, Disney, HBO, YouTube)
  audioEmerald,         // Neo Mint / Emerald with soundwave geometry (Spotify, Apple Music, Tidal)
  utilitiesLemon,       // Acid Neon Lemon with energy sunburst (PLN, PDAM, BPJS, Pajak)
  fiberInternet,        // Periwinkle Lavender with fiber concentric ovals (Indihome, Biznet, Telkomsel, Wifi)
  aiCloudProductivity,  // Bone Warm Grey with 3 terracotta disks (ChatGPT, GitHub, iCloud, Google One, Notion)
  housingLiving,        // Slate Charcoal with architectural lines (Kost, Sewa, Apartemen, Cicilan)
  fitnessLifestyle,     // Hot Coral Terracotta with dynamic arcs (Gym, Fitness, Club)
  recurringSmartBill,   // Oatmeal Sand with geometric waves (Default / General subscriptions)

  // Expanded curated themes
  tokyoMidnight,        // Deep Japanese Indigo with cobalt cyber lines & star grid
  solarAmber,           // Radiant Warm Amber with solar corona orbits
  arcticGlacier,        // Frosted Ice Cyan with crystalline prism facets
  cyberNeon,            // Cyberpunk Ultra Violet with neon magenta curves
  matchaZen,            // Japanese Matcha with organic zen pebble silhouettes
  terracottaSunset,     // Burnt Terracotta with dusk horizon semicircles
  monochromeStark,      // Swiss Stark Black with high-contrast Bauhaus diagonal
  lavenderDusk,         // Soft Lilac Dusk with dual celestial eclipse spheres
  cobaltVault,          // Electric Royal Cobalt with precision vault crosshair
  blushPop,             // Neo-Pastel Rose with retro pill geometry
  nordicPine,           // Deep Scandinavian Pine with topographic isolines
  copperPatina,         // Industrial Burnished Copper with brushed diagonals
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
          backgroundColor: Color(0xFF1E1418), // Cinematic dark obsidian crimson
          primaryGraphicColor: Color(0xFFE50914), // Netflix red arc
          secondaryGraphicColor: Color(0xFFFF5252),
          textColor: Color(0xFFFFFFFF),
          badgeColor: Color(0xFFE50914),
          networkBadgeText: 'STREAMING',
        );
      case ModernistCardTheme.audioEmerald:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFF7CB88D), // Emerald sage
          primaryGraphicColor: Color(0xFF183820),
          secondaryGraphicColor: Color(0xFF67A578),
          textColor: Color(0xFF0F2615),
          badgeColor: Color(0xFF0F2615),
          networkBadgeText: 'AUDIO',
        );
      case ModernistCardTheme.utilitiesLemon:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFFF3F76E), // Acid neon lemon
          primaryGraphicColor: Color(0xFFE2E658),
          secondaryGraphicColor: Color(0xFF20221A),
          textColor: Color(0xFF1A1C16),
          badgeColor: Color(0xFF1A1C16),
          networkBadgeText: 'UTILITY',
        );
      case ModernistCardTheme.fiberInternet:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFF9EACF0), // Periwinkle fiber
          primaryGraphicColor: Color(0xFF1E2856),
          secondaryGraphicColor: Color(0xFF8697E6),
          textColor: Color(0xFF151C3E),
          badgeColor: Color(0xFF151C3E),
          networkBadgeText: 'INTERNET',
        );
      case ModernistCardTheme.aiCloudProductivity:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFFE5E3DC), // Bone warm grey
          primaryGraphicColor: Color(0xFFE84E38), // Terracotta
          secondaryGraphicColor: Color(0xFFE84E38),
          textColor: Color(0xFF181A1E),
          badgeColor: Color(0xFF181A1E),
          networkBadgeText: 'PRO CLOUD',
        );
      case ModernistCardTheme.housingLiving:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFF56626A), // Slate charcoal
          primaryGraphicColor: Color(0xFF455057),
          secondaryGraphicColor: Color(0xFF75838B),
          textColor: Color(0xFFFFFFFF),
          badgeColor: Color(0xFFFFFFFF),
          networkBadgeText: 'HOUSING',
        );
      case ModernistCardTheme.fitnessLifestyle:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFFFF5252), // Hot coral
          primaryGraphicColor: Color(0xFFE03838),
          secondaryGraphicColor: Color(0xFFFF7A7A),
          textColor: Color(0xFFFFFFFF),
          badgeColor: Color(0xFFFFFFFF),
          networkBadgeText: 'FITNESS',
        );
      case ModernistCardTheme.recurringSmartBill:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFFE0D8C6), // Oatmeal sand
          primaryGraphicColor: Color(0xFFC7BC9E),
          secondaryGraphicColor: Color(0xFF4A4438),
          textColor: Color(0xFF2C2720),
          badgeColor: Color(0xFF2C2720),
          networkBadgeText: 'RECURRING',
        );
      case ModernistCardTheme.tokyoMidnight:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFF0D1424), // Midnight navy/indigo
          primaryGraphicColor: Color(0xFF3B82F6), // Cobalt blue
          secondaryGraphicColor: Color(0xFF60A5FA), // Sky accent
          textColor: Color(0xFFF1F5F9), // Crisp ice white
          badgeColor: Color(0xFF3B82F6),
          networkBadgeText: 'MIDNIGHT',
        );
      case ModernistCardTheme.solarAmber:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFFF59E0B), // Radiant amber
          primaryGraphicColor: Color(0xFFB45309), // Deep amber stroke
          secondaryGraphicColor: Color(0xFFFDE68A), // Warm light ring
          textColor: Color(0xFF1C1304), // Deep charcoal
          badgeColor: Color(0xFF1C1304),
          networkBadgeText: 'SOLAR',
        );
      case ModernistCardTheme.arcticGlacier:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFFBAE6FD), // Glacier cyan
          primaryGraphicColor: Color(0xFF0369A1), // Deep cyan
          secondaryGraphicColor: Color(0xFFE0F2FE), // Frost white
          textColor: Color(0xFF0C243C), // Navy slate
          badgeColor: Color(0xFF0C243C),
          networkBadgeText: 'GLACIER',
        );
      case ModernistCardTheme.cyberNeon:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFF1E1035), // Deep cyber violet
          primaryGraphicColor: Color(0xFFEC4899), // Neon magenta
          secondaryGraphicColor: Color(0xFF06B6D4), // Electric cyan
          textColor: Color(0xFFFFFFFF), // Pure white
          badgeColor: Color(0xFFEC4899),
          networkBadgeText: 'CYBER',
        );
      case ModernistCardTheme.matchaZen:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFF8A9A5B), // Warm matcha green
          primaryGraphicColor: Color(0xFF283618), // Deep olive/forest
          secondaryGraphicColor: Color(0xFFDDA15E), // Earthy accent
          textColor: Color(0xFF19220F), // Dark olive
          badgeColor: Color(0xFF19220F),
          networkBadgeText: 'MATCHA',
        );
      case ModernistCardTheme.terracottaSunset:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFFC2410C), // Burnt terracotta orange
          primaryGraphicColor: Color(0xFF7C2D12), // Deep rust
          secondaryGraphicColor: Color(0xFFFDBA74), // Sunset apricot
          textColor: Color(0xFFFFFFFF), // White
          badgeColor: Color(0xFFFFFFFF),
          networkBadgeText: 'TERRA',
        );
      case ModernistCardTheme.monochromeStark:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFF111114), // Swiss matte black
          primaryGraphicColor: Color(0xFFE4E4E7), // Bauhaus stark white
          secondaryGraphicColor: Color(0xFF3F3F46), // Graphite
          textColor: Color(0xFFFFFFFF), // White
          badgeColor: Color(0xFFFFFFFF),
          networkBadgeText: 'STARK',
        );
      case ModernistCardTheme.lavenderDusk:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFFDDD6FE), // Soft lavender orchid
          primaryGraphicColor: Color(0xFF5B21B6), // Deep purple
          secondaryGraphicColor: Color(0xFF8B5CF6), // Vibrant lilac
          textColor: Color(0xFF2E1065), // Deep plum
          badgeColor: Color(0xFF2E1065),
          networkBadgeText: 'LAVENDER',
        );
      case ModernistCardTheme.cobaltVault:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFF1D4ED8), // Electric Royal Cobalt
          primaryGraphicColor: Color(0xFF1E3A8A), // Navy
          secondaryGraphicColor: Color(0xFF93C5FD), // Bright ice
          textColor: Color(0xFFFFFFFF), // White
          badgeColor: Color(0xFFFFFFFF),
          networkBadgeText: 'COBALT',
        );
      case ModernistCardTheme.blushPop:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFFF472B6), // Neo-pastel blush pink
          primaryGraphicColor: Color(0xFF9D174D), // Rich crimson
          secondaryGraphicColor: Color(0xFFFBCFE8), // Soft rose
          textColor: Color(0xFF500724), // Dark berry
          badgeColor: Color(0xFF500724),
          networkBadgeText: 'BLUSH',
        );
      case ModernistCardTheme.nordicPine:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFF14281D), // Nordic deep pine
          primaryGraphicColor: Color(0xFF10B981), // Neo mint
          secondaryGraphicColor: Color(0xFF047857), // Forest
          textColor: Color(0xFFECFDF5), // Mint white
          badgeColor: Color(0xFF10B981),
          networkBadgeText: 'NORDIC',
        );
      case ModernistCardTheme.copperPatina:
        return const ModernistCardConfig(
          backgroundColor: Color(0xFF9A3412), // Warm burnished copper
          primaryGraphicColor: Color(0xFFB45309), // Amber gold
          secondaryGraphicColor: Color(0xFFFDE68A), // Gilded shine
          textColor: Color(0xFFFFFBEB), // Warm cream
          badgeColor: Color(0xFFFFFBEB),
          networkBadgeText: 'COPPER',
        );
    }
  }
}
/// Custom painter for the abstract modernist graphics in ref1.jpg
class ModernistCardPainter extends CustomPainter {
  final ModernistCardTheme theme;
  final Color primaryColor;
  final Color secondaryColor;

  ModernistCardPainter({
    required this.theme,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (theme) {
      case ModernistCardTheme.aiCloudProductivity:
      case ModernistCardTheme.fitnessLifestyle:
        _paintTerracottaDisks(canvas, size);
        break;
      case ModernistCardTheme.audioEmerald:
        _paintSageHatching(canvas, size);
        break;
      case ModernistCardTheme.fiberInternet:
        _paintPeriwinkleOvals(canvas, size);
        break;
      case ModernistCardTheme.utilitiesLemon:
        _paintNeonSunburst(canvas, size);
        break;
      case ModernistCardTheme.recurringSmartBill:
        _paintOatmealWaves(canvas, size);
        break;
      case ModernistCardTheme.streamingCinematic:
      case ModernistCardTheme.housingLiving:
        _paintGeometricCurves(canvas, size);
        break;
      case ModernistCardTheme.tokyoMidnight:
        _paintTokyoMidnight(canvas, size);
        break;
      case ModernistCardTheme.solarAmber:
        _paintSolarAmber(canvas, size);
        break;
      case ModernistCardTheme.arcticGlacier:
        _paintArcticGlacier(canvas, size);
        break;
      case ModernistCardTheme.cyberNeon:
        _paintCyberNeon(canvas, size);
        break;
      case ModernistCardTheme.matchaZen:
        _paintMatchaZen(canvas, size);
        break;
      case ModernistCardTheme.terracottaSunset:
        _paintTerracottaSunset(canvas, size);
        break;
      case ModernistCardTheme.monochromeStark:
        _paintMonochromeStark(canvas, size);
        break;
      case ModernistCardTheme.lavenderDusk:
        _paintLavenderDusk(canvas, size);
        break;
      case ModernistCardTheme.cobaltVault:
        _paintCobaltVault(canvas, size);
        break;
      case ModernistCardTheme.blushPop:
        _paintBlushPop(canvas, size);
        break;
      case ModernistCardTheme.nordicPine:
        _paintNordicPine(canvas, size);
        break;
      case ModernistCardTheme.copperPatina:
        _paintCopperPatina(canvas, size);
        break;
    }
  }

  /// 3 iconic red semicircles/disks from ref1.jpg (Mastercard CreditCard)
  void _paintTerracottaDisks(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final centerY = size.height * 0.52;
    final radius = size.height * 0.38;

    // Semicircle 1 (Left, facing right)
    final path1 = Path();
    final center1 = Offset(size.width * 0.28, centerY);
    path1.arcTo(
      Rect.fromCircle(center: center1, radius: radius),
      math.pi / 2,
      math.pi,
      false,
    );
    path1.close();
    canvas.drawPath(path1, paint);

    // Semicircle 2 (Middle, facing right)
    final path2 = Path();
    final center2 = Offset(size.width * 0.50, centerY);
    path2.arcTo(
      Rect.fromCircle(center: center2, radius: radius),
      math.pi / 2,
      math.pi,
      false,
    );
    path2.close();
    canvas.drawPath(path2, paint);

    // Full Circle 3 (Right)
    final center3 = Offset(size.width * 0.74, centerY);
    canvas.drawCircle(center3, radius, paint);
  }

  /// Diagonal hatching pattern from ref1.jpg (Sage DebitCard)
  void _paintSageHatching(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withValues(alpha: 0.65)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    const lineCount = 9;
    final startX = size.width * 0.52;
    final startY = size.height * 0.16;
    const length = 46.0;

    for (int i = 0; i < lineCount; i++) {
      final y = startY + i * 4.2;
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + length, y),
        paint,
      );
    }
  }

  /// Concentric modernist oval rings from ref1.jpg (Periwinkle BonusCard)
  void _paintPeriwinkleOvals(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..isAntiAlias = true;

    final center = Offset(size.width * 0.78, size.height * 0.32);
    canvas.drawOval(Rect.fromCenter(center: center, width: 34, height: 26), paint);
    canvas.drawOval(Rect.fromCenter(center: center, width: 18, height: 14), paint);
  }

  /// Sunburst / radial glow for Acid Lemon card
  void _paintNeonSunburst(Canvas canvas, Size size) {
    final sunPaint = Paint()
      ..color = const Color(0xFFFF9E00).withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width * 0.54, size.height * 0.22);
    canvas.drawCircle(center, 12, sunPaint);

    final rayPaint = Paint()
      ..color = const Color(0xFFFF9E00).withValues(alpha: 0.45)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4);
      final p1 = center + Offset(math.cos(angle) * 15, math.sin(angle) * 15);
      final p2 = center + Offset(math.cos(angle) * 22, math.sin(angle) * 22);
      canvas.drawLine(p1, p2, rayPaint);
    }
  }

  /// Waves for Oatmeal card
  void _paintOatmealWaves(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    path.moveTo(size.width * 0.4, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.3, size.width * 0.85, size.height * 0.55);
    canvas.drawPath(path, paint);
  }

  /// Abstract curves for Slate/Coral/Violet
  void _paintGeometricCurves(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.45, 0);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.6, size.width, size.height * 0.4);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  /// Tokyo Midnight: Japanese Indigo laser grid & constellation nodes
  void _paintTokyoMidnight(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.60)
      ..style = PaintingStyle.fill;

    // Perspective rays from top-right
    final focal = Offset(size.width * 0.85, -size.height * 0.2);
    for (int i = 0; i < 6; i++) {
      final target = Offset(size.width * (0.3 + i * 0.15), size.height);
      canvas.drawLine(focal, target, linePaint);
    }

    // Constellation grid dots
    final dots = [
      Offset(size.width * 0.65, size.height * 0.25),
      Offset(size.width * 0.80, size.height * 0.35),
      Offset(size.width * 0.72, size.height * 0.55),
      Offset(size.width * 0.88, size.height * 0.65),
    ];
    for (final d in dots) {
      canvas.drawCircle(d, 2.2, dotPaint);
    }
  }

  /// Solar Amber: Concentric solar corona orbit rings with warm radiant disk
  void _paintSolarAmber(Canvas canvas, Size size) {
    final ringPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.40)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final sunPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width * 0.82, size.height * 0.38);
    canvas.drawCircle(center, 24, sunPaint);
    canvas.drawCircle(center, 44, ringPaint);
    canvas.drawCircle(center, 68, ringPaint..strokeWidth = 1.4);
  }

  /// Arctic Glacier: Crystalline geometric prism facets & angled contour shards
  void _paintArcticGlacier(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.45)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final path1 = Path()
      ..moveTo(size.width * 0.55, 0)
      ..lineTo(size.width * 0.85, 0)
      ..lineTo(size.width * 0.65, size.height * 0.60)
      ..close();
    canvas.drawPath(path1, fillPaint);
    canvas.drawPath(path1, strokePaint);

    final path2 = Path()
      ..moveTo(size.width * 0.70, 0)
      ..lineTo(size.width, size.height * 0.45)
      ..lineTo(size.width * 0.78, size.height * 0.85)
      ..close();
    canvas.drawPath(path2, strokePaint);
  }

  /// Cyber Neon: Intersecting glowing hyper-curved neon arcs
  void _paintCyberNeon(Canvas canvas, Size size) {
    final magentaPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.55)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cyanPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.55)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Arc 1: sweeping from right bottom to top center
    final path1 = Path()
      ..moveTo(size.width * 0.45, 0)
      ..quadraticBezierTo(size.width * 0.60, size.height * 0.65, size.width, size.height * 0.50);
    canvas.drawPath(path1, magentaPaint);

    // Arc 2: counter sweeping curve
    final path2 = Path()
      ..moveTo(size.width * 0.60, 0)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.45, size.width, size.height * 0.85);
    canvas.drawPath(path2, cyanPaint);
  }

  /// Matcha Zen: Organic rounded pebble silhouettes & soothing rings
  void _paintMatchaZen(Canvas canvas, Size size) {
    final pebblePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final ringPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.40)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final center1 = Offset(size.width * 0.78, size.height * 0.32);
    canvas.drawOval(Rect.fromCenter(center: center1, width: 56, height: 38), pebblePaint);
    canvas.drawOval(Rect.fromCenter(center: center1, width: 80, height: 60), ringPaint);

    final center2 = Offset(size.width * 0.62, size.height * 0.62);
    canvas.drawOval(Rect.fromCenter(center: center2, width: 42, height: 28), pebblePaint);
  }

  /// Terracotta Sunset: Modernist dusk horizon arcs & warm semicircles
  void _paintTerracottaSunset(Canvas canvas, Size size) {
    final arcPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.50)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.60)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width * 0.76, size.height * 0.55);
    final path = Path()
      ..arcTo(Rect.fromCircle(center: center, radius: 46), math.pi, math.pi, false)
      ..close();
    canvas.drawPath(path, arcPaint);

    canvas.drawLine(
      Offset(size.width * 0.45, size.height * 0.55),
      Offset(size.width, size.height * 0.55),
      linePaint,
    );
  }

  /// Monochrome Stark: Bold Swiss Bauhaus 45-degree slash & precision micro-grid lines
  void _paintMonochromeStark(Canvas canvas, Size size) {
    final slashPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.20)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.30)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Diagonal Bauhaus polygon
    final path = Path()
      ..moveTo(size.width * 0.65, 0)
      ..lineTo(size.width * 0.90, 0)
      ..lineTo(size.width * 0.50, size.height)
      ..lineTo(size.width * 0.25, size.height)
      ..close();
    canvas.drawPath(path, slashPaint);

    // Precision horizontal grid lines
    for (int i = 0; i < 4; i++) {
      final y = size.height * (0.25 + i * 0.18);
      canvas.drawLine(Offset(size.width * 0.55, y), Offset(size.width * 0.92, y), gridPaint);
    }
  }

  /// Lavender Dusk: Dual celestial eclipse spheres & orbital ellipsis track
  void _paintLavenderDusk(Canvas canvas, Size size) {
    final spherePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.40)
      ..style = PaintingStyle.fill;

    final orbitPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.50)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width * 0.78, size.height * 0.36);
    canvas.drawCircle(center, 22, spherePaint);
    canvas.drawOval(Rect.fromCenter(center: center, width: 90, height: 42), orbitPaint);

    final satellite = Offset(size.width * 0.58, size.height * 0.50);
    canvas.drawCircle(satellite, 12, spherePaint..color = primaryColor.withValues(alpha: 0.25));
  }

  /// Cobalt Vault: Precision vault crosshair with concentric radar rings
  void _paintCobaltVault(Canvas canvas, Size size) {
    final radarPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.45)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width * 0.80, size.height * 0.40);
    canvas.drawCircle(center, 14, fillPaint);
    canvas.drawCircle(center, 32, radarPaint);
    canvas.drawCircle(center, 54, radarPaint);

    // Crosshairs
    canvas.drawLine(Offset(center.dx - 64, center.dy), Offset(center.dx + 64, center.dy), radarPaint);
    canvas.drawLine(Offset(center.dx, center.dy - 64), Offset(center.dx, center.dy + 64), radarPaint);
  }

  /// Blush Pop: Retro neo-pastel pill capsule silhouettes & floating spheres
  void _paintBlushPop(Canvas canvas, Size size) {
    final pillPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final ringPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.60)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(size.width * 0.76, size.height * 0.38), width: 72, height: 34),
      const Radius.circular(17),
    );
    canvas.drawRRect(rect, pillPaint);
    canvas.drawRRect(rect, ringPaint);

    canvas.drawCircle(Offset(size.width * 0.58, size.height * 0.60), 10, pillPaint);
  }

  /// Nordic Pine: Flowing topographic elevation isolines
  void _paintNordicPine(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.45)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    final path1 = Path()
      ..moveTo(w * 0.40, 0)
      ..cubicTo(w * 0.55, h * 0.40, w * 0.75, h * 0.25, w, h * 0.60);
    canvas.drawPath(path1, strokePaint);

    final path2 = Path()
      ..moveTo(w * 0.50, 0)
      ..cubicTo(w * 0.65, h * 0.50, w * 0.85, h * 0.35, w, h * 0.80);
    canvas.drawPath(path2, strokePaint);

    final path3 = Path()
      ..moveTo(w * 0.60, 0)
      ..cubicTo(w * 0.75, h * 0.60, w * 0.92, h * 0.45, w, h);
    canvas.drawPath(path3, strokePaint);
  }

  /// Copper Patina: Industrial 45-degree brushed metallic slashes
  void _paintCopperPatina(Canvas canvas, Size size) {
    final slashPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.45)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final accentPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.40)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final startX = size.width * (0.60 + i * 0.08);
      final startY = size.height * 0.15;
      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX - 28, startY + 46),
        slashPaint,
      );
    }

    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.65), 14, accentPaint);
  }

  @override
  bool shouldRepaint(covariant ModernistCardPainter oldDelegate) {
    return oldDelegate.theme != theme || oldDelegate.primaryColor != primaryColor;
  }
}

/// Contactless payment wave painter (•)))
class ContactlessPainter extends CustomPainter {
  final Color color;

  ContactlessPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final base = Offset(2, size.height / 2);

    // Dot
    canvas.drawCircle(base, 1.4, fillPaint);

    // Wave 1
    canvas.drawArc(
      Rect.fromCircle(center: base, radius: 4.5),
      -math.pi / 4,
      math.pi / 2,
      false,
      paint,
    );

    // Wave 2
    canvas.drawArc(
      Rect.fromCircle(center: base, radius: 8.5),
      -math.pi / 4,
      math.pi / 2,
      false,
      paint,
    );

    // Wave 3
    canvas.drawArc(
      Rect.fromCircle(center: base, radius: 12.5),
      -math.pi / 4,
      math.pi / 2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant ContactlessPainter oldDelegate) => oldDelegate.color != color;
}
