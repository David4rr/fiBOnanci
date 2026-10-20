import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/finance/finance_bloc.dart';
import '../../../core/formatters/app_currency.dart';
import '../../../data/database/app_database.dart';
import '../wallet_detail_screen.dart';

class WalletDetailModalRoute {
  static Future<void> show(BuildContext context, {required WalletEntry wallet, double initialChildSize = 1.0}) {
    final financeBloc = context.read<FinanceBloc>();
    final currencyFormatter = AppCurrency.forCode(financeBloc.state.profile.currency);
    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.65),
        transitionDuration: const Duration(milliseconds: 380),
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
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          final slide = Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(curvedAnim);

          return SlideTransition(
            position: slide,
            child: child,
          );
        },
      ),
    );
  }
}
