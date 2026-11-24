import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../bloc/finance/finance_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';

class BackupExportCompletedView extends StatelessWidget {
  final FinanceState state;
  final String savedPath;
  final String? jsonPayload;
  final bool isEncrypted;

  const BackupExportCompletedView({
    super.key,
    required this.state,
    required this.savedPath,
    this.jsonPayload,
    this.isEncrypted = false,
  });

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AppColors.canvasBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.canvasBorder)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: AppColors.neoChartreuse, size: 14),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: AppColors.textWhite, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Future<void> _shareFile() async {
    try {
      if (savedPath.isNotEmpty && File(savedPath).existsSync()) {
        await SharePlus.instance.share(
          ShareParams(files: [XFile(savedPath)], subject: 'Cadangan Data fiBOnanci'),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final s = state;
    final fileName = savedPath.split(Platform.pathSeparator).last;
    final friendlyLocation = Platform.isIOS
        ? 'Aplikasi Files > Di iPhone Saya > Fibonanci App'
        : 'Pengelola File > Folder Download / Documents';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.neoMint.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle_rounded, color: AppColors.neoMint, size: 36),
        ),
        const SizedBox(height: 10),
        Text('Cadangan Berhasil Disimpan!', style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isEncrypted) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.textIncome.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                child: Row(children: [
                  Icon(Icons.lock_rounded, color: AppColors.textIncome, size: 12),
                  const SizedBox(width: 4),
                  Text('Terenkripsi AES-256', style: TextStyle(color: AppColors.textIncome, fontSize: 11, fontWeight: FontWeight.bold)),
                ]),
              ),
              const SizedBox(width: 6),
            ],
            Text('Aman & Offline', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.canvasBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.canvasBorder)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.folder_outlined, color: AppColors.textAccent, size: 16),
              const SizedBox(width: 6),
              Text('LOKASI PENYIMPANAN:', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.textIncome.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                child: Text('Otomatis Tersimpan', style: TextStyle(color: AppColors.textIncome, fontSize: 9.5, fontWeight: FontWeight.bold)),
              ),
            ]),
            const SizedBox(height: 8),
            Text(fileName, style: TextStyle(color: AppColors.textAccent, fontSize: 12.5, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.subdirectory_arrow_right_rounded, color: AppColors.textMuted, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  friendlyLocation,
                  style: TextStyle(color: AppColors.textWhite, fontSize: 11, fontWeight: FontWeight.w600, height: 1.3),
                ),
              ),
            ]),
            const SizedBox(height: 4),
            Text(savedPath, style: TextStyle(color: AppColors.textSubtle, fontSize: 9.5, fontFamily: 'monospace')),
          ]),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center, children: [
          _buildStatChip(Icons.account_balance_wallet_outlined, '${s.wallets.length} Rekening'),
          _buildStatChip(Icons.receipt_long_outlined, '${s.transactions.length} Transaksi'),
          if (s.subscriptions.isNotEmpty) _buildStatChip(Icons.subscriptions_outlined, '${s.subscriptions.length} Tagihan'),
        ]),
        const SizedBox(height: 16),
        PrimaryActionButton(
          key: const Key('export_finish_btn'),
          text: 'Selesai',
          icon: Icons.check_circle_rounded,
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(height: 10),
        Center(
          child: TextButton.icon(
            key: const Key('export_share_btn'),
            icon: Icon(Icons.folder_shared_outlined, color: AppColors.textAccent, size: 16),
            label: Text('Pilih Lokasi Lain / Bagikan Berkas', style: TextStyle(color: AppColors.textAccent, fontSize: 12.5, fontWeight: FontWeight.w600)),
            onPressed: _shareFile,
          ),
        ),
      ],
    );
  }
}
