import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/update/app_update_downloader.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';

class InAppUpdateProgressCard extends StatelessWidget {
  final String version;
  final DownloadProgressInfo? progressInfo;
  final VoidCallback onInstall;
  final VoidCallback? onRetry;

  const InAppUpdateProgressCard({
    super.key,
    required this.version,
    required this.progressInfo,
    required this.onInstall,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final info = progressInfo;
    final isDone = info?.isCompleted ?? false;
    final isFailed = info?.isFailed ?? false;
    final progress = info?.progress ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.canvasBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDone
              ? AppColors.neoMint.withValues(alpha: 0.45)
              : (isFailed ? AppColors.neoCoral.withValues(alpha: 0.45) : AppColors.canvasBorder),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isDone
                    ? Icons.check_circle_rounded
                    : (isFailed ? Icons.error_outline_rounded : Icons.downloading_rounded),
                color: isDone ? AppColors.neoMint : (isFailed ? AppColors.neoCoral : AppColors.neoChartreuse),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isDone
                      ? 'Pembaruan v$version Siap Dipasang'
                      : (isFailed ? 'Gagal Mengunduh Pembaruan' : 'Mengunduh v$version...'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDone ? AppColors.textIncome : AppColors.textWhite,
                  ),
                ),
              ),
              if (!isDone && !isFailed && info != null)
                Text(
                  info.percentageText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textAccent,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: isDone ? 1.0 : (isFailed ? 0.0 : (progress > 0 ? progress : null)),
              minHeight: 6,
              backgroundColor: AppColors.surfaceSubtle,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDone ? AppColors.neoMint : (isFailed ? AppColors.neoCoral : AppColors.neoChartreuse),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isDone
                    ? 'File APK terverifikasi & siap diinstall'
                    : (isFailed
                        ? 'Koneksi terputus. Silakan coba lagi.'
                        : (info != null && info.totalBytes > 0
                            ? '${info.formattedDownloaded} / ${info.formattedTotal}'
                            : 'Menghubungkan ke GitHub...')),
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
              ),
              Text(
                'Pembersihan Otomatis Aktif',
                style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textSubtle),
              ),
            ],
          ),
          if (isDone) ...[
            const SizedBox(height: 12),
            PrimaryActionButton(
              key: const Key('install_downloaded_apk_btn'),
              text: 'Pasang Pembaruan Sekarang',
              icon: Icons.install_mobile_rounded,
              onPressed: onInstall,
            ),
          ] else if (isFailed && onRetry != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRetry,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh_rounded, size: 14, color: AppColors.neoCoral),
                  const SizedBox(width: 4),
                  Text('Coba Unduh Ulang', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.neoCoral, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
