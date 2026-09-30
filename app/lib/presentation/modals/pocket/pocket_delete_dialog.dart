import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';

void executeDeletePocket(BuildContext context, PocketEntry pocket) {
  context.read<FinanceBloc>().add(DeletePocketEvent(pocket.id));
  Navigator.of(context).pop();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: AppColors.neoCoral,
      content: Text(
        'Kantong "${pocket.name}" berhasil dihapus.',
        style: const TextStyle(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold),
      ),
    ),
  );
}

void showPocketDeleteDialog(BuildContext context, PocketEntry pocket) {
  executeDeletePocket(context, pocket);
}
