import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import 'confetti_overlay.dart';
import 'onboarding_celebration_card.dart';

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
          const SizedBox(height: 12),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.neoChartreuse.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.neoChartreuse.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.celebration_rounded,
              color: AppColors.neoChartreuse,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Selamat datang, $firstName!',
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
            'Brankas dan rekening pertamamu sudah aktif.\nSemua siap, ayo mulai atur keuanganmu!',
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
