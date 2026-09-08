import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import 'pocket/pocket_detail_sheet.dart';

export 'pocket/pocket_detail_sheet.dart';
export 'pocket/pocket_detail_tab.dart';
export 'pocket/pocket_detail_views.dart';
export 'pocket/pocket_transfer_dialog.dart';
export 'pocket/pocket_transfer_form.dart';

class PocketDetailModal {
  static void show(
    BuildContext context, {
    required PocketEntry pocket,
    int initialTab = 0,
    bool initialIsDeposit = true,
  }) {
    final financeBloc = context.read<FinanceBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return BlocProvider.value(
          value: financeBloc,
          child: PocketDetailSheet(
            pocket: pocket,
            initialTab: initialTab,
            initialIsDeposit: initialIsDeposit,
          ),
        );
      },
    );
  }

  static void showTransferDialog(BuildContext context, {required PocketEntry pocket, required bool isDeposit}) {
    show(context, pocket: pocket, initialTab: 1, initialIsDeposit: isDeposit);
  }
}
