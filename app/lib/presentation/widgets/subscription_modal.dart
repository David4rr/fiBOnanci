import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AddSubscriptionModal extends StatefulWidget {
  final AppDatabase db;

  const AddSubscriptionModal({super.key, required this.db});

  static Future<void> show(BuildContext context, AppDatabase db) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => AddSubscriptionModal(db: db),
    );
  }

  @override
  State<AddSubscriptionModal> createState() => _AddSubscriptionModalState();
}

class _AddSubscriptionModalState extends State<AddSubscriptionModal> {
  final _titleController = TextEditingController();
  final _costController = TextEditingController();
  int _dueDay = 15;
  bool _autoDeduct = false;
  String? _selectedWalletId;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final state = context.read<FinanceBloc>().state;
    if (state.wallets.isNotEmpty) {
      _selectedWalletId = state.wallets.first.id;
    }
    if (state.categories.isNotEmpty) {
      _selectedCategoryId = state.categories.firstWhere(
        (c) => c.name.contains('Tagihan') || c.name.contains('Hiburan'),
        orElse: () => state.categories.first,
      ).id;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final state = context.watch<FinanceBloc>().state;
    final wallets = state.wallets;

    final safeWalletId = wallets.any((w) => w.id == _selectedWalletId)
        ? _selectedWalletId
        : (wallets.isNotEmpty ? wallets.first.id : null);

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
                decoration: BoxDecoration(
                  color: AppColors.textSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tambah Tagihan Rutin', style: AppTypography.sectionTitle),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text('NAMA TAGIHAN / LANGGANAN', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              style: AppTypography.listTitle,
              decoration: InputDecoration(
                hintText: 'Misal: Netflix, Indihome, Kost, Gym...',
                hintStyle: AppTypography.listSubtitle,
                filled: true,
                fillColor: AppColors.canvasInputSearch,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text('BIAYA PER BULAN (RP)', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 6),
            TextField(
              controller: _costController,
              keyboardType: TextInputType.number,
              style: AppTypography.heroGreeting.copyWith(color: AppColors.textWhite),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: AppTypography.heroGreeting.copyWith(color: AppColors.textSubtle),
                prefixText: 'Rp ',
                prefixStyle: AppTypography.heroGreeting.copyWith(color: AppColors.neoCoral),
                filled: true,
                fillColor: AppColors.canvasInputSearch,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Due Day Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TANGGAL JATUH TEMPO', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
                Text('Setiap Tgl $_dueDay', style: AppTypography.cardMetricLabel.copyWith(color: AppColors.neoChartreuse)),
              ],
            ),
            Slider(
              value: _dueDay.toDouble(),
              min: 1,
              max: 31,
              divisions: 30,
              activeColor: AppColors.neoChartreuse,
              inactiveColor: AppColors.canvasInputSearch,
              onChanged: (val) => setState(() => _dueDay = val.round()),
            ),
            const SizedBox(height: 10),

            // Wallet Source
            Text('SUMBER DANA PEMBAYARAN', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
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
                  value: safeWalletId,
                  isExpanded: true,
                  dropdownColor: AppColors.canvasCardSurface,
                  style: AppTypography.listTitle,
                  items: wallets.map((w) {
                    return DropdownMenuItem<String>(
                      value: w.id,
                      child: Text(w.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedWalletId = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Auto Deduct Toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.canvasInputSearch,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.canvasBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Auto-Deduct Saldo', style: AppTypography.listTitle),
                      const SizedBox(height: 2),
                      Text('Potong saldo otomatis saat tgl jatuh tempo', style: AppTypography.listSubtitle),
                    ],
                  ),
                  Switch(
                    value: _autoDeduct,
                    activeColor: AppColors.neoChartreuse,
                    onChanged: (val) => setState(() => _autoDeduct = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neoChartreuse,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => _saveSubscription(context),
                child: Text(
                  'Simpan Tagihan',
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
    );
  }

  void _saveSubscription(BuildContext context) {
    final title = _titleController.text.trim();
    final rawCost = _costController.text.replaceAll(RegExp(r'[^\d]'), '');
    final cost = double.tryParse(rawCost);

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan nama tagihan!')));
      return;
    }
    if (cost == null || cost <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan nominal biaya yang valid!')));
      return;
    }
    if (_selectedWalletId == null || _selectedCategoryId == null) return;

    // Dispatch to BLoC!
    context.read<FinanceBloc>().add(
      AddSubscriptionEvent(
        title: title,
        cost: cost,
        dueDay: _dueDay,
        walletId: _selectedWalletId!,
        categoryId: _selectedCategoryId!,
        autoDeduct: _autoDeduct,
      ),
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.neoMint,
        content: Text(
          'Tagihan $title (Rp ${cost.toStringAsFixed(0)}) berhasil ditambahkan!',
          style: const TextStyle(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
