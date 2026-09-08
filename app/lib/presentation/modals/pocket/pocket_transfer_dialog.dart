import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';
import 'pocket_transfer_form.dart';

export 'pocket_transfer_form.dart';

class PocketTransferDialog {
  static void show(
    BuildContext context, {
    required PocketEntry pocket,
    required bool isDeposit,
  }) {
    final financeBloc = context.read<FinanceBloc>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetCtx) {
        return BlocProvider.value(
          value: financeBloc,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + MediaQuery.of(sheetCtx).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ModalGrabHandle(padding: EdgeInsets.only(bottom: 12)),
                  ModalHeader(
                    title: isDeposit ? 'Isi Dana ke Kantong' : 'Tarik Dana ke Rekening',
                    subtitle: isDeposit
                        ? 'Pilih rekening asal untuk memindahkan dana ke ${pocket.name}.'
                        : 'Pilih rekening tujuan penarikan dari ${pocket.name}.',
                    onClose: () => Navigator.of(sheetCtx).pop(),
                  ),
                  const SizedBox(height: 16),
                  PocketTransferForm(
                    pocket: pocket,
                    isDeposit: isDeposit,
                    onSuccess: () => Navigator.of(sheetCtx).pop(),
                    onCancel: () => Navigator.of(sheetCtx).pop(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
