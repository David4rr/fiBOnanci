import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Preset theme for the Swiss-editorial modernist cards in ref1.jpg
enum ModernistCardTheme {
  streamingCinematic,   // Dark Obsidian Crimson with bold curves (Netflix, Disney, HBO, YouTube)
  audioEmerald,         // Neo Mint / Emerald with soundwave geometry (Spotify, Apple Music, Tidal)
  utilitiesLemon,       // Acid Neon Lemon with energy sunburst (PLN, PDAM, BPJS, Pajak)
  fiberInternet,        // Periwinkle Lavender with fiber concentric ovals (Indihome, Biznet, Telkomsel, Wifi)
  aiCloudProductivity,  // Bone Warm Grey with 3 terracotta disks (ChatGPT, GitHub, iCloud, Google One, Notion)
  housingLiving,        // Slate Charcoal with architectural lines (Kost, Sewa, Apartemen, Cicilan)
  fitnessLifestyle,     // Hot Coral Terracotta with dynamic arcs (Gym, Fitness, Club)
  recurringSmartBill,   // Oatmeal Sand with geometric waves (Default / General subscriptions)
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
