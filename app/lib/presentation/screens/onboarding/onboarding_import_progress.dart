import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';

class OnboardingImportProgress extends StatelessWidget {
  final int step;
  final bool isSuccess;
  final String? errorMessage;
  final Map<String, dynamic>? summary;
  final VoidCallback onContinue;
  final VoidCallback? onRetry;

  const OnboardingImportProgress({
    super.key,
    required this.step,
    required this.isSuccess,
    this.errorMessage,
    this.summary,
    required this.onContinue,
    this.onRetry,
  });

  Widget _buildStepItem({required int stepNumber, required String title, required String subtitle}) {
    final bool isDone = step > stepNumber || isSuccess;
    final bool isCurrent = step == stepNumber && !isSuccess;

    final Color iconColor = isDone
        ? AppColors.neoMint
        : (isCurrent ? AppColors.neoChartreuse : AppColors.textSubtle);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: iconColor.withValues(alpha: 0.5)),
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check_rounded, color: AppColors.neoMint, size: 16)
                  : (isCurrent
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.neoChartreuse),
                        )
                      : Text('$stepNumber', style: const TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.bold))),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDone || isCurrent ? AppColors.textWhite : AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.canvasBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.canvasBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.neoChartreuse, size: 16),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: AppColors.textWhite, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Center(child: ModalGrabHandle()),
          const SizedBox(height: 16),
          const Icon(Icons.error_outline_rounded, color: AppColors.neoCoral, size: 44),
          const SizedBox(height: 12),
          const Text('Gagal Memulihkan Data', style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.neoCoral, fontSize: 12)),
          ),
          const SizedBox(height: 20),
          if (onRetry != null)
            PrimaryActionButton(text: 'Coba Lagi', icon: Icons.refresh_rounded, onPressed: onRetry!),
          const SizedBox(height: 12),
        ],
      );
    }

    if (isSuccess) {
      final wCount = summary?['walletsCount'] ?? 0;
      final tCount = summary?['transactionsCount'] ?? 0;
      final sCount = summary?['subscriptionsCount'] ?? 0;
      final uName = summary?['username'] ?? 'User';

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Center(child: ModalGrabHandle()),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.neoMint.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.neoMint, size: 44),
          ),
          const SizedBox(height: 12),
          const Text('Data Berhasil Dipulihkan!', style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Selamat datang kembali, @$uName.', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildStatBadge(Icons.account_balance_wallet_outlined, '$wCount Rekening'),
              _buildStatBadge(Icons.receipt_long_outlined, '$tCount Transaksi'),
              if (sCount > 0) _buildStatBadge(Icons.subscriptions_outlined, '$sCount Tagihan'),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryActionButton(
            text: 'Lanjutkan ke Aplikasi',
            icon: Icons.arrow_forward_rounded,
            onPressed: onContinue,
          ),
          const SizedBox(height: 12),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: ModalGrabHandle()),
        const SizedBox(height: 16),
        const ModalHeader(
          title: 'Memulihkan Data Cadangan',
          subtitle: 'Mohon tunggu, proses sinkronisasi offline sedang berjalan...',
        ),
        const SizedBox(height: 16),
        _buildStepItem(stepNumber: 1, title: 'Validasi Berkas JSON', subtitle: 'Memeriksa keutuhan struktur tabel dan data'),
        _buildStepItem(stepNumber: 2, title: 'Restorasi Database SQLite', subtitle: 'Menulis rekening, transaksi, dan saldo awal'),
        _buildStepItem(stepNumber: 3, title: 'Sinkronisasi Status', subtitle: 'Memperbarui metrik Safe-to-Spend & profil'),
        const SizedBox(height: 20),
      ],
    );
  }
}
