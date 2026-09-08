import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../widgets/subscription_modal.dart';
import '../../widgets/common/common_widgets.dart';
import 'subscription_detail_pay_button.dart';

/// Interactive action buttons for subscription detail modal:
/// Mark as paid (with morph animation), edit subscription, and confirmation delete dialog.
class SubscriptionDetailActions extends StatelessWidget {
  final SubscriptionEntry subscription;
  final WalletEntry wallet;
  final VoidCallback? onEdit;

  const SubscriptionDetailActions({
    super.key,
    required this.subscription,
    required this.wallet,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isInstallment = subscription.isInstallment;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SubscriptionDetailPayButton(
            subscription: subscription,
            wallet: wallet,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.canvasBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textWhite),
              label: Text(
                isInstallment ? 'Edit Cicilan' : 'Edit Tagihan',
                style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                if (onEdit != null) {
                  onEdit!();
                } else {
                  Navigator.of(context).pop();
                  AddSubscriptionModal.show(context, subscription: subscription);
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          SlideToDeleteButton(
            label: 'Hapus',
            onSlideComplete: () => _handleDelete(context),
          ),
        ],
      ),
    );
  }

  void _handleDelete(BuildContext context) {
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
  }
}
