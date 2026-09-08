import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

void showPocketDeleteDialog(BuildContext context, PocketEntry pocket) {
  showDialog(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      backgroundColor: AppColors.canvasCardSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Hapus Kantong?', style: AppTypography.sectionTitle),
      content: Text('Kantong "${pocket.name}" akan dihapus. Riwayat transaksi tetap tersimpan di buku kas.', style: AppTypography.listSubtitle),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('Batal', style: TextStyle(color: AppColors.textMuted))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () {
            context.read<FinanceBloc>().add(DeletePocketEvent(pocket.id));
            Navigator.of(dialogCtx).pop();
            Navigator.of(context).pop();
          },
          child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}
