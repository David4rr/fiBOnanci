import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../../domain/services/cashflow_calendar_service.dart';
import '../../../domain/services/multi_vector_insight_engine.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'activity_calendar_tx_tile.dart';

class ActivityCalendarDetailPeek extends StatelessWidget {
  final DailyCashflowSummary summary;
  final NumberFormat currencyFormatter;
  final List<WalletEntry> wallets;
  final List<CategoryEntry>? categories;
  final List<PocketEntry>? pockets;
  final ValueChanged<TransactionEntry>? onTapTransaction;

  const ActivityCalendarDetailPeek({
    super.key,
    required this.summary,
    required this.currencyFormatter,
    required this.wallets,
    this.categories,
    this.pockets,
    this.onTapTransaction,
  });

  @override
  Widget build(BuildContext context) {
    final d = summary.date;
    final dateLabel = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(d);
    final hasTxs = summary.transactions.isNotEmpty;
    final isNoSpend = summary.isNoSpendDay;
    final isHemat = summary.isHematDay && !isNoSpend;

    final insight = MultiVectorInsightEngine.generate(
      dailySafePace: summary.dailySafePace,
      dayExpense: summary.totalExpense,
      date: d,
      isDeficit: summary.status == DayActivityStatus.overPace,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(color: AppColors.canvasBorder.withValues(alpha: 0.35), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  dateLabel,
                  style: TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isNoSpend)
                _buildBadge(label: 'No-Spend Day', icon: Icons.star_rounded, color: AppColors.textAccent)
              else if (isHemat)
                _buildBadge(label: 'Hemat (Aman)', icon: Icons.local_fire_department_rounded, color: AppColors.textAccent)
              else if (summary.status == DayActivityStatus.overPace)
                _buildBadge(label: 'Melebihi Alokasi', icon: Icons.error_outline_rounded, color: AppColors.neoCoral),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMetricCol(label: 'Pemasukan', amount: summary.totalIncome, color: AppColors.textIncome, prefix: '+')),
              Container(width: 1, height: 26, color: AppColors.canvasBorder.withValues(alpha: 0.35)),
              Expanded(child: _buildMetricCol(label: 'Pengeluaran', amount: summary.totalExpense, color: summary.totalExpense > 0 ? AppColors.neoCoral : AppColors.textSubtle, prefix: summary.totalExpense > 0 ? '-' : '')),
              Container(width: 1, height: 26, color: AppColors.canvasBorder.withValues(alpha: 0.35)),
              Expanded(child: _buildMetricCol(label: 'Alokasi Harian', amount: summary.dailySafePace, color: AppColors.textAccent, prefix: '')),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 2),
            child: Text(
              '✨ ${insight.text}',
              style: TextStyle(color: AppColors.textSubtle, fontSize: 10.5, fontStyle: FontStyle.italic),
            ),
          ),
          if (hasTxs) ...[
            const SizedBox(height: 12),
            Text(
              'Transaksi Tanggal Ini (${summary.transactions.length})',
              style: AppTypography.cardMetricLabel.copyWith(color: AppColors.textSubtle, fontSize: 11),
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: summary.transactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, idx) => ActivityCalendarTxTile(
                tx: summary.transactions[idx],
                currencyFormatter: currencyFormatter,
                wallets: wallets,
                categories: categories,
                pockets: pockets,
                onTap: onTapTransaction,
              ),
            ),
          ] else if (!isNoSpend)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Center(
                child: Text(
                  'Tidak ada aktivitas transaksi tercatat',
                  style: TextStyle(color: AppColors.textSubtle, fontSize: 11),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBadge({required String label, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.cardMetricLabel.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildMetricCol({required String label, required double amount, required Color color, required String prefix}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSubtle, fontSize: 10)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$prefix${currencyFormatter.format(amount)}',
              style: AppTypography.tabularFigures.copyWith(color: color, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
