import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../core/formatters/app_currency.dart';
import '../../core/native_bridge/notification_bridge.dart';
import '../../core/notification_parser/bank_presets.dart';
import '../theme/app_colors.dart';
import '../widgets/common/common_widgets.dart';
import 'wallet/add_wallet_form_body.dart';
import 'wallet/installed_app_picker_modal.dart';
import 'wallet/wallet_binding_selector.dart';
import 'wallet/wallet_form_inputs.dart';
import 'wallet/wallet_modal_actions.dart';
import 'wallet/wallet_preset_chips.dart';

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
  String _colorHex = '#10B981';
  String _iconName = 'landmark';
  bool _isCustomPackage = false;
  bool _isManualPackage = false;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
    NotificationBridge.getInstalledBankApps();
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    for (final c in [_nameController, _balanceController, _accountNumberController, _customPackageController]) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    if (_isManualPackage) return;
    final text = _nameController.text.trim();
    if (text.isEmpty) return;
    final low = text.toLowerCase();
    if (low == 'kas' || low == 'kas tunai' || low == 'cash' || low == 'tunai') {
      if (_type != 'cash' || _selectedPackage != null) {
        setState(() { _type = 'cash'; _selectedPackage = null; _isCustomPackage = false; _colorHex = '#10B981'; _iconName = 'wallet'; });
      }
      return;
    }
    final m = findBankPresetByQuery(text);
    if (m != null && m.packageName != _selectedPackage) {
      setState(() { _type = m.type; _selectedPackage = m.packageName; _isCustomPackage = false; _colorHex = m.colorHex; _iconName = m.iconName; });
    }
  }

  void _applyPreset(BankAppPreset preset) {
    setState(() {
      _nameController.text = preset.shortName;
      _type = preset.type;
      _selectedPackage = preset.packageName;
      _isCustomPackage = false;
      _colorHex = preset.colorHex;
      _iconName = preset.iconName;
      _isManualPackage = false;
    });
  }

  void _applyCash() => setState(() {
    _nameController.text = 'Kas Tunai';
    _type = 'cash';
    _selectedPackage = null;
    _isCustomPackage = false;
    _colorHex = '#10B981';
    _iconName = 'wallet';
    _isManualPackage = false;
  });

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
      initialBalance: balance, colorHex: _colorHex, iconName: _type == 'cash' ? 'wallet' : _iconName,
      boundPackageName: boundPkg?.isNotEmpty == true ? boundPkg : null,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottomInset = media.viewInsets.bottom;
    final sheetHeight = math.max(380.0, math.min(media.size.height - bottomInset - 24, 730.0));
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
              AddWalletHeader(isForm: isForm, onBack: isForm ? () => Navigator.pop(context) : () => _switchTab(0)),
              Expanded(
                child: SmoothPageView(
                  controller: _pageController,
                  children: [
                    AddWalletFormBody(
                      presetChips: WalletPresetChips(
                        selectedPackage: _selectedPackage, selectedType: _type,
                        onPresetSelected: _applyPreset, onCashSelected: _applyCash,
                      ),
                      formInputs: WalletFormInputs(
                        nameController: _nameController, balanceController: _balanceController,
                        accountNumberController: _accountNumberController, symbol: symbol,
                        selectedType: _type, onTypeChanged: (val) => setState(() => _type = val),
                      ),
                      bindingSelector: WalletBindingSelector(
                        selectedPackage: _selectedPackage, isCustomPackage: _isCustomPackage,
                        customPackageController: _customPackageController, onOpenAppPicker: () => _switchTab(1),
                        onPackageChanged: (pkg, custom) => setState(() {
                          _selectedPackage = pkg; _isCustomPackage = custom; _isManualPackage = true;
                        }),
                      ),
                      actions: WalletModalActions(onCancel: () => Navigator.pop(context), onSave: _saveWallet),
                    ),
                    InstalledAppPickerModal(
                      isInline: true,
                      onClose: () => _switchTab(0),
                      onAppSelected: (picked) {
                        setState(() {
                          _customPackageController.text = picked; _selectedPackage = picked;
                          _isCustomPackage = true; _isManualPackage = true;
                        });
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
