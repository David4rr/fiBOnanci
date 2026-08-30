import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Individual pastel expense card item matching the Swiss-editorial reference.
class OverlappingDeckItem extends StatelessWidget {
  final String title;
  final String category;
  final double amount;
  final Color categoryColor;
  final IconData iconData;
  final String? subtitle;
  final bool isExpense;
  final bool isExpanded;
  final DateTime? transactionDate;
  final List<double>? weeklySpending;
  final VoidCallback? onTap;
  final VoidCallback? onManage;

  const OverlappingDeckItem({
    super.key,
    required this.title,
    required this.category,
    required this.amount,
    required this.categoryColor,
    required this.iconData,
    this.subtitle,
    this.isExpense = true,
    this.isExpanded = false,
    this.transactionDate,
    this.weeklySpending,
    this.onTap,
    this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: isExpense ? '-Rp ' : '+Rp ',
      decimalDigits: 0,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        height: isExpanded ? 295.0 : 190.0,
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        decoration: BoxDecoration(
          color: categoryColor,
          borderRadius: BorderRadius.circular(26),
          border: isExpanded ? Border.all(color: const Color(0xFF0C0D11).withValues(alpha: 0.35), width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isExpanded ? 0.45 : 0.35),
              blurRadius: isExpanded ? 20 : 14,
              offset: Offset(0, isExpanded ? -6 : -4),
              spreadRadius: isExpanded ? 2 : 1,
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row: Icon Circle Avatar & Tabular Amount
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0C0D11).withValues(alpha: 0.12),
                    ),
                    child: Center(
                      child: Icon(iconData, color: const Color(0xFF0C0D11), size: 20),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    currencyFormatter.format(amount.abs()),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0C0D11),
                      letterSpacing: -0.6,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Middle: Category Eyebrow
              Text(
                category.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0C0D11).withValues(alpha: 0.65),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),

              // Title: Merchant / Note
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0C0D11),
                  letterSpacing: -0.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Expanded Insight: 7-Day Bar Chart & Detail Action
              if (isExpanded) ...[
                const SizedBox(height: 14),
                Container(
                  height: 1,
                  color: const Color(0xFF0C0D11).withValues(alpha: 0.14),
                ),
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
                      child: _buildMini7DayBarChart(transactionDate ?? DateTime.now(), weeklySpending),
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
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Kelola',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: categoryColor,
                                ),
                              ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMini7DayBarChart(DateTime txDate, List<double>? weeklySpending) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final int activeDayIndex = (txDate.weekday - 1).clamp(0, 6);

    final data = (weeklySpending != null && weeklySpending.length == 7)
        ? weeklySpending
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

/// Vertically stacked deck of cards overlapping by negative vertical step
class OverlappingDeckList extends StatelessWidget {
  final List<Widget> children;
  final double overlapOffset;
  final double stepOffset;
  final double cardHeight;

  const OverlappingDeckList({
    super.key,
    required this.children,
    this.overlapOffset = 70.0,
    this.stepOffset = 95.0,
    this.cardHeight = 200.0,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalHeight = (children.length - 1) * stepOffset + cardHeight;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < children.length; i++)
            Positioned(
              top: i * stepOffset,
              left: 0,
              right: 0,
              child: children[i],
            ),
        ],
      ),
    );
  }
}
