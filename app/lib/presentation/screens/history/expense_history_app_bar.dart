import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';

class ExpenseHistoryAppBar extends StatelessWidget {
  final double totalFiltered;
  final NumberFormat currencyFormatter;
  final GestureDragUpdateCallback? onDragUpdate;
  final GestureDragEndCallback? onDragEnd;
  final VoidCallback? onDismiss;
  final bool isEditing;
  final VoidCallback? onReturnToHistory;
  final String? customTitle;
  final String? customSubtitle;

  const ExpenseHistoryAppBar({
    super.key,
    required this.totalFiltered,
    required this.currencyFormatter,
    this.onDragUpdate,
    this.onDragEnd,
    this.onDismiss,
    this.isEditing = false,
    this.onReturnToHistory,
    this.customTitle,
    this.customSubtitle,
  });

  @override
  Widget build(BuildContext context) {
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing ? (customTitle ?? 'Edit Transaksi') : 'Riwayat\nPengeluaran',
                        style: AppTypography.modalTitle,
                        maxLines: isEditing ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isEditing
                            ? (customSubtitle ?? 'Ubah rincian mutasi transaksi')
                            : 'Total Terfilter: ${currencyFormatter.format(totalFiltered)}',
                        style: AppTypography.modalSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: isEditing ? (onReturnToHistory ?? () {}) : (onDismiss ?? () => Navigator.of(context).pop()),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeInOutCubic,
                    switchOutCurve: Curves.easeInOutCubic,
                    transitionBuilder: (child, anim) {
                      final key = child.key is ValueKey<IconData>
                          ? (child.key as ValueKey<IconData>).value
                          : null;
                      final turnsTween = key == Icons.keyboard_arrow_left_rounded
                          ? Tween<double>(begin: -0.25, end: 0.0)
                          : (key == Icons.keyboard_arrow_down_rounded
                              ? Tween<double>(begin: 0.25, end: 0.0)
                              : Tween<double>(begin: 0.0, end: 0.0));
                      return RotationTransition(
                        turns: anim.drive(turnsTween),
                        child: FadeTransition(opacity: anim, child: child),
                      );
                    },
                    child: Icon(
                      isEditing ? Icons.keyboard_arrow_left_rounded : Icons.keyboard_arrow_down_rounded,
                      key: ValueKey<IconData>(
                        isEditing ? Icons.keyboard_arrow_left_rounded : Icons.keyboard_arrow_down_rounded,
                      ),
                      size: 28,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
