import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../data/database/app_database.dart';
import '../../widgets/common/common_widgets.dart';

class WalletDeleteDialog {
  static void executeDelete(
    BuildContext parentContext,
    BuildContext modalContext,
    WalletEntry wallet,
  ) {
    parentContext.read<FinanceBloc>().add(DeleteWalletEvent(wallet.id));
    Navigator.pop(modalContext);
    AppSnackBar.showError(
      parentContext,
      'Rekening Dihapus',
      message: 'Rekening "${wallet.name}" berhasil dihapus.',
      tag: 'HAPUS',
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
