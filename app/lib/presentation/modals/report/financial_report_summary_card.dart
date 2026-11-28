import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/formatters/app_currency.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/services/financial_report_service.dart';
import '../../../core/l10n/category_localizer.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../screens/expense_history_screen.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';
import 'category_donut_chart.dart';
import 'financial_report_category_grid.dart';

class FinancialReportSummaryCard extends StatefulWidget {
  final FinancialReportData data;
  final ReportFlowType flowType;
  final List<TransactionEntry> allTransactions;
  final List<WalletEntry> wallets;

  const FinancialReportSummaryCard({
    super.key,
    required this.data,
    required this.flowType,
    required this.allTransactions,
    required this.wallets,
  });

  @override
  State<FinancialReportSummaryCard> createState() => _FinancialReportSummaryCardState();
}

class _FinancialReportSummaryCardState extends State<FinancialReportSummaryCard> {
  int? _selectedSliceIndex;

  @override
  void didUpdateWidget(covariant FinancialReportSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.flowType != widget.flowType) _selectedSliceIndex = null;
  }

  List<UnifiedDonutSlice> _buildSlices() {
    final data = widget.data;
    final items = <UnifiedDonutSlice>[];
    final includeIn = widget.flowType == ReportFlowType.income || widget.flowType == ReportFlowType.all;
    final includeOut = widget.flowType == ReportFlowType.expense || widget.flowType == ReportFlowType.all;

    if (includeIn) {
      final denom = widget.flowType == ReportFlowType.all ? (data.totalIncome + data.totalExpense) : data.totalIncome;
      for (int i = 0; i < data.incomeByCategory.length; i++) {
        final c = data.incomeByCategory[i];
        items.add(UnifiedDonutSlice(
          categoryId: 'in_${c.categoryId}', name: CategoryLocalizer.name(context, id: c.categoryId, rawName: c.name), amount: c.amount,
          percentage: denom > 0 ? (c.amount / denom) * 100.0 : 0.0, txCount: c.txCount,
          isIncome: true, color: CategoryDonutChart.resolveSliceColor(c.colorHex, true, i),
        ));
      }
    }

    if (includeOut) {
      final denom = widget.flowType == ReportFlowType.all ? (data.totalIncome + data.totalExpense) : data.totalExpense;
      for (int i = 0; i < data.expenseByCategory.length; i++) {
        final c = data.expenseByCategory[i];
        items.add(UnifiedDonutSlice(
          categoryId: 'out_${c.categoryId}', name: CategoryLocalizer.name(context, id: c.categoryId, rawName: c.name), amount: c.amount,
          percentage: denom > 0 ? (c.amount / denom) * 100.0 : 0.0, txCount: c.txCount,
          isIncome: false, color: CategoryDonutChart.resolveSliceColor(c.colorHex, false, i),
        ));
      }
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final fmt = AppCurrency.of(context);
    final data = widget.data;
    final slices = _buildSlices();

    final double centerTotal = switch (widget.flowType) {
      ReportFlowType.expense => data.totalExpense,
      ReportFlowType.income => data.totalIncome,
      ReportFlowType.all => data.netCashflow,
    };

    final String centerSublabel = switch (widget.flowType) {
      ReportFlowType.expense => l10n.reportTransactionsCount(data.totalTxCount),
      ReportFlowType.income => '${data.savingsRate.toStringAsFixed(0)}%',
      ReportFlowType.all => '${data.savingsRate.toStringAsFixed(0)}%',
    };

    return Column(
      children: [
        CategoryDonutChart(
          slices: slices,
          centerTotal: centerTotal,
          centerLabel: widget.flowType.label,
          centerSublabel: centerSublabel,
          centerSublabelColor: widget.flowType == ReportFlowType.all
              ? (data.netCashflow >= 0 ? AppColors.neoMint : AppColors.neoCoral)
              : AppColors.textMuted,
          selectedIndex: _selectedSliceIndex,
          onSelectIndex: (idx) => setState(() => _selectedSliceIndex = idx),
        ),
        const SizedBox(height: 22),
        if (slices.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: CardlessEmptyView(
              icon: Icons.pie_chart_outline_rounded,
              title: l10n.reportEmptyTitle,
              description: l10n.reportEmptyDesc,
            ),
          )
        else
          FinancialReportCategoryGrid(
            slices: slices,
            selectedIndex: _selectedSliceIndex,
            formatter: fmt.format,
            onTapSlice: (i) => setState(() => _selectedSliceIndex = _selectedSliceIndex == i ? null : i),
          ),
        const SizedBox(height: 22),
        Center(
          child: OutlinedButton(
            key: const Key('report_history_button'),
            onPressed: () => ExpenseHistoryScreen.show(
              context,
              allTransactions: widget.allTransactions,
              wallets: widget.wallets,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textWhite,
              side: BorderSide(color: AppColors.borderSubtle, width: 1.2),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            ),
            child: Text(
              l10n.historyButton,
              style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textWhite),
            ),
          ),
        ),
      ],
    );
  }
}
