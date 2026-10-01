import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class SpringSwipeableCard extends StatefulWidget {
  final Widget child;
  final Color accentColor;
  final VoidCallback onConfirmed;
  final VoidCallback onRejected;
  final ValueChanged<double>? onDragOffsetChanged;

  const SpringSwipeableCard({
    super.key,
    required this.child,
    required this.accentColor,
    required this.onConfirmed,
    required this.onRejected,
    this.onDragOffsetChanged,
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
      widget.onDragOffsetChanged?.call(_dragOffset);
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
    widget.onDragOffsetChanged?.call(_dragOffset);
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

  Widget _buildActionSlot(bool isRight) {
    final color = isRight ? AppColors.neoMint : AppColors.neoCoral;
    final bg = isRight ? const Color(0xFF10231C) : const Color(0xFF261317);
    final icon = isRight ? Icons.check_rounded : Icons.delete_outline_rounded;
    final text = isRight ? 'Benar' : 'Salah';

    final badge = Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.20),
        border: Border.all(color: color.withValues(alpha: 0.50), width: 1.5),
      ),
      child: Icon(icon, color: color, size: 20),
    );
    final label = Text(
      text,
      style: GoogleFonts.plusJakartaSans(color: color, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: -0.3),
    );

    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.45), width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          alignment: isRight ? Alignment.centerLeft : Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: isRight ? [badge, const SizedBox(width: 12), label] : [label, const SizedBox(width: 12), badge],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRight = _dragOffset > 1.0;
    final isLeft = _dragOffset < -1.0;

    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Stack(
        children: [
          if (isRight || isLeft) _buildActionSlot(isRight),
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
