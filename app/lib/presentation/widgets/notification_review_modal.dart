import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../core/native_bridge/notification_bridge.dart';
import '../../core/notification_parser/parsed_notification.dart';
import '../../data/repositories/finance_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'notification_review_selectors.dart';

export 'notification_review_selectors.dart';

class NotificationReviewModal extends StatefulWidget {
  final ParsedNotificationResult parsed;
  final String rawPackage;

  const NotificationReviewModal({super.key, required this.parsed, required this.rawPackage});

  static Future<bool?> show(BuildContext context, {required ParsedNotificationResult parsed, required String rawPackage}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => NotificationReviewModal(parsed: parsed, rawPackage: rawPackage),
    );
  }

  @override
  State<NotificationReviewModal> createState() => _NotificationReviewModalState();
}

class _NotificationReviewModalState extends State<NotificationReviewModal> {
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late String _type;
  String? _selectedWalletId;
  String? _selectedCategoryId;
  bool _isSaving = false;
  bool _rememberBinding = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.parsed.amount.toStringAsFixed(0));
    _notesController = TextEditingController(text: widget.parsed.counterparty);
    _type = widget.parsed.type;

    final repo = context.read<FinanceBloc>().repository;
    repo.getNotificationRules().then((rules) {
      final match = rules.where((r) => r.packageName == widget.rawPackage && r.isEnabled).firstOrNull;
      if (match != null && mounted) setState(() => _selectedWalletId = match.walletId);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _confirmAndSave(BuildContext context) async {
    final double? amt = double.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (amt == null || amt <= 0) return;

    final state = context.read<FinanceBloc>().state;
    final walletId = _selectedWalletId ?? (state.wallets.isNotEmpty ? state.wallets.first.id : null);
    final categoryId = _selectedCategoryId ?? (state.categories.isNotEmpty ? state.categories.first.id : null);
    if (walletId == null || categoryId == null) return;

    setState(() => _isSaving = true);
    if (_rememberBinding) {
      context.read<FinanceBloc>().add(BindWalletToPackageEvent(walletId: walletId, packageName: widget.rawPackage, isEnabled: true));
      final repo = context.read<FinanceBloc>().repository;
      if (repo is DriftFinanceRepository) await NotificationBridge.syncAllowedPackages(repo.db);
    }

    if (!context.mounted) return;
    context.read<FinanceBloc>().add(AddTransactionEvent(
      walletId: walletId,
      categoryId: categoryId,
      amount: amt,
      type: _type,
      notes: _notesController.text.trim(),
      source: 'notification_prompt',
      externalRef: widget.parsed.externalRef,
    ));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final state = context.watch<FinanceBloc>().state;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textSubtle, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Review Notifikasi Bank', style: AppTypography.sectionTitle),
                  const SizedBox(height: 4),
                  Text('Deteksi otomatis dari ${widget.rawPackage}', style: AppTypography.listSubtitle),
                ]),
                IconButton(onPressed: () => Navigator.pop(context, false), icon: const Icon(Icons.close, color: AppColors.textWhite, size: 18)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                NotificationReviewSelectors.buildTypePill(label: 'Pemasukan (+)', isSelected: _type == 'income', activeColor: AppColors.neoMint, onTap: () => setState(() => _type = 'income')),
                const SizedBox(width: 10),
                NotificationReviewSelectors.buildTypePill(label: 'Pengeluaran (-)', isSelected: _type == 'expense', activeColor: AppColors.neoCoral, onTap: () => setState(() => _type = 'expense')),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: AppTypography.heroGreeting.copyWith(color: AppColors.textWhite),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                prefixStyle: AppTypography.heroGreeting.copyWith(color: _type == 'income' ? AppColors.neoMint : AppColors.neoCoral),
                filled: true,
                fillColor: AppColors.canvasInputSearch,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            Text('REKENING TUJUAN / ASAL', style: AppTypography.badgeLabel.copyWith(color: AppColors.neoChartreuse)),
            const SizedBox(height: 6),
            NotificationReviewSelectors.buildWalletDropdown(wallets: state.wallets, selectedWalletId: _selectedWalletId, onChanged: (v) => setState(() => _selectedWalletId = v)),
            const SizedBox(height: 16),
            Text('KATEGORI', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 6),
            NotificationReviewSelectors.buildCategoryDropdown(categories: state.categories, selectedCategoryId: _selectedCategoryId, onChanged: (v) => setState(() => _selectedCategoryId = v)),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              style: AppTypography.listTitle,
              decoration: InputDecoration(hintText: 'Catatan / Merchant', filled: true, fillColor: AppColors.canvasInputSearch, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 14),
            CheckboxListTile(
              value: _rememberBinding,
              onChanged: (val) => setState(() => _rememberBinding = val ?? false),
              title: Text('Ingat rekening ini untuk ${widget.rawPackage}', style: AppTypography.listSubtitle.copyWith(color: AppColors.textWhite)),
              activeColor: AppColors.neoChartreuse,
              checkColor: AppColors.textDarkPrimary,
              contentPadding: EdgeInsets.zero,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.canvasBorder), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
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
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.neoChartreuse, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      onPressed: _isSaving ? null : () => _confirmAndSave(context),
                      child: _isSaving ? const CircularProgressIndicator(color: AppColors.textDarkPrimary) : Text('Konfirmasi Simpan', style: AppTypography.listTitle.copyWith(color: AppColors.textDarkPrimary, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
