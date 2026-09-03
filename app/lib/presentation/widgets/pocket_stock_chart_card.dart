import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../data/database/app_database.dart';
import '../../domain/services/cashflow_analytics_service.dart';
import '../theme/app_colors.dart';
import 'painters/pocket_spline_painter.dart';
import 'pocket_stock_chart_header.dart';

export 'painters/pocket_spline_painter.dart';
export 'pocket_stock_chart_header.dart';

/// Compact, minimalist stock-like chart card representing total pocket balance trajectory.
class PocketStockChartCard extends StatefulWidget {
  final double currentTotal;
  final int pocketsCount;
  final List<TransactionEntry> transactions;
  final DateTime? referenceDate;

  const PocketStockChartCard({
    super.key,
    required this.currentTotal,
    required this.pocketsCount,
    required this.transactions,
    this.referenceDate,
  });

  @override
  State<PocketStockChartCard> createState() => _PocketStockChartCardState();
}

class _PocketStockChartCardState extends State<PocketStockChartCard> with SingleTickerProviderStateMixin {
  String _selectedFilter = '1M';
  int? _scrubbedIndex;
  late AnimationController _animController;
  late Animation<double> _animProgress;

  static final _currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  static const _filters = ['1M', '1B', '1T', 'Semua'];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _animProgress = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
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
    if (_scrubbedIndex != null) setState(() => _scrubbedIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    DateTime? refDate = widget.referenceDate;
    if (refDate == null && widget.transactions.isNotEmpty) {
      final latest = widget.transactions
          .map((t) => t.transactionDate.toLocal())
          .reduce((a, b) => a.isAfter(b) ? a : b);
      if (DateTime.now().difference(latest).inDays.abs() > 4) {
        refDate = latest;
      }
    }

    final trend = CashflowAnalyticsService.computePocketTrendSeries(
      currentTotal: widget.currentTotal,
      transactions: widget.transactions,
      filter: _selectedFilter,
      referenceDate: refDate,
    );

    final values = trend.values;
    final isUpward = trend.isUpward;
    final themeColor = isUpward ? AppColors.neoMint : AppColors.statusDeficit;

    final displayBalance = (_scrubbedIndex != null && _scrubbedIndex! < values.length)
        ? values[_scrubbedIndex!]
        : trend.currentBalance;

    final scrubbedLabel = (_scrubbedIndex != null && _scrubbedIndex! < trend.labels.length)
        ? trend.labels[_scrubbedIndex!]
        : null;

    final delta = trend.delta;
    final pct = trend.percentChange;
    final String deltaSign = delta >= 0 ? '+' : '';
    final String deltaFormatted = '$deltaSign${_currencyFormatter.format(delta)}';
    final String pctFormatted = '$deltaSign${pct.toStringAsFixed(1)}%';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.canvasCardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.canvasBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          PocketStockChartHeader(
            displayBalance: displayBalance,
            themeColor: themeColor,
            isUpward: isUpward,
            pctFormatted: pctFormatted,
            deltaFormatted: deltaFormatted,
            pocketsCount: widget.pocketsCount,
            scrubbedIndex: _scrubbedIndex,
            scrubbedLabel: scrubbedLabel,
            selectedFilter: _selectedFilter,
            filters: _filters,
            onFilterChanged: _onFilterChanged,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragDown: (d) => _handleTouch(d.localPosition, width, values.length),
                  onHorizontalDragUpdate: (d) => _handleTouch(d.localPosition, width, values.length),
                  onHorizontalDragEnd: (_) => _clearTouch(),
                  onHorizontalDragCancel: () => _clearTouch(),
                  onTapDown: (d) => _handleTouch(d.localPosition, width, values.length),
                  onTapUp: (_) {
                    Future.delayed(const Duration(milliseconds: 1500), () {
                      if (mounted && _scrubbedIndex != null) _clearTouch();
                    });
                  },
                  child: AnimatedBuilder(
                    animation: _animProgress,
                    builder: (context, _) {
                      return CustomPaint(
                        size: Size(width, 90),
                        painter: PocketSplinePainter(
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
