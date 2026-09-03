import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'painters/spline_chart_painter.dart';

export 'painters/spline_chart_painter.dart';

/// Lightweight, interactive 30-day spline chart with animated entry & touch scrubbing.
class TrendSplineChart extends StatefulWidget {
  final List<double>? values;
  final List<double>? incomeValues;
  final List<double>? expenseValues;
  final List<String> labels;
  final Color lineColor;
  final String? headline;
  final String? subtitle;
  final double height;

  const TrendSplineChart({
    super.key,
    this.values,
    this.incomeValues,
    this.expenseValues,
    required this.labels,
    this.lineColor = AppColors.neoMint,
    this.headline,
    this.subtitle,
    this.height = 130,
  });

  bool get isDual => incomeValues != null && expenseValues != null;

  @override
  State<TrendSplineChart> createState() => _TrendSplineChartState();
}

class _TrendSplineChartState extends State<TrendSplineChart> {
  int? _touchedIndex;
  static final _currencyFmt = NumberFormat.compactSimpleCurrency(locale: 'id_ID');

  void _handleTouch(Offset localPosition, double width, int count) {
    if (count <= 1 || width <= 0) return;
    final double fraction = (localPosition.dx / width).clamp(0.0, 1.0);
    final int index = (fraction * (count - 1)).round().clamp(0, count - 1);
    if (_touchedIndex != index) setState(() => _touchedIndex = index);
  }

  void _clearTouch() {
    if (_touchedIndex != null) setState(() => _touchedIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    final int count = widget.isDual
        ? math.max(widget.incomeValues!.length, widget.expenseValues!.length)
        : (widget.values?.length ?? 0);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.canvasCardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.canvasBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.headline != null)
                Expanded(
                  child: Text(
                    widget.headline!,
                    style: AppTypography.listTitle.copyWith(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textWhite),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(width: 8),
              if (_touchedIndex != null && _touchedIndex! < count)
                _buildScrubbingBadge(_touchedIndex!)
              else if (widget.isDual)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLegendDot(AppColors.neoMint, 'Masuk'),
                    const SizedBox(width: 10),
                    _buildLegendDot(AppColors.neoCoral, 'Keluar'),
                  ],
                )
              else if (widget.subtitle != null)
                Text(widget.subtitle!, style: AppTypography.badgeLabel.copyWith(color: widget.lineColor, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final chartWidth = constraints.maxWidth;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragDown: (d) => _handleTouch(d.localPosition, chartWidth, count),
                onHorizontalDragUpdate: (d) => _handleTouch(d.localPosition, chartWidth, count),
                onHorizontalDragEnd: (_) => _clearTouch(),
                onHorizontalDragCancel: () => _clearTouch(),
                onTapDown: (d) => _handleTouch(d.localPosition, chartWidth, count),
                onTapUp: (_) => Future.delayed(const Duration(milliseconds: 1200), _clearTouch),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 750),
                  curve: Curves.easeOutCubic,
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, progress, child) {
                    return CustomPaint(
                      size: Size(chartWidth, widget.height),
                      painter: SplineChartPainter(
                        values: widget.values,
                        incomeValues: widget.incomeValues,
                        expenseValues: widget.expenseValues,
                        labels: widget.labels,
                        lineColor: widget.lineColor,
                        touchedIndex: _touchedIndex,
                        progress: progress,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScrubbingBadge(int index) {
    final dateStr = index < widget.labels.length && widget.labels[index].isNotEmpty ? widget.labels[index] : 'H-${30 - index}';

    if (widget.isDual) {
      final inAmt = index < widget.incomeValues!.length ? widget.incomeValues![index] : 0.0;
      final exAmt = index < widget.expenseValues!.length ? widget.expenseValues![index] : 0.0;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.canvasInputSearch,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.canvasBorder, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$dateStr • ', style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
            Text('+${_currencyFmt.format(inAmt)} ', style: const TextStyle(color: AppColors.neoMint, fontSize: 10, fontWeight: FontWeight.bold)),
            Text('-${_currencyFmt.format(exAmt)}', style: const TextStyle(color: AppColors.neoCoral, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    } else {
      final amt = index < widget.values!.length ? widget.values![index] : 0.0;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.canvasInputSearch,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.canvasBorder, width: 0.8),
        ),
        child: Text('$dateStr: ${_currencyFmt.format(amt)}', style: TextStyle(color: widget.lineColor, fontSize: 10, fontWeight: FontWeight.bold)),
      );
    }
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
