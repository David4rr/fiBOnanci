import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/formatters/rupiah_input_formatter.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'subscription_modal_selectors.dart';

export 'subscription_modal_selectors.dart';

class AddSubscriptionModal extends StatefulWidget {
  final SubscriptionEntry? subscription;
  const AddSubscriptionModal({super.key, this.subscription});

  static Future<void> show(BuildContext context, {SubscriptionEntry? subscription}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => AddSubscriptionModal(subscription: subscription),
    );
  }

  @override
  State<AddSubscriptionModal> createState() => _AddSubscriptionModalState();
}

class _AddSubscriptionModalState extends State<AddSubscriptionModal> {
  late final TextEditingController _titleController;
  late final TextEditingController _costController;
  late int _dueDay;
  late bool _autoDeduct;
  String? _selectedWalletId;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final sub = widget.subscription;
    if (sub != null) {
      _titleController = TextEditingController(text: sub.title);
      _costController = TextEditingController(text: NumberFormat.decimalPattern('id_ID').format(sub.cost.round()));
      _dueDay = sub.dueDay;
      _autoDeduct = sub.autoDeduct;
      _selectedWalletId = sub.walletId;
      _selectedCategoryId = sub.categoryId;
    } else {
      _titleController = TextEditingController();
      _costController = TextEditingController();
      _dueDay = 15;
      _autoDeduct = false;
      final state = context.read<FinanceBloc>().state;
      if (state.wallets.isNotEmpty) _selectedWalletId = state.wallets.first.id;
      if (state.categories.isNotEmpty) {
        _selectedCategoryId = state.categories.firstWhere(
          (c) => c.name.contains('Tagihan') || c.name.contains('Hiburan'),
          orElse: () => state.categories.first,
        ).id;
      }
    }
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
    if (title.isEmpty || cost <= 0 || _selectedWalletId == null || _selectedCategoryId == null) return;

    final bloc = context.read<FinanceBloc>();
    if (widget.subscription != null) {
      bloc.add(UpdateSubscriptionEvent(
        subscriptionId: widget.subscription!.id,
        title: title,
        cost: cost,
        dueDay: _dueDay,
        walletId: _selectedWalletId!,
        categoryId: _selectedCategoryId!,
        autoDeduct: _autoDeduct,
      ));
    } else {
      bloc.add(AddSubscriptionEvent(
        title: title,
        cost: cost,
        dueDay: _dueDay,
        walletId: _selectedWalletId!,
        categoryId: _selectedCategoryId!,
        autoDeduct: _autoDeduct,
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.subscription != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final state = context.watch<FinanceBloc>().state;
    final wallets = state.wallets;
    final safeWalletId = wallets.any((w) => w.id == _selectedWalletId) ? _selectedWalletId : (wallets.isNotEmpty ? wallets.first.id : null);

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
                  Text(isEditing ? 'Edit Tagihan Rutin' : 'Tambah Tagihan Baru', style: AppTypography.sectionTitle),
                  const SizedBox(height: 4),
                  Text('Langganan, cicilan, atau tagihan rutin', style: AppTypography.listSubtitle),
                ]),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: AppColors.textWhite, size: 18)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              style: AppTypography.listTitle,
              decoration: InputDecoration(
                hintText: 'cth: Netflix, Spotify, Listrik PLN, Kosan',
                hintStyle: AppTypography.listSubtitle,
                filled: true,
                fillColor: AppColors.canvasInputSearch,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _costController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, RupiahInputFormatter()],
              style: AppTypography.heroGreeting.copyWith(color: AppColors.textWhite),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                prefixStyle: AppTypography.heroGreeting.copyWith(color: AppColors.neoCoral),
                filled: true,
                fillColor: AppColors.canvasInputSearch,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            SubscriptionDueDaySlider(dueDay: _dueDay, onDayChanged: (d) => setState(() => _dueDay = d)),
            const SizedBox(height: 8),
            SubscriptionWalletDropdown(wallets: wallets, selectedWalletId: safeWalletId, onWalletChanged: (v) => setState(() => _selectedWalletId = v)),
            const SizedBox(height: 12),
            SubscriptionAutoDeductSwitch(autoDeduct: _autoDeduct, onToggle: (val) => setState(() => _autoDeduct = val)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.neoChartreuse, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () => _saveSubscription(context),
                child: Text(
                  isEditing ? 'Simpan Perubahan' : 'Simpan Tagihan',
                  style: GoogleFonts.plusJakartaSans(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textDarkPrimary),
                ),
              ),
            ),
            if (isEditing) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: AppColors.neoCoral),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: Text('Hapus Langganan Ini', style: AppTypography.listTitle.copyWith(color: AppColors.neoCoral, fontSize: 13, fontWeight: FontWeight.w700)),
                  onPressed: () => showSubscriptionDeleteDialog(context, widget.subscription!.id),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
