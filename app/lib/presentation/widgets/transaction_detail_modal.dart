import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/formatters/rupiah_input_formatter.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'transaction_detail_components.dart';
import 'transaction_modal_selectors.dart';
import 'common/common_widgets.dart';

export 'transaction_detail_components.dart';

class TransactionDetailModal extends StatefulWidget {
  final TransactionEntry transaction;
  final VoidCallback? onClose;
  final VoidCallback? onSaved;
  final VoidCallback? onDeleted;
  final bool isInline;

  const TransactionDetailModal({
    super.key,
    required this.transaction,
    this.onClose,
    this.onSaved,
    this.onDeleted,
    this.isInline = false,
  });

  static Future<void> show(BuildContext context, {required TransactionEntry transaction}) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: AppColors.canvasCardSurface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        builder: (_) => TransactionDetailModal(transaction: transaction),
      );

  @override
  State<TransactionDetailModal> createState() => _TransactionDetailModalState();
}

class _TransactionDetailModalState extends State<TransactionDetailModal> {
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late String _type;
  late String _walletId;
  late String _categoryId;
  String? _destinationWalletId;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: RupiahInputFormatter.format(widget.transaction.amount));
    _notesController = TextEditingController(text: widget.transaction.notes ?? '');
    _type = widget.transaction.type;
    _walletId = widget.transaction.walletId;
    _categoryId = widget.transaction.categoryId;
    _destinationWalletId = widget.transaction.destinationWalletId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveChanges(BuildContext context) {
    final newAmount = RupiahInputFormatter.parse(_amountController.text);
    if (newAmount <= 0) return;
    if (_type == 'transfer' && _walletId == _destinationWalletId) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rekening asal dan tujuan tidak boleh sama!')));
      return;
    }
    context.read<FinanceBloc>().add(UpdateTransactionEvent(
      transactionId: widget.transaction.id,
      newAmount: newAmount,
      newCategoryId: _type == 'transfer' ? '11111111-1111-4111-8111-111111111111' : _categoryId,
      newNotes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      newType: _type,
      newWalletId: _walletId,
      newDestinationWalletId: _type == 'transfer' ? _destinationWalletId : null,
    ));
    if (widget.onSaved != null) {
      widget.onSaved!();
    } else {
      Navigator.pop(context);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(backgroundColor: AppColors.neoMint, content: Text('Perubahan transaksi & saldo dompet berhasil diperbarui!', style: TextStyle(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final state = context.watch<FinanceBloc>().state;
    final wallets = state.wallets;
    final categories = state.categories;

    _walletId = wallets.any((w) => w.id == _walletId) ? _walletId : (wallets.isNotEmpty ? wallets.first.id : '');
    if (_destinationWalletId == null && wallets.length > 1) {
      _destinationWalletId = wallets.firstWhere((w) => w.id != _walletId, orElse: () => wallets.last).id;
    }
    final matchingCats = categories.where((c) => c.type == _type).toList();
    if (_type != 'transfer' && !matchingCats.any((c) => c.id == _categoryId)) {
      _categoryId = matchingCats.isNotEmpty ? matchingCats.first.id : '';
    }

    return ColoredBox(
      color: AppColors.canvasCardSurface,
      child: Padding(
        padding: widget.isInline ? EdgeInsets.fromLTRB(20, 16, 20, 48 + bottomInset) : EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
        child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.isInline) ...[
              const ModalGrabHandle(padding: EdgeInsets.only(bottom: 14)),
              ModalHeader(
                title: 'Edit Transaksi',
                subtitle: 'Ubah kategori, rekening, atau nominal',
                onClose: widget.onClose ?? () => Navigator.pop(context),
              ),
            ],
            TransactionTypeToggle(
              selectedType: _type,
              onTypeChanged: (t) => setState(() {
                _type = t;
                final matching = categories.where((c) => c.type == t).toList();
                if (t != 'transfer' && !matching.any((c) => c.id == _categoryId)) {
                  _categoryId = matching.isNotEmpty ? matching.first.id : '';
                }
              }),
            ),
            const SizedBox(height: 16),
            CurrencyAmountField(controller: _amountController),
            const SizedBox(height: 14),
            Text('REKENING PENYIMPANAN', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 6),
            TransactionDetailComponents.buildWalletDropdown(wallets: wallets, selectedId: _walletId, onChanged: (v) => setState(() => _walletId = v!)),
            if (_type == 'transfer') ...[
              const SizedBox(height: 12),
              Text('Rekening Tujuan', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 6),
              TransactionDetailComponents.buildWalletDropdown(wallets: wallets.where((w) => w.id != _walletId).toList(), selectedId: _destinationWalletId, onChanged: (v) => setState(() => _destinationWalletId = v)),
            ] else ...[
              const SizedBox(height: 12),
              Text('Kategori', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 6),
              TransactionDropdownContainer(
                child: DropdownButton<String>(
                  value: _categoryId.isNotEmpty ? _categoryId : null,
                  isExpanded: true,
                  dropdownColor: AppColors.canvasCardSurface,
                  items: matchingCats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: AppTypography.listTitle))).toList(),
                  onChanged: (v) => setState(() => _categoryId = v!),
                ),
              ),
            ],
            const SizedBox(height: 12),
            AppTextField(
              controller: _notesController,
              hintText: 'Catatan (Opsional)',
            ),
            const SizedBox(height: 24),
            TransactionDetailComponents.buildActionButtons(
              context: context,
              onSave: () => _saveChanges(context),
              onCancel: widget.onClose,
            ),
            const SizedBox(height: 14),
            SlideToDeleteButton(
              label: 'Hapus Transaksi',
              onSlideComplete: () => TransactionDetailComponents.showDeleteDialog(
                context,
                widget.transaction.id,
                onDeleted: widget.onDeleted,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
