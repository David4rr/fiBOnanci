import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import 'painters/pocket_cashflow_painter.dart';

/// Modular mini cashflow chart designed specifically for Kantong Tabungan.
class PocketCashflowChart extends StatefulWidget {
  final PocketEntry pocket;
  final List<TransactionEntry> transactions;
  final bool isDark;
  final Color primaryColor, secondaryColor, accentColor;
  final NumberFormat currencyFormatter;
  const PocketCashflowChart({
    super.key, required this.pocket, required this.transactions, required this.isDark,
    required this.primaryColor, required this.secondaryColor, required this.accentColor,
    required this.currencyFormatter,
  });

  @override
  State<PocketCashflowChart> createState() => _PocketCashflowChartState();
}

class _PocketCashflowChartState extends State<PocketCashflowChart> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _anim;
  AnimationStatusListener? _routeListener;
  ModalRoute? _observedRoute;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
    _anim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final route = ModalRoute.of(context);
      if (route == null || route.animation == null || route.animation!.isCompleted) {
        _animController.forward();
      } else {
        _observedRoute = route;
        _routeListener = (status) {
          if (status == AnimationStatus.completed) {
            _observedRoute?.animation?.removeStatusListener(_routeListener!);
            _routeListener = null;
            if (mounted) _animController.forward(from: 0.0);
          }
        };
        route.animation!.addStatusListener(_routeListener!);
      }
    });
  }

  @override
  void didUpdateWidget(covariant PocketCashflowChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pocket.currentAmount != widget.pocket.currentAmount ||
        oldWidget.transactions.length != widget.transactions.length) {
      if (_animController.isAnimating || _animController.isCompleted) {
        _animController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    if (_routeListener != null && _observedRoute?.animation != null) {
      _observedRoute!.animation!.removeStatusListener(_routeListener!);
    }
    _animController.dispose();
    super.dispose();
  }

  String _formatCompact(double amt) {
    if (amt >= 1000000000) return '${(amt / 1000000000).toStringAsFixed((amt / 1000000000) % 1 == 0 ? 0 : 1)}M';
    if (amt >= 1000000) return '${(amt / 1000000).toStringAsFixed((amt / 1000000) % 1 == 0 ? 0 : 1)}jt';
    if (amt >= 1000) return '${(amt / 1000).toStringAsFixed((amt / 1000) % 1 == 0 ? 0 : 0)}rb';
    return amt.toStringAsFixed(0);
  }

  List<double> _calculatePoints() {
    const numPoints = 7;
    final current = widget.pocket.currentAmount;
    if (widget.transactions.isEmpty) return List.filled(numPoints, current);

    final sorted = List<TransactionEntry>.from(widget.transactions)
      ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

    final now = DateTime.now();
    final firstTx = sorted.first.transactionDate;
    final totalSpanDays = now.difference(firstTx).inDays;

    final List<DateTime> sampleDates = [];
    if (totalSpanDays > 7) {
      final startMs = firstTx.millisecondsSinceEpoch, endMs = now.millisecondsSinceEpoch;
      for (int i = 0; i < numPoints; i++) {
        sampleDates.add(DateTime.fromMillisecondsSinceEpoch((startMs + ((endMs - startMs) * (i / (numPoints - 1)))).round()));
      }
    } else {
      for (int i = numPoints - 1; i >= 0; i--) {
        sampleDates.add(DateTime(now.year, now.month, now.day - i, 23, 59, 59, 999));
      }
    }
    final List<double> vals = List.filled(numPoints, current);
    for (int i = numPoints - 2; i >= 0; i--) {
      final after = sampleDates[i];
      final next = sampleDates[i + 1];
      double netDelta = 0.0;
      for (final tx in sorted) {
        final d = tx.transactionDate;
        if (d.isAfter(after) && !d.isAfter(next)) {
          final n = (tx.notes ?? '').toLowerCase();
          final isDep = n.contains('setoran') || tx.type == 'transfer';
          netDelta += isDep ? tx.amount : -tx.amount;
        }
      }
      vals[i] = (vals[i + 1] - netDelta).clamp(0.0, double.infinity);
    }
    return vals;
  }

  @override
  Widget build(BuildContext context) {
    double totalIn = 0.0, totalOut = 0.0;
    for (final tx in widget.transactions) {
      final n = (tx.notes ?? '').toLowerCase();
      final isDep = n.contains('setoran') || tx.type == 'transfer';
      if (isDep) {
        totalIn += tx.amount;
      } else {
        totalOut += tx.amount;
      }
    }

    final hasTx = widget.transactions.isNotEmpty;
    final points = _calculatePoints();
    final lineColor = widget.isDark ? widget.accentColor : const Color(0xFF0C0D11).withValues(alpha: 0.85);
    final inColor = widget.isDark ? AppColors.neoMint : const Color(0xFF1B5E20);
    final outColor = widget.isDark ? AppColors.neoCoral : const Color(0xFFB71C1C);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FadeTransition(
          opacity: _anim,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasTx && totalIn > 0) ...[
                  Text('+${_formatCompact(totalIn)}', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: inColor, fontFeatures: const [FontFeature.tabularFigures()])),
                  if (totalOut > 0) ...[
                    Text(' • ', style: TextStyle(fontSize: 9, color: widget.secondaryColor.withValues(alpha: 0.4))),
                    Text('-${_formatCompact(totalOut)}', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: outColor, fontFeatures: const [FontFeature.tabularFigures()])),
                  ],
                ] else ...[
                  Icon(Icons.show_chart_rounded, size: 12, color: widget.secondaryColor.withValues(alpha: 0.7)),
                  const SizedBox(width: 4),
                  Text('Arus Kas', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: widget.secondaryColor)),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context, _) => CustomPaint(
              size: Size.infinite,
              painter: PocketCashflowSplinePainter(
                values: points,
                lineColor: lineColor,
                fillColor: lineColor.withValues(alpha: widget.isDark ? 0.22 : 0.12),
                progress: _anim.value,
                hasTransactions: hasTx,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
