import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../core/l10n/locale_notifier.dart';
import '../../data/database/app_database.dart';
import '../../domain/services/subscription_schedule_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'common/common_widgets.dart';

export 'subscription_due_day_slider.dart';
export 'subscription_start_cycle_selector.dart';

class SubscriptionWalletDropdown extends StatelessWidget {
  final List<WalletEntry> wallets;
  final String? selectedWalletId;
  final ValueChanged<String?> onWalletChanged;

  const SubscriptionWalletDropdown({
    super.key,
    required this.wallets,
    required this.selectedWalletId,
    required this.onWalletChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppL10n.of(context).subModalPaymentSource, style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.canvasInputSearch,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.canvasBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedWalletId,
              isExpanded: true,
              dropdownColor: AppColors.canvasCardSurface,
              style: AppTypography.listTitle,
              items: wallets.map((w) => DropdownMenuItem<String>(value: w.id, child: Text(w.name))).toList(),
              onChanged: onWalletChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class SubscriptionAutoDeductSwitch extends StatelessWidget {
  final bool autoDeduct;
  final ValueChanged<bool> onToggle;

  const SubscriptionAutoDeductSwitch({
    super.key,
    required this.autoDeduct,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.canvasInputSearch,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.canvasBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppL10n.of(context).subModalAutoDeductTitle, style: AppTypography.listTitle),
                const SizedBox(height: 2),
                Text(AppL10n.of(context).subModalAutoDeductSubtitle, style: AppTypography.listSubtitle, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: autoDeduct,
            activeThumbColor: AppColors.neoChartreuse,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}

void executeDeleteSubscription(BuildContext context, String subscriptionId, {VoidCallback? onDeleted}) {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppL10n.of(context);
  final navigator = Navigator.of(context);
  context.read<FinanceBloc>().add(DeleteSubscriptionEvent(subscriptionId));
  if (onDeleted != null) {
    onDeleted();
  } else {
    navigator.maybePop();
  }
  AppSnackBar.showWithMessenger(
    messenger,
    title: l10n.subDeletedSnackTitle,
    message: l10n.subDeletedSnackMsg,
    type: AppSnackBarType.error,
    tag: l10n.subDeletedSnackTag,
  );
}

void showSubscriptionDeleteDialog(BuildContext context, String subscriptionId) {
  executeDeleteSubscription(context, subscriptionId);
}

class SubscriptionDeleteButton extends StatelessWidget {
  final String subscriptionId;
  const SubscriptionDeleteButton({super.key, required this.subscriptionId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        style: TextButton.styleFrom(foregroundColor: AppColors.neoCoral),
        icon: const Icon(Icons.delete_outline_rounded, size: 18),
        label: Text(AppL10n.of(context).subDeleteThisBtn, style: AppTypography.listTitle.copyWith(color: AppColors.neoCoral, fontSize: 13, fontWeight: FontWeight.w700)),
        onPressed: () => showSubscriptionDeleteDialog(context, subscriptionId),
      ),
    );
  }
}

void dispatchSaveSubscription(
  BuildContext context, {
  SubscriptionEntry? existing,
  required String title,
  required double cost,
  required int dueDay,
  required DateTime nextDueDate,
  required String walletId,
  required String categoryId,
  required bool autoDeduct,
  required bool isInstallment,
  required int totalCycles,
}) {
  final bloc = context.read<FinanceBloc>();
  final deadline = isInstallment
      ? SubscriptionScheduleService.calculateInstallmentDeadline(
          firstDueDate: nextDueDate,
          dueDay: dueDay,
          totalCycles: totalCycles,
          paidCycles: existing?.paidCycles ?? 0,
        )
      : null;
  if (existing != null) {
    bloc.add(UpdateSubscriptionEvent(
      subscriptionId: existing.id,
      title: title,
      cost: cost,
      dueDay: dueDay,
      nextDueDate: nextDueDate,
      walletId: walletId,
      categoryId: categoryId,
      autoDeduct: autoDeduct,
      isInstallment: isInstallment,
      totalCycles: isInstallment ? totalCycles : null,
      paidCycles: existing.paidCycles,
      deadlineDate: deadline,
    ));
  } else {
    bloc.add(AddSubscriptionEvent(
      title: title,
      cost: cost,
      dueDay: dueDay,
      nextDueDate: nextDueDate,
      walletId: walletId,
      categoryId: categoryId,
      autoDeduct: autoDeduct,
      isInstallment: isInstallment,
      totalCycles: isInstallment ? totalCycles : null,
      deadlineDate: deadline,
    ));
  }
}
