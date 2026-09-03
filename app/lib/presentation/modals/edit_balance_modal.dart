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
    final accountNumberController = TextEditingController(
      text: wallet.accountNumber ?? '',
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
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Penyesuaian Saldo: ${wallet.name}',
                          style: AppTypography.sectionTitle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ubah saldo awal rekening sesuai saldo riil saat ini di m-banking.',
                          style: AppTypography.listSubtitle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.canvasInputSearch,
                        border: Border.all(color: AppColors.canvasBorder, width: 0.8),
                      ),
                      child: const Icon(Icons.close, color: AppColors.textWhite, size: 18),
                    ),
                  ),
                ],
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
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.canvasBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Navigator.pop(ctx);
                        },
                        child: Text(
                          'Batal',
                          style: AppTypography.listTitle.copyWith(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
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
                          final accNum = accountNumberController.text.trim();
                          final boundPkg = isCustomPackage
                              ? customPackageController.text.trim()
                              : selectedPackage;

                          context.read<FinanceBloc>().add(
                            UpdateWalletBalanceEvent(
                              walletId: wallet.id,
                              newBalance: newBal > 0 ? newBal : wallet.balance,
                              accountNumber: accNum,
                            ),
                          );

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
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.neoCoral,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: Text(
                    'Hapus Rekening',
                    style: AppTypography.listTitle.copyWith(
                      color: AppColors.neoCoral,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, ctx, wallet);
                  },
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
  static void _showDeleteConfirmationDialog(
    BuildContext parentContext,
    BuildContext modalContext,
    WalletEntry wallet,
  ) {
    showDialog<bool>(
      context: modalContext,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.canvasCardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.canvasBorder),
          ),
          title: Text(
            'Hapus Rekening?',
            style: AppTypography.sectionTitle.copyWith(
              color: AppColors.textWhite,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Rekening "${wallet.name}" beserta aturan notifikasinya akan dihapus. Riwayat mutasi transaksi sebelumnya tetap aman dan tercatat.',
            style: AppTypography.listSubtitle.copyWith(
              color: AppColors.textMuted,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Batal',
                style: AppTypography.listTitle.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neoCoral,
                foregroundColor: AppColors.textDarkPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true && modalContext.mounted) {
        parentContext.read<FinanceBloc>().add(DeleteWalletEvent(wallet.id));
        Navigator.pop(modalContext);
        ScaffoldMessenger.of(parentContext).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.neoCoral,
            content: Text(
              'Rekening ${wallet.name} berhasil dihapus.',
              style: const TextStyle(
                color: AppColors.textDarkPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    });
  }

}
