import 'package:flutter/material.dart';

import '../../core/native_bridge/notification_bridge.dart';
import '../../core/notification_parser/notification_parser.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/notification_review_modal.dart';

/// Modal sheet for viewing and reviewing queued notifications captured while the app was inactive.
class PendingInboxModal {
  static Future<void> show(BuildContext context) async {
    final initialPending = await NotificationBridge.getPendingRawNotifications();
    if (!context.mounted) return;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _PendingInboxSheet(initialPending: initialPending),
    );
  }
}

class _PendingInboxSheet extends StatefulWidget {
  final List<Map<String, dynamic>> initialPending;

  const _PendingInboxSheet({required this.initialPending});

  @override
  State<_PendingInboxSheet> createState() => _PendingInboxSheetState();
}

class _PendingInboxSheetState extends State<_PendingInboxSheet> {
  late List<Map<String, dynamic>> _pending;

  @override
  void initState() {
    super.initState();
    _pending = List<Map<String, dynamic>>.from(widget.initialPending);
  }

  void _removeItem(Map<String, dynamic> item) {
    NotificationBridge.removePendingNotification(item);
    setState(() {
      _pending.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
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
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.inbox_outlined, color: AppColors.neoChartreuse, size: 22),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Kotak Masuk Notifikasi',
                        style: AppTypography.sectionTitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Notifikasi bank yang masuk saat aplikasi tidak dibuka ditampung aman di sini:',
            style: AppTypography.listSubtitle,
          ),
          const SizedBox(height: 16),
          if (_pending.isEmpty)
            Container(
              width: double.infinity,
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
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.6,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _pending.length,
                itemBuilder: (context, index) {
                  final item = _pending[index];
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
                            Expanded(
                              child: Text(
                                pkg.contains('seabank') ? 'SeaBank' : (pkg.contains('shopee') ? 'ShopeePay' : title),
                                style: AppTypography.listTitle,
                                overflow: TextOverflow.ellipsis,
                              ),
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
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 38,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.neoChartreuse,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Text(
                                    'Review & Simpan',
                                    style: AppTypography.listTitle.copyWith(
                                      color: AppColors.textDarkPrimary,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (parsed != null) {
                                      final confirmed = await NotificationReviewModal.show(
                                        context,
                                        parsed: parsed,
                                        rawPackage: pkg,
                                      );
                                      if (confirmed == true) {
                                        _removeItem(item);
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 38,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.canvasBorder),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                ),
                                child: Text(
                                  'Abaikan',
                                  style: AppTypography.listSubtitle.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                                onPressed: () => _removeItem(item),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
