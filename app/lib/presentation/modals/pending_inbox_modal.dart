import 'package:flutter/material.dart';

import '../../core/native_bridge/notification_bridge.dart';
import '../../core/notification_parser/notification_parser.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/notification_review_modal.dart';

/// Modal sheet for viewing and reviewing queued notifications captured while the app was inactive.
class PendingInboxModal {
  static void show(BuildContext context) async {
    final pending = await NotificationBridge.getPendingRawNotifications();
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.inbox_outlined, color: AppColors.neoChartreuse, size: 22),
                      const SizedBox(width: 8),
                      Text('Kotak Masuk Notifikasi', style: AppTypography.sectionTitle),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Notifikasi bank yang masuk saat aplikasi tidak dibuka ditampung aman di sini:',
                style: AppTypography.listSubtitle,
              ),
              const SizedBox(height: 16),
              if (pending.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.canvasInputSearch,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'Tidak ada antrean notifikasi tertunda.\nSemua transaksi bank Anda sudah rapi tercatat!',
                      textAlign: TextAlign.center,
                      style: AppTypography.listSubtitle,
                    ),
                  ),
                )
              else
                for (final item in pending)
                  Builder(builder: (c) {
                    final pkg = item['package'] as String? ?? '';
                    final title = item['title'] as String? ?? '';
                    final text = item['text'] as String? ?? '';
                    final parsed = NotificationParser.parse(packageName: pkg, title: title, body: text);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.canvasInputSearch,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.canvasBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                pkg.contains('seabank') ? 'SeaBank' : (pkg.contains('shopee') ? 'ShopeePay' : title),
                                style: AppTypography.listTitle,
                              ),
                              if (parsed != null)
                                Text(
                                  parsed.type == 'income'
                                      ? '+Rp ${parsed.amount.toStringAsFixed(0)}'
                                      : '-Rp ${parsed.amount.toStringAsFixed(0)}',
                                  style: AppTypography.listAmount.copyWith(
                                    color: parsed.type == 'income' ? AppColors.neoMint : AppColors.neoCoral,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(text, style: AppTypography.listSubtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 12),
                          if (parsed != null)
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.neoChartreuse,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  'Review & Simpan',
                                  style: AppTypography.listTitle.copyWith(
                                    color: AppColors.textDarkPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  await NotificationReviewModal.show(context, parsed: parsed, rawPackage: pkg);
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
            ],
          ),
        );
      },
    );
  }
}
