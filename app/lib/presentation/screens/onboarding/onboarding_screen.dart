import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/finance/finance_bloc.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/app_snack_bar.dart';
import 'onboarding_bottom_bar.dart';
import 'onboarding_import_modal.dart';
import 'onboarding_language_step.dart';
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
  final bool isNewProfile;
  const OnboardingScreen({super.key, required this.onComplete, this.isNewProfile = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

enum _OnboardingStage { language, welcome, steps }

class _OnboardingScreenState extends State<OnboardingScreen> {
  late _OnboardingStage _stage = widget.isNewProfile ? _OnboardingStage.steps : _OnboardingStage.language;
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
    for (final c in [_fullNameCtrl, _usernameCtrl, _occupationCtrl, _incomeCtrl, _walletNameCtrl, _balanceCtrl]) {
      c.dispose();
    }
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
    if (_currentStep == 1) {
      final uname = _usernameCtrl.text.trim().replaceAll('@', '').toLowerCase();
      if (uname.isEmpty) return;
      if (widget.isNewProfile &&
          context.read<FinanceBloc>().state.profiles.any((p) => !p.isDeleted && p.username.toLowerCase() == uname)) {
        final l10n = AppL10n.of(context);
        AppSnackBar.showError(context, l10n.onbUsernameTakenTitle, message: l10n.onbUsernameTakenMsg);
        return;
      }
    }
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
    } else if (widget.isNewProfile) {
      Navigator.of(context).pop();
    } else {
      setState(() => _stage = _OnboardingStage.welcome);
    }
  }

  Future<void> _finish() => OnboardingSubmit.execute(
        context: context, fullName: _fullNameCtrl.text, username: _usernameCtrl.text,
        occupation: _occupationCtrl.text, incomeText: _incomeCtrl.text,
        walletName: _walletNameCtrl.text, walletType: _walletType,
        balanceText: _balanceCtrl.text, onComplete: widget.onComplete, isNewProfile: widget.isNewProfile,
      );

  Widget _buildStep() => switch (_currentStep) {
        0 => OnboardingStepName(controller: _fullNameCtrl, onNext: _next),
        1 => OnboardingStepUsername(
            firstName: _fullNameCtrl.text.trim().split(' ').first,
            usernameController: _usernameCtrl,
            occupationController: _occupationCtrl,
            onNext: _next,
          ),
        2 => OnboardingStepIncome(incomeController: _incomeCtrl, onNext: _next),
        3 => OnboardingStepWallet(
            walletNameController: _walletNameCtrl,
            walletType: _walletType,
            onWalletTypeChanged: (t) => setState(() => _walletType = t),
            balanceController: _balanceCtrl,
            onNext: _next,
          ),
        _ => OnboardingStepCelebration(
            fullName: _fullNameCtrl.text,
            username: _usernameCtrl.text,
            walletName: _walletNameCtrl.text,
            walletType: _walletType,
            balanceText: _balanceCtrl.text,
          ),
      };

  @override
  Widget build(BuildContext context) {
    if (_stage != _OnboardingStage.steps) {
      return Scaffold(
        backgroundColor: AppColors.canvasBg,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _stage == _OnboardingStage.language
                  ? OnboardingLanguageStep(onContinue: () => setState(() => _stage = _OnboardingStage.welcome))
                  : OnboardingWelcomeChoice(
                      onBack: () => setState(() => _stage = _OnboardingStage.language),
                      onStartNew: () => setState(() => _stage = _OnboardingStage.steps),
                      onImportBackup: () => OnboardingImportModal.show(context, onImportSuccess: widget.onComplete),
                    ),
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
              child: Center(
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
            ),
            OnboardingBottomBar(currentStep: _currentStep, canContinue: canContinue, onNext: _next, onSkip: _skipIncome),
          ],
        ),
      ),
    );
  }
}
