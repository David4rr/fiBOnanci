import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/notifications/in_app_notification_storage.dart';
import '../../theme/app_colors.dart';

class InboxReminderCard extends StatelessWidget {
  final InAppNotificationItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const InboxReminderCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (now.year == dt.year && now.month == dt.month && now.day == dt.day) {
      return DateFormat('HH:mm').format(dt);
    }
    return DateFormat('d MMM, HH:mm').format(dt);
  }

  IconData _getCategoryIcon() {
    switch (item.category) {
      case 'streak':
        return Icons.bolt_rounded;
      case 'system':
        return Icons.info_outline_rounded;
      case 'bill':
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Color _getCategoryColor() {
    switch (item.category) {
      case 'streak':
        return AppColors.neoChartreuse;
      case 'system':
        return const Color(0xFF60A5FA);
      case 'bill':
      default:
        return AppColors.neoMint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Dismissible(
          key: ValueKey('inbox_reminder_${item.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: const Color(0xFF261317),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hapus',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.neoCoral,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neoCoral.withValues(alpha: 0.20),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.neoCoral,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          onDismissed: (_) => onDelete(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: item.isRead
                    ? AppColors.canvasCardSurface
                    : AppColors.canvasCardSurface.withAlpha(240),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: item.isRead
                      ? AppColors.canvasBorder
                      : AppColors.neoChartreuse.withAlpha(90),
                  width: item.isRead ? 0.8 : 1.2,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: catColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: catColor.withAlpha(60)),
                    ),
                    child: Icon(_getCategoryIcon(), color: catColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.textWhite,
                                  fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTimestamp(item.timestamp),
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                            if (!item.isRead) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.neoChartreuse,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.body,
                          style: GoogleFonts.plusJakartaSans(
                            color: item.isRead
                                ? AppColors.textMuted
                                : AppColors.textWhite.withAlpha(220),
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
