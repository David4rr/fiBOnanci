import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../bloc/finance/finance_state.dart';
import '../../core/formatters/rupiah_input_formatter.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'pocket/pocket_type_selector.dart';

export 'pocket/pocket_type_selector.dart';

class AddPocketModal {
  static void show(BuildContext context) {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    final initialController = TextEditingController();
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    String selectedType = 'savings';
    String? selectedWalletId;
    String? nameError;
    String? initialError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            final activeWallets = state.wallets.where((w) => !w.isDeleted).toList();
            selectedWalletId = activeWallets.any((w) => w.id == selectedWalletId) ? selectedWalletId : (activeWallets.isNotEmpty ? activeWallets.first.id : null);

            return StatefulBuilder(
              builder: (modalContext, setModalState) {
                final currentType = kPocketTypes.firstWhere((t) => t['id'] == selectedType, orElse: () => kPocketTypes.first);
                final Color activeColor = Color(int.parse((currentType['color'] as String).replaceAll('#', '0xFF')));

                return Padding(
                  padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textSubtle, borderRadius: BorderRadius.circular(2)))),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Buat Kantong Alokasi Baru', style: AppTypography.sectionTitle),
                                  const SizedBox(height: 4),
                                  Text('Pisahkan dana tabungan agar tidak terpakai saat belanja harian.', style: AppTypography.listSubtitle),
                                ],
                              ),
                            ),
                            IconButton(onPressed: () => Navigator.pop(modalContext), icon: const Icon(Icons.close, color: AppColors.textWhite, size: 18)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('TIPE KANTONG', style: AppTypography.listSubtitle),
                        const SizedBox(height: 8),
                        PocketTypeSelector(selectedType: selectedType, onSelectType: (id) => setModalState(() => selectedType = id)),
                        const SizedBox(height: 16),
                        PocketTypeSelector.buildTextField(
                          controller: nameController,
                          label: 'Nama Kantong',
                          hintText: 'Nama Kantong (cth: Tabungan Pensiun, Liburan)',
                          errorText: nameError,
                          onChanged: (_) {
                            if (nameError != null) setModalState(() => nameError = null);
                          },
                        ),
                        const SizedBox(height: 12),
                        PocketTypeSelector.buildTextField(
                          controller: targetController,
                          label: 'Target Tabungan (Opsional)',
                          hintText: 'Rp 0',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, RupiahInputFormatter()],
                        ),
                        const SizedBox(height: 12),
                        PocketTypeSelector.buildTextField(
                          controller: initialController,
                          label: 'Setoran Awal (Opsional)',
                          hintText: 'Rp 0',
                          errorText: initialError,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, RupiahInputFormatter()],
                          onChanged: (_) {
                            if (initialError != null) setModalState(() => initialError = null);
                          },
                        ),
                        if (activeWallets.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text('Ambil Dari Rekening (Jika ada setoran awal)', style: AppTypography.listSubtitle),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(color: AppColors.canvasInputSearch, borderRadius: BorderRadius.circular(16)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedWalletId,
                                isExpanded: true,
                                dropdownColor: AppColors.canvasCardSurface,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
                                items: activeWallets.map((w) => DropdownMenuItem(value: w.id, child: Text('${w.name} (${currencyFormatter.format(w.balance)})', style: AppTypography.listSubtitle.copyWith(color: AppColors.textWhite), overflow: TextOverflow.ellipsis))).toList(),
                                onChanged: (val) {
                                  if (val != null) setModalState(() => selectedWalletId = val);
                                },
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 52,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.canvasBorder), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text('Batal', style: AppTypography.listTitle.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: activeColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                                  onPressed: () {
                                    final name = nameController.text.trim();
                                    if (name.isEmpty) {
                                      setModalState(() => nameError = 'Nama kantong wajib diisi');
                                      return;
                                    }
                                    final target = RupiahInputFormatter.parse(targetController.text);
                                    final initial = RupiahInputFormatter.parse(initialController.text);
                                    if (initial > 0 && selectedWalletId != null && activeWallets.isNotEmpty) {
                                      final wallet = activeWallets.firstWhere((w) => w.id == selectedWalletId, orElse: () => activeWallets.first);
                                      if (initial > wallet.balance) {
                                        setModalState(() => initialError = 'Saldo tidak cukup (Maks Rp ${wallet.balance.toStringAsFixed(0)})');
                                        return;
                                      }
                                    }
                                    context.read<FinanceBloc>().add(AddPocketEvent(
                                      name: name, type: selectedType,
                                      targetAmount: target > 0 ? target : null, initialAmount: initial,
                                      colorHex: currentType['color'] as String, iconName: 'flag',
                                      linkedWalletId: initial > 0 ? selectedWalletId : null,
                                    ));
                                    Navigator.pop(ctx);
                                  },
                                  child: Text('Buat Kantong Sekarang', style: GoogleFonts.plusJakartaSans(color: AppColors.canvasBg, fontWeight: FontWeight.w800, fontSize: 15)),
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
          },
        );
      },
    );
  }
}
