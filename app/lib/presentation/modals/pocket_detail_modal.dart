import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/pocket_transaction_tile.dart';
import 'pocket/pocket_detail_views.dart';
import 'pocket/pocket_transfer_dialog.dart';

export 'pocket/pocket_detail_views.dart';
export 'pocket/pocket_transfer_dialog.dart';

class PocketDetailModal {
  static void show(BuildContext context, {required PocketEntry pocket}) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final Color pocketColor = Color(int.parse(pocket.colorHex.replaceAll('#', '0xFF')));
    final financeBloc = context.read<FinanceBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return BlocProvider.value(
          value: financeBloc,
          child: BlocBuilder<FinanceBloc, FinanceState>(
            builder: (context, state) {
              final latestPocket = state.pockets.firstWhere((p) => p.id == pocket.id, orElse: () => pocket);
              final pocketTxs = state.transactions.where((tx) {
                final n = (tx.notes ?? '').toLowerCase();
                final nameLower = latestPocket.name.toLowerCase();
                return n.contains(nameLower) || (n.contains('kantong') && tx.walletId == latestPocket.linkedWalletId);
              }).toList();

              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.88),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textSubtle, borderRadius: BorderRadius.circular(2)))),
                      const SizedBox(height: 18),
                      PocketDetailHeader(pocket: latestPocket, pocketColor: pocketColor, currencyFormatter: currencyFormatter),
                      const SizedBox(height: 20),
                      PocketDetailActions(pocket: latestPocket, pocketColor: pocketColor),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('Riwayat Mutasi', style: AppTypography.sectionTitle.copyWith(fontSize: 15.5))),
                          if (pocketTxs.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: AppColors.canvasInputSearch, borderRadius: BorderRadius.circular(8)),
                              child: Text('${pocketTxs.length} mutasi', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (pocketTxs.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(color: AppColors.canvasInputSearch, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.canvasBorder)),
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 32, color: AppColors.textSubtle),
                              const SizedBox(height: 8),
                              Text('Belum ada riwayat mutasi', style: AppTypography.listSubtitle),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pocketTxs.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) => PocketTransactionTile(
                            transaction: pocketTxs[index],
                            wallets: state.wallets,
                            currencyFormatter: currencyFormatter,
                          ),
                        ),
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton.icon(
                          onPressed: () => showPocketDeleteDialog(context, latestPocket),
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                          label: const Text('Hapus Kantong', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700, fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  static void showTransferDialog(BuildContext context, {required PocketEntry pocket, required bool isDeposit}) {
    PocketTransferDialog.show(context, pocket: pocket, isDeposit: isDeposit);
  }
}
