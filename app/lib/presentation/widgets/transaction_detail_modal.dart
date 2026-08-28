import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class TransactionDetailModal extends StatefulWidget {
  final AppDatabase db;
  final TransactionEntry transaction;

  const TransactionDetailModal({
    super.key,
    required this.db,
    required this.transaction,
  });

  static Future<void> show(
    BuildContext context, {
    required AppDatabase db,
    required TransactionEntry transaction,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => TransactionDetailModal(
        db: db,
        transaction: transaction,
      ),
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
    _amountController = TextEditingController(
      text: widget.transaction.amount.toStringAsFixed(0),
    );
    _notesController = TextEditingController(
      text: widget.transaction.notes ?? '',
    );
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

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final state = context.watch<FinanceBloc>().state;
    final wallets = state.wallets;
    final categories = state.categories;

    final safeWalletId = wallets.any((w) => w.id == _walletId)
        ? _walletId
        : (wallets.isNotEmpty ? wallets.first.id : null);

    if (_destinationWalletId == null && wallets.length > 1) {
      _destinationWalletId = wallets.firstWhere((w) => w.id != _walletId, orElse: () => wallets.last).id;
    }

    final safeDestWalletId = wallets.any((w) => w.id == _destinationWalletId)
        ? _destinationWalletId
        : (wallets.isNotEmpty ? wallets.last.id : null);

    final safeCategoryId = categories.any((c) => c.id == _categoryId)
        ? _categoryId
        : (categories.isNotEmpty ? categories.first.id : null);

    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.textSubtle, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 18),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Edit Transaksi', style: AppTypography.sectionTitle),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Tercatat: ${DateFormat('dd MMM yyyy, HH:mm').format(widget.transaction.transactionDate)} • Sumber: ${widget.transaction.source}',
                style: AppTypography.listSubtitle,
              ),
              const SizedBox(height: 16),

              // Type Selector: 3 Tabs (Expense, Income, Transfer)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.canvasInputSearch,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.canvasBorder),
                ),
                child: Row(
                  children: [
                    _buildTypeTab('expense', 'Pengeluaran', AppColors.neoCoral),
                    _buildTypeTab('income', 'Pemasukan', AppColors.neoMint),
                    _buildTypeTab('transfer', 'Transfer', AppColors.neoCyan),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Amount Input
              Text('NOMINAL (RP)', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 6),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: AppTypography.heroGreeting.copyWith(color: AppColors.textWhite),
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  prefixStyle: AppTypography.heroGreeting.copyWith(
                    color: _type == 'income' ? AppColors.neoMint : (_type == 'transfer' ? AppColors.neoCyan : AppColors.neoCoral),
                  ),
                  filled: true,
                  fillColor: AppColors.canvasInputSearch,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              // Wallet Selector
              Text(
                _type == 'transfer' ? 'REKENING ASAL' : 'REKENING PENYIMPANAN (PINDAH DOMPET)',
                style: AppTypography.badgeLabel.copyWith(color: AppColors.neoChartreuse),
              ),
              const SizedBox(height: 6),
              _buildWalletDropdown(wallets, safeWalletId, (val) {
                if (val != null) setState(() => _walletId = val);
              }),
              const SizedBox(height: 16),

              // Destination Wallet (If Transfer)
              if (_type == 'transfer') ...[
                Text('REKENING TUJUAN', style: AppTypography.badgeLabel.copyWith(color: AppColors.neoCyan)),
                const SizedBox(height: 6),
                _buildWalletDropdown(wallets, safeDestWalletId, (val) {
                  if (val != null) setState(() => _destinationWalletId = val);
                }),
                const SizedBox(height: 16),
              ],

              // Category (If Expense/Income)
              if (_type != 'transfer') ...[
                Text('KATEGORI', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
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
                      value: safeCategoryId,
                      isExpanded: true,
                      dropdownColor: AppColors.canvasCardSurface,
                      style: AppTypography.listTitle,
                      items: categories.map((c) {
                        return DropdownMenuItem<String>(
                          value: c.id,
                          child: Text(c.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _categoryId = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Notes
              Text('CATATAN / MERCHANT', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 6),
              TextField(
                controller: _notesController,
                style: AppTypography.listTitle,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.canvasInputSearch,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons (Hapus vs Simpan)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.statusDeficit),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.delete_outline, color: AppColors.statusDeficit),
                        label: const Text('Hapus', style: TextStyle(color: AppColors.statusDeficit)),
                        onPressed: () => _deleteTransaction(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neoChartreuse,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => _saveChanges(context),
                        child: Text(
                          'Simpan Perubahan',
                          style: AppTypography.listTitle.copyWith(
                            color: AppColors.textDarkPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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

  Widget _buildTypeTab(String type, String label, Color color) {
    final isSelected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.badgeLabel.copyWith(
                color: isSelected ? AppColors.textDarkPrimary : AppColors.textMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWalletDropdown(List<WalletEntry> wallets, String? selectedId, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.canvasInputSearch,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neoChartreuse.withOpacity(0.6), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedId,
          isExpanded: true,
          dropdownColor: AppColors.canvasCardSurface,
          style: AppTypography.listTitle,
          items: wallets.map((w) {
            return DropdownMenuItem<String>(
              value: w.id,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Color(int.parse(w.colorHex.replaceFirst('#', '0xFF'))),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(w.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text(
                    NumberFormat.compactSimpleCurrency(locale: 'id_ID').format(w.balance),
                    style: AppTypography.listSubtitle,
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _saveChanges(BuildContext context) {
    final raw = _amountController.text.replaceAll(RegExp(r'[^\d]'), '');
    final newAmount = double.tryParse(raw);
    if (newAmount == null || newAmount <= 0) return;

    if (_type == 'transfer' && _walletId == _destinationWalletId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rekening asal dan tujuan tidak boleh sama!')),
      );
      return;
    }

    context.read<FinanceBloc>().add(
      UpdateTransactionEvent(
        transactionId: widget.transaction.id,
        newWalletId: _walletId,
        newAmount: newAmount,
        newType: _type,
        newCategoryId: _categoryId,
        newDestinationWalletId: _type == 'transfer' ? _destinationWalletId : null,
        newNotes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      ),
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.neoMint,
        content: Text(
          'Perubahan transaksi & saldo dompet berhasil diperbarui!',
          style: TextStyle(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _deleteTransaction(BuildContext context) {
    context.read<FinanceBloc>().add(
      DeleteTransactionEvent(widget.transaction.id),
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.neoCoral,
        content: Text(
          'Transaksi dihapus & saldo dompet dikembalikan semula!',
          style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
