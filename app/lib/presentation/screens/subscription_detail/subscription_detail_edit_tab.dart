import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../core/formatters/rupiah_input_formatter.dart';
import '../../../data/database/app_database.dart';
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
      text: NumberFormat.decimalPattern('id_ID').format(sub.cost.round()),
    );
    _dueDay = sub.dueDay;
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
    final cost = RupiahInputFormatter.parse(_costController.text);
    if (title.isEmpty || cost <= 0 || _selectedWalletId == null || _selectedCategoryId == null) {
      return;
    }

    final bloc = context.read<FinanceBloc>();
    final deadline = _isInstallment
        ? SubscriptionInstallmentSelector.calculateDeadlineDate(
            dueDay: _dueDay,
            totalCycles: _totalCycles,
          )
        : null;

    bloc.add(UpdateSubscriptionEvent(
      subscriptionId: widget.subscription.id,
      title: title,
      cost: cost,
      dueDay: _dueDay,
      walletId: _selectedWalletId!,
      categoryId: _selectedCategoryId!,
      autoDeduct: _autoDeduct,
      isInstallment: _isInstallment,
      totalCycles: _isInstallment ? _totalCycles : null,
      paidCycles: widget.subscription.paidCycles,
      deadlineDate: deadline,
    ));

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
            hintText: 'cth: Netflix, Spotify, Listrik PLN, Kosan',
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
            onToggleInstallment: (v) => setState(() => _isInstallment = v),
            onCyclesChanged: (c) => setState(() => _totalCycles = c),
          ),
          const SizedBox(height: 12),
          SubscriptionDueDaySlider(
            dueDay: _dueDay,
            onDayChanged: (d) => setState(() => _dueDay = d),
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
            text: 'Simpan Perubahan',
            onPressed: () => _saveSubscription(context),
          ),
          const SizedBox(height: 14),
          SlideToDeleteButton(
            label: _isInstallment ? 'Hapus Cicilan Ini' : 'Hapus Langganan Ini',
            onSlideComplete: () => showSubscriptionDeleteDialog(context, widget.subscription.id),
          ),
        ],
      ),
    );
  }
}
