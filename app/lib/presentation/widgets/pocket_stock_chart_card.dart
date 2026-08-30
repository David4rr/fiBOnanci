import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../data/database/app_database.dart';
import '../../domain/services/cashflow_analytics_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Compact, minimalist stock-like chart card representing total pocket balance trajectory.
/// Reflects deposits (upward trajectory) and withdrawals (downward trajectory) with
/// 1-week, 1-month, 1-year, and all-time time range filters.
class PocketStockChartCard extends StatefulWidget {
  final double currentTotal;
  final int pocketsCount;
  final List<TransactionEntry> transactions;

  const PocketStockChartCard({
    super.key,
    required this.currentTotal,
    required this.pocketsCount,
    required this.transactions,
  });

  @override
  State<PocketStockChartCard> createState() => _PocketStockChartCardState();
}

class _PocketStockChartCardState extends State<PocketStockChartCard> with SingleTickerProviderStateMixin {
  String _selectedFilter = '1M';
  int? _scrubbedIndex;
  late AnimationController _animController;
  late Animation<double> _animProgress;

  static final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static const _filters = ['1M', '1B', '1T', 'Semua'];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _animProgress = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant PocketStockChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentTotal != widget.currentTotal ||
        oldWidget.transactions.length != widget.transactions.length) {
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onFilterChanged(String filter) {
    if (_selectedFilter == filter) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedFilter = filter;
      _scrubbedIndex = null;
    });
    _animController.forward(from: 0.0);
  }

  void _handleTouch(Offset localPosition, double width, int count) {
    if (count <= 0 || width <= 0) return;
    final dx = count > 1 ? width / (count - 1) : width;
    final nearest = (localPosition.dx / dx).round().clamp(0, count - 1);
    if (_scrubbedIndex != nearest) {
      HapticFeedback.selectionClick();
      setState(() => _scrubbedIndex = nearest);
    }
  }

  void _clearTouch() {
    if (_scrubbedIndex != null) {
      setState(() => _scrubbedIndex = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trend = CashflowAnalyticsService.computePocketTrendSeries(
      currentTotal: widget.currentTotal,
      transactions: widget.transactions,
      filter: _selectedFilter,
    );

    final values = trend.values;
    final isUpward = trend.isUpward;
    final themeColor = isUpward ? AppColors.neoMint : AppColors.neoCoral;

    final double displayBalance = (_scrubbedIndex != null && _scrubbedIndex! < values.length)
        ? values[_scrubbedIndex!]
        : trend.currentBalance;

    final String? scrubbedLabel = (_scrubbedIndex != null && _scrubbedIndex! < trend.labels.length)
        ? (trend.labels[_scrubbedIndex!].isNotEmpty ? trend.labels[_scrubbedIndex!] : null)
        : null;

    final delta = trend.delta;
    final pct = trend.percentChange;
    final String deltaSign = delta >= 0 ? '+' : '';
    final String deltaFormatted = '$deltaSign${_currencyFormatter.format(delta)}';
    final String pctFormatted = '$deltaSign${pct.toStringAsFixed(1)}%';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.canvasCardSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.canvasBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Header (Left: Metric & Subtitle, Right: Filter Pills)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Title, Balance & Stock Trend Delta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL DANA TERKUMPUL',
                      style: AppTypography.badgeLabel.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 9.5,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currencyFormatter.format(displayBalance),
                      style: GoogleFonts.plusJakartaSans(
                        color: themeColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Delta or Scrubbing Label
                    if (_scrubbedIndex != null)
                      Text(
                        scrubbedLabel != null ? 'Titik: $scrubbedLabel' : 'Titik pantau',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textWhite.withValues(alpha: 0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: themeColor.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isUpward ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                                  color: themeColor,
                                  size: 11,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  pctFormatted,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: themeColor,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '$deltaFormatted (${widget.pocketsCount} kantong)',
                              style: AppTypography.listSubtitle.copyWith(fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Right: Ultra-Compact Stock Filter Pills
              Container(
                decoration: BoxDecoration(
                  color: AppColors.canvasBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.canvasBorder),
                ),
                padding: const EdgeInsets.all(2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _onFilterChanged(filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: isSelected ? themeColor.withValues(alpha: 0.18) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          filter,
                          style: GoogleFonts.plusJakartaSans(
                            color: isSelected ? themeColor : AppColors.textMuted,
                            fontSize: 10.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Row 2: Stock Spline Chart
          SizedBox(
            height: 90,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragStart: (details) =>
                      _handleTouch(details.localPosition, width, values.length),
                  onHorizontalDragUpdate: (details) =>
                      _handleTouch(details.localPosition, width, values.length),
                  onHorizontalDragEnd: (_) => _clearTouch(),
                  onTapDown: (details) =>
                      _handleTouch(details.localPosition, width, values.length),
                  onTapUp: (_) {
                    Future.delayed(const Duration(milliseconds: 1500), () {
                      if (mounted) _clearTouch();
                    });
                  },
                  child: AnimatedBuilder(
                    animation: _animProgress,
                    builder: (context, _) {
                      return CustomPaint(
                        size: Size(width, 90),
                        painter: _PocketSplinePainter(
                          values: values,
                          labels: trend.labels,
                          lineColor: themeColor,
                          touchedIndex: _scrubbedIndex,
                          progress: _animProgress.value,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PocketSplinePainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color lineColor;
  final int? touchedIndex;
  final double progress;

  _PocketSplinePainter({
    required this.values,
    required this.labels,
    required this.lineColor,
    this.touchedIndex,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const bottomLabelHeight = 16.0;
    final chartHeight = size.height - bottomLabelHeight;
    if (chartHeight <= 0 || values.isEmpty) return;

    final n = values.length;
    final double minVal = values.reduce(math.min);
    final double maxVal = values.reduce(math.max);

    const topPad = 8.0;
    const bottomPad = 6.0;
    final plotH = chartHeight - topPad - bottomPad;
    final dx = n > 1 ? size.width / (n - 1) : size.width;

    // Calculate Points
    final points = _calcPoints(values, n, dx, minVal, maxVal, topPad, plotH, size.width);

    // Draw Scrubbing Vertical Crosshair Guide
    if (touchedIndex != null && touchedIndex! < n) {
      final scrubX = points[touchedIndex!].dx;
      final guidePaint = Paint()
        ..color = AppColors.canvasBorder
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(scrubX, 0), Offset(scrubX, chartHeight), guidePaint);
    }

    // Draw Cubic Spline Curve & Gradient Fill
    _drawSplineCurve(canvas, points, chartHeight, lineColor, activeIndex: touchedIndex);

    // Draw Minimalist Date Axis Labels
    _drawLabels(canvas, size, points, bottomLabelHeight);
  }

  List<Offset> _calcPoints(
    List<double> vals,
    int n,
    double dx,
    double minVal,
    double maxVal,
    double topPad,
    double plotH,
    double totalWidth,
  ) {
    final List<Offset> points = [];
    final bool isFlat = (maxVal - minVal) == 0;
    final double range = isFlat ? 1.0 : (maxVal - minVal);

    for (int i = 0; i < n; i++) {
      final v = vals[i];
      final norm = isFlat ? 0.5 : ((v - minVal) / range).clamp(0.0, 1.0);
      final x = n > 1 ? i * dx : totalWidth / 2;
      final baseTargetY = topPad + (1.0 - norm) * plotH;
      final y = plotH + topPad - ((plotH + topPad - baseTargetY) * progress);
      points.add(Offset(x, y));
    }
    return points;
  }

  void _drawSplineCurve(
    Canvas canvas,
    List<Offset> points,
    double chartHeight,
    Color color, {
    int? activeIndex,
  }) {
    if (points.isEmpty) return;

    final path = Path();
    final fillPath = Path();

    path.moveTo(points[0].dx, points[0].dy);
    fillPath.moveTo(points[0].dx, chartHeight);
    fillPath.lineTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];

      final controlX = (p0.dx + p1.dx) / 2;
      path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
      fillPath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    fillPath.lineTo(points.last.dx, chartHeight);
    fillPath.close();

    // 1. Subtle Gradient Area Fill
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withValues(alpha: 0.24 * progress),
        color.withValues(alpha: 0.01),
      ],
    );
    final fillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, points.last.dx, chartHeight))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // 2. Main Spline Stroke
    final strokePaint = Paint()
      ..color = color.withValues(alpha: 0.95)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    // 3. Glowing Active/End Dot
    final targetIndex = activeIndex ?? (points.length - 1);
    if (targetIndex < points.length) {
      final activePoint = points[targetIndex];

      // Outer glow
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(activePoint, 6.0, glowPaint);

      // Inner dot
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(activePoint, 3.2, dotPaint);

      final innerWhite = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(activePoint, 1.4, innerWhite);
    }
  }

  void _drawLabels(Canvas canvas, Size size, List<Offset> points, double labelHeight) {
    if (labels.isEmpty) return;

    for (int i = 0; i < labels.length && i < points.length; i++) {
      final label = labels[i];
      if (label.isEmpty) continue;

      final textSpan = TextSpan(
        text: label,
        style: GoogleFonts.plusJakartaSans(
          color: AppColors.textMuted,
          fontSize: 9.0,
          fontWeight: FontWeight.w600,
        ),
      );
      final tp = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final x = (points[i].dx - tp.width / 2).clamp(0.0, size.width - tp.width);
      final y = size.height - labelHeight + 2;
      tp.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant _PocketSplinePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.touchedIndex != touchedIndex ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.values != values;
  }
}
