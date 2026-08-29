import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/formatters/rupiah_input_formatter.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class TransactionModal extends StatefulWidget {
  final AppDatabase db;

  const TransactionModal({super.key, required this.db});

  static Future<void> show(BuildContext context, AppDatabase db) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => TransactionModal(db: db),
    );
  }

  @override
  State<TransactionModal> createState() => _TransactionModalState();
}

class _TransactionModalState extends State<TransactionModal> {
  String _type = 'expense'; // 'expense', 'income', 'transfer'
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedWalletId;
  String? _selectedDestinationWalletId;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // Synchronously grab cached data from RAM via BLoC (0 ms latency!)
    final state = context.read<FinanceBloc>().state;
    if (state.wallets.isNotEmpty) {
      _selectedWalletId = state.wallets.first.id;
      if (state.wallets.length > 1) {
        _selectedDestinationWalletId = state.wallets[1].id;
      }
    }
    if (state.categories.isNotEmpty) {
      _selectedCategoryId = state.categories.first.id;
    }
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

    return RepaintBoundary(
      child: Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header & Type Switcher
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Catat Transaksi', style: AppTypography.sectionTitle),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Type Segmented Pills
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
            const SizedBox(height: 20),

            // Amount Input
            Text('NOMINAL (RP)', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 6),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, RupiahInputFormatter()],
              style: AppTypography.heroGreeting.copyWith(color: AppColors.textWhite),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: AppTypography.heroGreeting.copyWith(color: AppColors.textSubtle),
                prefixText: 'Rp ',
                prefixStyle: AppTypography.heroGreeting.copyWith(color: AppColors.neoChartreuse),
                filled: true,
                fillColor: AppColors.canvasInputSearch,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Wallet Selector
            Text(
              _type == 'transfer' ? 'REKENING ASAL' : 'DOMPET / REKENING',
              style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 6),
            _buildWalletDropdown(wallets, isSource: true),
            const SizedBox(height: 16),

            // Destination Wallet (Transfer Only)
            if (_type == 'transfer') ...[
              Text('REKENING TUJUAN', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 6),
              _buildWalletDropdown(wallets, isSource: false),
              const SizedBox(height: 16),
            ],

            // Category Selector
            if (_type != 'transfer') ...[
              Text('KATEGORI', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 6),
              _buildCategoryDropdown(categories),
              const SizedBox(height: 16),
            ],

            // Notes / Description
            Text('CATATAN / MERCHANT', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              style: AppTypography.listTitle,
              decoration: InputDecoration(
                hintText: 'Misal: Kopi Kenangan, Bensin, Gaji...',
                hintStyle: AppTypography.listSubtitle,
                filled: true,
                fillColor: AppColors.canvasInputSearch,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neoChartreuse,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => _saveTransaction(context),
                child: Text(
                  'Simpan Transaksi',
                  style: AppTypography.listTitle.copyWith(
                    color: AppColors.textDarkPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildTypeTab(String type, String label, Color activeColor) {
    final isSelected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.badgeLabel.copyWith(
                color: isSelected ? AppColors.textDarkPrimary : AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWalletDropdown(List<WalletEntry> wallets, {required bool isSource}) {
    final selectedId = isSource ? _selectedWalletId : _selectedDestinationWalletId;
    final safeId = wallets.any((w) => w.id == selectedId)
        ? selectedId
        : (wallets.isNotEmpty ? wallets.first.id : null);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.canvasInputSearch,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.canvasBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeId,
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
                  Text(w.name),
                  const Spacer(),
                  Text(
                    NumberFormat.compactSimpleCurrency(locale: 'id_ID').format(w.balance),
                    style: AppTypography.listSubtitle,
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                if (isSource) {
                  _selectedWalletId = val;
                } else {
                  _selectedDestinationWalletId = val;
                }
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(List<CategoryEntry> categories) {
    final safeCatId = categories.any((c) => c.id == _selectedCategoryId)
        ? _selectedCategoryId
        : (categories.isNotEmpty ? categories.first.id : null);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.canvasInputSearch,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.canvasBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeCatId,
          isExpanded: true,
          dropdownColor: AppColors.canvasCardSurface,
          style: AppTypography.listTitle,
          items: categories.map((c) {
            return DropdownMenuItem<String>(
              value: c.id,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Color(int.parse(c.colorHex.replaceFirst('#', '0xFF'))),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(c.name),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedCategoryId = val);
          },
        ),
      ),
    );
  }

  void _saveTransaction(BuildContext context) {
    final amount = RupiahInputFormatter.parse(_amountController.text);
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal yang valid (> 0)!')),
      );
      return;
    }

    if (_selectedWalletId == null) return;
    if (_type == 'transfer' && _selectedWalletId == _selectedDestinationWalletId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rekening asal dan tujuan tidak boleh sama!')),
      );
      return;
    }

    // Dispatch Event directly to BLoC! No disk wait on main thread!
    context.read<FinanceBloc>().add(
      AddTransactionEvent(
        walletId: _selectedWalletId!,
        categoryId: _selectedCategoryId ?? '11111111-1111-4111-8111-111111111101',
        amount: amount,
        type: _type,
        destinationWalletId: _type == 'transfer' ? _selectedDestinationWalletId : null,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        transactionDate: DateTime.now().toUtc(),
      ),
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.neoMint,
        content: Text(
          'Transaksi Rp ${amount.toStringAsFixed(0)} berhasil dicatat!',
          style: const TextStyle(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
