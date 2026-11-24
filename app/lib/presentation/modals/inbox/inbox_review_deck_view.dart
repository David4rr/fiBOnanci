import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import 'inbox_cards_list.dart';
import 'inbox_empty_view.dart';

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
    if (pending.isEmpty) {
      return const Center(child: InboxEmptyView());
    }
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 12),
            child: Text(
              'Geser kanan untuk terima, kiri untuk tolak',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ),
          InboxCardsList(
            items: pending,
            onConfirm: onConfirm,
            onReject: onReject,
            onReassign: onReassign,
            onEdit: onEdit,
          ),
        ],
      ),
    );
  }
}
