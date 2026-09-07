import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../widgets/subscription_modal.dart';
import '../../widgets/common/common_widgets.dart';

/// Interactive action buttons for subscription detail modal:
/// Mark as paid, edit subscription modal, and confirmation delete dialog.
class SubscriptionDetailActions extends StatelessWidget {
  final SubscriptionEntry subscription;
  final WalletEntry wallet;

  const SubscriptionDetailActions({
    super.key,
    required this.subscription,
    required this.wallet,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isPaidThisMonth = subscription.lastPaidDate != null &&
        subscription.lastPaidDate!.year == now.year &&
        subscription.lastPaidDate!.month == now.month;

    final isInstallment = subscription.isInstallment;
    final totalCycles = subscription.totalCycles ?? 0;
    final isCompleted = subscription.status == 'completed' ||
        (isInstallment && totalCycles > 0 && subscription.paidCycles >= totalCycles);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isPaidThisMonth && !isCompleted)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neoChartreuse,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.check_circle_outline, color: AppColors.textDarkPrimary),
                label: Text(
                  isInstallment
                      ? 'Bayar Cicilan Bulan Ini (${subscription.paidCycles + 1}/${totalCycles > 0 ? totalCycles : "?"})'
                      : 'Tandai Sudah Lunas Bulan Ini',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppColors.textDarkPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                onPressed: () {
                  context.read<FinanceBloc>().add(MarkSubscriptionPaidEvent(subscription.id));
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.neoMint,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      content: Text(
                        'Tagihan ${subscription.title} ditandai lunas! Saldo ${wallet.name} terpotong otomatis.',
                        style: const TextStyle(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.neoMint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.neoMint.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, color: AppColors.neoMint, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isCompleted
                          ? 'Semua cicilan telah lunas! Rencana pembiayaan ini telah selesai.'
                          : 'Tagihan periode bulan ini telah lunas tercatat di buku kas.',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.neoMint,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.canvasBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textWhite),
                  label: const Text(
                    'Edit Tagihan',
                    style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    AddSubscriptionModal.show(context, subscription: subscription);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.neoCoral.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.neoCoral),
                  label: const Text(
                    'Hapus',
                    style: TextStyle(color: AppColors.neoCoral, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    final financeBloc = context.read<FinanceBloc>();
                    final navigator = Navigator.of(context);
                    AppConfirmationDialog.show(
                      context,
                      title: 'Hapus Tagihan?',
                      content: 'Tagihan ini akan dihapus dari daftar monitoring komitmen bulanan.',
                      confirmText: 'Hapus',
                      confirmColor: AppColors.neoCoral,
                      onConfirm: () {
                        financeBloc.add(DeleteSubscriptionEvent(subscription.id));
                        navigator.maybePop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
