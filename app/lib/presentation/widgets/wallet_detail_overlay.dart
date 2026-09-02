import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'transaction_detail_modal.dart';
import 'trend_spline_chart.dart';
import 'wallet_card.dart';

/// Interactive standalone focused card overlay.
/// Features standalone physical ATM card, actions row, 30-day dual trend chart, and history list.
class WalletDetailOverlay extends StatelessWidget {
  final WalletEntry wallet;
  final List<WalletEntry> allWallets;
  final List<TransactionEntry> transactions;
  final NumberFormat currencyFormatter;
  final List<double> Function(List<TransactionEntry>, {String? walletId, required String type}) computeSeries;
  final List<String> Function() computeDayLabels;
  final VoidCallback onClose;
  final VoidCallback onEditBalance;
  final VoidCallback onAddTransaction;

  const WalletDetailOverlay({
    super.key,
    required this.wallet,
    required this.allWallets,
    required this.transactions,
    required this.currencyFormatter,
    required this.computeSeries,
    required this.computeDayLabels,
    required this.onClose,
    required this.onEditBalance,
    required this.onAddTransaction,
  });

  @override
  Widget build(BuildContext context) {
    final walletTx = transactions
        .where((tx) => tx.walletId == wallet.id || tx.destinationWalletId == wallet.id)
        .toList();
    final cardIndex = allWallets.indexWhere((w) => w.id == wallet.id);
    final cardColor = getWalletColor(cardIndex, wallet.colorHex);

    return Stack(
      children: [
        // Dark Dimmed Scrim
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onClose,
            child: Container(
              color: Colors.black.withValues(alpha: 0.80),
            ),
          ),
        ),

        // Bottom-Anchored Focused Detail Sheet View
        Positioned.fill(
          child: SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.88,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Detail Rekening',
                            style: AppTypography.heroGreeting.copyWith(fontSize: 20),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _confirmDeleteWallet(context),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.canvasCardSurface,
                                  border: Border.all(color: AppColors.canvasBorder, width: 1),
                                ),
                                child: const Icon(Icons.delete_outline_rounded, color: AppColors.neoCoral, size: 16),
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: onClose,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.canvasCardSurface,
                                  border: Border.all(color: AppColors.canvasBorder, width: 1),
                                ),
                                child: const Icon(Icons.close, color: AppColors.textWhite, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Element 1: Standalone Floating ATM Card
                    AspectRatio(
                      aspectRatio: 85.60 / 53.98,
                      child: WalletCard(
                        wallet: wallet,
                        index: cardIndex,
                        fmt: currencyFormatter,
                        cardH: 200,
                        isLifted: true,
                        showBottomLayout: true,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Element 2: Separate Bottom Container
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.canvasCardSurface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.canvasBorder, width: 1.2),
                        ),
                        child: ListView(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          children: [
                            // Action Buttons Row
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.neoChartreuse,
                                      foregroundColor: AppColors.textDarkPrimary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      padding: const EdgeInsets.symmetric(vertical: 11),
                                      elevation: 0,
                                    ),
                                    icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textDarkPrimary),
                                    label: Text(
                                      'Ubah Saldo',
                                      style: AppTypography.listTitle.copyWith(
                                        color: AppColors.textDarkPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    onPressed: onEditBalance,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.textWhite,
                                      side: const BorderSide(color: AppColors.canvasBorder, width: 1),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      padding: const EdgeInsets.symmetric(vertical: 11),
                                    ),
                                    icon: const Icon(Icons.add_rounded, size: 16, color: AppColors.neoChartreuse),
                                    label: Text(
                                      'Catat Transaksi',
                                      style: AppTypography.listTitle.copyWith(
                                        color: AppColors.textWhite,
                                        fontSize: 13,
                                      ),
                                    ),
                                    onPressed: onAddTransaction,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // 30-Day Trend Chart
                            TrendSplineChart(
                              incomeValues: computeSeries(transactions, type: 'income', walletId: wallet.id),
                              expenseValues: computeSeries(transactions, type: 'expense', walletId: wallet.id),
                              labels: computeDayLabels(),
                              lineColor: cardColor,
                              headline: 'Tren Mutasi ${wallet.name}',
                              subtitle: '30 Hari Terakhir',
                              height: 95,
                            ),
                            const SizedBox(height: 14),

                            // Riwayat Transaksi Header & List
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Riwayat Transaksi',
                                    style: AppTypography.sectionTitle.copyWith(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text('${walletTx.length} transaksi', style: AppTypography.listSubtitle),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (walletTx.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.canvasInputSearch,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    'Belum ada transaksi di rekening ini.',
                                    style: AppTypography.listSubtitle,
                                  ),
                                ),
                              )
                            else
                              for (final tx in walletTx.take(5)) ...[
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => TransactionDetailModal.show(context, transaction: tx),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.canvasInputSearch,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.canvasBorder, width: 0.6),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: (tx.type == 'income'
                                                    ? AppColors.neoMint
                                                    : (tx.type == 'transfer' ? AppColors.neoCyan : AppColors.neoCoral))
                                                .withValues(alpha: 0.15),
                                          ),
                                          child: Icon(
                                            tx.type == 'income'
                                                ? Icons.arrow_downward
                                                : (tx.type == 'transfer' ? Icons.swap_horiz : Icons.arrow_upward),
                                            color: tx.type == 'income'
                                                ? AppColors.neoMint
                                                : (tx.type == 'transfer' ? AppColors.neoCyan : AppColors.neoCoral),
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                tx.notes ??
                                                    (tx.type == 'transfer'
                                                        ? 'Transfer Saldo'
                                                        : (tx.type == 'income' ? 'Pemasukan' : 'Pengeluaran')),
                                                style: AppTypography.listTitle.copyWith(fontSize: 13),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                DateFormat('d MMM, HH:mm', 'id_ID').format(tx.transactionDate.toLocal()),
                                                style: AppTypography.listSubtitle.copyWith(fontSize: 10),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${tx.type == 'expense' ? '-' : (tx.type == 'income' ? '+' : '')}${currencyFormatter.format(tx.amount)}',
                                          style: AppTypography.listAmount.copyWith(
                                            fontSize: 13,
                                            color: tx.type == 'income'
                                                ? AppColors.neoMint
                                                : (tx.type == 'transfer' ? AppColors.neoCyan : AppColors.textWhite),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  void _confirmDeleteWallet(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.canvasCardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.canvasBorder),
          ),
          title: Text(
            'Hapus Rekening?',
            style: AppTypography.sectionTitle.copyWith(
              color: AppColors.textWhite,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Rekening "${wallet.name}" beserta aturan notifikasinya akan dihapus. Riwayat mutasi transaksi sebelumnya tetap aman dan tercatat.',
            style: AppTypography.listSubtitle.copyWith(
              color: AppColors.textMuted,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Batal',
                style: AppTypography.listTitle.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neoCoral,
                foregroundColor: AppColors.textDarkPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        context.read<FinanceBloc>().add(DeleteWalletEvent(wallet.id));
        onClose();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.neoCoral,
            content: Text(
              'Rekening ${wallet.name} berhasil dihapus.',
              style: const TextStyle(
                color: AppColors.textDarkPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    });
  }

}
