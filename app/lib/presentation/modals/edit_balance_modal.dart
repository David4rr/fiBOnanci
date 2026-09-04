import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../core/formatters/rupiah_input_formatter.dart';
import '../../core/native_bridge/notification_bridge.dart';
import '../../core/notification_parser/bank_presets.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/finance_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common/common_widgets.dart';
import 'wallet/wallet_binding_selector.dart';
import 'wallet/wallet_delete_dialog.dart';

export 'wallet/wallet_binding_selector.dart';
export 'wallet/wallet_delete_dialog.dart';

class EditBalanceModal {
  static void show(BuildContext context, WalletEntry wallet) {
    final controller = TextEditingController(text: RupiahInputFormatter.format(wallet.balance));
    final accountNumberController = TextEditingController(text: wallet.accountNumber ?? '');
    final customPackageController = TextEditingController();
    String? selectedPackage;
    bool isCustomPackage = false;
    bool rulesLoaded = false;
    NotificationRuleEntry? currentRule;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            if (!rulesLoaded) {
              rulesLoaded = true;
              final repo = context.read<FinanceBloc>().repository;
              repo.getNotificationRulesForWallet(wallet.id).then((rules) {
                final match = rules.where((r) => r.isEnabled).firstOrNull;
                if (match != null && modalContext.mounted) {
                  setModalState(() {
                    currentRule = match;
                    selectedPackage = match.packageName;
                    isCustomPackage = !kPopularBankAppPresets.any((p) => p.packageName == selectedPackage);
                    if (isCustomPackage) customPackageController.text = selectedPackage ?? '';
                  });
                }
              });
            }
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ModalGrabHandle(padding: EdgeInsets.only(bottom: 14)),
                    ModalHeader(
                      title: 'Penyesuaian Saldo: ${wallet.name}',
                      subtitle: 'Ubah saldo awal rekening sesuai saldo riil saat ini di m-banking.',
                      onClose: () => Navigator.pop(modalContext),
                    ),
                    CurrencyAmountField(controller: controller),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: accountNumberController,
                      hintText: 'Nomor Rekening (Opsional, cth: 5410982341)',
                    ),
                    const SizedBox(height: 14),
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
                    const SizedBox(height: 20),
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
                                final newBal = RupiahInputFormatter.parse(controller.text);
                                final accNum = accountNumberController.text.trim();
                                final boundPkg = isCustomPackage ? customPackageController.text.trim() : selectedPackage;

                                context.read<FinanceBloc>().add(
                                  UpdateWalletBalanceEvent(
                                    walletId: wallet.id,
                                    newBalance: newBal > 0 ? newBal : wallet.balance,
                                    accountNumber: accNum,
                                  ),
                                );
                                final repo = context.read<FinanceBloc>().repository;
                                if (boundPkg != null && boundPkg.isNotEmpty) {
                                  repo.bindWalletToPackage(walletId: wallet.id, packageName: boundPkg).then((_) {
                                    if (repo is DriftFinanceRepository) NotificationBridge.syncAllowedPackages(repo.db);
                                  });
                                } else if (currentRule != null) {
                                  repo.unbindPackage(currentRule!.packageName).then((_) {
                                    if (repo is DriftFinanceRepository) NotificationBridge.syncAllowedPackages(repo.db);
                                  });
                                }
                                Navigator.pop(ctx);
                              },
                              child: Text('Perbarui Saldo', style: AppTypography.listTitle.copyWith(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: TextButton.icon(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.neoCoral, size: 18),
                        label: Text('Hapus Rekening', style: AppTypography.listTitle.copyWith(color: AppColors.neoCoral, fontSize: 13.5, fontWeight: FontWeight.w600)),
                        onPressed: () => WalletDeleteDialog.show(context, modalContext, wallet),
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
  }
}
