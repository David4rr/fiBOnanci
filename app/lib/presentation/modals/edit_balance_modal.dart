import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../core/formatters/app_currency.dart';
import '../../core/native_bridge/notification_bridge.dart';
import '../../core/notification_parser/bank_presets.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/finance_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common/common_widgets.dart';
import 'wallet/installed_app_picker_modal.dart';
import 'wallet/wallet_binding_selector.dart';
import 'wallet/wallet_delete_dialog.dart';

export 'wallet/wallet_binding_selector.dart';
export 'wallet/wallet_delete_dialog.dart';

class EditBalanceModal {
  static void show(BuildContext context, WalletEntry wallet) {
    final controller = TextEditingController(text: AppCurrency.formatInputOf(context, wallet.balance));
    final accountNumberController = TextEditingController(text: wallet.accountNumber ?? '');
    final customPackageController = TextEditingController();
    final pageController = PageController();
    String? selectedPackage;
    bool isCustomPackage = false;
    bool rulesLoaded = false;
    int currentTab = 0;
    NotificationRuleEntry? currentRule;
    NotificationBridge.getInstalledBankApps();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      clipBehavior: Clip.antiAlias,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            void switchTab(int tab) {
              FocusManager.instance.primaryFocus?.unfocus();
              setModalState(() => currentTab = tab);
              SmoothPageView.animateTo(pageController, tab);
            }
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
            final media = MediaQuery.of(ctx);
            final bottomInset = media.viewInsets.bottom;
            final sheetHeight = math.max(360.0, math.min(media.size.height - bottomInset - 32, 560.0));
            final isForm = currentTab == 0;

            return Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: SizedBox(
                height: sheetHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          isForm ? const ModalGrabHandle(padding: EdgeInsets.only(bottom: 14)) : const SizedBox(height: 18),
                          ModalHeader(
                            title: isForm ? 'Penyesuaian Saldo: ${wallet.name}' : 'Pilih Aplikasi',
                            subtitle: isForm ? 'Ubah saldo awal rekening sesuai saldo riil saat ini di m-banking.' : 'Cari bank atau e-wallet di HP Anda',
                            closeIcon: isForm ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_left_rounded,
                            onClose: isForm ? () => Navigator.pop(modalContext) : () => switchTab(0),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SmoothPageView(
                        controller: pageController,
                        children: [
                          SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CurrencyAmountField(controller: controller),
                                const SizedBox(height: 12),
                                AppTextField(controller: accountNumberController, hintText: 'Nomor Rekening (Opsional, cth: 5410982341)'),
                                const SizedBox(height: 14),
                                WalletBindingSelector(
                                  selectedPackage: selectedPackage, isCustomPackage: isCustomPackage,
                                  customPackageController: customPackageController, onOpenAppPicker: () => switchTab(1),
                                  onPackageChanged: (pkg, custom) => setModalState(() { selectedPackage = pkg; isCustomPackage = custom; }),
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
                                            final newBal = AppCurrency.parseInputOf(context, controller.text);
                                            final accNum = accountNumberController.text.trim();
                                            final boundPkg = isCustomPackage ? customPackageController.text.trim() : selectedPackage;
                                            context.read<FinanceBloc>().add(UpdateWalletBalanceEvent(walletId: wallet.id, newBalance: newBal > 0 ? newBal : wallet.balance, accountNumber: accNum));
                                            final repo = context.read<FinanceBloc>().repository;
                                            if (boundPkg != null && boundPkg.isNotEmpty) {
                                              repo.bindWalletToPackage(walletId: wallet.id, packageName: boundPkg).then((_) { if (repo is DriftFinanceRepository) NotificationBridge.syncAllowedPackages(repo.db); });
                                            } else if (currentRule != null) {
                                              repo.unbindPackage(currentRule!.packageName).then((_) { if (repo is DriftFinanceRepository) NotificationBridge.syncAllowedPackages(repo.db); });
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
                          InstalledAppPickerModal(
                            isInline: true,
                            onClose: () => switchTab(0),
                            onAppSelected: (picked) {
                              setModalState(() {
                                customPackageController.text = picked;
                                selectedPackage = picked;
                                isCustomPackage = true;
                              });
                              switchTab(0);
                            },
                          ),
                        ],
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
