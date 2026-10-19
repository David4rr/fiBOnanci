import 'package:flutter/material.dart';

import 'inbox_cards_list.dart';
import 'inbox_empty_view.dart';
import 'inbox_header_ribbon.dart';

class InboxReviewDeckView extends StatelessWidget {
  final List<Map<String, dynamic>> pending;
  final ValueChanged<Map<String, dynamic>> onConfirm;
  final ValueChanged<Map<String, dynamic>> onReject;
  final ValueChanged<Map<String, dynamic>> onReassign;
  final ValueChanged<Map<String, dynamic>> onEdit;

  const InboxReviewDeckView({
    super.key,
    required this.pending,
    required this.onConfirm,
    required this.onReject,
    required this.onReassign,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InboxHeaderRibbon(pendingCount: pending.length),
        if (pending.isEmpty)
          const InboxEmptyView()
        else
          InboxCardsList(
            items: pending,
            onConfirm: onConfirm,
            onReject: onReject,
            onReassign: onReassign,
            onEdit: onEdit,
          ),
      ],
    );
  }
}
