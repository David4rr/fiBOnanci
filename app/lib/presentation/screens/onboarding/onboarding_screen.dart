import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'onboarding_bottom_bar.dart';
import 'onboarding_import_modal.dart';
import 'onboarding_step_celebration.dart';
import 'onboarding_step_income.dart';
import 'onboarding_step_name.dart';
import 'onboarding_step_username.dart';
import 'onboarding_step_wallet.dart';
import 'onboarding_submit.dart';
import 'onboarding_top_bar.dart';
import 'onboarding_welcome_choice.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _isWelcome = true;
  int _currentStep = 0;
  final _fullNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _occupationCtrl = TextEditingController();
  final _incomeCtrl = TextEditingController();
  final _walletNameCtrl = TextEditingController(text: 'BCA');
  String _walletType = 'bank';
  final _balanceCtrl = TextEditingController();
  bool _userEditedUsername = false;

  @override
  void initState() {
    super.initState();
    _fullNameCtrl.addListener(_onFullNameChanged);
    _usernameCtrl.addListener(_onUsernameChanged);
    _walletNameCtrl.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _fullNameCtrl.removeListener(_onFullNameChanged);
    _usernameCtrl.removeListener(_onUsernameChanged);
    _walletNameCtrl.removeListener(_onFieldChanged);
    _fullNameCtrl.dispose();
    _usernameCtrl.dispose();
    _occupationCtrl.dispose();
    _incomeCtrl.dispose();
    _walletNameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  String _slug(String t) => t.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_').replaceAll(RegExp(r'[^a-z0-9_]'), '');

  void _onFullNameChanged() {
    if (!_userEditedUsername && _fullNameCtrl.text.trim().isNotEmpty) {
      _usernameCtrl.text = _slug(_fullNameCtrl.text);
    }
    if (mounted) setState(() {});
  }

  void _onUsernameChanged() {
    if (_usernameCtrl.text != _slug(_fullNameCtrl.text)) _userEditedUsername = true;
    if (mounted) setState(() {});
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  void _next() {
    if (_currentStep == 0 && _fullNameCtrl.text.trim().isEmpty) return;
    if (_currentStep == 1 && _usernameCtrl.text.trim().isEmpty) return;
    if (_currentStep == 3 && _walletNameCtrl.text.trim().isEmpty) return;

    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      _finish();
    }
  }

  void _skipIncome() {
    _incomeCtrl.clear();
    setState(() => _currentStep++);
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      setState(() => _isWelcome = true);
    }
  }

  Future<void> _finish() async {
    await OnboardingSubmit.execute(
      context: context,
      fullName: _fullNameCtrl.text,
      username: _usernameCtrl.text,
      occupation: _occupationCtrl.text,
      incomeText: _incomeCtrl.text,
      walletName: _walletNameCtrl.text,
      walletType: _walletType,
      balanceText: _balanceCtrl.text,
      onComplete: widget.onComplete,
    );
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return OnboardingStepName(controller: _fullNameCtrl, onNext: _next);
      case 1:
        return OnboardingStepUsername(
          firstName: _fullNameCtrl.text.trim().split(' ').first,
          usernameController: _usernameCtrl,
          occupationController: _occupationCtrl,
          onNext: _next,
        );
      case 2:
        return OnboardingStepIncome(incomeController: _incomeCtrl, onNext: _next);
      case 3:
        return OnboardingStepWallet(
          walletNameController: _walletNameCtrl,
          walletType: _walletType,
          onWalletTypeChanged: (t) => setState(() => _walletType = t),
          balanceController: _balanceCtrl,
          onNext: _next,
        );
      default:
        return OnboardingStepCelebration(
          fullName: _fullNameCtrl.text,
          username: _usernameCtrl.text,
          walletName: _walletNameCtrl.text,
          walletType: _walletType,
          balanceText: _balanceCtrl.text,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isWelcome) {
      return Scaffold(
        backgroundColor: AppColors.canvasBg,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: OnboardingWelcomeChoice(
              onStartNew: () => setState(() => _isWelcome = false),
              onImportBackup: () => OnboardingImportModal.show(context, onImportSuccess: widget.onComplete),
            ),
          ),
        ),
      );
    }

    final canContinue = (_currentStep == 0 && _fullNameCtrl.text.trim().isNotEmpty) ||
        (_currentStep == 1 && _usernameCtrl.text.trim().isNotEmpty) ||
        (_currentStep == 2) ||
        (_currentStep == 3 && _walletNameCtrl.text.trim().isNotEmpty) ||
        (_currentStep == 4);

    return Scaffold(
      backgroundColor: AppColors.canvasBg,
      body: SafeArea(
        child: Column(
          children: [
            OnboardingTopBar(currentStep: _currentStep, onBack: _back),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                  child: KeyedSubtree(key: ValueKey(_currentStep), child: _buildStep()),
                ),
              ),
            ),
            OnboardingBottomBar(
              currentStep: _currentStep,
              canContinue: canContinue,
              onNext: _next,
              onSkip: _skipIncome,
            ),
          ],
        ),
      ),
    );
  }
}
