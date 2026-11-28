import 'dart:io';
import 'package:flutter/material.dart';

import '../../core/l10n/locale_notifier.dart';
import '../modals/notification_permission_modal.dart';
import '../theme/app_colors.dart';

class NotificationPermissionBanner extends StatefulWidget {
  final VoidCallback? onDismiss;

  const NotificationPermissionBanner({super.key, this.onDismiss});

  @override
  State<NotificationPermissionBanner> createState() => _NotificationPermissionBannerState();
}

class _NotificationPermissionBannerState extends State<NotificationPermissionBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    if (!Platform.isAndroid && !Platform.environment.containsKey('FLUTTER_TEST')) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => NotificationPermissionModal.show(context),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.canvasCardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.canvasBorder, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.notifications_active_outlined, color: AppColors.textAccent, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppL10n.of(context).notifBannerTitle,
                        style: TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        AppL10n.of(context).notifBannerSub,
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.neoChartreuse,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppL10n.of(context).notifBannerEnable,
                    style: TextStyle(color: AppColors.textDarkPrimary, fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() => _dismissed = true);
                    widget.onDismiss?.call();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(Icons.close, color: AppColors.textMuted, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
