import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../core/formatters/app_currency.dart';
import '../../core/formatters/rupiah_input_formatter.dart';
import '../../core/native_bridge/notification_bridge.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common/common_widgets.dart';
import 'wallet/installed_app_picker_modal.dart';
import 'wallet/wallet_binding_selector.dart';
import 'wallet/wallet_type_selector.dart';

class AddWalletModal extends StatefulWidget {
  const AddWalletModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      clipBehavior: Clip.antiAlias,
      builder: (ctx) => const AddWalletModal(),
    );
  }

  @override
  State<AddWalletModal> createState() => _AddWalletModalState();
}

class _AddWalletModalState extends State<AddWalletModal> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _customPackageController = TextEditingController();
  late final PageController _pageController = PageController();
  String _type = 'bank';
  String? _selectedPackage;
  bool _isCustomPackage = false;
  int _currentTab = 0;
  @override
  void initState() {
    super.initState();
    NotificationBridge.getInstalledBankApps();
  }

  @override
  void dispose() {
    for (final c in [_nameController, _balanceController, _accountNumberController, _customPackageController]) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _switchTab(int tab) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _currentTab = tab);
    SmoothPageView.animateTo(_pageController, tab);
  }

  void _saveWallet() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final balance = AppCurrency.parseInputOf(context, _balanceController.text);
    final accNum = _accountNumberController.text.trim();
    final boundPkg = _isCustomPackage ? _customPackageController.text.trim() : _selectedPackage;

    context.read<FinanceBloc>().add(AddWalletEvent(
      name: name, type: _type, accountNumber: accNum.isNotEmpty ? accNum : null,
      initialBalance: balance, colorHex: '#10B981', iconName: _type == 'cash' ? 'wallet' : 'landmark',
      boundPackageName: boundPkg?.isNotEmpty == true ? boundPkg : null,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottomInset = media.viewInsets.bottom;
    final sheetHeight = math.max(360.0, math.min(media.size.height - bottomInset - 24, 700.0));
    final symbol = AppCurrency.symbolOf(context, listen: false);
    final isForm = _currentTab == 0;

    return PopScope(
      canPop: isForm,
      onPopInvokedWithResult: (didPop, _) { if (!didPop) _switchTab(0); },
      child: Padding(
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
                      title: isForm ? 'Tambah Rekening Baru' : 'Pilih Aplikasi',
                      subtitle: isForm ? 'Bank, E-Wallet, atau Kas Tunai' : 'Cari bank atau e-wallet di HP Anda',
                      closeIcon: isForm ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_left_rounded,
                      onClose: isForm ? () => Navigator.pop(context) : () => _switchTab(0),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SmoothPageView(
                  controller: _pageController,
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          AppTextField(controller: _nameController, hintText: 'Nama Rekening (cth: Kas Tunai, Bank Jago Saving)'),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _balanceController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly, RupiahInputFormatter()],
                            style: AppTypography.listTitle,
                            decoration: InputDecoration(
                              hintText: 'Saldo Awal (${symbol.trim()})', prefixText: symbol, filled: true,
                              fillColor: AppColors.canvasInputSearch,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppTextField(controller: _accountNumberController, hintText: 'Nomor Rekening (Opsional, cth: 5410982341)'),
                          const SizedBox(height: 12),
                          WalletTypeSelector(selectedType: _type, onTypeChanged: (val) => setState(() => _type = val)),
                          const SizedBox(height: 16),
                          WalletBindingSelector(
                            selectedPackage: _selectedPackage, isCustomPackage: _isCustomPackage,
                            customPackageController: _customPackageController, onOpenAppPicker: () => _switchTab(1),
                            onPackageChanged: (pkg, custom) => setState(() { _selectedPackage = pkg; _isCustomPackage = custom; }),
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
                                    onPressed: () => Navigator.pop(context),
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
                                    child: Text('Simpan Rekening', style: AppTypography.listTitle.copyWith(color: AppColors.textDarkPrimary, fontWeight: FontWeight.w800)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    InstalledAppPickerModal(
                      isInline: true,
                      onClose: () => _switchTab(0),
                      onAppSelected: (picked) {
                        setState(() { _customPackageController.text = picked; _selectedPackage = picked; _isCustomPackage = true; });
                        _switchTab(0);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
