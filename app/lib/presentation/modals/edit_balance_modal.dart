import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class EditBalanceModal {
  static void show(BuildContext context, WalletEntry wallet) {
    final controller = TextEditingController(
      text: RupiahInputFormatter.format(wallet.balance),
    );
    final customPackageController = TextEditingController();
    String? selectedPackage;
    bool isCustomPackage = false;
    bool rulesLoaded = false;
    NotificationRuleEntry? currentRule;
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
                    if (isCustomPackage) {
                      customPackageController.text = selectedPackage ?? '';
                    }
                  });
                }
              });
            }
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
              Text(
                'Penyesuaian Saldo: ${wallet.name}',
                style: AppTypography.sectionTitle,
              ),
              const SizedBox(height: 6),
              Text(
                'Ubah saldo awal rekening sesuai saldo riil saat ini di m-banking.',
                style: AppTypography.listSubtitle,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  RupiahInputFormatter(),
                ],
                autofocus: false,
                style: AppTypography.heroGreeting.copyWith(
                  color: AppColors.textWhite,
                ),
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  prefixStyle: AppTypography.heroGreeting.copyWith(
                    color: AppColors.neoChartreuse,
                  ),
                  filled: true,
                  fillColor: AppColors.canvasInputSearch,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Hubungkan Notifikasi Aplikasi (Opsional)',
                style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.canvasInputSearch,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: isCustomPackage ? '__custom__' : selectedPackage,
                    isExpanded: true,
                    dropdownColor: AppColors.canvasCardSurface,
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
                    style: AppTypography.listTitle,
                    hint: Text('Tidak Terhubung (Input Manual)', style: AppTypography.listSubtitle),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Tidak Terhubung (Input Manual)', style: AppTypography.listSubtitle),
                      ),
                      ...kPopularBankAppPresets.map((p) => DropdownMenuItem<String?>(
                        value: p.packageName,
                        child: Row(
                          children: [
                            const Icon(Icons.notifications_active_outlined, size: 18, color: AppColors.neoChartreuse),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${p.name} (${p.packageName})',
                                style: AppTypography.listTitle,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )),
                      const DropdownMenuItem<String?>(
                        value: '__custom__',
                        child: Row(
                          children: [
                            Icon(Icons.edit_note, size: 18, color: AppColors.neoCyan),
                            SizedBox(width: 8),
                            Text('Input Package Name Lainnya...', style: TextStyle(color: AppColors.neoCyan)),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setModalState(() {
                        if (val == '__custom__') {
                          isCustomPackage = true;
                          selectedPackage = null;
                        } else {
                          isCustomPackage = false;
                          selectedPackage = val;
                        }
                      });
                    },
                  ),
                ),
              ),
              if (isCustomPackage) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: customPackageController,
                  style: AppTypography.listTitle,
                  decoration: InputDecoration(
                    hintText: 'Package Name (contoh: id.krom.bank)',
                    hintStyle: AppTypography.listSubtitle,
                    filled: true,
                    fillColor: AppColors.canvasInputSearch,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
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
                    'Perbarui Saldo',
                    style: AppTypography.listTitle.copyWith(
                      color: AppColors.textDarkPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    final newBal = RupiahInputFormatter.parse(controller.text);
                    final boundPkg = isCustomPackage
                        ? customPackageController.text.trim()
                        : selectedPackage;

                    if (newBal > 0) {
                      context.read<FinanceBloc>().add(
                        UpdateWalletBalanceEvent(
                          walletId: wallet.id,
                          newBalance: newBal,
                        ),
                      );
                    }

                    final repo = context.read<FinanceBloc>().repository;
                    if (boundPkg != null && boundPkg.isNotEmpty) {
                      repo.bindWalletToPackage(
                        walletId: wallet.id,
                        packageName: boundPkg,
                      ).then((_) {
                        if (repo is DriftFinanceRepository) {
                          NotificationBridge.syncAllowedPackages(repo.db);
                        }
                      });
                    } else if (currentRule != null) {
                      repo.unbindPackage(currentRule!.packageName).then((_) {
                        if (repo is DriftFinanceRepository) {
                          NotificationBridge.syncAllowedPackages(repo.db);
                        }
                      });
                    }

                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.neoChartreuse,
                        content: Text(
                          'Rekening ${wallet.name} berhasil diperbarui.',
                          style: const TextStyle(
                            color: AppColors.textDarkPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
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
}
