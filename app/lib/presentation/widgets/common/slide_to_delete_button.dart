import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

/// Tactile swipe-to-confirm action button designed for irreversible actions.
/// Requires the user to slide the thumb from left to right before invoking
/// [onSlideComplete] to trigger the confirmation dialog.
class SlideToDeleteButton extends StatefulWidget {
  final String label;
  final VoidCallback onSlideComplete;
  final double height;

  const SlideToDeleteButton({
    super.key,
    required this.label,
    required this.onSlideComplete,
    this.height = 52.0,
  });

  @override
  State<SlideToDeleteButton> createState() => _SlideToDeleteButtonState();
}

class _SlideToDeleteButtonState extends State<SlideToDeleteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  double _dragProgress = 0.0;
  bool _hapticTriggered = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..addListener(() => setState(() => _dragProgress = _animController.value));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details, double maxDrag) {
    if (maxDrag <= 0) return;
    setState(() {
      _dragProgress = (_dragProgress + details.primaryDelta! / maxDrag).clamp(0.0, 1.0);
      _animController.value = _dragProgress;
    });

    if (_dragProgress >= 0.75 && !_hapticTriggered) {
      _hapticTriggered = true;
      HapticFeedback.selectionClick();
    } else if (_dragProgress < 0.75 && _hapticTriggered) {
      _hapticTriggered = false;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragProgress >= 0.75) {
      _completeSlide();
    } else {
      _resetSlide();
    }
  }

  void _completeSlide() {
    HapticFeedback.heavyImpact();
    _animController.animateTo(1.0, curve: Curves.easeOut).then((_) {
      widget.onSlideComplete();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _resetSlide();
      });
    });
  }

  void _resetSlide() {
    _hapticTriggered = false;
    _animController.animateTo(0.0, curve: Curves.easeOutBack);
  }

  void _handleTap() {
    _animController.animateTo(1.0, curve: Curves.easeInOut).then((_) {
      widget.onSlideComplete();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _resetSlide();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final thumbSize = widget.height - 8;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final maxDrag = totalWidth - thumbSize - 8;

        return GestureDetector(
          onTap: _handleTap,
          onHorizontalDragUpdate: (d) => _onDragUpdate(d, maxDrag),
          onHorizontalDragEnd: _onDragEnd,
          child: Container(
            height: widget.height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.neoCoral.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.neoCoral.withValues(alpha: 0.35), width: 1.2),
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 4 + thumbSize + (_dragProgress * maxDrag),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.neoCoral.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                Center(
                  child: Opacity(
                    opacity: (1.0 - (_dragProgress * 1.5)).clamp(0.0, 1.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.neoCoral,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.keyboard_double_arrow_right_rounded, size: 16, color: AppColors.neoCoral),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 4 + (_dragProgress * maxDrag),
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      color: AppColors.neoCoral,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neoCoral.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOutBack,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, anim) => ScaleTransition(
                          scale: anim,
                          child: RotationTransition(
                            turns: anim.drive(Tween<double>(begin: 0.125, end: 0.0)),
                            child: FadeTransition(opacity: anim, child: child),
                          ),
                        ),
                        child: _dragProgress >= 0.75
                            ? const Icon(Icons.delete_rounded, key: ValueKey('trash'), color: AppColors.textDarkPrimary, size: 20)
                            : const Icon(Icons.arrow_forward_rounded, key: ValueKey('arrow'), color: AppColors.textDarkPrimary, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
