import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import 'pocket_transfer_dialog.dart';

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
              label: Text(
                'Isi Dana',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.canvasBg,
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                ),
              ),
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
                disabledBackgroundColor: AppColors.canvasInputSearch,
                disabledForegroundColor: AppColors.textMuted,
                side: pocket.currentAmount > 0 ? null : const BorderSide(color: AppColors.canvasBorder, width: 0.8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              icon: Icon(
                Icons.north_east_rounded,
                color: pocket.currentAmount > 0 ? AppColors.canvasBg : AppColors.textMuted,
                size: 18,
              ),
              label: Text(
                'Tarik Dana',
                style: GoogleFonts.plusJakartaSans(
                  color: pocket.currentAmount > 0 ? AppColors.canvasBg : AppColors.textMuted,
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                ),
              ),
              onPressed: pocket.currentAmount > 0
                  ? (onWithdraw ?? () => PocketTransferDialog.show(context, pocket: pocket, isDeposit: false))
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
