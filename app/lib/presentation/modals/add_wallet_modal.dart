import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../core/formatters/rupiah_input_formatter.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AddWalletModal {
  static void show(BuildContext context) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    String type = 'bank';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                24 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
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
                  Text('Tambah Dompet / Rekening Baru', style: AppTypography.sectionTitle),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nameController,
                    style: AppTypography.listTitle,
                    decoration: InputDecoration(
                      hintText: 'Nama Rekening (cth: Kas Tunai, Bank Jago Saving)',
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
                  TextField(
                    controller: balanceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      RupiahInputFormatter(),
                    ],
                    style: AppTypography.listTitle,
                    decoration: InputDecoration(
                      hintText: 'Saldo Awal (Rp)',
                      prefixText: 'Rp ',
                      filled: true,
                      fillColor: AppColors.canvasInputSearch,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildTypePill(
                        label: 'Bank',
                        isSelected: type == 'bank',
                        onTap: () => setModalState(() => type = 'bank'),
                      ),
                      const SizedBox(width: 8),
                      _buildTypePill(
                        label: 'E-Wallet',
                        isSelected: type == 'ewallet',
                        onTap: () => setModalState(() => type = 'ewallet'),
                      ),
                      const SizedBox(width: 8),
                      _buildTypePill(
                        label: 'Kas Tunai',
                        isSelected: type == 'cash',
                        onTap: () => setModalState(() => type = 'cash'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neoChartreuse,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Simpan Rekening',
                        style: AppTypography.listTitle.copyWith(
                          color: AppColors.textDarkPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        final name = nameController.text.trim();
                        final bal = RupiahInputFormatter.parse(balanceController.text);
                        if (name.isNotEmpty) {
                          context.read<FinanceBloc>().add(
                            AddWalletEvent(
                              name: name,
                              type: type,
                              initialBalance: bal,
                              colorHex: '#10B981',
                              iconName: 'wallet',
                            ),
                          );
                          Navigator.pop(modalContext);
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildTypePill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neoChartreuse : AppColors.canvasInputSearch,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.neoChartreuse : AppColors.canvasBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.badgeLabel.copyWith(
            color: isSelected ? AppColors.textDarkPrimary : AppColors.textWhite,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
