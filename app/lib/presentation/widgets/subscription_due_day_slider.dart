import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/l10n/locale_notifier.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'painters/telescope_slider_painter.dart';
import 'telescope_date_badge.dart';

/// Minimalist parallax ruler slider for due-day selection (1..31):
/// active indicator moves directly with touch while graduation lines glide smoothly in parallax.
class SubscriptionDueDaySlider extends StatefulWidget {
  final int dueDay;
  final String? badgeText;
  final VoidCallback? onBadgeTap;
  final bool isFutureCycle;
  final ValueChanged<int> onDayChanged;

  const SubscriptionDueDaySlider({
    super.key,
    required this.dueDay,
    required this.onDayChanged,
    this.badgeText,
    this.onBadgeTap,
    this.isFutureCycle = false,
  });

  @override
  State<SubscriptionDueDaySlider> createState() => _SubscriptionDueDaySliderState();
}

class _SubscriptionDueDaySliderState extends State<SubscriptionDueDaySlider>
    with TickerProviderStateMixin {
  static const _milestones = [1, 5, 10, 15, 20, 25, 31];
  late final AnimationController _posController;
  late final AnimationController _dragController;
  late double _fromDay;
  late double _toDay;
  bool _isDragging = false;
  double? _dragFractionDay;

  @override
  void initState() {
    super.initState();
    _fromDay = widget.dueDay.toDouble();
    _toDay = widget.dueDay.toDouble();
    _posController = AnimationController(vsync: this, duration: const Duration(milliseconds: 240))
      ..addListener(() => setState(() {}));
    _dragController = AnimationController(vsync: this, duration: const Duration(milliseconds: 140))
      ..addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant SubscriptionDueDaySlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dueDay != widget.dueDay && !_isDragging) {
      _fromDay = _currentAnimatedDay();
      _toDay = widget.dueDay.toDouble();
      _posController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _posController.dispose();
    _dragController.dispose();
    super.dispose();
  }

  double _currentAnimatedDay() {
    if (_isDragging && _dragFractionDay != null) return _dragFractionDay!;
    final t = Curves.easeOutCubic.transform(_posController.value);
    return _fromDay + (_toDay - _fromDay) * t;
  }

  double _fractionDayFromOffset(Offset localPosition, double trackWidth) {
    const pad = 18.0;
    final usable = (trackWidth - pad * 2).clamp(1.0, double.infinity);
    final dx = (localPosition.dx - pad).clamp(0.0, usable);
    return (1.0 + (dx / usable) * 30.0).clamp(1.0, 31.0);
  }

  void _selectDay(int day) {
    final clamped = day.clamp(1, 31);
    if (clamped != widget.dueDay) {
      HapticFeedback.selectionClick();
      widget.onDayChanged(clamped);
    }
  }

  void _applyDrag(Offset pos, double width, {required bool start}) {
    if (start) {
      _isDragging = true;
      _dragController.forward();
    }
    final frac = _fractionDayFromOffset(pos, width);
    setState(() => _dragFractionDay = frac);
    _selectDay(frac.round());
  }

  void _onDragEnd() {
    if (!_isDragging) return;
    _fromDay = _dragFractionDay ?? widget.dueDay.toDouble();
    _toDay = widget.dueDay.toDouble();
    _isDragging = false;
    _dragFractionDay = null;
    _dragController.reverse();
    _posController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final accent = widget.isFutureCycle ? AppColors.neoMint : AppColors.neoCoral;
    final animatedDay = _currentAnimatedDay();
    final dragProgress = Curves.easeOutCubic.transform(_dragController.value);
    final badgeLabel = widget.badgeText ?? l10n.subDueDayEveryMonth(widget.dueDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(l10n.subDueDateHeader, style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted, letterSpacing: 0.8), overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            TelescopeDateBadge(label: badgeLabel, accent: accent, isHighlighted: _isDragging || widget.isFutureCycle, onTap: widget.onBadgeTap),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (d) => _applyDrag(d.localPosition, width, start: true),
              onHorizontalDragUpdate: (d) => _applyDrag(d.localPosition, width, start: false),
              onHorizontalDragEnd: (_) => _onDragEnd(),
              onHorizontalDragCancel: _onDragEnd,
              onTapDown: (d) => _selectDay(_fractionDayFromOffset(d.localPosition, width).round()),
              child: SizedBox(
                height: 44,
                width: width,
                child: CustomPaint(
                  painter: TelescopeSliderPainter(
                    animatedDay: animatedDay,
                    dragProgress: dragProgress,
                    accentColor: accent,
                    trackColor: AppColors.canvasInputSearch,
                    majorTickColor: AppColors.textWhite.withValues(alpha: 0.78),
                    minorTickColor: AppColors.textMuted.withValues(alpha: 0.28),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final m in _milestones)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _selectDay(m),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 160),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: m == widget.dueDay ? FontWeight.w800 : FontWeight.w600,
                      color: m == widget.dueDay ? accent : AppColors.textMuted.withValues(alpha: 0.6),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    child: Text('$m'),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
