import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../core/l10n/locale_notifier.dart';
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
      AppL10n.of(parentContext).walletDeletedTitle,
      message: AppL10n.of(parentContext).walletDeletedMsg(wallet.name),
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
