import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../core/formatters/app_currency.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import 'transaction_modal_form.dart';
import 'transaction_modal_selectors.dart';

export 'transaction_modal_selectors.dart';

class TransactionModal extends StatefulWidget {
  final String? initialWalletId;
  final SmartInputSource? initialInputSource;
  final SmartTransactionDraft? initialDraft;
  final VoidCallback? onClose, onSaved;
  final bool isInline;

  const TransactionModal({
    super.key, this.initialWalletId, this.initialInputSource, this.initialDraft, this.onClose, this.onSaved, this.isInline = false,
  });

  static Future<void> show(BuildContext context, {String? initialWalletId, SmartInputSource? initialInputSource, SmartTransactionDraft? initialDraft}) =>
      showModalBottomSheet<void>(
        context: context, isScrollControlled: true, backgroundColor: AppColors.canvasCardSurface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        clipBehavior: Clip.antiAlias,
        builder: (ctx) => TransactionModal(initialWalletId: initialWalletId, initialInputSource: initialInputSource, initialDraft: initialDraft),
      );
  @override
  State<TransactionModal> createState() => _TransactionModalState();
}

class _TransactionModalState extends State<TransactionModal> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _type = 'expense';
  String? _selectedWalletId, _selectedDestinationWalletId, _selectedCategoryId, _selectedTargetProfileId;
  List<WalletEntry> _targetProfileWallets = const [];

  @override
  void initState() {
    super.initState();
    final state = context.read<FinanceBloc>().state;
    _selectedTargetProfileId = state.profile.id;
    if (state.wallets.isNotEmpty) {
      _selectedWalletId = (widget.initialWalletId != null && state.wallets.any((w) => w.id == widget.initialWalletId))
          ? widget.initialWalletId : state.wallets.first.id;
      final others = state.wallets.where((w) => w.id != _selectedWalletId).toList();
      _selectedDestinationWalletId = others.isNotEmpty ? others.first.id : (state.wallets.length > 1 ? state.wallets[1].id : null);
    }
    final initialCats = state.categories.where((c) => c.type == _type).toList();
    if (initialCats.isNotEmpty) _selectedCategoryId = initialCats.first.id;
    if (widget.initialDraft != null) _applyDraft(widget.initialDraft!);
    if (widget.initialInputSource != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _triggerSmartInput(widget.initialInputSource!); });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _applyDraft(SmartTransactionDraft draft) {
    _type = draft.type;
    if (draft.amount != null && draft.amount! > 0) _amountController.text = NumberFormat.decimalPattern('id_ID').format(draft.amount!.round());
    _selectedWalletId = draft.walletId ?? _selectedWalletId;
    _selectedDestinationWalletId = draft.destinationWalletId ?? _selectedDestinationWalletId;
    _selectedCategoryId = draft.categoryId ?? _selectedCategoryId;
    if (draft.notes != null && draft.notes!.isNotEmpty) _notesController.text = draft.notes!;
  }

  Future<void> _triggerSmartInput(SmartInputSource source) async {
    final state = context.read<FinanceBloc>().state;
    final draft = await executeSmartTransactionCapture(
      context, source: source, wallets: state.wallets, categories: state.categories, preferredWalletId: _selectedWalletId,
    );
    if (!mounted || draft == null || !draft.hasMeaningfulData) return;
    setState(() => _applyDraft(draft));
    HapticFeedback.mediumImpact();
  }

  Future<void> _handleTargetProfileChanged(String profileId, ProfileEntry currentProfile) async {
    setState(() => _selectedTargetProfileId = profileId);
    if (profileId != currentProfile.id) {
      final wallets = await context.read<FinanceBloc>().repository.getWallets(profileId: profileId);
      if (mounted && _selectedTargetProfileId == profileId) {
        setState(() {
          _targetProfileWallets = wallets;
          _selectedDestinationWalletId = wallets.isNotEmpty ? wallets.first.id : null;
        });
      }
    } else {
      final others = context.read<FinanceBloc>().state.wallets.where((w) => w.id != _selectedWalletId).toList();
      setState(() => _selectedDestinationWalletId = others.isNotEmpty ? others.first.id : null);
    }
  }

  void _onSave() {
    final amount = AppCurrency.parseInputOf(context, _amountController.text);
    if (amount <= 0 || _selectedWalletId == null || (_type != 'transfer' && _selectedCategoryId == null)) return;
    final state = context.read<FinanceBloc>().state;
    final isCross = _type == 'transfer' && _selectedTargetProfileId != null && _selectedTargetProfileId != state.profile.id;
    if (isCross && _selectedDestinationWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih rekening tujuan di profil tujuan!')));
      return;
    }
    if (!isCross && _type == 'transfer' && (_selectedDestinationWalletId == null || _selectedDestinationWalletId == _selectedWalletId)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih rekening tujuan yang berbeda dari rekening asal!')));
      return;
    }
    final note = _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null;
    if (isCross) {
      context.read<FinanceBloc>().add(TransferCrossProfileEvent(
        sourceWalletId: _selectedWalletId!, destinationWalletId: _selectedDestinationWalletId!, amount: amount, notes: note, transactionDate: DateTime.now(),
      ));
    } else {
      context.read<FinanceBloc>().add(AddTransactionEvent(
        walletId: _selectedWalletId!, amount: amount, type: _type, transactionDate: DateTime.now(),
        categoryId: _type == 'transfer' ? '11111111-1111-4111-8111-111111111111' : _selectedCategoryId!,
        destinationWalletId: _type == 'transfer' ? _selectedDestinationWalletId : null, notes: note,
      ));
    }
    if (widget.onSaved != null) { widget.onSaved!(); } else { Navigator.pop(context); }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final state = context.watch<FinanceBloc>().state;
    if (_selectedWalletId == null || !state.wallets.any((w) => w.id == _selectedWalletId)) {
      _selectedWalletId = state.wallets.isNotEmpty ? state.wallets.first.id : null;
    }
    final isCross = _type == 'transfer' && _selectedTargetProfileId != null && _selectedTargetProfileId != state.profile.id;
    final destWallets = isCross ? _targetProfileWallets : state.wallets.where((w) => w.id != _selectedWalletId).toList();
    if (_selectedDestinationWalletId == null || !destWallets.any((w) => w.id == _selectedDestinationWalletId)) {
      _selectedDestinationWalletId = destWallets.isNotEmpty ? destWallets.first.id : null;
    }
    final matchingCats = state.categories.where((c) => c.type == _type).toList();
    if (_type != 'transfer' && (_selectedCategoryId == null || !matchingCats.any((c) => c.id == _selectedCategoryId))) {
      _selectedCategoryId = matchingCats.isNotEmpty ? matchingCats.first.id : null;
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.canvasCardSurface,
        borderRadius: widget.isInline ? BorderRadius.zero : const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: widget.isInline ? EdgeInsets.fromLTRB(20, 16, 20, 48 + bottomInset) : EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.isInline)
                TransactionModalHeaderView(type: _type, onClose: widget.onClose ?? () => Navigator.pop(context)),
              TransactionFormInputs(
                type: _type,
                onTypeChanged: (t) => setState(() {
                  _type = t;
                  final cats = state.categories.where((c) => c.type == t).toList();
                  _selectedCategoryId = cats.isNotEmpty ? cats.first.id : null;
                }),
                amountController: _amountController,
                selectedWalletId: _selectedWalletId,
                wallets: state.wallets,
                onWalletChanged: (val) => setState(() => _selectedWalletId = val),
                profiles: state.profiles,
                currentProfile: state.profile,
                selectedTargetProfileId: _selectedTargetProfileId ?? state.profile.id,
                onTargetProfileChanged: (pId) => _handleTargetProfileChanged(pId, state.profile),
                selectedDestinationWalletId: _selectedDestinationWalletId,
                destWallets: destWallets,
                onDestinationWalletChanged: (val) => setState(() => _selectedDestinationWalletId = val),
                selectedCategoryId: _selectedCategoryId,
                matchingCats: matchingCats,
                onCategoryChanged: (val) => setState(() => _selectedCategoryId = val),
                notesController: _notesController,
                onCancel: widget.onClose ?? () => Navigator.pop(context),
                onSave: _onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
