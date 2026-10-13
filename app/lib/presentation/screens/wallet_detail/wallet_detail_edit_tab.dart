import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../core/formatters/app_currency.dart';
import '../../../core/native_bridge/notification_bridge.dart';
import '../../../core/notification_parser/bank_presets.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/finance_repository.dart';
import '../../modals/wallet/installed_app_picker_modal.dart';
import '../../modals/wallet/wallet_binding_selector.dart';
import '../../modals/wallet/wallet_delete_dialog.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';

/// Inline edit tab within WalletDetailScreen, eliminating multi-modal stacking.
class WalletDetailEditTab extends StatefulWidget {
  final WalletEntry wallet;
  final VoidCallback onReturnToDetails;
  final bool isPickingApp;
  final ValueChanged<bool>? onPickingAppChanged;

  const WalletDetailEditTab({
    super.key,
    required this.wallet,
    required this.onReturnToDetails,
    this.isPickingApp = false,
    this.onPickingAppChanged,
  });

  @override
  State<WalletDetailEditTab> createState() => _WalletDetailEditTabState();
}

class _WalletDetailEditTabState extends State<WalletDetailEditTab> {
  late final TextEditingController _controller;
  late final TextEditingController _accountNumberController;
  late final TextEditingController _customPackageController;
  late final PageController _pageController = PageController(initialPage: widget.isPickingApp ? 1 : 0);
  String? _selectedPackage;
  bool _isCustomPackage = false;
  bool _rulesLoaded = false;
  NotificationRuleEntry? _currentRule;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: AppCurrency.formatInputOf(context, widget.wallet.balance));
    _accountNumberController = TextEditingController(text: widget.wallet.accountNumber ?? '');
    _customPackageController = TextEditingController();
    NotificationBridge.getInstalledBankApps();
  }

  @override
  void didUpdateWidget(covariant WalletDetailEditTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPickingApp != oldWidget.isPickingApp && _pageController.hasClients) {
      SmoothPageView.animateTo(_pageController, widget.isPickingApp ? 1 : 0);
    }
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_rulesLoaded) {
      _rulesLoaded = true;
      final repo = context.read<FinanceBloc>().repository;
      repo.getNotificationRulesForWallet(widget.wallet.id).then((rules) {
        final match = rules.where((r) => r.isEnabled).firstOrNull;
        if (match != null && mounted) {
          setState(() {
            _currentRule = match;
            _selectedPackage = match.packageName;
            _isCustomPackage = !kPopularBankAppPresets.any((p) => p.packageName == _selectedPackage);
            if (_isCustomPackage) _customPackageController.text = _selectedPackage ?? '';
          });
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in [_controller, _accountNumberController, _customPackageController]) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _setPickingApp(bool picking) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (widget.onPickingAppChanged != null) {
      widget.onPickingAppChanged!(picking);
    } else {
      SmoothPageView.animateTo(_pageController, picking ? 1 : 0);
    }
  }

  void _saveWallet() {
    final newBal = AppCurrency.parseInputOf(context, _controller.text);
    final accNum = _accountNumberController.text.trim();
    final boundPkg = _isCustomPackage ? _customPackageController.text.trim() : _selectedPackage;

    context.read<FinanceBloc>().add(UpdateWalletBalanceEvent(
      walletId: widget.wallet.id,
      newBalance: newBal > 0 ? newBal : widget.wallet.balance,
      accountNumber: accNum,
    ));
    final repo = context.read<FinanceBloc>().repository;
    if (boundPkg != null && boundPkg.isNotEmpty) {
      repo.bindWalletToPackage(walletId: widget.wallet.id, packageName: boundPkg).then((_) {
        if (repo is DriftFinanceRepository) NotificationBridge.syncAllowedPackages(repo.db);
      });
    } else if (_currentRule != null) {
      repo.unbindPackage(_currentRule!.packageName).then((_) {
        if (repo is DriftFinanceRepository) NotificationBridge.syncAllowedPackages(repo.db);
      });
    }

    widget.onReturnToDetails();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.canvasCardSurface,
      child: SmoothPageView(
        controller: _pageController,
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 48 + MediaQuery.of(context).viewInsets.bottom),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                CurrencyAmountField(controller: _controller),
                const SizedBox(height: 12),
                AppTextField(controller: _accountNumberController, hintText: 'Nomor Rekening (Opsional, cth: 5410982341)'),
                const SizedBox(height: 14),
                WalletBindingSelector(
                  selectedPackage: _selectedPackage, isCustomPackage: _isCustomPackage,
                  customPackageController: _customPackageController, onOpenAppPicker: () => _setPickingApp(true),
                  onPackageChanged: (pkg, custom) => setState(() { _selectedPackage = pkg; _isCustomPackage = custom; }),
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
                          onPressed: widget.onReturnToDetails,
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
                          onPressed: _saveWallet,
                          child: Text('Perbarui Saldo', style: AppTypography.listTitle.copyWith(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SlideToDeleteButton(label: 'Hapus Rekening', onSlideComplete: () => WalletDeleteDialog.show(context, context, widget.wallet)),
              ],
            ),
          ),
          InstalledAppPickerModal(
            isInline: true,
            onClose: () => _setPickingApp(false),
            onAppSelected: (picked) {
              setState(() { _customPackageController.text = picked; _selectedPackage = picked; _isCustomPackage = true; });
              _setPickingApp(false);
            },
          ),
        ],
      ),
    );
  }
}
