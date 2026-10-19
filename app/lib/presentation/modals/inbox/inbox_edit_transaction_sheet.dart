import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/common/modal_grab_handle.dart';
import 'inbox_inline_edit_form.dart';

export 'inbox_inline_edit_form.dart';

/// Legacy modal wrapper retained for backward compatibility.
class InboxEditTransactionSheet extends StatelessWidget {
  final double initialAmount;
  final String initialType;
  final String initialCounterparty;
  final String? walletName;

  const InboxEditTransactionSheet({
    super.key,
    required this.initialAmount,
    required this.initialType,
    required this.initialCounterparty,
    this.walletName,
  });

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required double initialAmount,
    required String initialType,
    required String initialCounterparty,
    String? walletName,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => InboxEditTransactionSheet(
        initialAmount: initialAmount,
        initialType: initialType,
        initialCounterparty: initialCounterparty,
        walletName: walletName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.canvasCardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ModalGrabHandle(),
          const SizedBox(height: 12),
          InboxInlineEditForm(
            initialAmount: initialAmount,
            initialType: initialType,
            initialCounterparty: initialCounterparty,
            walletName: walletName,
            onSave: (res) => Navigator.of(context).pop(res),
            onCancel: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
