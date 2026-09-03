import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MiniWeeklyBarChart extends StatelessWidget {
  final DateTime txDate;
  final List<double>? weeklySpending;

  const MiniWeeklyBarChart({
    super.key,
    required this.txDate,
    this.weeklySpending,
  });

  @override
  Widget build(BuildContext context) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final int activeDayIndex = (txDate.weekday - 1).clamp(0, 6);

    final data = (weeklySpending != null && weeklySpending!.length == 7)
        ? weeklySpending!
        : List.filled(7, 0.0);

    final double maxSpend = data.reduce(math.max);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int d = 0; d < 7; d++) ...[
          Builder(builder: (context) {
            final double spend = data[d];
            final bool isTodayOrActive = d == activeDayIndex;

            final double barHeight = maxSpend > 0
                ? (spend > 0 ? (spend / maxSpend * 40.0 + 8.0).clamp(8.0, 48.0) : 6.0)
                : (isTodayOrActive ? 24.0 : 6.0);

            return Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: barHeight,
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    decoration: BoxDecoration(
                      color: isTodayOrActive
                          ? const Color(0xFF0C0D11)
                          : (spend > 0
                              ? const Color(0xFF0C0D11).withValues(alpha: 0.55)
                              : const Color(0xFF0C0D11).withValues(alpha: 0.18)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    days[d],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: isTodayOrActive ? FontWeight.w800 : FontWeight.w600,
                      color: const Color(0xFF0C0D11).withValues(alpha: isTodayOrActive ? 0.95 : 0.45),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}
