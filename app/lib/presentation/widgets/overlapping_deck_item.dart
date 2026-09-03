import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'overlapping_deck_expanded_insight.dart';

export 'mini_weekly_bar_chart.dart';
export 'overlapping_deck_expanded_insight.dart';
export 'overlapping_deck_list.dart';

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

  static final NumberFormat _expenseFormatter = NumberFormat.currency(locale: 'id_ID', symbol: '-Rp ', decimalDigits: 0);
  static final NumberFormat _incomeFormatter = NumberFormat.currency(locale: 'id_ID', symbol: '+Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = isExpense ? _expenseFormatter : _incomeFormatter;

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
          border: Border.all(
            color: isExpanded ? const Color(0xFF0C0D11).withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.06),
            width: isExpanded ? 2 : 1,
          ),
          boxShadow: isExpanded
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 16, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
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
                    child: Center(child: Icon(iconData, color: const Color(0xFF0C0D11), size: 20)),
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
              if (isExpanded)
                OverlappingDeckExpandedInsight(
                  category: category,
                  categoryColor: categoryColor,
                  transactionDate: transactionDate ?? DateTime.now(),
                  weeklySpending: weeklySpending,
                  currencyFormatter: currencyFormatter,
                  onManage: onManage,
                  subtitle: subtitle,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
