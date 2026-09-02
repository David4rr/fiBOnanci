import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../bloc/finance/finance_state.dart';
import '../../core/native_bridge/notification_bridge.dart';
import '../../core/notification_parser/parsed_notification.dart';
import '../../data/repositories/finance_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
class NotificationReviewModal extends StatefulWidget {
  final ParsedNotificationResult parsed;
  final String rawPackage;

  const NotificationReviewModal({
    super.key,
    required this.parsed,
    required this.rawPackage,
  });

  static Future<bool?> show(
    BuildContext context, {
    required ParsedNotificationResult parsed,
    required String rawPackage,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => NotificationReviewModal(
        parsed: parsed,
        rawPackage: rawPackage,
      ),
    );
  }

  @override
  State<NotificationReviewModal> createState() => _NotificationReviewModalState();
}

class _NotificationReviewModalState extends State<NotificationReviewModal> {
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late String _type; // 'expense', 'income'

  String? _selectedWalletId;
  String? _selectedCategoryId;
  bool _isSaving = false;
  bool _rememberBinding = false;
  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.parsed.amount.toStringAsFixed(0),
    );
    _notesController = TextEditingController(
      text: widget.parsed.counterparty,
    );
    _type = widget.parsed.type;
    final repo = context.read<FinanceBloc>().repository;
    repo.getNotificationRules().then((rules) {
      final match = rules.where((r) => r.packageName == widget.rawPackage && r.isEnabled).firstOrNull;
      if (match != null && mounted) {
        setState(() {
          _selectedWalletId = match.walletId;
        });
      }
    });
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

    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        final wallets = state.wallets;
        final categories = state.categories;
            // Smart Pre-selection of target wallet
            if (_selectedWalletId == null && wallets.isNotEmpty) {
              final pkg = widget.rawPackage.toLowerCase();
              final notes = widget.parsed.counterparty.toLowerCase();

              if (pkg.contains('shopee') || notes.contains('shopee')) {
                _selectedWalletId = wallets.firstWhere((w) => w.name.toLowerCase().contains('shopee'), orElse: () => wallets.first).id;
              } else if (pkg.contains('seabank') || pkg.contains('bke') || notes.contains('seabank')) {
                _selectedWalletId = wallets.firstWhere((w) => w.name.toLowerCase().contains('seabank'), orElse: () => wallets.first).id;
              } else if (pkg.contains('bcadigital') || pkg.contains('blu') || notes.contains('blu')) {
                _selectedWalletId = wallets.firstWhere((w) => w.name.toLowerCase().contains('blu'), orElse: () => wallets.first).id;
              } else if (pkg.contains('bca') || notes.contains('bca')) {
                _selectedWalletId = wallets.firstWhere((w) => w.name.toLowerCase().contains('bca utama'), orElse: () => wallets.first).id;
              } else if (pkg.contains('mandiri') || notes.contains('mandiri')) {
                _selectedWalletId = wallets.firstWhere((w) => w.name.toLowerCase().contains('mandiri'), orElse: () => wallets.first).id;
              } else if (pkg.contains('jago') || notes.contains('jago')) {
                _selectedWalletId = wallets.firstWhere((w) => w.name.toLowerCase().contains('jago'), orElse: () => wallets.first).id;
              } else if (pkg.contains('ovo') || notes.contains('ovo')) {
                _selectedWalletId = wallets.firstWhere((w) => w.name.toLowerCase().contains('ovo'), orElse: () => wallets.first).id;
              } else {
                _selectedWalletId = wallets.first.id;
              }
            }

            // Pre-select category
            if (_selectedCategoryId == null && categories.isNotEmpty) {
              _selectedCategoryId = categories.firstWhere(
                (c) => c.type == _type,
                orElse: () => categories.first,
              ).id;
            }

            return Padding(
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

                    // Header Tag
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.notifications_active, color: AppColors.neoChartreuse, size: 22),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Konfirmasi Notifikasi',
                                  style: AppTypography.sectionTitle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textMuted),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Notifikasi bank terdeteksi! Periksa & ubah rekening atau nominal jika ada yang keliru:',
                      style: AppTypography.listSubtitle,
                    ),
                    const SizedBox(height: 16),

                    // Type Selector (Pemasukan vs Pengeluaran)
                    Row(
                      children: [
                        _buildTypePill(
                          label: 'Pemasukan (+)',
                          isSelected: _type == 'income',
                          activeColor: AppColors.neoMint,
                          onTap: () => setState(() => _type = 'income'),
                        ),
                        const SizedBox(width: 10),
                        _buildTypePill(
                          label: 'Pengeluaran (-)',
                          isSelected: _type == 'expense',
                          activeColor: AppColors.neoCoral,
                          onTap: () => setState(() => _type = 'expense'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Amount Input
                    Text('NOMINAL TRANSAKSI (RP)', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: AppTypography.heroGreeting.copyWith(color: AppColors.textWhite),
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        prefixStyle: AppTypography.heroGreeting.copyWith(
                          color: _type == 'income' ? AppColors.neoMint : AppColors.neoCoral,
                        ),
                        filled: true,
                        fillColor: AppColors.canvasInputSearch,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Target Wallet Dropdown (USER CAN CHANGE HERE IF WRONG)
                    Text('REKENING TUJUAN / ASAL (BISA DIUBAH)', style: AppTypography.badgeLabel.copyWith(color: AppColors.neoChartreuse)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.canvasInputSearch,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.neoChartreuse.withValues(alpha: 0.5), width: 1.5),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: wallets.any((w) => w.id == _selectedWalletId)
                              ? _selectedWalletId
                              : (wallets.isNotEmpty ? wallets.first.id : null),
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
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedWalletId = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
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
                          value: categories.any((c) => c.id == _selectedCategoryId)
                              ? _selectedCategoryId
                              : (categories.isNotEmpty ? categories.first.id : null),
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
                            if (val != null) setState(() => _selectedCategoryId = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

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
                    const SizedBox(height: 14),
                    CheckboxListTile(
                      value: _rememberBinding,
                      onChanged: (val) => setState(() => _rememberBinding = val ?? false),
                      title: Text(
                        'Ingat rekening ini untuk aplikasi ${widget.rawPackage}',
                        style: AppTypography.listSubtitle.copyWith(color: AppColors.textWhite),
                      ),
                      subtitle: Text(
                        'Notifikasi berikutnya akan otomatis diarahkan ke rekening ini.',
                        style: AppTypography.listSubtitle.copyWith(color: AppColors.textMuted),
                      ),
                      activeColor: AppColors.neoChartreuse,
                      checkColor: AppColors.textDarkPrimary,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 24),

                    // Actions Row (Abaikan vs Konfirmasi)
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.canvasBorder),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Abaikan', style: TextStyle(color: AppColors.textMuted)),
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
                              onPressed: _isSaving ? null : () => _confirmAndSave(context),
                              child: _isSaving
                                  ? const CircularProgressIndicator(color: AppColors.textDarkPrimary)
                                  : Text(
                                      'Konfirmasi Simpan',
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
            );
      },
    );
  }

  Widget _buildTypePill({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : AppColors.canvasInputSearch,
            borderRadius: BorderRadius.circular(14),
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

  Future<void> _confirmAndSave(BuildContext context) async {
    final rawAmount = _amountController.text.replaceAll(RegExp(r'[^\d]'), '');
    final amount = double.tryParse(rawAmount);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nominal harus valid!')));
      return;
    }
    if (_selectedWalletId == null || _selectedCategoryId == null) return;

    setState(() => _isSaving = true);
    final now = DateTime.now();
    final bloc = context.read<FinanceBloc>();
    final repo = bloc.repository;

    try {
      if (_rememberBinding && _selectedWalletId != null) {
        await repo.bindWalletToPackage(
          walletId: _selectedWalletId!,
          packageName: widget.rawPackage,
        );
        if (repo is DriftFinanceRepository) {
          await NotificationBridge.syncAllowedPackages(repo.db);
        }
      }

      bloc.add(
        AddTransactionEvent(
          walletId: _selectedWalletId!,
          categoryId: _selectedCategoryId!,
          amount: amount,
          type: _type,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          source: 'notification_prompt',
          externalRef: widget.parsed.externalRef,
          transactionDate: now,
        ),
      );
      if (mounted && context.mounted) {
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
