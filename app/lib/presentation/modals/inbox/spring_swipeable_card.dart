import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class SpringSwipeableCard extends StatefulWidget {
  final Widget child;
  final Color accentColor;
  final VoidCallback onConfirmed;
  final VoidCallback onRejected;

  const SpringSwipeableCard({
    super.key,
    required this.child,
    required this.accentColor,
    required this.onConfirmed,
    required this.onRejected,
  });

  @override
  State<SpringSwipeableCard> createState() => _SpringSwipeableCardState();
}

class _SpringSwipeableCardState extends State<SpringSwipeableCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this);
    _controller.addListener(() {
      setState(() => _dragOffset = _controller.value);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_controller.isAnimating) _controller.stop();
    setState(() {
      _dragOffset += details.primaryDelta ?? 0.0;
      _controller.value = _dragOffset;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0.0;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final threshold = screenWidth * 0.50;

    if (_dragOffset >= threshold) {
      _dismissRight();
    } else if (_dragOffset <= -threshold) {
      _dismissLeft();
    } else {
      _snapBackWithSpring(velocity);
    }
  }

  void _snapBackWithSpring(double velocity) {
    final simulation = SpringSimulation(
      const SpringDescription(mass: 1.0, stiffness: 420.0, damping: 24.0),
      _dragOffset,
      0.0,
      velocity,
    );
    _controller.animateWith(simulation);
  }

  void _dismissRight() {
    final target = MediaQuery.sizeOf(context).width;
    _controller.animateTo(target, duration: const Duration(milliseconds: 200), curve: Curves.easeOutCubic).then((_) {
      if (mounted) widget.onConfirmed();
    });
  }

  void _dismissLeft() {
    final target = -MediaQuery.sizeOf(context).width;
    _controller.animateTo(target, duration: const Duration(milliseconds: 200), curve: Curves.easeOutCubic).then((_) {
      if (mounted) widget.onRejected();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDraggingRight = _dragOffset > 0;
    final isDraggingLeft = _dragOffset < 0;
    final threshold = MediaQuery.sizeOf(context).width * 0.50;
    final progress = (_dragOffset.abs() / threshold).clamp(0.0, 1.0);

    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  if (isDraggingRight)
                    Positioned.fill(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColors.neoMint.withValues(alpha: 0.12 * progress),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.neoMint.withValues(alpha: 0.35 * progress)),
                        ),
                        child: Opacity(
                          opacity: (progress * 1.2).clamp(0.0, 1.0),
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.neoMint.withValues(alpha: 0.2)),
                                child: const Icon(Icons.check_rounded, color: AppColors.neoMint, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Text('Benar', style: GoogleFonts.plusJakartaSans(color: AppColors.neoMint, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: -0.2)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (isDraggingLeft)
                    Positioned.fill(
                      child: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColors.neoCoral.withValues(alpha: 0.12 * progress),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.neoCoral.withValues(alpha: 0.35 * progress)),
                        ),
                        child: Opacity(
                          opacity: (progress * 1.2).clamp(0.0, 1.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Salah', style: GoogleFonts.plusJakartaSans(color: AppColors.neoCoral, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: -0.2)),
                              const SizedBox(width: 8),
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.neoCoral.withValues(alpha: 0.2)),
                                child: const Icon(Icons.delete_outline_rounded, color: AppColors.neoCoral, size: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
