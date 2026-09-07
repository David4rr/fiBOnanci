import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../data/database/app_database.dart';
import 'subscription_detail_screen.dart';

/// Modal route displaying full-screen subscription or installment details
/// with transparent backdrop scrim and cubic slide/fade transition.
class SubscriptionDetailModalRoute {
  static Future<void> show(
    BuildContext context, {
    required SubscriptionEntry subscription,
    required WalletEntry wallet,
    int? indexOverride,
    double initialChildSize = 1.0,
  }) {
    final financeBloc = context.read<FinanceBloc>();

    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.65),
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (ctx, animation, secondaryAnimation) {
          return BlocProvider.value(
            value: financeBloc,
            child: SubscriptionDetailScreen(
              subscriptionId: subscription.id,
              initialWallet: wallet,
              indexOverride: indexOverride,
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
          final slide = Tween<Offset>(
            begin: const Offset(0.0, 0.08),
            end: Offset.zero,
          ).animate(curvedAnim);
          final fade = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(curvedAnim);

          return SlideTransition(
            position: slide,
            child: FadeTransition(opacity: fade, child: child),
          );
        },
      ),
    );
  }
}
