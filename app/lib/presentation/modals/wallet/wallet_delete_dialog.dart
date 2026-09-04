import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';

class WalletDeleteDialog {
  static void show(
    BuildContext parentContext,
    BuildContext modalContext,
    WalletEntry wallet,
  ) {
    AppConfirmationDialog.show(
      modalContext,
      title: 'Hapus Rekening?',
      content: 'Rekening "${wallet.name}" beserta aturan notifikasinya akan dihapus. Riwayat mutasi transaksi sebelumnya tetap aman dan tercatat.',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      confirmColor: AppColors.neoCoral,
      confirmTextColor: AppColors.textDarkPrimary,
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
