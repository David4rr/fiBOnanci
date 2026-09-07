import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Specification details card for subscription or installment plan.
/// Displays payment account, method, period status, and debt cycle progress.
class SubscriptionDetailSpecsCard extends StatelessWidget {
  final SubscriptionEntry subscription;
  final WalletEntry wallet;
  final NumberFormat currencyFormatter;

  const SubscriptionDetailSpecsCard({
    super.key,
    required this.subscription,
    required this.wallet,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isPaidThisMonth = subscription.lastPaidDate != null &&
        subscription.lastPaidDate!.year == now.year &&
        subscription.lastPaidDate!.month == now.month;

    final isInstallment = subscription.isInstallment;
    final totalCycles = subscription.totalCycles ?? 0;
    final paidCycles = subscription.paidCycles;
    final isCompleted = subscription.status == 'completed' ||
        (isInstallment && totalCycles > 0 && paidCycles >= totalCycles);

    final remainingCycles = (totalCycles - paidCycles).clamp(0, totalCycles);
    final remainingCost = subscription.cost * remainingCycles;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.canvasCardSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.canvasBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRow('Rekening Pembayaran', wallet.name, Icons.account_balance_wallet_outlined),
          const Divider(color: AppColors.canvasBorder, height: 20),
          _buildRow('Saldo Rekening Saat Ini', currencyFormatter.format(wallet.balance), Icons.account_balance_outlined),
          const Divider(color: AppColors.canvasBorder, height: 20),
          _buildRow('Metode Pembayaran', subscription.autoDeduct ? 'Auto-Deduct Aktif' : 'Manual Transfer / QRIS', Icons.sync_rounded),
          const Divider(color: AppColors.canvasBorder, height: 20),
          _buildRow(
            'Status Periode Ini',
            isCompleted ? 'Cicilan Selesai' : (isPaidThisMonth ? 'Sudah Lunas' : 'Belum Dibayar'),
            (isPaidThisMonth || isCompleted) ? Icons.verified_rounded : Icons.pending_actions_rounded,
            valueColor: (isPaidThisMonth || isCompleted) ? AppColors.neoMint : AppColors.neoCoral,
          ),
          if (isInstallment) ...[
            const Divider(color: AppColors.canvasBorder, height: 20),
            _buildRow(
              'Rencana Cicilan',
              '$paidCycles dari $totalCycles bulan lunas',
              Icons.timelapse_rounded,
              valueColor: isCompleted ? AppColors.neoMint : AppColors.neoCoral,
            ),
            const SizedBox(height: 10),
            _buildProgressBar(paidCycles: paidCycles, totalCycles: totalCycles),
            if (!isCompleted) ...[
              const Divider(color: AppColors.canvasBorder, height: 20),
              _buildRow('Sisa Tagihan Pokok', currencyFormatter.format(remainingCost), Icons.payments_outlined, valueColor: AppColors.neoCoral),
            ],
            if (subscription.deadlineDate != null) ...[
              const Divider(color: AppColors.canvasBorder, height: 20),
              _buildRow('Tenggat Selesai', DateFormat('MMMM yyyy', 'id_ID').format(subscription.deadlineDate!), Icons.event_available_rounded),
            ],
          ] else ...[
            const Divider(color: AppColors.canvasBorder, height: 20),
            _buildRow('Siklus Tagihan', subscription.billingCycle == 'monthly' ? 'Bulanan' : 'Tahunan', Icons.repeat_rounded),
            const Divider(color: AppColors.canvasBorder, height: 20),
            _buildRow('Jatuh Tempo', 'Setiap tanggal ${subscription.dueDay}', Icons.calendar_today_rounded),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar({required int paidCycles, required int totalCycles}) {
    final progress = totalCycles > 0 ? (paidCycles / totalCycles).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.canvasBg,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? AppColors.neoMint : AppColors.neoChartreuse,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Progress Pembayaran', style: AppTypography.listSubtitle.copyWith(fontSize: 11)),
            Text('${(progress * 100).toInt()}%', style: AppTypography.listTitle.copyWith(fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }

  static Widget _buildRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Text(label, style: AppTypography.listSubtitle),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTypography.listTitle.copyWith(
              color: valueColor ?? AppColors.textWhite,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
