import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';

class WalletDeleteDialog {
  static void executeDelete(
    BuildContext parentContext,
    BuildContext modalContext,
    WalletEntry wallet,
  ) {
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

  static void show(
    BuildContext parentContext,
    BuildContext modalContext,
    WalletEntry wallet,
  ) {
    executeDelete(parentContext, modalContext, wallet);
  }
}
