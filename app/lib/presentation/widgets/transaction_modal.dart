import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../core/formatters/rupiah_input_formatter.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'common/common_widgets.dart';
import 'transaction_modal_selectors.dart';

export 'transaction_modal_selectors.dart';

class TransactionModal extends StatefulWidget {
  final String? initialWalletId;

  const TransactionModal({super.key, this.initialWalletId});

  static Future<void> show(BuildContext context, {String? initialWalletId}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => TransactionModal(initialWalletId: initialWalletId),
    );
  }

  @override
  State<TransactionModal> createState() => _TransactionModalState();
}

class _TransactionModalState extends State<TransactionModal> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _type = 'expense';
  String? _selectedWalletId;
  String? _selectedDestinationWalletId;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final state = context.read<FinanceBloc>().state;
    if (state.wallets.isNotEmpty) {
      _selectedWalletId = (widget.initialWalletId != null && state.wallets.any((w) => w.id == widget.initialWalletId))
          ? widget.initialWalletId
          : state.wallets.first.id;
      final others = state.wallets.where((w) => w.id != _selectedWalletId).toList();
      _selectedDestinationWalletId = others.isNotEmpty ? others.first.id : (state.wallets.length > 1 ? state.wallets[1].id : null);
    }
    final initialCats = state.categories.where((c) => c.type == _type).toList();
    if (initialCats.isNotEmpty) _selectedCategoryId = initialCats.first.id;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onSave() {
    final amount = RupiahInputFormatter.parse(_amountController.text);
    if (amount <= 0 || _selectedWalletId == null || (_type != 'transfer' && _selectedCategoryId == null)) return;
    context.read<FinanceBloc>().add(
      AddTransactionEvent(
        walletId: _selectedWalletId!,
        categoryId: _type == 'transfer' ? '11111111-1111-4111-8111-111111111111' : _selectedCategoryId!,
        amount: amount,
        type: _type,
        destinationWalletId: _type == 'transfer' ? _selectedDestinationWalletId : null,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        transactionDate: DateTime.now(),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final state = context.watch<FinanceBloc>().state;
    final matchingCats = state.categories.where((c) => c.type == _type).toList();
    if (_type != 'transfer' && (_selectedCategoryId == null || !matchingCats.any((c) => c.id == _selectedCategoryId))) {
      _selectedCategoryId = matchingCats.isNotEmpty ? matchingCats.first.id : null;
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.canvasCardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ModalGrabHandle(padding: EdgeInsets.only(bottom: 14)),
            ModalHeader(
              title: 'Catat Transaksi',
              subtitle: 'Catatan instan tanpa loading',
              onClose: () => Navigator.pop(context),
            ),
            TransactionTypeToggle(
              selectedType: _type,
              onTypeChanged: (t) => setState(() {
                _type = t;
                final cats = state.categories.where((c) => c.type == t).toList();
                _selectedCategoryId = cats.isNotEmpty ? cats.first.id : null;
              }),
            ),
            const SizedBox(height: 16),
            CurrencyAmountField(controller: _amountController),
            const SizedBox(height: 12),
            TransactionDropdownContainer(
              child: DropdownButton<String>(
                value: _selectedWalletId,
                isExpanded: true,
                dropdownColor: AppColors.canvasCardSurface,
                hint: Text(_type == 'transfer' ? 'Pilih Rekening Asal' : 'Pilih Rekening', style: AppTypography.listSubtitle),
                items: state.wallets.map((w) => DropdownMenuItem(value: w.id, child: Text(w.name, style: AppTypography.listTitle))).toList(),
                onChanged: (val) => setState(() => _selectedWalletId = val),
              ),
            ),
            const SizedBox(height: 12),
            if (_type == 'transfer')
              TransactionDropdownContainer(
                child: DropdownButton<String>(
                  value: _selectedDestinationWalletId,
                  isExpanded: true,
                  dropdownColor: AppColors.canvasCardSurface,
                  hint: Text('Pilih Rekening Tujuan', style: AppTypography.listSubtitle),
                  items: state.wallets.where((w) => w.id != _selectedWalletId).map((w) => DropdownMenuItem(value: w.id, child: Text(w.name, style: AppTypography.listTitle))).toList(),
                  onChanged: (val) => setState(() => _selectedDestinationWalletId = val),
                ),
              )
            else
              TransactionDropdownContainer(
                child: DropdownButton<String>(
                  value: _selectedCategoryId,
                  isExpanded: true,
                  dropdownColor: AppColors.canvasCardSurface,
                  hint: Text('Pilih Kategori', style: AppTypography.listSubtitle),
                  items: matchingCats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: AppTypography.listTitle))).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                ),
              ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _notesController,
              hintText: 'Catatan (Opsional)',
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.canvasBorder), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      onPressed: () => Navigator.pop(context),
                      child: Text('Batal', style: AppTypography.listTitle.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: PrimaryActionButton(
                    text: 'Simpan Transaksi',
                    onPressed: _onSave,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  }
}
