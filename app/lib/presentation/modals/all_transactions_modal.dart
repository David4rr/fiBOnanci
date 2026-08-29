import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/transaction_detail_modal.dart';

class AllTransactionsModal {
  static void show(
    BuildContext context, {
    required List<TransactionEntry> allTransactions,
    required List<WalletEntry> wallets,
    required AppDatabase db,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Semua Riwayat Transaksi (${allTransactions.length})',
                style: AppTypography.sectionTitle,
              ),
              const SizedBox(height: 14),
              Expanded(
                child: allTransactions.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada transaksi',
                          style: AppTypography.listSubtitle,
                        ),
                      )
                    : ListView.builder(
                        itemCount: allTransactions.length,
                        itemBuilder: (ctx, i) {
                          final tx = allTransactions[i];
                          final w = wallets.firstWhere(
                            (wallet) => wallet.id == tx.walletId,
                            orElse: () => wallets.first,
                          );
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: tx.type == 'expense'
                                  ? AppColors.neoCoral.withValues(alpha: 0.2)
                                  : AppColors.neoMint.withValues(alpha: 0.2),
                              child: Icon(
                                tx.type == 'expense'
                                    ? Icons.arrow_outward
                                    : Icons.arrow_downward,
                                color: tx.type == 'expense'
                                    ? AppColors.neoCoral
                                    : AppColors.neoMint,
                              ),
                            ),
                            title: Text(
                              tx.notes ?? tx.type.toUpperCase(),
                              style: AppTypography.listTitle,
                            ),
                            subtitle: Text(
                              '${w.name} • ${DateFormat('dd MMM yyyy, HH:mm').format(tx.transactionDate)}',
                              style: AppTypography.listSubtitle,
                            ),
                            trailing: Text(
                              '${tx.type == 'income' ? '+' : '-'}Rp ${tx.amount.toStringAsFixed(0)}',
                              style: AppTypography.listAmount.copyWith(
                                color: tx.type == 'income'
                                    ? AppColors.neoMint
                                    : AppColors.textWhite,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              TransactionDetailModal.show(context, db: db, transaction: tx);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
