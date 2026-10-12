import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/formatters/app_currency.dart';
import '../../../domain/services/financial_report_service.dart';
import '../../theme/app_colors.dart';
import 'category_donut_chart.dart';

class FinancialReportSummaryCard extends StatefulWidget {
  final FinancialReportData data;

  const FinancialReportSummaryCard({super.key, required this.data});

  @override
  State<FinancialReportSummaryCard> createState() => _FinancialReportSummaryCardState();
}

class _FinancialReportSummaryCardState extends State<FinancialReportSummaryCard> {
  int? _selectedSliceIndex;

  List<UnifiedDonutSlice> _buildUnifiedSlices() {
    final data = widget.data;
    final totalFlow = data.totalIncome + data.totalExpense;
    if (totalFlow <= 0) return const [];
    final slices = <UnifiedDonutSlice>[];
    for (int i = 0; i < data.incomeByCategory.length; i++) {
      final c = data.incomeByCategory[i];
      slices.add(UnifiedDonutSlice(
        categoryId: 'in_${c.categoryId}', name: c.name, amount: c.amount,
        percentage: (c.amount / totalFlow) * 100.0, txCount: c.txCount,
        isIncome: true, color: CategoryDonutChart.resolveSliceColor(c.colorHex, true, i),
      ));
    }
    for (int i = 0; i < data.expenseByCategory.length; i++) {
      final c = data.expenseByCategory[i];
      slices.add(UnifiedDonutSlice(
        categoryId: 'out_${c.categoryId}', name: c.name, amount: c.amount,
        percentage: (c.amount / totalFlow) * 100.0, txCount: c.txCount,
        isIncome: false, color: CategoryDonutChart.resolveSliceColor(c.colorHex, false, i),
      ));
    }
    return slices;
  }

  @override
  Widget build(BuildContext context) {
    final fmt = AppCurrency.of(context);
    final data = widget.data;
    final slices = _buildUnifiedSlices();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ARUS KAS BERSIH (${data.period.label.toUpperCase()})',
            style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.6),
          ),
          const SizedBox(height: 12),
          CategoryDonutChart(
            slices: slices,
            totalIncome: data.totalIncome,
            totalExpense: data.totalExpense,
            savingsRate: data.savingsRate,
            selectedIndex: _selectedSliceIndex,
            onSelectIndex: (idx) => setState(() => _selectedSliceIndex = idx),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMinimalMetric('Pemasukan', '+${fmt.format(data.totalIncome)}', AppColors.neoMint)),
              Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.06)),
              Expanded(child: _buildMinimalMetric('Pengeluaran', '-${fmt.format(data.totalExpense)}', AppColors.neoCoral)),
            ],
          ),
          if (slices.isNotEmpty) ...[
            const SizedBox(height: 16),
            Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
            const SizedBox(height: 8),
            ...List.generate(slices.length, (i) => _buildSliceRow(slices[i], i, fmt.format(slices[i].amount))),
          ],
        ],
      ),
    );
  }

  Widget _buildMinimalMetric(String label, String val, Color dotColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor)),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          val,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textWhite, fontFeatures: const [FontFeature.tabularFigures()]),
        ),
      ],
    );
  }

  Widget _buildSliceRow(UnifiedDonutSlice item, int index, String formattedAmt) {
    final isSelected = _selectedSliceIndex == index;
    final sign = item.isIncome ? '+' : '-';
    final amountColor = item.isIncome ? AppColors.neoMint : AppColors.textWhite;
    return GestureDetector(
      key: Key('report_category_row_$index'),
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selectedSliceIndex = isSelected ? null : index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.06) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: item.color)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: AppColors.textWhite),
              ),
            ),
            Text(
              '$sign$formattedAmt',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: amountColor, fontFeatures: const [FontFeature.tabularFigures()]),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 34,
              child: Text(
                '${item.percentage.toStringAsFixed(0)}%',
                textAlign: TextAlign.right,
                style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted, fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
