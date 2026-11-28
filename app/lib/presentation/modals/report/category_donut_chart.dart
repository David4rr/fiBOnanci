import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/formatters/app_currency.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';
import 'category_donut_painter.dart';

class UnifiedDonutSlice {
  final String categoryId;
  final String name;
  final double amount;
  final double percentage;
  final int txCount;
  final bool isIncome;
  final Color color;

  const UnifiedDonutSlice({
    required this.categoryId,
    required this.name,
    required this.amount,
    required this.percentage,
    required this.txCount,
    required this.isIncome,
    required this.color,
  });
}

class CategoryDonutChart extends StatelessWidget {
  final List<UnifiedDonutSlice> slices;
  final double centerTotal;
  final String centerLabel;
  final String centerSublabel;
  final Color? centerSublabelColor;
  final int? selectedIndex;
  final ValueChanged<int?> onSelectIndex;

  const CategoryDonutChart({
    super.key,
    required this.slices,
    required this.centerTotal,
    required this.centerLabel,
    required this.centerSublabel,
    this.centerSublabelColor,
    required this.selectedIndex,
    required this.onSelectIndex,
  });

  static const _incomePalette = [AppColors.neoMint, AppColors.neoCyan, AppColors.neoChartreuse];
  static const _expensePalette = [
    Color(0xFFF59E0B),
    Color(0xFFA855F7),
    Color(0xFF38BDF8),
    Color(0xFF84CC16),
    Color(0xFF6366F1),
    AppColors.neoCoral,
    Color(0xFFEC4899),
  ];

  static Color resolveSliceColor(String hex, bool isIncome, int index) {
    if (isIncome) return _incomePalette[index % _incomePalette.length];
    final cleaned = hex.replaceAll('#', '');
    if (cleaned.length == 6) {
      final v = int.tryParse('FF$cleaned', radix: 16);
      if (v != null && cleaned.toUpperCase() != '64748B' && cleaned.toUpperCase() != '10B981') {
        return Color(v);
      }
    }
    return _expensePalette[index % _expensePalette.length];
  }

  void _handleTapDown(TapDownDetails details, Size size) {
    final totalSliceSum = slices.fold<double>(0.0, (s, e) => s + e.amount);
    if (slices.isEmpty || totalSliceSum <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final dx = details.localPosition.dx - center.dx;
    final dy = details.localPosition.dy - center.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    final outerR = math.min(size.width, size.height) / 2;
    if (dist < outerR * 0.42 || dist > outerR * 1.05) {
      onSelectIndex(null);
      return;
    }
    double angle = math.atan2(dy, dx) + math.pi / 2;
    if (angle < 0) angle += 2 * math.pi;

    double cumulative = 0.0;
    for (int i = 0; i < slices.length; i++) {
      final sweep = (slices[i].amount / totalSliceSum) * 2 * math.pi;
      if (angle >= cumulative && angle <= cumulative + sweep) {
        onSelectIndex(selectedIndex == i ? null : i);
        return;
      }
      cumulative += sweep;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = AppCurrency.of(context);
    final totalSliceSum = slices.fold<double>(0.0, (s, e) => s + e.amount);
    final activeIdx = (selectedIndex != null && selectedIndex! < slices.length) ? selectedIndex : null;
    final selected = activeIdx != null ? slices[activeIdx] : null;
    final targetAmount = selected?.amount ?? centerTotal;

    return SizedBox(
      height: 224,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, 224);
          return GestureDetector(
            key: const Key('category_donut_chart'),
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _handleTapDown(d, size),
            child: TweenAnimationBuilder<double>(
              key: ValueKey('${totalSliceSum.toStringAsFixed(0)}_${slices.length}_$centerLabel'),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 620),
              curve: Curves.easeOutCubic,
              builder: (context, progress, child) => CustomPaint(
                size: size,
                painter: DonutRingPainter(
                  slices: slices,
                  totalSliceSum: totalSliceSum,
                  progress: progress,
                  selectedIndex: activeIdx,
                ),
                child: child,
              ),
              child: Center(
                child: SizedBox(
                  width: 146,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected != null) ...[
                        Text(
                          selected.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 2),
                      ],
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: AnimatedCountingText(
                          value: targetAmount,
                          formatter: (v) => fmt.format(v),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textWhite,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        selected != null
                            ? '${selected.percentage.toStringAsFixed(1)}% • ${selected.txCount}x'
                            : centerSublabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: selected?.color ?? centerSublabelColor ?? AppColors.textMuted,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
