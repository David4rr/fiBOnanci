import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/formatters/app_currency.dart';
import '../../theme/app_colors.dart';

class UnifiedDonutSlice {
  final String categoryId;
  final String name;
  final double amount;
  final double percentage;
  final int txCount;
  final bool isIncome;
  final Color color;

  const UnifiedDonutSlice({required this.categoryId, required this.name, required this.amount, required this.percentage, required this.txCount, required this.isIncome, required this.color});
}

class CategoryDonutChart extends StatelessWidget {
  final List<UnifiedDonutSlice> slices;
  final double totalIncome;
  final double totalExpense;
  final double savingsRate;
  final int? selectedIndex;
  final ValueChanged<int?> onSelectIndex;

  const CategoryDonutChart({
    super.key,
    required this.slices,
    required this.totalIncome,
    required this.totalExpense,
    required this.savingsRate,
    required this.selectedIndex,
    required this.onSelectIndex,
  });
  static const _incomePalette = [AppColors.neoMint, AppColors.neoCyan, AppColors.neoChartreuse];
  static const _expensePalette = [AppColors.neoCoral, Color(0xFFF59E0B), AppColors.neoPurple, Color(0xFFEC4899), Color(0xFFEF4444)];

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
    final totalFlow = totalIncome + totalExpense;
    if (slices.isEmpty || totalFlow <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final dx = details.localPosition.dx - center.dx;
    final dy = details.localPosition.dy - center.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    final outerR = math.min(size.width, size.height) / 2;
    if (dist < outerR * 0.45 || dist > outerR * 1.05) {
      onSelectIndex(null);
      return;
    }
    double angle = math.atan2(dy, dx) + math.pi / 2;
    if (angle < 0) angle += 2 * math.pi;

    double cumulative = 0.0;
    for (int i = 0; i < slices.length; i++) {
      final sweep = (slices[i].amount / totalFlow) * 2 * math.pi;
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
    final totalFlow = totalIncome + totalExpense;
    final activeIdx = (selectedIndex != null && selectedIndex! < slices.length) ? selectedIndex : null;
    final selected = activeIdx != null ? slices[activeIdx] : null;
    final netCashflow = totalIncome - totalExpense;
    final netColor = netCashflow >= 0 ? AppColors.neoMint : AppColors.neoCoral;

    return SizedBox(
      height: 176,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, 176);
          return GestureDetector(
            key: const Key('category_donut_chart'),
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _handleTapDown(d, size),
            child: TweenAnimationBuilder<double>(
              key: ValueKey('${totalFlow}_${slices.length}'),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutCubic,
              builder: (context, progress, child) => CustomPaint(
                size: size,
                painter: _DonutRingPainter(slices: slices, totalFlow: totalFlow, progress: progress, selectedIndex: activeIdx),
                child: child,
              ),
              child: Center(
                child: SizedBox(
                  width: 124,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selected?.name ?? 'Arus Kas Bersih',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selected != null
                            ? '${selected.isIncome ? "+" : "-"}${fmt.format(selected.amount)}'
                            : '${netCashflow > 0 ? "+" : ""}${fmt.format(netCashflow)}',
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textWhite,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        selected != null
                            ? '${selected.percentage.toStringAsFixed(1)}% Arus Kas'
                            : 'Tabungan ${savingsRate.toStringAsFixed(0)}%',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: selected != null ? selected.color : netColor,
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

class _DonutRingPainter extends CustomPainter {
  final List<UnifiedDonutSlice> slices;
  final double totalFlow;
  final double progress;
  final int? selectedIndex;

  const _DonutRingPainter({required this.slices, required this.totalFlow, required this.progress, required this.selectedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = math.min(size.width, size.height) / 2 - 14;
    final trackPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 12..color = Colors.white.withValues(alpha: 0.04);
    canvas.drawCircle(center, baseRadius, trackPaint);
    if (slices.isEmpty || totalFlow <= 0) return;

    final gapRadians = slices.length > 1 ? 0.045 : 0.0;
    double startAngle = -math.pi / 2;
    for (int i = 0; i < slices.length; i++) {
      final item = slices[i];
      final rawSweep = (item.amount / totalFlow) * 2 * math.pi * progress;
      final sweep = math.max(0.01, rawSweep - gapRadians);
      final isSelected = selectedIndex == i;
      final isDimmed = selectedIndex != null && !isSelected;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 16.0 : 12.0
        ..strokeCap = StrokeCap.butt
        ..color = isDimmed ? item.color.withValues(alpha: 0.25) : item.color;
      canvas.drawArc(Rect.fromCircle(center: center, radius: isSelected ? baseRadius + 2.0 : baseRadius), startAngle + gapRadians / 2, sweep, false, paint);
      startAngle += rawSweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutRingPainter old) => old.progress != progress || old.selectedIndex != selectedIndex || old.totalFlow != totalFlow;
}
