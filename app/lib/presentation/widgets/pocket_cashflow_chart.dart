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
  late AnimationController _animController;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
    _anim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant PocketCashflowChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pocket.currentAmount != widget.pocket.currentAmount ||
        oldWidget.transactions.length != widget.transactions.length) {
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _formatCompact(double amt) {
    if (amt >= 1000000000) {
      final v = amt / 1000000000;
      return '${v.toStringAsFixed(v % 1 == 0 ? 0 : 1)}M';
    } else if (amt >= 1000000) {
      final v = amt / 1000000;
      return '${v.toStringAsFixed(v % 1 == 0 ? 0 : 1)}jt';
    } else if (amt >= 1000) {
      final v = amt / 1000;
      return '${v.toStringAsFixed(v % 1 == 0 ? 0 : 0)}rb';
    }
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
      final startMs = firstTx.millisecondsSinceEpoch;
      final endMs = now.millisecondsSinceEpoch;
      for (int i = 0; i < numPoints; i++) {
        final ms = (startMs + ((endMs - startMs) * (i / (numPoints - 1)))).round();
        sampleDates.add(DateTime.fromMillisecondsSinceEpoch(ms));
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
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasTx && totalIn > 0) ...[
                Text(
                  '+${_formatCompact(totalIn)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: inColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (totalOut > 0) ...[
                  Text(' • ', style: TextStyle(fontSize: 9, color: widget.secondaryColor.withValues(alpha: 0.4))),
                  Text(
                    '-${_formatCompact(totalOut)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: outColor,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ] else ...[
                Icon(Icons.show_chart_rounded, size: 12, color: widget.secondaryColor.withValues(alpha: 0.7)),
                const SizedBox(width: 4),
                Text('Arus Kas', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: widget.secondaryColor)),
              ],
            ],
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
