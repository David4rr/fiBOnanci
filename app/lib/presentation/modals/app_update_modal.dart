import 'package:flutter/material.dart';

import '../../core/native_bridge/notification_bridge.dart';
import '../../core/update/app_update_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common/modal_grab_handle.dart';
import '../widgets/common/modal_sheet_scaffold.dart';
import '../widgets/common/primary_action_button.dart';

class AppUpdateModal extends StatelessWidget {
  final AppUpdateInfo updateInfo;

  const AppUpdateModal({super.key, required this.updateInfo});

  static Future<void> show(BuildContext context, AppUpdateInfo info) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AppUpdateModal(updateInfo: info),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheetScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: ModalGrabHandle()),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.neoChartreuse.withAlpha(30),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.neoChartreuse.withAlpha(60)),
                ),
                child: const Icon(Icons.system_update_rounded, color: AppColors.neoChartreuse, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pembaruan Tersedia', style: AppTypography.sectionTitle),
                    const SizedBox(height: 2),
                    Text(
                      'Versi v${updateInfo.latestVersion} siap diunduh',
                      style: AppTypography.listSubtitle.copyWith(color: AppColors.neoMint),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.canvasBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.canvasBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('v${updateInfo.currentVersion}', style: const TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.w600)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textMuted),
                ),
                Text(
                  'v${updateInfo.latestVersion}',
                  style: const TextStyle(color: AppColors.neoChartreuse, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text('Catatan Rilis:', style: TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 140),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.canvasBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.canvasBorder),
            ),
            child: SingleChildScrollView(
              child: Text(
                updateInfo.releaseNotes.trim().isEmpty
                    ? 'Peningkatan performa dan perbaikan sistem.'
                    : updateInfo.releaseNotes.trim(),
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.45),
              ),
            ),
          ),
          const SizedBox(height: 20),
          PrimaryActionButton(
            text: 'Unduh & Pasang Pembaruan',
            icon: Icons.download_rounded,
            onPressed: () async {
              final messenger = ScaffoldMessenger.maybeOf(context);
              Navigator.pop(context);

              final targetUrl = updateInfo.apkUrl ?? updateInfo.htmlUrl;
              final isApk = targetUrl.toLowerCase().contains('.apk');

              if (isApk) {
                final fileName = 'fiBOnanci-v${updateInfo.latestVersion}.apk';
                final started = await NotificationBridge.downloadApk(targetUrl, fileName: fileName);
                if (started) {
                  messenger?.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Mengunduh pembaruan v${updateInfo.latestVersion}... Cek status di bilah notifikasi.',
                        style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                      ),
                      backgroundColor: AppColors.canvasCardSurface,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                  return;
                }
              }

              await NotificationBridge.openUrl(targetUrl);
            },
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Nanti Saja', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
