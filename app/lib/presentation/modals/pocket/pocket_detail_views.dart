import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'pocket_transfer_dialog.dart';

export 'pocket_delete_dialog.dart';
IconData getPocketIcon(String type) => switch (type) {
  'savings' => Icons.savings_outlined,
  'retirement' => Icons.elderly_outlined,
  'emergency' => Icons.shield_outlined,
  _ => Icons.flag_outlined,
};

String getPocketTypeLabel(String type) => switch (type) {
  'savings' => 'Simpanan',
  'retirement' => 'Masa Tua',
  'emergency' => 'Dana Darurat',
  _ => 'Target / Impian',
};

class PocketDetailHeader extends StatelessWidget {
  final PocketEntry pocket;
  final Color pocketColor;
  final NumberFormat currencyFormatter;

  const PocketDetailHeader({
    super.key,
    required this.pocket,
    required this.pocketColor,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final double? target = pocket.targetAmount;
    final latestCurrent = pocket.currentAmount;
    final latestProgress = (target != null && target > 0) ? (latestCurrent / target).clamp(0.0, 1.0) : 1.0;

    return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.canvasInputSearch,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.canvasBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Terkumpul di Kantong', style: AppTypography.listSubtitle),
              const SizedBox(height: 6),
              Text(
                currencyFormatter.format(latestCurrent),
                style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textWhite, fontFeatures: const [FontFeature.tabularFigures()]),
              ),
              if (target != null && target > 0) ...[
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Target: ${currencyFormatter.format(target)}', style: AppTypography.listSubtitle),
                    Text('${(latestProgress * 100).toStringAsFixed(0)}%', style: TextStyle(color: pocketColor, fontWeight: FontWeight.w800, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: latestProgress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(pocketColor),
                  ),
                ),
              ],
            ],
          ),
    );
  }
}

class PocketDetailActions extends StatelessWidget {
  final PocketEntry pocket;
  final Color pocketColor;
  final VoidCallback? onDeposit;
  final VoidCallback? onWithdraw;

  const PocketDetailActions({
    super.key,
    required this.pocket,
    required this.pocketColor,
    this.onDeposit,
    this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neoMint,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              icon: const Icon(Icons.south_west_rounded, color: AppColors.canvasBg, size: 18),
              label: Text('Isi Dana', style: GoogleFonts.plusJakartaSans(color: AppColors.canvasBg, fontWeight: FontWeight.w800, fontSize: 13.5)),
              onPressed: onDeposit ?? () => PocketTransferDialog.show(context, pocket: pocket, isDeposit: true),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: pocket.currentAmount > 0 ? AppColors.neoCoral : AppColors.canvasInputSearch,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              icon: Icon(Icons.north_east_rounded, color: pocket.currentAmount > 0 ? AppColors.canvasBg : AppColors.textMuted, size: 18),
              label: Text('Tarik Dana', style: GoogleFonts.plusJakartaSans(color: pocket.currentAmount > 0 ? AppColors.canvasBg : AppColors.textMuted, fontWeight: FontWeight.w800, fontSize: 13.5)),
              onPressed: pocket.currentAmount > 0 ? (onWithdraw ?? () => PocketTransferDialog.show(context, pocket: pocket, isDeposit: false)) : null,
            ),
          ),
        ),
      ],
    );
  }
}
