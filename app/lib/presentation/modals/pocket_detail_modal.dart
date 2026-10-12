import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../data/database/app_database.dart';
import 'pocket/pocket_detail_sheet.dart';

export 'pocket/pocket_detail_sheet.dart';
export 'pocket/pocket_detail_tab.dart';
export 'pocket/pocket_detail_views.dart';
export 'pocket/pocket_transfer_dialog.dart';
export 'pocket/pocket_transfer_form.dart';

class PocketDetailModal {
  static Future<void> show(
    BuildContext context, {
    required PocketEntry pocket,
    int initialTab = 0,
    bool initialIsDeposit = true,
  }) {
    final financeBloc = context.read<FinanceBloc>();

    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.65),
        transitionDuration: const Duration(milliseconds: 340),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (ctx, animation, secondaryAnimation) {
          return BlocProvider.value(
            value: financeBloc,
            child: PocketDetailSheet(
              pocket: pocket,
              initialTab: initialTab,
              initialIsDeposit: initialIsDeposit,
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnim = CurvedAnimation(
            parent: animation,
            curve: const Cubic(0.16, 1.0, 0.3, 1.0),
            reverseCurve: Curves.easeOut,
          );
          final slide = Tween<Offset>(begin: const Offset(0.0, 0.08), end: Offset.zero).animate(curvedAnim);
          final fade = Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnim);
          return SlideTransition(position: slide, child: FadeTransition(opacity: fade, child: child));
        },
      ),
    );
  }

  static Future<void> showTransferDialog(BuildContext context, {required PocketEntry pocket, required bool isDeposit}) {
    return show(context, pocket: pocket, initialTab: 1, initialIsDeposit: isDeposit);
  }
}
