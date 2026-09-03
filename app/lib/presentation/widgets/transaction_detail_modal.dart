import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/formatters/rupiah_input_formatter.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'transaction_detail_components.dart';
import 'transaction_modal_selectors.dart';

export 'transaction_detail_components.dart';

class TransactionDetailModal extends StatefulWidget {
  final TransactionEntry transaction;
  const TransactionDetailModal({super.key, required this.transaction});

  static Future<void> show(BuildContext context, {required TransactionEntry transaction}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => TransactionDetailModal(transaction: transaction),
    );
  }

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
      newWalletId: _walletId,
      newAmount: newAmount,
      newType: _type,
      newCategoryId: _categoryId,
      newDestinationWalletId: _type == 'transfer' ? _destinationWalletId : null,
      newNotes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    ));
    Navigator.pop(context);
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
    _categoryId = categories.any((c) => c.id == _categoryId) ? _categoryId : (categories.isNotEmpty ? categories.first.id : '');

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textSubtle, borderRadius: BorderRadius.circular(2)))),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Edit Transaksi', style: AppTypography.sectionTitle),
                    const SizedBox(height: 4),
                    Text('Ubah kategori, rekening, atau nominal', style: AppTypography.listSubtitle),
                  ]),
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: AppColors.textWhite, size: 18)),
              ],
            ),
            const SizedBox(height: 16),
            TransactionTypeToggle(selectedType: _type, onTypeChanged: (t) => setState(() => _type = t)),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, RupiahInputFormatter()],
              style: AppTypography.heroGreeting.copyWith(color: AppColors.textWhite),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                prefixStyle: AppTypography.heroGreeting.copyWith(color: AppColors.neoChartreuse),
                filled: true,
                fillColor: AppColors.canvasInputSearch,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
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
                  items: categories.where((c) => c.type == _type).map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: AppTypography.listTitle))).toList(),
                  onChanged: (v) => setState(() => _categoryId = v!),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              style: AppTypography.listTitle,
              decoration: InputDecoration(
                hintText: 'Catatan (Opsional)',
                hintStyle: AppTypography.listSubtitle,
                filled: true,
                fillColor: AppColors.canvasInputSearch,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            TransactionDetailComponents.buildActionButtons(context: context, onSave: () => _saveChanges(context)),
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: AppColors.neoCoral),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: Text('Hapus Transaksi', style: AppTypography.listTitle.copyWith(color: AppColors.neoCoral, fontSize: 13, fontWeight: FontWeight.w700)),
                onPressed: () => TransactionDetailComponents.showDeleteDialog(context, widget.transaction.id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
