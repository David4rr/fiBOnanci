import 'package:flutter/material.dart';
import 'modernist_card_theme.dart';
import 'painters/modernist_painters_ambient.dart';
import 'painters/modernist_painters_base.dart';
import 'painters/modernist_painters_geometric.dart';

export 'contactless_painter.dart';
export 'modernist_card_theme.dart';

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
        ModernistPaintersBase.paintTerracottaDisks(canvas, size, primaryColor);
        break;
      case ModernistCardTheme.audioEmerald:
        ModernistPaintersBase.paintSageHatching(canvas, size, primaryColor);
        break;
      case ModernistCardTheme.fiberInternet:
        ModernistPaintersBase.paintPeriwinkleOvals(canvas, size, primaryColor);
        break;
      case ModernistCardTheme.utilitiesLemon:
        ModernistPaintersBase.paintNeonSunburst(canvas, size);
        break;
      case ModernistCardTheme.recurringSmartBill:
        ModernistPaintersBase.paintOatmealWaves(canvas, size, primaryColor);
        break;
      case ModernistCardTheme.streamingCinematic:
      case ModernistCardTheme.housingLiving:
        ModernistPaintersBase.paintGeometricCurves(canvas, size, primaryColor);
        break;
      case ModernistCardTheme.tokyoMidnight:
        ModernistPaintersAmbient.paintTokyoMidnight(canvas, size, primaryColor, secondaryColor);
        break;
      case ModernistCardTheme.solarAmber:
        ModernistPaintersAmbient.paintSolarAmber(canvas, size, primaryColor, secondaryColor);
        break;
      case ModernistCardTheme.arcticGlacier:
        ModernistPaintersAmbient.paintArcticGlacier(canvas, size, primaryColor, secondaryColor);
        break;
      case ModernistCardTheme.cyberNeon:
        ModernistPaintersAmbient.paintCyberNeon(canvas, size, primaryColor, secondaryColor);
        break;
      case ModernistCardTheme.matchaZen:
        ModernistPaintersAmbient.paintMatchaZen(canvas, size, primaryColor, secondaryColor);
        break;
      case ModernistCardTheme.terracottaSunset:
        ModernistPaintersAmbient.paintTerracottaSunset(canvas, size, primaryColor, secondaryColor);
        break;
      case ModernistCardTheme.monochromeStark:
        ModernistPaintersGeometric.paintMonochromeStark(canvas, size, primaryColor, secondaryColor);
        break;
      case ModernistCardTheme.lavenderDusk:
        ModernistPaintersGeometric.paintLavenderDusk(canvas, size, primaryColor, secondaryColor);
        break;
      case ModernistCardTheme.cobaltVault:
        ModernistPaintersGeometric.paintCobaltVault(canvas, size, primaryColor, secondaryColor);
        break;
      case ModernistCardTheme.blushPop:
        ModernistPaintersGeometric.paintBlushPop(canvas, size, primaryColor, secondaryColor);
        break;
      case ModernistCardTheme.nordicPine:
        ModernistPaintersGeometric.paintNordicPine(canvas, size, primaryColor);
        break;
      case ModernistCardTheme.copperPatina:
        ModernistPaintersGeometric.paintCopperPatina(canvas, size, primaryColor, secondaryColor);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant ModernistCardPainter oldDelegate) {
    return oldDelegate.theme != theme || oldDelegate.primaryColor != primaryColor;
  }
}
