import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'mini_weekly_bar_chart.dart';

class OverlappingDeckExpandedInsight extends StatelessWidget {
  final String category;
  final Color categoryColor;
  final DateTime transactionDate;
  final List<double>? weeklySpending;
  final NumberFormat currencyFormatter;
  final VoidCallback? onManage;
  final String? subtitle;

  const OverlappingDeckExpandedInsight({
    super.key,
    required this.category,
    required this.categoryColor,
    required this.transactionDate,
    required this.weeklySpending,
    required this.currencyFormatter,
    this.onManage,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 14),
        Container(height: 1, color: const Color(0xFF0C0D11).withValues(alpha: 0.14)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Tren ${category.toLowerCase()} (Sen–Min)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0C0D11).withValues(alpha: 0.65),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            if (weeklySpending != null)
              Text(
                currencyFormatter.format(weeklySpending!.reduce((a, b) => a + b)),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0C0D11).withValues(alpha: 0.8),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: MiniWeeklyBarChart(txDate: transactionDate, weeklySpending: weeklySpending),
            ),
            if (onManage != null) ...[
              const SizedBox(width: 14),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onManage,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C0D11),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Kelola', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: categoryColor)),
                      const SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 15, color: categoryColor),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0C0D11).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_balance_wallet_outlined, size: 14, color: Color(0xFF0C0D11)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    subtitle!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0C0D11).withValues(alpha: 0.85),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
