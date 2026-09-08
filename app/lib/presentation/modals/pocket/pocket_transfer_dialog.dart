import 'package:flutter/material.dart';
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
import '../../widgets/common/common_widgets.dart';

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

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetCtx) {
        return BlocProvider.value(
          value: financeBloc,
          child: StatefulBuilder(
            builder: (ctx, setSheetState) {
              return BlocBuilder<FinanceBloc, FinanceState>(
                builder: (ctx, state) {
                  final activeWallets = state.wallets.where((w) => !w.isDeleted).toList();
                  final safeWalletId = activeWallets.any((w) => w.id == selectedWalletId)
                      ? selectedWalletId
                      : (activeWallets.isNotEmpty ? activeWallets.first.id : null);
                  selectedWalletId = safeWalletId;
                  final actionColor = isDeposit ? AppColors.neoMint : AppColors.neoCoral;

                  return Padding(
                    padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + MediaQuery.of(sheetCtx).viewInsets.bottom),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ModalGrabHandle(padding: EdgeInsets.only(bottom: 12)),
                          ModalHeader(
                            title: isDeposit ? 'Isi Dana ke Kantong' : 'Tarik Dana ke Rekening',
                            subtitle: isDeposit
                                ? 'Pilih rekening asal untuk memindahkan dana ke ${pocket.name}.'
                                : 'Pilih rekening tujuan penarikan dari ${pocket.name}.',
                            onClose: () => Navigator.of(sheetCtx).pop(),
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
                                      setSheetState(() {
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
                          CurrencyAmountField(
                            controller: amountController,
                            labelText: 'Nominal',
                            prefixColor: actionColor,
                            hintText: '0',
                            onChanged: (_) {
                              if (errorMessage != null) setSheetState(() => errorMessage = null);
                            },
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
                          const SizedBox(height: 20),
                          PrimaryActionButton(
                            text: 'Konfirmasi',
                            backgroundColor: actionColor,
                            foregroundColor: AppColors.canvasBg,
                            onPressed: activeWallets.isEmpty
                                ? null
                                : () {
                                    final amount = RupiahInputFormatter.parse(amountController.text);
                                    if (amount <= 0) {
                                      setSheetState(() => errorMessage = 'Masukkan nominal lebih dari Rp 0');
                                      return;
                                    }
                                    if (selectedWalletId == null) {
                                      setSheetState(() => errorMessage = 'Pilih rekening terlebih dahulu');
                                      return;
                                    }
                                    final selectedWallet = activeWallets.firstWhere((w) => w.id == selectedWalletId);
                                    if (isDeposit && amount > selectedWallet.balance) {
                                      setSheetState(() => errorMessage = 'Saldo ${selectedWallet.name} tidak cukup (${currencyFormatter.format(selectedWallet.balance)})');
                                      return;
                                    }
                                    if (!isDeposit && amount > pocket.currentAmount) {
                                      setSheetState(() => errorMessage = 'Saldo kantong tidak cukup (${currencyFormatter.format(pocket.currentAmount)})');
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
                                    Navigator.of(sheetCtx).pop();
                                  },
                          ),
                        ],
                      ),
                    ),
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
