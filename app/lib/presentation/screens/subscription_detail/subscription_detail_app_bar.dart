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
  final bool isEditing;
  final VoidCallback? onReturnToDetails;

  const SubscriptionDetailAppBar({
    super.key,
    required this.subscription,
    required this.currencyFormatter,
    this.onDragUpdate,
    this.onDragEnd,
    this.onDismiss,
    this.isEditing = false,
    this.onReturnToDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isInstallment = subscription.isInstallment;
    final title = isEditing
        ? (isInstallment ? 'Edit Cicilan' : 'Edit Tagihan Rutin')
        : (isInstallment ? 'Detail Cicilan' : 'Detail Tagihan');
    final subtitle = isEditing
        ? (isInstallment
            ? 'Rencana cicilan tenor & jatuh tempo'
            : 'Langganan, tagihan rutin, atau tagihan berkala')
        : subscription.title;
    final closeIcon = isEditing
        ? Icons.keyboard_arrow_left_rounded
        : Icons.keyboard_arrow_down_rounded;
    final onClose = isEditing
        ? (onReturnToDetails ?? onDismiss ?? () => Navigator.of(context).maybePop())
        : (onDismiss ?? () => Navigator.of(context).maybePop());

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
              title: title,
              subtitle: subtitle,
              closeIcon: closeIcon,
              onClose: onClose,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
