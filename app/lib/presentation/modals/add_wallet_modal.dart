import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../core/formatters/rupiah_input_formatter.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'wallet/wallet_binding_selector.dart';
import 'wallet/wallet_type_selector.dart';

export 'wallet/wallet_binding_selector.dart';
export 'wallet/wallet_type_selector.dart';

class AddWalletModal {
  static void show(BuildContext context) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    final accountNumberController = TextEditingController();
    final customPackageController = TextEditingController();
    String type = 'bank';
    String? selectedPackage;
    bool isCustomPackage = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
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
                              Text('Tambah Rekening Baru', style: AppTypography.sectionTitle),
                              const SizedBox(height: 4),
                              Text('Bank, E-Wallet, atau Kas Tunai', style: AppTypography.listSubtitle),
                            ],
                          ),
                        ),
                        IconButton(onPressed: () => Navigator.pop(modalContext), icon: const Icon(Icons.close, color: AppColors.textWhite, size: 18)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      style: AppTypography.listTitle,
                      decoration: InputDecoration(
                        hintText: 'Nama Rekening (cth: Kas Tunai, Bank Jago Saving)',
                        hintStyle: AppTypography.listSubtitle,
                        filled: true,
                        fillColor: AppColors.canvasInputSearch,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: balanceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, RupiahInputFormatter()],
                      style: AppTypography.listTitle,
                      decoration: InputDecoration(
                        hintText: 'Saldo Awal (Rp)',
                        prefixText: 'Rp ',
                        filled: true,
                        fillColor: AppColors.canvasInputSearch,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: accountNumberController,
                      keyboardType: TextInputType.text,
                      style: AppTypography.listTitle,
                      decoration: InputDecoration(
                        hintText: 'Nomor Rekening (Opsional, cth: 5410982341)',
                        hintStyle: AppTypography.listSubtitle,
                        filled: true,
                        fillColor: AppColors.canvasInputSearch,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    WalletTypeSelector(selectedType: type, onTypeChanged: (val) => setModalState(() => type = val)),
                    const SizedBox(height: 16),
                    WalletBindingSelector(
                      selectedPackage: selectedPackage,
                      isCustomPackage: isCustomPackage,
                      customPackageController: customPackageController,
                      onPackageChanged: (pkg, custom) {
                        setModalState(() {
                          selectedPackage = pkg;
                          isCustomPackage = custom;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.canvasBorder), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                              onPressed: () => Navigator.pop(modalContext),
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
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.neoChartreuse, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                              onPressed: () {
                                final name = nameController.text.trim();
                                if (name.isEmpty) return;
                                final balance = RupiahInputFormatter.parse(balanceController.text);
                                final accNum = accountNumberController.text.trim();
                                final boundPkg = isCustomPackage ? customPackageController.text.trim() : selectedPackage;

                                context.read<FinanceBloc>().add(
                                  AddWalletEvent(
                                    name: name,
                                    type: type,
                                    accountNumber: accNum.isNotEmpty ? accNum : null,
                                    initialBalance: balance,
                                    colorHex: '#10B981',
                                    iconName: type == 'cash' ? 'wallet' : 'landmark',
                                    boundPackageName: boundPkg?.isNotEmpty == true ? boundPkg : null,
                                  ),
                                );
                                Navigator.pop(modalContext);
                              },
                              child: Text('Simpan Rekening', style: AppTypography.listTitle.copyWith(color: AppColors.textDarkPrimary, fontWeight: FontWeight.w800)),
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
  }
}
