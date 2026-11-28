import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../theme/app_colors.dart';
import 'confetti_overlay.dart';
import 'onboarding_celebration_card.dart';

bool get _isFlutterTest => !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

class OnboardingStepCelebration extends StatefulWidget {
  final String fullName;
  final String username;
  final String walletName;
  final String walletType;
  final String balanceText;

  const OnboardingStepCelebration({
    super.key,
    required this.fullName,
    required this.username,
    required this.walletName,
    required this.walletType,
    required this.balanceText,
  });

  @override
  State<OnboardingStepCelebration> createState() =>
      _OnboardingStepCelebrationState();
}

class _OnboardingStepCelebrationState extends State<OnboardingStepCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cardAnimCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
    _cardAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _scaleAnim = CurvedAnimation(
      parent: _cardAnimCtrl,
      curve: Curves.easeOutBack,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardAnimCtrl,
      curve: Curves.easeOutCubic,
    ));
    _cardAnimCtrl.forward();
  }

  @override
  void dispose() {
    _cardAnimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firstName = widget.fullName.trim().isEmpty
        ? 'Teman'
        : widget.fullName.trim().split(' ').first;

    return ConfettiOverlay(
      child: Column(
        children: [
          const SizedBox(height: 4),
          SizedBox(
            height: 156,
            width: 200,
            child: Lottie.asset(
              'assets/lottie/onb_ready.json',
              height: 156,
              animate: !_isFlutterTest,
              repeat: true,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.celebration_rounded,
                color: AppColors.neoChartreuse,
                size: 56,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            AppL10n.of(context).onbCelebrationTitle(firstName),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppL10n.of(context).onbCelebrationDesc,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          SlideTransition(
            position: _slideAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: OnboardingCelebrationCard(
                walletName: widget.walletName,
                walletType: widget.walletType,
                balanceText: widget.balanceText,
                username: widget.username,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
