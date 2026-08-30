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

class AddPocketModal {
  static void show(BuildContext context) {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    final initialController = TextEditingController();

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    String selectedType = 'savings';
    String? selectedWalletId;
    String? nameError;
    String? initialError;
    final List<Map<String, dynamic>> pocketTypes = [
      {'id': 'savings', 'label': 'Simpanan', 'icon': Icons.savings_outlined, 'color': '#A855F7'},
      {'id': 'retirement', 'label': 'Masa Tua', 'icon': Icons.elderly_outlined, 'color': '#D4F442'},
      {'id': 'emergency', 'label': 'Dana Darurat', 'icon': Icons.shield_outlined, 'color': '#7DF24E'},
      {'id': 'goal', 'label': 'Target / Impian', 'icon': Icons.flag_outlined, 'color': '#26D9D9'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            final activeWallets = state.wallets.where((w) => !w.isDeleted).toList();
            final safeWalletId = activeWallets.any((w) => w.id == selectedWalletId)
                ? selectedWalletId
                : (activeWallets.isNotEmpty ? activeWallets.first.id : null);
            selectedWalletId = safeWalletId;

            return StatefulBuilder(
              builder: (modalContext, setModalState) {
                final currentType = pocketTypes.firstWhere(
                  (t) => t['id'] == selectedType,
                  orElse: () => pocketTypes.first,
                );
                final Color activeColor = Color(int.parse((currentType['color'] as String).replaceAll('#', '0xFF')));

                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    16,
                    24,
                    24 + MediaQuery.of(ctx).viewInsets.bottom,
                  ),
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
                        Text('Buat Kantong Alokasi Baru', style: AppTypography.sectionTitle),
                        const SizedBox(height: 4),
                        Text(
                          'Pisahkan dana tabungan agar tidak terpakai saat belanja harian.',
                          style: AppTypography.listSubtitle,
                        ),
                        const SizedBox(height: 16),

                        // Nama Kantong
                        TextField(
                          controller: nameController,
                          style: AppTypography.listTitle,
                          onChanged: (_) {
                            if (nameError != null) {
                              setModalState(() => nameError = null);
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Nama Kantong (cth: Tabungan Pensiun, Liburan)',
                            hintStyle: AppTypography.listSubtitle,
                            errorText: nameError,
                            filled: true,
                            fillColor: AppColors.canvasInputSearch,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Jenis / Tujuan Kantong
                        Text('Tujuan Kantong', style: AppTypography.listTitle),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: pocketTypes.map((type) {
                            final isSelected = selectedType == type['id'];
                            final Color itemColor = Color(int.parse((type['color'] as String).replaceAll('#', '0xFF')));

                            return GestureDetector(
                              onTap: () {
                                setModalState(() => selectedType = type['id'] as String);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? itemColor.withValues(alpha: 0.2) : AppColors.canvasInputSearch,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected ? itemColor : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      type['icon'] as IconData,
                                      size: 16,
                                      color: isSelected ? itemColor : AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      type['label'] as String,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : AppColors.textMuted,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Target Tabungan
                        TextField(
                          controller: targetController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            RupiahInputFormatter(),
                          ],
                          style: AppTypography.listTitle,
                          decoration: InputDecoration(
                            labelText: 'Target Tabungan (Opsional)',
                            labelStyle: AppTypography.listSubtitle,
                            hintText: 'Rp 0',
                            hintStyle: AppTypography.listSubtitle,
                            filled: true,
                            fillColor: AppColors.canvasInputSearch,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Setoran Awal
                        TextField(
                          controller: initialController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) {
                            if (initialError != null) {
                              setModalState(() => initialError = null);
                            }
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            RupiahInputFormatter(),
                          ],
                          style: AppTypography.listTitle,
                          decoration: InputDecoration(
                            labelText: 'Setoran Awal (Opsional)',
                            labelStyle: AppTypography.listSubtitle,
                            hintText: 'Rp 0',
                            hintStyle: AppTypography.listSubtitle,
                            errorText: initialError,
                            filled: true,
                            fillColor: AppColors.canvasInputSearch,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        // Rekening Sumber jika ada setoran awal
                        if (activeWallets.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text('Ambil Dari Rekening (Jika ada setoran awal)', style: AppTypography.listSubtitle),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: AppColors.canvasInputSearch,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedWalletId,
                                isExpanded: true,
                                dropdownColor: AppColors.canvasCardSurface,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
                                items: activeWallets.map((w) {
                                  return DropdownMenuItem<String>(
                                    value: w.id,
                                    child: Text(
                                      '${w.name} (${currencyFormatter.format(w.balance)})',
                                      style: AppTypography.listSubtitle.copyWith(color: AppColors.textWhite),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setModalState(() => selectedWalletId = val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),

                        // Tombol Buat Kantong
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: activeColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              final name = nameController.text.trim();
                              if (name.isEmpty) {
                                setModalState(() {
                                  nameError = 'Nama kantong wajib diisi';
                                });
                                return;
                              }

                              final target = RupiahInputFormatter.parse(targetController.text);
                              final initial = RupiahInputFormatter.parse(initialController.text);

                              if (initial > 0 && selectedWalletId != null && activeWallets.isNotEmpty) {
                                final wallet = activeWallets.firstWhere(
                                  (w) => w.id == selectedWalletId,
                                  orElse: () => activeWallets.first,
                                );
                                if (initial > wallet.balance) {
                                  setModalState(() {
                                    initialError = 'Saldo tidak cukup (Maks Rp ${wallet.balance.toStringAsFixed(0)})';
                                  });
                                  return;
                                }
                              }

                              // 1. Dispatch create pocket event
                              context.read<FinanceBloc>().add(
                                AddPocketEvent(
                                  name: name,
                                  type: selectedType,
                                  targetAmount: target > 0 ? target : null,
                                  initialAmount: initial,
                                  colorHex: currentType['color'] as String,
                                  iconName: selectedType,
                                  linkedWalletId: selectedWalletId,
                                ),
                              );

                              // 2. If initial amount > 0 and wallet selected, also deduct from wallet
                              if (initial > 0 && selectedWalletId != null && activeWallets.isNotEmpty) {
                                final wallet = activeWallets.firstWhere(
                                  (w) => w.id == selectedWalletId,
                                  orElse: () => activeWallets.first,
                                );
                                context.read<FinanceBloc>().add(
                                  UpdateWalletBalanceEvent(
                                    walletId: selectedWalletId!,
                                    newBalance: wallet.balance - initial,
                                  ),
                                );
                              }

                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.canvasCardSurface,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, color: AppColors.neoMint, size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Kantong "$name" berhasil dibuat!',
                                          style: AppTypography.listTitle.copyWith(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'Buat Kantong Sekarang',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.canvasBg,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ),
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
