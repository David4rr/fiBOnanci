import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/locale_notifier.dart';
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
    final l10n = AppL10n.of(context);
    final isInstallment = subscription.isInstallment;
    final title = isEditing
        ? (isInstallment ? l10n.subModalEditInstallment : l10n.subModalEditBill)
        : (isInstallment ? l10n.subDetailInstallmentTitle : l10n.subDetailBillTitle);
    final subtitle = isEditing
        ? (isInstallment ? l10n.subModalSubInstallment : l10n.subModalSubBill)
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
          if (!isEditing)
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 4),
              child: Center(child: ModalGrabHandle()),
            )
          else
            const SizedBox(height: 16),
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
