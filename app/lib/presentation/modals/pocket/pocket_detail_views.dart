import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bento_folder_card.dart';
import '../../widgets/pocket_card_theme.dart';
import '../../widgets/pocket_cashflow_chart.dart';
export 'pocket_delete_dialog.dart';
export 'pocket_detail_actions.dart';

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
  final List<TransactionEntry> transactions;

  const PocketDetailHeader({
    super.key,
    required this.pocket,
    required this.pocketColor,
    this.themeConfig,
    required this.currencyFormatter,
    this.transactions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final config = themeConfig ?? PocketCardThemeConfig.resolve(pocket, 0);
    final double? target = pocket.targetAmount;
    final latestCurrent = pocket.currentAmount;
    final hasTarget = target != null && target > 0;
    final latestProgress = hasTarget ? (latestCurrent / target).clamp(0.0, 1.0) : null;

    final isNeoPastel = config.backgroundColor == AppColors.neoCoral ||
        config.backgroundColor == AppColors.neoChartreuse ||
        config.backgroundColor == AppColors.neoMint ||
        config.backgroundColor == AppColors.neoCyan;
    final isDark = isNeoPastel
        ? false
        : ThemeData.estimateBrightnessForColor(config.backgroundColor) == Brightness.dark;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.4);
    final cardHeight = (172.0 * textScale).clamp(172.0, 216.0);

    final topTrailingWidget = hasTarget
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: config.iconBgColor, borderRadius: BorderRadius.circular(12)),
            child: Text(
              '${(latestProgress! * 100).toStringAsFixed(0)}%',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: config.primaryTextColor),
            ),
          )
        : null;

    final subtitleWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          pocket.name,
          style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: config.secondaryTextColor, letterSpacing: -0.2),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          hasTarget ? 'Target: ${currencyFormatter.format(target)}' : 'Total Terkumpul di Kantong',
          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: config.tertiaryTextColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    Widget buildCard({required bool includeChart}) {
      return BentoFolderCard(
        backgroundColor: config.backgroundColor,
        gradient: null,
        textColor: config.primaryTextColor,
        subtitleColor: config.secondaryTextColor,
        iconColor: config.iconColor,
        iconBgColor: config.iconBgColor,
        height: cardHeight,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        iconData: getPocketIcon(pocket.type),
        topTrailing: topTrailingWidget,
        title: currencyFormatter.format(latestCurrent),
        subtitleWidget: subtitleWidget,
        progress: latestProgress,
        rightWidget: includeChart
            ? PocketCashflowChart(
                pocket: pocket,
                transactions: transactions,
                isDark: isDark,
                primaryColor: config.primaryTextColor,
                secondaryColor: config.secondaryTextColor,
                accentColor: config.iconBgColor,
                currencyFormatter: currencyFormatter,
              )
            : null,
      );
    }

    return Hero(
      tag: 'pocket_card_${pocket.id}',
      flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
        return Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: buildCard(includeChart: false),
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: buildCard(includeChart: true),
      ),
    );
  }
}
