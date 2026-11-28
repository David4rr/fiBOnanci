import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/finance/finance_bloc.dart';
import '../../../core/formatters/app_currency.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/services/subscription_schedule_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/subscription_installment_selector.dart';
import '../../widgets/subscription_modal_selectors.dart';

/// Full-height edit view for installments and subscriptions embedded as a
/// sliding tab inside [SubscriptionDetailScreen].
class SubscriptionDetailEditTab extends StatefulWidget {
  final SubscriptionEntry subscription;
  final VoidCallback? onSaved;
  final VoidCallback? onReturnToDetails;

  const SubscriptionDetailEditTab({
    super.key,
    required this.subscription,
    this.onSaved,
    this.onReturnToDetails,
  });

  @override
  State<SubscriptionDetailEditTab> createState() => _SubscriptionDetailEditTabState();
}

class _SubscriptionDetailEditTabState extends State<SubscriptionDetailEditTab> {
  late final TextEditingController _titleController;
  late final TextEditingController _costController;
  late int _dueDay;
  late DateTime _nextDueDate;
  late bool _autoDeduct;
  late bool _isInstallment;
  late int _totalCycles;
  String? _selectedWalletId;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final sub = widget.subscription;
    _titleController = TextEditingController(text: sub.title);
    _costController = TextEditingController(
      text: AppCurrency.formatInputOf(context, sub.cost),
    );
    _dueDay = sub.dueDay;
    _nextDueDate = SubscriptionScheduleService.dateOnly(sub.nextDueDate);
    _autoDeduct = sub.autoDeduct;
    _isInstallment = sub.isInstallment;
    _totalCycles = sub.totalCycles ?? 3;
    _selectedWalletId = sub.walletId;
    _selectedCategoryId = sub.categoryId;
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
    if (title.isEmpty || cost <= 0 || _selectedWalletId == null || _selectedCategoryId == null) {
      return;
    }
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
    if (widget.onSaved != null) {
      widget.onSaved!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FinanceBloc>().state;
    final wallets = state.wallets;
    final safeWalletId = wallets.any((w) => w.id == _selectedWalletId)
        ? _selectedWalletId
        : (wallets.isNotEmpty ? wallets.first.id : null);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _titleController,
            hintText: AppL10n.of(context).subsHintExample,
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
            paidCycles: widget.subscription.paidCycles,
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
                preserveMonth: true,
                referenceDate: DateTime.now(),
              );
            }),
            onNextDueDateChanged: (dt) => setState(() {
              _dueDay = dt.day;
              _nextDueDate = dt;
            }),
          ),
          const SizedBox(height: 8),
          SubscriptionWalletDropdown(
            wallets: wallets,
            selectedWalletId: safeWalletId,
            onWalletChanged: (v) => setState(() => _selectedWalletId = v),
          ),
          const SizedBox(height: 12),
          SubscriptionAutoDeductSwitch(
            autoDeduct: _autoDeduct,
            onToggle: (val) => setState(() => _autoDeduct = val),
          ),
          const SizedBox(height: 20),
          PrimaryActionButton(
            text: AppL10n.of(context).inboxEditSaveBtn,
            onPressed: () => _saveSubscription(context),
          ),
          const SizedBox(height: 14),
          SlideToDeleteButton(
            label: _isInstallment ? AppL10n.of(context).subsDeleteInstallment : AppL10n.of(context).subsDeleteSub,
            onSlideComplete: () => executeDeleteSubscription(context, widget.subscription.id),
          ),
        ],
      ),
    );
  }
}
