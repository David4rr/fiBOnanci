import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class WalletDeleteDialog {
  static void show(
    BuildContext parentContext,
    BuildContext modalContext,
    WalletEntry wallet,
  ) {
    showDialog<bool>(
      context: modalContext,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.canvasCardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.canvasBorder),
          ),
          title: Text(
            'Hapus Rekening?',
            style: AppTypography.sectionTitle.copyWith(color: AppColors.textWhite, fontSize: 18),
          ),
          content: Text(
            'Rekening "${wallet.name}" beserta aturan notifikasinya akan dihapus. Riwayat mutasi transaksi sebelumnya tetap aman dan tercatat.',
            style: AppTypography.listSubtitle.copyWith(color: AppColors.textMuted, fontSize: 14, height: 1.4),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('Batal', style: AppTypography.listTitle.copyWith(color: AppColors.textMuted, fontSize: 14)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neoCoral,
                foregroundColor: AppColors.textDarkPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true && modalContext.mounted) {
        parentContext.read<FinanceBloc>().add(DeleteWalletEvent(wallet.id));
        Navigator.pop(modalContext);
        ScaffoldMessenger.of(parentContext).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.neoCoral,
            content: Text(
              'Rekening ${wallet.name} berhasil dihapus.',
              style: const TextStyle(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    });
  }
}
