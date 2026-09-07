import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../widgets/common/common_widgets.dart';

/// Standard modal app bar matching other modal headers across the app
/// with a tactile grab handle, standard modal typography, and dismiss chevron.
class SubscriptionDetailAppBar extends StatelessWidget {
  final SubscriptionEntry subscription;
  final NumberFormat currencyFormatter;
  final GestureDragUpdateCallback? onDragUpdate;
  final GestureDragEndCallback? onDragEnd;
  final VoidCallback? onDismiss;

  const SubscriptionDetailAppBar({
    super.key,
    required this.subscription,
    required this.currencyFormatter,
    this.onDragUpdate,
    this.onDragEnd,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isInstallment = subscription.isInstallment;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: onDragUpdate,
      onVerticalDragEnd: onDragEnd,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 4),
            child: Center(child: ModalGrabHandle()),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: ModalHeader(
              title: isInstallment ? 'Detail Cicilan' : 'Detail Tagihan',
              subtitle: subscription.title,
              onClose: onDismiss ?? () => Navigator.of(context).maybePop(),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
