import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class BottomNavDock extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTapIndex;
  final VoidCallback onCenterAction;

  const BottomNavDock({
    super.key,
    required this.currentIndex,
    required this.onTapIndex,
    required this.onCenterAction,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 320,
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. LEFT POD: Home & Tagihan (Inner curve concentric with the + button)
                  SizedBox(
                    width: 128,
                    height: 56,
                    child: CustomPaint(
                      painter: const PodBorderPainter(isLeft: true),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6, right: 16),
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
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 2. CENTER FLAT CIRCULAR BUTTON (Floats in the concentric cradle)
                  _CenterActionButton(onPressed: onCenterAction),

                  // 3. RIGHT POD: Wallets & Settings (Inner curve concentric with the + button)
                  SizedBox(
                    width: 128,
                    height: 56,
                    child: CustomPaint(
                      painter: const PodBorderPainter(isLeft: false),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 6),
                        child: Row(
                          children: [
                            _buildNavItem(
                              index: 2,
                              icon: Icons.account_balance_wallet_outlined,
                              activeIcon: Icons.account_balance_wallet,
                              label: 'Wallets',
                            ),
                            _buildNavItem(
                              index: 3,
                              icon: Icons.settings_outlined,
                              activeIcon: Icons.settings,
                              label: 'Settings',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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

/// Custom Painter: Fills pod and strokes the 1.2px border along the concave curve
class PodBorderPainter extends CustomPainter {
  final bool isLeft;

  const PodBorderPainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final r = size.height / 2; // 28.0
    // Cutout radius 34.0 is concentric with the 25px-radius button, leaving a clean uniform gap!
    const cutoutRadius = 34.0;

    if (isLeft) {
      // Left Pod: Rounded outer left, concave curve on inner right
      path.moveTo(r, 0);
      path.lineTo(size.width, 0);

      // Concave curve inward hugging the button circle
      path.arcToPoint(
        Offset(size.width, size.height),
        radius: const Radius.circular(cutoutRadius),
        clockwise: false, // Inward curve!
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
        clockwise: false, // Inward curve!
      );
    }
    path.close();

    // 1. Fill background surface
    final fillPaint = Paint()
      ..color = AppColors.canvasCardSurface
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // 2. Stroke 1.2px border along the entire path (including the concave curve)
    final strokePaint = Paint()
      ..color = AppColors.canvasBorder
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
        child: SizedBox(
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.isActive ? widget.activeIcon : widget.icon,
                color: widget.isActive ? AppColors.neoChartreuse : AppColors.textMuted,
                size: widget.isActive ? 20 : 22,
              ),
              if (widget.isActive) ...[
                const SizedBox(height: 2),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: AppColors.neoChartreuse,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterActionButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _CenterActionButton({required this.onPressed});

  @override
  State<_CenterActionButton> createState() => _CenterActionButtonState();
}

class _CenterActionButtonState extends State<_CenterActionButton> {
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
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.neoChartreuse,
            // Solid flat neon circle: ZERO STROKE, ZERO BORDER, ZERO SHADOW
          ),
          child: const Center(
            child: Icon(
              Icons.add_rounded,
              color: AppColors.textDarkPrimary,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
