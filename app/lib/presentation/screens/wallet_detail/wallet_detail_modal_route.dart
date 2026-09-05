import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../data/database/app_database.dart';
import '../wallet_detail_screen.dart';

class WalletDetailModalRoute {
  static Future<void> show(BuildContext context, {required WalletEntry wallet, double initialChildSize = 1.0}) {
    final financeBloc = context.read<FinanceBloc>();
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
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
            child: WalletDetailScreen(
              walletId: wallet.id,
              currencyFormatter: currencyFormatter,
              initialChildSize: initialChildSize,
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
}
