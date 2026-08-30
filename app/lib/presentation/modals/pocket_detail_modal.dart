import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../bloc/finance/finance_state.dart';
import '../../core/formatters/rupiah_input_formatter.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/pocket_transaction_tile.dart';
class PocketDetailModal {
  static void show(BuildContext context, {required PocketEntry pocket}) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final Color pocketColor = Color(int.parse(pocket.colorHex.replaceAll('#', '0xFF')));
    final double? target = pocket.targetAmount;
    final financeBloc = context.read<FinanceBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return BlocProvider.value(
          value: financeBloc,
          child: BlocBuilder<FinanceBloc, FinanceState>(
            builder: (context, state) {
            final latestPocket = state.pockets.firstWhere(
              (p) => p.id == pocket.id,
              orElse: () => pocket,
            );
            final latestCurrent = latestPocket.currentAmount;
            final latestProgress = (target != null && target > 0)
                ? (latestCurrent / target).clamp(0.0, 1.0)
                : 1.0;

            final pocketTxs = state.transactions.where((tx) {
              final n = (tx.notes ?? '').toLowerCase();
              final nameLower = latestPocket.name.toLowerCase();
              return n.contains(nameLower) ||
                  (n.contains('kantong') && tx.walletId == latestPocket.linkedWalletId);
            }).toList();

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.88,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  16,
                  24,
                  24 + MediaQuery.of(ctx).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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

                  // Header with Icon & Type Chip
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: pocketColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Icon(
                            _getPocketIcon(latestPocket.type),
                            color: pocketColor,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(latestPocket.name, style: AppTypography.sectionTitle),
                            const SizedBox(height: 2),
                            Text(
                              _getPocketTypeLabel(latestPocket.type),
                              style: TextStyle(
                                color: pocketColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Saldo Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.canvasInputSearch,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.canvasBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Terkumpul di Kantong', style: AppTypography.listSubtitle),
                        const SizedBox(height: 6),
                        Text(
                          currencyFormatter.format(latestCurrent),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textWhite,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        if (target != null && target > 0) ...[
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Target: ${currencyFormatter.format(target)}',
                                style: AppTypography.listSubtitle,
                              ),
                              Text(
                                '${(latestProgress * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color: pocketColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: latestProgress,
                              minHeight: 8,
                              backgroundColor: Colors.white.withValues(alpha: 0.08),
                              valueColor: AlwaysStoppedAnimation<Color>(pocketColor),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons: Tambah Dana & Tarik Dana
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: pocketColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.add_rounded, color: AppColors.canvasBg, size: 20),
                            label: Text(
                              'Isi Dana',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.canvasBg,
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                              ),
                            ),
                            onPressed: () {
                              showTransferDialog(
                                context,
                                pocket: latestPocket,
                                isDeposit: true,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.canvasBorder, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.arrow_upward_rounded, color: AppColors.textWhite, size: 18),
                            label: Text(
                              'Tarik Dana',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textWhite,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                            onPressed: latestCurrent > 0
                                ? () {
                                    showTransferDialog(
                                      context,
                                      pocket: latestPocket,
                                      isDeposit: false,
                                    );
                                  }
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Riwayat Mutasi Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Riwayat Mutasi',
                          style: AppTypography.sectionTitle.copyWith(fontSize: 15.5),
                        ),
                      ),
                      if (pocketTxs.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.canvasBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.canvasBorder),
                          ),
                          child: Text(
                            '${pocketTxs.length} mutasi',
                            style: AppTypography.badgeLabel.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (pocketTxs.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.canvasBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.canvasBorder),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 28,
                              color: AppColors.textMuted.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Belum ada riwayat mutasi',
                              style: AppTypography.listSubtitle.copyWith(fontSize: 12.5),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Isi atau tarik dana untuk mulai mencatat',
                              style: AppTypography.listSubtitle.copyWith(
                                fontSize: 11,
                                color: AppColors.textMuted.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    for (final tx in pocketTxs) ...[
                      PocketTransactionTile(
                        transaction: tx,
                        wallets: state.wallets,
                        currencyFormatter: currencyFormatter,
                      ),
                      const SizedBox(height: 8),
                    ],

                  const SizedBox(height: 16),

                  // Delete Button
                  Center(
                    child: TextButton(
                      onPressed: () {
                        context.read<FinanceBloc>().add(DeletePocketEvent(latestPocket.id));
                        Navigator.of(ctx).pop();
                      },
                      child: Text(
                        'Hapus Kantong Ini',
                        style: TextStyle(
                          color: AppColors.statusDeficit,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  static void showTransferDialog(
    BuildContext context, {
    required PocketEntry pocket,
    required bool isDeposit,
  }) {
    final amountController = TextEditingController();
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
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
                            Text(
                              isDeposit ? 'Rekening Sumber' : 'Rekening Tujuan',
                              style: AppTypography.listSubtitle,
                            ),
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
                                        style: AppTypography.listSubtitle.copyWith(
                                          color: AppColors.textWhite,
                                          fontWeight: FontWeight.w600,
                                        ),
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
                              decoration: BoxDecoration(
                                color: AppColors.neoCoral.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Belum ada rekening aktif untuk transaksi.',
                                style: GoogleFonts.plusJakartaSans(color: AppColors.neoCoral, fontSize: 12),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              RupiahInputFormatter(),
                            ],
                            onChanged: (_) {
                              if (errorMessage != null) {
                                setDialogState(() => errorMessage = null);
                              }
                            },
                            style: AppTypography.listTitle,
                            decoration: InputDecoration(
                              labelText: 'Nominal',
                              labelStyle: AppTypography.listSubtitle,
                              hintText: 'Rp 0',
                              hintStyle: AppTypography.listSubtitle,
                              filled: true,
                              fillColor: AppColors.canvasInputSearch,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          if (errorMessage != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.neoCoral.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, color: AppColors.neoCoral, size: 14),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      errorMessage!,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: AppColors.neoCoral,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                        child: Text('Batal', style: TextStyle(color: AppColors.textMuted)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neoMint,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: activeWallets.isEmpty
                            ? null
                            : () {
                                final amount = RupiahInputFormatter.parse(amountController.text);
                                if (amount <= 0) {
                                  setDialogState(() {
                                    errorMessage = 'Masukkan nominal lebih dari Rp 0';
                                  });
                                  return;
                                }
                                if (selectedWalletId == null) {
                                  setDialogState(() {
                                    errorMessage = 'Pilih rekening terlebih dahulu';
                                  });
                                  return;
                                }

                                final selectedWallet = activeWallets.firstWhere((w) => w.id == selectedWalletId);
                                if (isDeposit && amount > selectedWallet.balance) {
                                  setDialogState(() {
                                    errorMessage = 'Saldo ${selectedWallet.name} tidak cukup (${currencyFormatter.format(selectedWallet.balance)})';
                                  });
                                  return;
                                }

                                if (!isDeposit && amount > pocket.currentAmount) {
                                  setDialogState(() {
                                    errorMessage = 'Saldo kantong tidak cukup (${currencyFormatter.format(pocket.currentAmount)})';
                                  });
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
                        child: Text(
                          'Konfirmasi',
                          style: TextStyle(color: AppColors.canvasBg, fontWeight: FontWeight.bold),
                        ),
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

  static IconData _getPocketIcon(String type) {
    switch (type) {
      case 'retirement':
        return Icons.elderly_outlined;
      case 'emergency':
        return Icons.shield_outlined;
      case 'goal':
        return Icons.flag_outlined;
      case 'savings':
      default:
        return Icons.savings_outlined;
    }
  }

  static String _getPocketTypeLabel(String type) {
    switch (type) {
      case 'retirement':
        return 'Alokasi Pensiun / Masa Tua';
      case 'emergency':
        return 'Dana Darurat';
      case 'goal':
        return 'Target / Impian';
      case 'savings':
      default:
        return 'Tabungan Bebas';
    }
  }
}
