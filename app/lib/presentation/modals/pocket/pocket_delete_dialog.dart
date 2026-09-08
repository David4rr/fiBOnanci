import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';

void showPocketDeleteDialog(BuildContext context, PocketEntry pocket) {
  AppConfirmationDialog.show(
    context,
    title: 'Hapus Kantong?',
    content: 'Kantong "${pocket.name}" akan dihapus. Riwayat transaksi tetap tersimpan di buku kas.',
    confirmText: 'Hapus',
    cancelText: 'Batal',
    confirmColor: AppColors.neoCoral,
    confirmTextColor: AppColors.textDarkPrimary,
  ).then((confirmed) {
    if (confirmed == true && context.mounted) {
      context.read<FinanceBloc>().add(DeletePocketEvent(pocket.id));
      Navigator.of(context).pop();
    }
  });
}
