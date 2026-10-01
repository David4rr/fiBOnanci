import 'package:flutter/material.dart';
import 'inbox_stacked_deck.dart';
export 'inbox_stacked_deck.dart';
class InboxCardsList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final ValueChanged<Map<String, dynamic>> onConfirm;
  final ValueChanged<Map<String, dynamic>> onReject;
  final ValueChanged<Map<String, dynamic>>? onReassign;

  const InboxCardsList({
    super.key,
    required this.items,
    required this.onConfirm,
    required this.onReject,
    this.onReassign,
  });

  @override
  Widget build(BuildContext context) {
    return InboxStackedDeck(
      items: items,
      onConfirm: onConfirm,
      onReject: onReject,
      onReassign: onReassign,
    );
  }
}
