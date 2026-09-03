import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class BottomNavDock extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTapIndex;
  final VoidCallback? onAddAction;
  final VoidCallback? onCenterAction;

  const BottomNavDock({
    super.key,
    required this.currentIndex,
    required this.onTapIndex,
    this.onAddAction,
    this.onCenterAction,
  }) : assert(
          onAddAction != null || onCenterAction != null,
          'Either onAddAction or onCenterAction must be provided',
        );

  VoidCallback get _action => onAddAction ?? onCenterAction!;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SizedBox(
              height: 56,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Grouped left-aligned, pill-shaped container (iPhone style)
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xB813141C),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: const Color(0x33FFFFFF),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Row(
                                children: [
                                  _buildNavItem(
                                    index: 0,
                                    icon: Icons.dashboard_outlined,
                                    activeIcon: Icons.dashboard,
                                    label: 'Home',
                                  ),
                                  _buildNavItem(
                                    index: 1,
                                    icon: Icons.receipt_long_outlined,
                                    activeIcon: Icons.receipt_long,
                                    label: 'Tagihan',
                                  ),
                                  _buildNavItem(
                                    index: 2,
                                    icon: Icons.account_balance_wallet_outlined,
                                    activeIcon: Icons.account_balance_wallet,
                                    label: 'Wallets',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 2. Add: Isolated circular button, right-aligned
                  _AddActionButton(onPressed: _action),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = currentIndex == index;

    return Expanded(
      child: _NavItemWidget(
        isActive: isActive,
        icon: icon,
        activeIcon: activeIcon,
        label: label,
        onTap: () {
          HapticFeedback.selectionClick();
          onTapIndex(index);
        },
      ),
    );
  }
}

/// Custom Clipper to constrain BackdropFilter exactly to the pod geometry
class PodClipper extends CustomClipper<Path> {
  final bool isLeft;

  const PodClipper({required this.isLeft});

  @override
  Path getClip(Size size) => PodBorderPainter.buildPath(size, isLeft);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Custom Painter: Fills pod with translucent glass and strokes crisp 1.2px frosted border
class PodBorderPainter extends CustomPainter {
  final bool isLeft;

  const PodBorderPainter({required this.isLeft});

  static Path buildPath(Size size, bool isLeft) {
    final path = Path();
    final r = size.height / 2; // 28.0
    // Cutout radius 34.0 is concentric with the 25px-radius button
    const cutoutRadius = 34.0;

    if (isLeft) {
      // Left Pod: Rounded outer left, concave curve on inner right
      path.moveTo(r, 0);
      path.lineTo(size.width, 0);

      // Concave curve inward hugging the button circle
      path.arcToPoint(
        Offset(size.width, size.height),
        radius: const Radius.circular(cutoutRadius),
        clockwise: false,
      );

      path.lineTo(r, size.height);
      path.quadraticBezierTo(0, size.height, 0, size.height - r);
      path.lineTo(0, r);
      path.quadraticBezierTo(0, 0, r, 0);
    } else {
      // Right Pod: Concave curve on inner left, rounded outer right
      path.moveTo(0, 0);
      path.lineTo(size.width - r, 0);
      path.quadraticBezierTo(size.width, 0, size.width, r);
      path.lineTo(size.width, size.height - r);
      path.quadraticBezierTo(size.width, size.height, size.width - r, size.height);
      path.lineTo(0, size.height);

      // Concave curve inward hugging the button circle
      path.arcToPoint(
        const Offset(0, 0),
        radius: const Radius.circular(cutoutRadius),
        clockwise: false,
      );
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = buildPath(size, isLeft);

    // 1. Translucent frosted glass fill (~72% opacity deep obsidian)
    final fillPaint = Paint()
      ..color = const Color(0xB813141C)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // 2. Crisp translucent border (frosted rim highlight)
    final strokePaint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NavItemWidget extends StatefulWidget {
  final bool isActive;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.isActive,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_NavItemWidget> createState() => _NavItemWidgetState();
}

class _NavItemWidgetState extends State<_NavItemWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.neoChartreuse.withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.isActive ? widget.activeIcon : widget.icon,
                  color: widget.isActive ? AppColors.neoChartreuse : AppColors.textMuted,
                  size: widget.isActive ? 19 : 21,
                ),
                if (widget.isActive) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.neoChartreuse,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddActionButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _AddActionButton({required this.onPressed});

  @override
  State<_AddActionButton> createState() => _AddActionButtonState();
}

class _AddActionButtonState extends State<_AddActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onPressed();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.neoChartreuse,
            boxShadow: [
              BoxShadow(
                color: AppColors.neoChartreuse.withValues(alpha: 0.35),
                blurRadius: 16,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.30),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.add_rounded,
              color: AppColors.textDarkPrimary,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}

