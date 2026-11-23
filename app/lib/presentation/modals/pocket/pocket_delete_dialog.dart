import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../data/database/app_database.dart';
import '../../widgets/common/common_widgets.dart';

void executeDeletePocket(BuildContext context, PocketEntry pocket) {
  final hasBalance = pocket.currentAmount > 0;
  context.read<FinanceBloc>().add(DeletePocketEvent(pocket.id));
  Navigator.of(context).pop();
  AppSnackBar.showError(
    context,
    'Kantong Dihapus',
    message: hasBalance
        ? 'Kantong "${pocket.name}" dihapus & saldo dikembalikan ke rekening.'
        : 'Kantong "${pocket.name}" berhasil dihapus.',
    tag: 'HAPUS',
  );
}

void showPocketDeleteDialog(BuildContext context, PocketEntry pocket) {
  executeDeletePocket(context, pocket);
}
