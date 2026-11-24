import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

enum AppSnackBarType { success, info, warning, error }

/// Tactile, clean toast card with vertical accent capsule divider.
class TactileToastCard extends StatefulWidget {
  final String title;
  final String? message;
  final String? tag;
  final IconData? icon;
  final AppSnackBarType type;
  final VoidCallback? onAction;
  final String? actionLabel;

  const TactileToastCard({
    super.key,
    required this.title,
    this.message,
    this.tag,
    this.icon,
    this.type = AppSnackBarType.info,
    this.onAction,
    this.actionLabel,
  });

  @override
  State<TactileToastCard> createState() => _TactileToastCardState();
}

class _TactileToastCardState extends State<TactileToastCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;
  late final Animation<double> _capsule;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 240))..forward();
    _slide = Tween<Offset>(begin: const Offset(0, 0.20), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _scale = Tween<double>(begin: 0.96, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _capsule = Tween<double>(begin: 0.40, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.10, 1.0, curve: Curves.easeOutCubic)));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  (Color primary, Color secondary, String defaultTag, IconData defaultIcon) _resolveTheme() => switch (widget.type) {
        AppSnackBarType.success => (AppColors.textIncome, const Color(0xFF10B981), 'SUKSES', Icons.check_circle_rounded),
        AppSnackBarType.info => (AppColors.textAccent, AppColors.neoCyan, 'INFO', Icons.info_outline_rounded),
        AppSnackBarType.warning => (AppColors.statusCaution, const Color(0xFFFBBF24), 'PERHATIAN', Icons.warning_amber_rounded),
        AppSnackBarType.error => (AppColors.neoCoral, const Color(0xFFEF4444), 'HAPUS', Icons.delete_outline_rounded),
      };

  @override
  Widget build(BuildContext context) {
    final (primary, secondary, defTag, defIcon) = _resolveTheme();
    final tagText = (widget.tag ?? defTag).toUpperCase();
    final iconData = widget.icon ?? defIcon;

    return Dismissible(
      key: const Key('tactile_toast_dismissible'),
      direction: DismissDirection.down,
      onDismissed: (_) => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
      child: FadeTransition(
        opacity: _ctrl,
        child: SlideTransition(
          position: _slide,
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.canvasCardSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.canvasBorder, width: 1.0),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: AppColors.isDark ? 0.25 : 0.08), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Container(
                    constraints: const BoxConstraints(minWidth: 44),
                    alignment: Alignment.center,
                    child: Text(
                      tagText,
                      style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedBuilder(
                    animation: _capsule,
                    builder: (_, child) => Transform.scale(
                      scaleY: _capsule.value,
                      alignment: Alignment.center,
                      child: Container(
                        width: 4.0,
                        height: 28,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.5),
                          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [primary, secondary]),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(iconData, color: primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: primary, height: 1.25),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.message != null && widget.message!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.message!,
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textMuted, height: 1.25),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.actionLabel != null && widget.onAction != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: widget.onAction,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Text(widget.actionLabel!, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: primary)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
