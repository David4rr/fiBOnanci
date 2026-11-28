import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/formatters/app_currency.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../data/database/app_database.dart';
import '../../core/l10n/locale_notifier.dart';
import '../../domain/services/subscription_schedule_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'common/common_widgets.dart';
import 'subscription_installment_selector.dart';
import 'subscription_modal_selectors.dart';

export 'subscription_modal_selectors.dart';

class AddSubscriptionModal extends StatefulWidget {
  final SubscriptionEntry? subscription;
  const AddSubscriptionModal({super.key, this.subscription});

  static Future<void> show(BuildContext context, {SubscriptionEntry? subscription}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => AddSubscriptionModal(subscription: subscription),
    );
  }

  @override
  State<AddSubscriptionModal> createState() => _AddSubscriptionModalState();
}

class _AddSubscriptionModalState extends State<AddSubscriptionModal> {
  late final TextEditingController _titleController;
  late final TextEditingController _costController;
  late int _dueDay;
  late DateTime _nextDueDate;
  late bool _hasManualCycleOverride;
  late bool _autoDeduct;
  late bool _isInstallment;
  late int _totalCycles;
  String? _selectedWalletId;
  String? _selectedCategoryId;
  @override
  void initState() {
    super.initState();
    final sub = widget.subscription;
    if (sub != null) {
      _titleController = TextEditingController(text: sub.title);
      _costController = TextEditingController(text: AppCurrency.formatInputOf(context, sub.cost));
      _dueDay = sub.dueDay;
      _nextDueDate = SubscriptionScheduleService.dateOnly(sub.nextDueDate);
      _hasManualCycleOverride = true;
      _autoDeduct = sub.autoDeduct;
      _isInstallment = sub.isInstallment;
      _totalCycles = sub.totalCycles ?? 3;
      _selectedWalletId = sub.walletId;
      _selectedCategoryId = sub.categoryId;
    } else {
      final now = DateTime.now();
      _titleController = TextEditingController();
      _costController = TextEditingController();
      _dueDay = 15;
      _nextDueDate = SubscriptionScheduleService.resolveFirstDueDate(
        dueDay: _dueDay,
        monthOffset: SubscriptionScheduleService.defaultMonthOffset(dueDay: _dueDay, referenceDate: now),
        referenceDate: now,
      );
      _hasManualCycleOverride = false;
      _autoDeduct = false;
      _isInstallment = false;
      _totalCycles = 3;
      final state = context.read<FinanceBloc>().state;
      if (state.wallets.isNotEmpty) _selectedWalletId = state.wallets.first.id;
      if (state.categories.isNotEmpty) {
        _selectedCategoryId = state.categories.firstWhere(
          (c) => c.name.contains('Tagihan') || c.name.contains('Hiburan'),
          orElse: () => state.categories.first,
        ).id;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _saveSubscription(BuildContext context) {
    final title = _titleController.text.trim();
    final cost = AppCurrency.parseInputOf(context, _costController.text);
    if (title.isEmpty || cost <= 0 || _selectedWalletId == null || _selectedCategoryId == null) return;
    dispatchSaveSubscription(
      context,
      existing: widget.subscription,
      title: title,
      cost: cost,
      dueDay: _dueDay,
      nextDueDate: _nextDueDate,
      walletId: _selectedWalletId!,
      categoryId: _selectedCategoryId!,
      autoDeduct: _autoDeduct,
      isInstallment: _isInstallment,
      totalCycles: _totalCycles,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.subscription != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final state = context.watch<FinanceBloc>().state;
    final wallets = state.wallets;
    final safeWalletId = wallets.any((w) => w.id == _selectedWalletId) ? _selectedWalletId : (wallets.isNotEmpty ? wallets.first.id : null);

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ModalGrabHandle(padding: EdgeInsets.only(bottom: 14)),
            ModalHeader(
              title: isEditing
                  ? (_isInstallment ? AppL10n.of(context).subModalEditInstallment : AppL10n.of(context).subModalEditBill)
                  : (_isInstallment ? AppL10n.of(context).subModalAddInstallment : AppL10n.of(context).subModalAddBill),
              subtitle: _isInstallment
                  ? AppL10n.of(context).subModalSubInstallment
                  : AppL10n.of(context).subModalSubBill,
              titleStyle: AppTypography.modalTitle,
              subtitleStyle: AppTypography.modalSubtitle,
              onClose: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _titleController,
              hintText: AppL10n.of(context).hintSubscriptionTitle,
            ),
            const SizedBox(height: 12),
            CurrencyAmountField(
              controller: _costController,
              prefixColor: AppColors.neoCoral,
            ),
            const SizedBox(height: 12),
            SubscriptionInstallmentSelector(
              isInstallment: _isInstallment,
              totalCycles: _totalCycles,
              dueDay: _dueDay,
              firstDueDate: _nextDueDate,
              paidCycles: widget.subscription?.paidCycles ?? 0,
              onToggleInstallment: (v) => setState(() => _isInstallment = v),
              onCyclesChanged: (c) => setState(() => _totalCycles = c),
            ),
            const SizedBox(height: 12),
            SubscriptionDueSchedulePicker(
              dueDay: _dueDay,
              nextDueDate: _nextDueDate,
              onDayChanged: (d) => setState(() {
                _dueDay = d;
                _nextDueDate = SubscriptionScheduleService.applyDayChange(
                  currentNextDueDate: _nextDueDate,
                  newDueDay: d,
                  preserveMonth: _hasManualCycleOverride,
                  referenceDate: DateTime.now(),
                );
              }),
              onNextDueDateChanged: (dt) => setState(() {
                _hasManualCycleOverride = true;
                _dueDay = dt.day;
                _nextDueDate = dt;
              }),
            ),
            const SizedBox(height: 12),
            SubscriptionWalletDropdown(wallets: wallets, selectedWalletId: safeWalletId, onWalletChanged: (v) => setState(() => _selectedWalletId = v)),
            const SizedBox(height: 12),
            SubscriptionAutoDeductSwitch(autoDeduct: _autoDeduct, onToggle: (val) => setState(() => _autoDeduct = val)),
            const SizedBox(height: 20),
            PrimaryActionButton(
              text: isEditing ? AppL10n.of(context).subModalSaveChanges : AppL10n.of(context).subModalSaveBill,
              onPressed: () => _saveSubscription(context),
            ),
            if (isEditing) ...[
              const SizedBox(height: 12),
              SubscriptionDeleteButton(subscriptionId: widget.subscription!.id),
            ],
          ],
        ),
      ),
    );
  }
}
