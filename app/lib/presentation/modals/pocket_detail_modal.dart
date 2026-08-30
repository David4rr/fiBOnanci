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

class PocketDetailModal {
  static void show(BuildContext context, {required PocketEntry pocket}) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final Color pocketColor = Color(int.parse(pocket.colorHex.replaceAll('#', '0xFF')));
    final double? target = pocket.targetAmount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            // Find latest pocket record from state if available
            final latestPocket = state.pockets.firstWhere(
              (p) => p.id == pocket.id,
              orElse: () => pocket,
            );
            final latestCurrent = latestPocket.currentAmount;
            final latestProgress = (target != null && target > 0)
                ? (latestCurrent / target).clamp(0.0, 1.0)
                : 1.0;

            return Padding(
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
                              _showTransferDialog(
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
                                    _showTransferDialog(
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
                  const SizedBox(height: 12),

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
            );
          },
        );
      },
    );
  }

  static void _showTransferDialog(
    BuildContext context, {
    required PocketEntry pocket,
    required bool isDeposit,
  }) {
    final amountController = TextEditingController();
    String? selectedWalletId;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return BlocBuilder<FinanceBloc, FinanceState>(
          builder: (ctx, state) {
            final activeWallets = state.wallets;
            if (selectedWalletId == null && activeWallets.isNotEmpty) {
              selectedWalletId = activeWallets.first.id;
            }

            return AlertDialog(
              backgroundColor: AppColors.canvasCardSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                isDeposit ? 'Isi Dana ke Kantong' : 'Tarik Dana ke Rekening',
                style: AppTypography.sectionTitle,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDeposit
                        ? 'Pilih rekening asal untuk memindahkan dana ke ${pocket.name}.'
                        : 'Pilih rekening tujuan penarikan dari ${pocket.name}.',
                    style: AppTypography.listSubtitle,
                  ),
                  const SizedBox(height: 14),
                  if (activeWallets.isNotEmpty) ...[
                    Text(
                      isDeposit ? 'Rekening Sumber' : 'Rekening Tujuan',
                      style: AppTypography.listSubtitle,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.canvasInputSearch,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedWalletId,
                          isExpanded: true,
                          dropdownColor: AppColors.canvasCardSurface,
                          items: activeWallets.map((w) {
                            return DropdownMenuItem<String>(
                              value: w.id,
                              child: Text(
                                '${w.name} (Saldo: Rp ${w.balance.toStringAsFixed(0)})',
                                style: AppTypography.listSubtitle.copyWith(color: AppColors.textWhite),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              selectedWalletId = val;
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      RupiahInputFormatter(),
                    ],
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
                ],
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
                  onPressed: () {
                    final amount = RupiahInputFormatter.parse(amountController.text);
                    if (amount <= 0 || selectedWalletId == null) return;

                    context.read<FinanceBloc>().add(
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
