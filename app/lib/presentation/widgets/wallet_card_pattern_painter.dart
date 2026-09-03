import 'package:flutter/material.dart';
import 'painters/wallet_patterns_geometric.dart';
import 'painters/wallet_patterns_organic.dart';

export 'painters/wallet_patterns_geometric.dart';
export 'painters/wallet_patterns_organic.dart';

/// Available procedural card texture patterns.
enum WalletPatternType {
  topographicContours, // Organic elevation lines, Swiss alpine cartography
  bauhausConcentric,   // Modernist overlapping arc rings & discs (Bauhaus/Swiss)
  isometricCircuit,    // Micro-tech 45° cross-hatch & node pathways
  fluidWaveSplines,    // Layered flowing sine curves & liquidity waves
  angularPrismGeom,    // Bold angled facets, diagonal light shards
  constellationMatrix, // Mathematical dot matrix with orbital constellation nodes
}

class WalletPatternHelper {
  /// Deterministically assigns a pattern based on wallet ID string or index.
  static WalletPatternType getPatternForWallet(String walletId, [int? fallbackIndex]) {
    if (walletId.isNotEmpty) {
      final hash = walletId.codeUnits.fold<int>(
        0,
        (prev, elem) => ((prev << 5) - prev + elem) & 0x7FFFFFFF,
      );
      final index = hash % WalletPatternType.values.length;
      return WalletPatternType.values[index];
    }
    return WalletPatternType.values[(fallbackIndex ?? 0) % WalletPatternType.values.length];
  }
}

/// Custom painter rendering tactile, high-end procedural card textures.
class WalletCardPatternPainter extends CustomPainter {
  final WalletPatternType patternType;
  final Color primaryPatternColor;
  final Color secondaryPatternColor;

  const WalletCardPatternPainter({
    required this.patternType,
    required this.primaryPatternColor,
    required this.secondaryPatternColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (patternType) {
      case WalletPatternType.topographicContours:
        WalletPatternsOrganic.paintTopographicContours(canvas, size, primaryPatternColor, secondaryPatternColor);
        break;
      case WalletPatternType.bauhausConcentric:
        WalletPatternsOrganic.paintBauhausConcentric(canvas, size, primaryPatternColor, secondaryPatternColor);
        break;
      case WalletPatternType.fluidWaveSplines:
        WalletPatternsOrganic.paintFluidWaveSplines(canvas, size, primaryPatternColor, secondaryPatternColor);
        break;
      case WalletPatternType.isometricCircuit:
        WalletPatternsGeometric.paintIsometricCircuit(canvas, size, primaryPatternColor, secondaryPatternColor);
        break;
      case WalletPatternType.angularPrismGeom:
        WalletPatternsGeometric.paintAngularPrismGeom(canvas, size, primaryPatternColor, secondaryPatternColor);
        break;
      case WalletPatternType.constellationMatrix:
        WalletPatternsGeometric.paintConstellationMatrix(canvas, size, primaryPatternColor, secondaryPatternColor);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant WalletCardPatternPainter oldDelegate) {
    return oldDelegate.patternType != patternType ||
        oldDelegate.primaryPatternColor != primaryPatternColor ||
        oldDelegate.secondaryPatternColor != secondaryPatternColor;
  }
}
