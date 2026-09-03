import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../modals/pocket_detail_modal.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/bento_folder_card.dart';
import '../../widgets/pocket_stock_chart_card.dart';

class WalletPocketsView extends StatelessWidget {
  final List<PocketEntry> pockets;
  final double totalPocketsAmount;
  final List<TransactionEntry> transactions;
  final NumberFormat currencyFormatter;

  const WalletPocketsView({
    super.key,
    required this.pockets,
    required this.totalPocketsAmount,
    required this.transactions,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    if (pockets.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate([
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: PocketStockChartCard(
              currentTotal: totalPocketsAmount,
              pocketsCount: pockets.length,
              transactions: transactions,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.canvasCardSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.canvasBorder),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.neoChartreuse.withValues(alpha: 0.12),
                    ),
                    child: const Center(
                      child: Icon(Icons.savings_outlined, color: AppColors.neoChartreuse, size: 30),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Belum Ada Kantong Tabungan', style: AppTypography.sectionTitle),
                  const SizedBox(height: 8),
                  Text(
                    'Pisahkan dana untuk Tabungan Pensiun/Masa Tua, Dana Darurat, atau Impianmu agar aman dari belanja harian.',
                    textAlign: TextAlign.center,
                    style: AppTypography.listSubtitle,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.neoChartreuse.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.neoChartreuse.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_circle_outline, color: AppColors.neoChartreuse, size: 16),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Ketuk tombol + di bawah untuk membuat',
                            style: GoogleFonts.plusJakartaSans(color: AppColors.neoChartreuse, fontWeight: FontWeight.w700, fontSize: 12.0),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: PocketStockChartCard(
              currentTotal: totalPocketsAmount,
              pocketsCount: pockets.length,
              transactions: transactions,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 148,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final pocket = pockets[index];
                final Color pColor = Color(int.parse(pocket.colorHex.replaceAll('#', '0xFF')));
                final target = pocket.targetAmount;
                final current = pocket.currentAmount;
                final double? progress = (target != null && target > 0) ? (current / target).clamp(0.0, 1.0) : null;
                final isDark = ThemeData.estimateBrightnessForColor(pColor) == Brightness.dark;
                final Color primaryText = isDark ? AppColors.textWhite : AppColors.textDarkPrimary;
                final Color secondaryText = isDark ? Colors.white.withValues(alpha: 0.95) : AppColors.textDarkPrimary;
                final Color tertiaryText = isDark ? Colors.white.withValues(alpha: 0.70) : AppColors.textDarkSecondary;

                return BentoFolderCard(
                  backgroundColor: pColor,
                  height: 148,
                  iconData: getPocketIcon(pocket.type),
                  title: currencyFormatter.format(current),
                  subtitleWidget: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        pocket.name,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: secondaryText, letterSpacing: -0.2),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              target != null && target > 0 ? currencyFormatter.format(target) : 'Tanpa target',
                              style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w600, color: tertiaryText),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (progress != null) ...[
                            const SizedBox(width: 4),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: primaryText, fontFeatures: const [FontFeature.tabularFigures()]),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  onTap: () => PocketDetailModal.show(context, pocket: pocket),
                );
              },
              childCount: pockets.length,
            ),
          ),
        ),
      ],
    );
  }
}
