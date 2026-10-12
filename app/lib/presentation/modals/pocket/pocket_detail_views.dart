import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bento_folder_card.dart';
import '../../widgets/pocket_card_theme.dart';
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
  final PocketCardThemeConfig? themeConfig;
  final NumberFormat currencyFormatter;

  const PocketDetailHeader({
    super.key,
    required this.pocket,
    required this.pocketColor,
    this.themeConfig,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final config = themeConfig ?? PocketCardThemeConfig.resolve(pocket, 0);
    final double? target = pocket.targetAmount;
    final latestCurrent = pocket.currentAmount;
    final hasTarget = target != null && target > 0;
    final latestProgress = hasTarget ? (latestCurrent / target).clamp(0.0, 1.0) : null;

    return Hero(
      tag: 'pocket_card_${pocket.id}',
      flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
        final Hero toHero = toHeroContext.widget as Hero;
        return Material(
          color: Colors.transparent,
          child: SingleChildScrollView(physics: const NeverScrollableScrollPhysics(), child: toHero.child),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: BentoFolderCard(
          backgroundColor: config.backgroundColor,
          gradient: null,
          textColor: config.primaryTextColor,
          subtitleColor: config.secondaryTextColor,
          iconColor: config.iconColor,
          iconBgColor: config.iconBgColor,
          height: 172,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          iconData: getPocketIcon(pocket.type),
          topTrailing: hasTarget
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: config.iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(latestProgress! * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: config.primaryTextColor,
                    ),
                  ),
                )
              : null,
          title: currencyFormatter.format(latestCurrent),
          subtitleWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                pocket.name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: config.secondaryTextColor,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                hasTarget ? 'Target: ${currencyFormatter.format(target)}' : 'Total Terkumpul di Kantong',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: config.tertiaryTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          progress: latestProgress,
        ),
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
                disabledBackgroundColor: AppColors.canvasInputSearch,
                disabledForegroundColor: AppColors.textMuted,
                side: pocket.currentAmount > 0 ? null : const BorderSide(color: AppColors.canvasBorder, width: 0.8),
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
