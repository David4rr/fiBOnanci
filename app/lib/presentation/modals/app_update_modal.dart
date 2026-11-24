import 'package:flutter/material.dart';

import '../../core/native_bridge/notification_bridge.dart';
import '../../core/update/app_update_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common/common_widgets.dart';

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
                  color: AppColors.canvasBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.canvasBorder),
                ),
                child: const Center(
                  child: FibonanciLogoMark(size: 28, showGlow: true),
                ),
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
                      style: AppTypography.listSubtitle.copyWith(color: AppColors.textIncome),
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
                Text('v${updateInfo.currentVersion}', style: TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.w600)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textMuted),
                ),
                Text(
                  'v${updateInfo.latestVersion}',
                  style: TextStyle(color: AppColors.textAccent, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text('Catatan Rilis (Changelog):', style: TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 180),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.canvasBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.canvasBorder),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: UserFriendlyChangelogView(releaseNotes: updateInfo.releaseNotes, isCompact: true),
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
                if (started && messenger != null) {
                  AppSnackBar.showWithMessenger(
                    messenger,
                    title: 'Mengunduh Pembaruan',
                    message: 'Mengunduh pembaruan v${updateInfo.latestVersion}... Cek status di bilah notifikasi.',
                    type: AppSnackBarType.info,
                    tag: 'UPDATE',
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
              child: Text('Nanti Saja', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
