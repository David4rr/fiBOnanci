import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/finance/finance_bloc.dart';
import 'peekable_balance_text.dart';

/// Smoothly animates a numeric currency or metric value from 0 (on mount)
/// or from its previous value whenever [value] changes, using tabular figures
/// to prevent horizontal digit jitter.
class AnimatedCountingText extends StatelessWidget {
  final double value;
  final String Function(double animatedValue) formatter;
  final TextStyle style;
  final Duration duration;
  final Curve curve;
  final bool animateOnMount;
  final bool respectPrivacyMask;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AnimatedCountingText({
    super.key,
    required this.value,
    required this.formatter,
    required this.style,
    this.duration = const Duration(milliseconds: 560),
    this.curve = Curves.easeOutCubic,
    this.animateOnMount = true,
    this.respectPrivacyMask = true,
    this.textAlign,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
  });

  bool _isHidden(BuildContext context) {
    if (!respectPrivacyMask) return false;
    try {
      return context.select<FinanceBloc, bool>((b) => b.state.isBalanceHidden);
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeTarget = value.isFinite ? value : 0.0;
    final tabularStyle = style.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    if (_isHidden(context)) {
      return PeekableBalanceText(
        text: formatter(safeTarget),
        style: tabularStyle,
        isHidden: true,
        textAlign: textAlign,
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: animateOnMount ? 0.0 : safeTarget,
        end: safeTarget,
      ),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, _) {
        return Text(
          formatter(animatedValue),
          style: tabularStyle,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}
