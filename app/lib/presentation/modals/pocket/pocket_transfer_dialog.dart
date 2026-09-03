import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../bloc/finance/finance_state.dart';
import '../../../core/formatters/rupiah_input_formatter.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class PocketTransferDialog {
  static void show(
    BuildContext context, {
    required PocketEntry pocket,
    required bool isDeposit,
  }) {
    final amountController = TextEditingController();
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final financeBloc = context.read<FinanceBloc>();
    String? selectedWalletId;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return BlocProvider.value(
          value: financeBloc,
          child: StatefulBuilder(
            builder: (dialogCtx, setDialogState) {
              return BlocBuilder<FinanceBloc, FinanceState>(
                builder: (ctx, state) {
                  final activeWallets = state.wallets.where((w) => !w.isDeleted).toList();
                  final safeWalletId = activeWallets.any((w) => w.id == selectedWalletId)
                      ? selectedWalletId
                      : (activeWallets.isNotEmpty ? activeWallets.first.id : null);
                  selectedWalletId = safeWalletId;

                  return AlertDialog(
                    backgroundColor: AppColors.canvasCardSurface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    title: Text(
                      isDeposit ? 'Isi Dana ke Kantong' : 'Tarik Dana ke Rekening',
                      style: AppTypography.sectionTitle,
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDeposit
                                ? 'Pilih rekening asal untuk memindahkan dana ke ${pocket.name}.'
                                : 'Pilih rekening tujuan penarikan dari ${pocket.name}.',
                            style: AppTypography.listSubtitle,
                          ),
                          const SizedBox(height: 16),
                          if (activeWallets.isNotEmpty) ...[
                            Text(isDeposit ? 'Rekening Sumber' : 'Rekening Tujuan', style: AppTypography.listSubtitle),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.canvasInputSearch,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.canvasBorder),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedWalletId,
                                  isExpanded: true,
                                  dropdownColor: AppColors.canvasCardSurface,
                                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
                                  items: activeWallets.map((w) {
                                    return DropdownMenuItem<String>(
                                      value: w.id,
                                      child: Text(
                                        '${w.name} (${currencyFormatter.format(w.balance)})',
                                        style: AppTypography.listSubtitle.copyWith(color: AppColors.textWhite, fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setDialogState(() {
                                        selectedWalletId = val;
                                        errorMessage = null;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: AppColors.neoCoral.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                              child: Text('Belum ada rekening aktif untuk transaksi.', style: GoogleFonts.plusJakartaSans(color: AppColors.neoCoral, fontSize: 12)),
                            ),
                            const SizedBox(height: 16),
                          ],
                          TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly, RupiahInputFormatter()],
                            onChanged: (_) {
                              if (errorMessage != null) setDialogState(() => errorMessage = null);
                            },
                            style: AppTypography.listTitle,
                            decoration: InputDecoration(
                              labelText: 'Nominal',
                              labelStyle: AppTypography.listSubtitle,
                              hintText: 'Rp 0',
                              hintStyle: AppTypography.listSubtitle,
                              filled: true,
                              fillColor: AppColors.canvasInputSearch,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            ),
                          ),
                          if (errorMessage != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: AppColors.neoCoral.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, color: AppColors.neoCoral, size: 14),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(errorMessage!, style: GoogleFonts.plusJakartaSans(color: AppColors.neoCoral, fontSize: 11.5, fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('Batal', style: TextStyle(color: AppColors.textMuted))),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.neoMint, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: activeWallets.isEmpty
                            ? null
                            : () {
                                final amount = RupiahInputFormatter.parse(amountController.text);
                                if (amount <= 0) {
                                  setDialogState(() => errorMessage = 'Masukkan nominal lebih dari Rp 0');
                                  return;
                                }
                                if (selectedWalletId == null) {
                                  setDialogState(() => errorMessage = 'Pilih rekening terlebih dahulu');
                                  return;
                                }
                                final selectedWallet = activeWallets.firstWhere((w) => w.id == selectedWalletId);
                                if (isDeposit && amount > selectedWallet.balance) {
                                  setDialogState(() => errorMessage = 'Saldo ${selectedWallet.name} tidak cukup (${currencyFormatter.format(selectedWallet.balance)})');
                                  return;
                                }
                                if (!isDeposit && amount > pocket.currentAmount) {
                                  setDialogState(() => errorMessage = 'Saldo kantong tidak cukup (${currencyFormatter.format(pocket.currentAmount)})');
                                  return;
                                }
                                financeBloc.add(
                                  TransferPocketFundsEvent(
                                    pocketId: pocket.id,
                                    walletId: selectedWalletId!,
                                    amount: amount,
                                    isDepositToPocket: isDeposit,
                                  ),
                                );
                                Navigator.of(dialogCtx).pop();
                              },
                        child: const Text('Konfirmasi', style: TextStyle(color: AppColors.canvasBg, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
