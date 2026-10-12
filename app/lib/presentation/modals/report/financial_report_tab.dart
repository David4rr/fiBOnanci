import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bloc/finance/finance_state.dart';
import '../../../domain/services/financial_report_service.dart';
import '../../theme/app_colors.dart';
import 'financial_report_breakdown_cards.dart';
import 'financial_report_summary_card.dart';

class FinancialReportTab extends StatefulWidget {
  final FinanceState state;

  const FinancialReportTab({super.key, required this.state});

  @override
  State<FinancialReportTab> createState() => _FinancialReportTabState();
}

class _FinancialReportTabState extends State<FinancialReportTab> {
  ReportPeriod _selectedPeriod = ReportPeriod.thisMonth;

  @override
  Widget build(BuildContext context) {
    final report = FinancialReportService.generate(
      wallets: widget.state.wallets,
      pockets: widget.state.pockets,
      categories: widget.state.categories,
      transactions: widget.state.transactions,
      subscriptions: widget.state.subscriptions,
      period: _selectedPeriod,
    );

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: ReportPeriod.values.map((period) {
              final isSelected = period == _selectedPeriod;
              return Expanded(
                child: GestureDetector(
                  key: Key('report_period_${period.name}'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _selectedPeriod = period),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withValues(alpha: 0.10) : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      period.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.textWhite : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        FinancialReportSummaryCard(data: report),
        const SizedBox(height: 14),
        FinancialReportBreakdownCards(data: report),
      ],
    );
  }
}
